import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../home_screen.dart';
import '../Booking/timeReserveDetail.dart';

import '../../models/service.dart';
import '../../models/serviceCategory.dart';
import '../../models/worker.dart';
import '../../models/serviceVariant.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  List<ServiceCategory> _serviceCategories = [];
  List<Service> _services = [];
  List<Worker> _workers = [];
  List<String> _possibleTimes = [];
  List<AdditionalFee> additionalFees = [];

  late Worker? selectedWorker;

  String selectedCategoryId = "";
  String selectedWorkerId = "";
  String selectedDate = "";
  String selectedTime = "";
  String selectedSchedule = "";
  int currentStep = 0;
  int totalPrice = 0;
  int totalDuration = 0;
  int _selectedIndex = 0;

  bool loadingPossibleTimes = true;
  bool loadServices = true;

  DateTime currentDate = DateTime.now();
  final List<TimeReserveItem> _selectedServices = [];

  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardEndDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  Future fetchCategories() async {
    try {
      final url = Uri.parse(
        'http://10.0.2.2:4004/api/v1/serviceCategories/list',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _serviceCategories =
              (jsonData['rows'] as List)
                  .map((eachCategory) => ServiceCategory.fromJson(eachCategory))
                  .toList();
          selectedCategoryId =
              _serviceCategories.isNotEmpty ? _serviceCategories[0].id : "";
          fetchServices();
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (err) {
      print("Error fetching categories: $err");
    }
  }

  Future fetchServices() async {
    try {
      setState(() {
        loadServices = true;
      });
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/services/list');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'filter': {'category': selectedCategoryId},
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          final jsonData = jsonDecode(response.body);
          _services =
              (jsonData['rows'] as List)
                  .map((eachService) => Service.fromJson(eachService))
                  .toList();
          print(_services);
        });
      } else {
        print("Error fetching services: ${response.statusCode}");
      }
      setState(() {
        loadServices = false;
      });
    } catch (err) {
      print("Error fetching services: $err");
    }
  }

  Future fetchWorkers() async {
    try {
      List<String> servicesToSend = [];
      _selectedServices.forEach((service) {
        servicesToSend.add(service.service.id);
      });
      final url = Uri.parse(
        'http://10.0.2.2:4004/api/v1/services/getWorkerByService',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'services': servicesToSend}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _workers =
              (jsonData as List)
                  .map((eachWorker) => Worker.fromJson(eachWorker))
                  .toList();
        });
      } else {
        print("jiijii");
      }
    } catch (err) {
      print(err);
    }
  }

  Future fetchPossibleTimes() async {
    try {
      setState(() {
        _possibleTimes.clear();
        loadingPossibleTimes = true;
      });
      final url = Uri.parse(
        'http://10.0.2.2:4004/api/v1/timeRequests/getPossibleTimes',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'dateTitle': selectedDate,
          'worker': selectedWorkerId,
          'duration': getTotalDuration(_selectedServices),
        }),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          selectedSchedule = jsonData['schedule'];
          _possibleTimes =
              (jsonData['rows'] as List)
                  .map((eachTime) => eachTime['time'].toString())
                  .toList();
        });
      } else {
        print("jiijii");
      }
      setState(() {
        loadingPossibleTimes = false;
      });
    } catch (err) {
      print(err);
    }
  }

  Future fetchAdditionalFees(Worker worker) async {
    try {
      List<String> serviceIds = [];
      _selectedServices.forEach((service) {
        serviceIds.add(service.service.id);
      });
      final url = Uri.parse(
        'http://10.0.2.2:4004/api/v1/workerLevels/getAdditionalFee',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'services': serviceIds,
          'workerLevel': worker.level.id,
        }),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          additionalFees =
              (jsonData as List)
                  .map((addFee) => AdditionalFee.fromJson(addFee))
                  .toList();
        });
      } else {
        print('jiijii');
      }
    } catch (err) {
      print(err);
    }
  }

  Future createTimeReserve() async {
    try {
      final List<Map<String, dynamic>> reqServices = [];

      _selectedServices.forEach((service) {
        if (service.variant != null) {
          reqServices.add({
            "service": service.service.id,
            "variant": service.variant!.id,
            "price": service.price,
          });
        } else {
          reqServices.add({
            "service": service.service.id,
            "price": service.price,
          });
        }
      });

      final List<Map<String, dynamic>> reqAdditionalFees = [];

      additionalFees.forEach((addPrice) {
        reqAdditionalFees.add({
          'service': addPrice.id,
          'price': addPrice.addPrice,
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Амжилттай төлөгдлөө, Цаг захиалга үүсгэж байна. '),
          backgroundColor: Colors.green,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      final String? customerId = await _secureStorage.read(key: 'customerId');
      if (customerId == null) {
        _showLoginDialog();
      } else {
        final url = Uri.parse(
          'http://10.0.2.2:4004/api/v1/timeReserves/create',
        );
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'customer': customerId,
            'schedule': selectedSchedule,
            'services': reqServices,
            'startTime': selectedTime,
            'additionalPrices': reqAdditionalFees,
          }),
        );
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          String responseTimeReserveId = jsonData['_id'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      TimeReservceDetail(timeReserveId: responseTimeReserveId),
            ),
          );
        } else {
          print('jiijii');
        }
      }
    } catch (err) {
      print(err);
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Нэвтрэх шаардлагатай',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Container(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Утас',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Нууц үг',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () async {
                    final url = Uri.parse(
                      'http://10.0.2.2:4004/api/v1/customers/login',
                    );
                    final response = await http.post(
                      url,
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({
                        'phone': _phoneController.text,
                        'password': _passwordController.text,
                      }),
                    );

                    if (response.statusCode == 200) {
                      final jsonData = jsonDecode(response.body);
                      _saveCredentials(jsonData['customer'], jsonData['token']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Амжилттай нэвтэрлээ'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Амжилтгүй'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                  },
                  child: Text('Нэвтрэх'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 36),
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveCredentials(String customerId, String token) async {
    await _secureStorage.write(key: 'customerId', value: customerId);
    await _secureStorage.write(key: 'token', value: token);
  }

  void nextStep() async {
    if (currentStep == 0) {
      setState(() {
        currentStep++;
      });
      fetchWorkers();
    } else if (currentStep == 1) {
      setState(() {
        currentStep++;
        selectedDate = DateFormat('yyyy-MM-dd').format(currentDate);
        loadingPossibleTimes = false;
        fetchPossibleTimes();
      });
    } else if (currentStep == 2) {
      final String? customerId = await _secureStorage.read(key: 'customerId');
      if (customerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Та нэвтэрч байж үйлдлийг хийх боломжтой'),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }
      setState(() {
        currentStep++;
      });
    } else if (currentStep == 3) {
      createTimeReserve();
    }
  }

  void goBack() {
    if (currentStep == 1) {
      setState(() {
        currentStep--;
        selectedWorkerId = "";
      });
    } else if (currentStep == 2) {
      setState(() {
        currentStep--;
        selectedDate = "";
        selectedTime = "";
        selectedSchedule = "";
        _possibleTimes.clear();
      });
    } else if (currentStep == 3) {
      setState(() {
        currentStep--;
      });
    }
  }

  int getTotalPrice(
    List<TimeReserveItem> selectedServices,
    List<AdditionalFee> additionalFees,
  ) {
    int sum = 0;
    selectedServices.forEach((service) {
      sum += service.price;
    });
    additionalFees.forEach((fee) {
      sum += fee.addPrice;
    });
    return sum;
  }

  int getTotalDuration(List<TimeReserveItem> selectedServices) {
    int sum = 0;
    selectedServices.forEach((service) {
      if (service.variant != null) {
        sum += service.variant!.duration;
      } else {
        sum += service.service.duration;
      }
    });
    return sum;
  }

  List<DateTime> getWeekDates(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    cardEndDateController.dispose();
    cardNumberController.dispose();
    cardHolderController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    cardHolderController.addListener(_onTextChanged);
    cardNumberController.addListener(_onTextChanged);
    cardEndDateController.addListener(_onTextChanged);
    cvvController.addListener(_onTextChanged);
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final currentWeekDates = getWeekDates(currentDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Үйлчилгээний цаг товлох'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: const CircleBorder(),
            minimumSize: const Size(56, 56),
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(
                    'Нийт үйлчилгээнүүд',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ..._selectedServices.map((service) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${service.service.title} '),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${service.variant != null ? service.variant?.title : ''} ',
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${service.price}₮'),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${service.variant != null ? service.variant?.duration : service.service.duration} минут ',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Нийт:'),
                          Text(
                            '${getTotalPrice(_selectedServices, additionalFees)}₮',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: const Icon(Icons.medical_services_outlined),
        ),
      ),
      bottomSheet: SizedBox(
        height: 80,
        width: double.infinity,
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextButton(
                    onPressed: currentStep != 0 ? goBack : null,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(40, 40),
                      foregroundColor: Colors.pink,
                      // side: const BorderSide(
                      //   color: Colors.pink,
                      //   width: 1,
                      // ),
                    ),
                    child: const Icon(Icons.backspace_outlined),
                  ),
                ),
                const Expanded(flex: 1, child: const SizedBox()),
                Expanded(
                  flex: 18,
                  child: ElevatedButton(
                    onPressed:
                        (currentStep == 0 && _selectedServices.isEmpty)
                            ? null
                            : (currentStep == 1 && selectedWorkerId == '')
                            ? null
                            : (currentStep == 2 &&
                                (selectedSchedule == '' || selectedTime == ''))
                            ? null
                            : (currentStep == 3 &&
                                (cardEndDateController.text.trim().isEmpty ||
                                    cardHolderController.text.trim().isEmpty ||
                                    cardNumberController.text.trim().isEmpty ||
                                    cvvController.text.trim().isEmpty))
                            ? null
                            : nextStep,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 40),
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      ' ${currentStep == 3
                          ? 'Захиалах'
                          : currentStep == 2
                          ? 'Төлбөр төлөх'
                          : 'Үргэлжлүүлэх'}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body:
          _serviceCategories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : currentStep == 0
              ? Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 10.0,
                          children: [
                            ..._serviceCategories.map((category) {
                              int index = _serviceCategories.indexOf(category);
                              return ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _selectedIndex = index;
                                    selectedCategoryId = category.id;
                                  });
                                  await fetchServices();
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(120, 40),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  backgroundColor:
                                      _selectedIndex == index
                                          ? Colors.pink
                                          : Colors.white,
                                  side: BorderSide(
                                    color: Colors.pink,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.network(
                                      category.image,
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      category.title,
                                      style: TextStyle(
                                        color:
                                            _selectedIndex == index
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    loadServices
                        ? SizedBox(
                          height: 600,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.pink,
                            ),
                          ),
                        )
                        : Expanded(
                          child: ListView(
                            children:
                                _services.map((service) {
                                  return Card(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color:
                                            !_selectedServices.any(
                                                  (item) =>
                                                      item.service.id ==
                                                      service.id,
                                                )
                                                ? const Color.fromARGB(
                                                  255,
                                                  179,
                                                  168,
                                                  168,
                                                )
                                                : const Color.fromARGB(
                                                  255,
                                                  224,
                                                  36,
                                                  96,
                                                ),
                                        width:
                                            !_selectedServices.any(
                                                  (item) =>
                                                      item.service.id ==
                                                      service.id,
                                                )
                                                ? 1
                                                : 2,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Image.network(
                                            service.image,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const Expanded(
                                          flex: 1,
                                          child: SizedBox(),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [Text(service.title)],
                                            ),
                                          ),
                                        ),
                                        const Expanded(
                                          flex: 1,
                                          child: SizedBox(),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Center(
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    !_selectedServices.any(
                                                          (item) =>
                                                              item.service.id ==
                                                              service.id,
                                                        )
                                                        ? const Color.fromARGB(
                                                          255,
                                                          179,
                                                          168,
                                                          168,
                                                        )
                                                        : const Color.fromARGB(
                                                          255,
                                                          224,
                                                          36,
                                                          96,
                                                        ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  if (_selectedServices.any(
                                                    (item) =>
                                                        item.service.id ==
                                                        service.id,
                                                  )) {
                                                    _selectedServices
                                                        .removeWhere(
                                                          (item) =>
                                                              item.service.id ==
                                                              service.id,
                                                        );
                                                  } else {
                                                    if (service.variants ==
                                                            null ||
                                                        service
                                                            .variants!
                                                            .isEmpty) {
                                                      _selectedServices.add(
                                                        TimeReserveItem(
                                                          service: service,
                                                          price: service.price,
                                                        ),
                                                      );
                                                    } else {
                                                      showModalBottomSheet(
                                                        backgroundColor:
                                                            Colors.white,
                                                        isScrollControlled:
                                                            true,
                                                        context: context,
                                                        shape: const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.vertical(
                                                                top:
                                                                    Radius.circular(
                                                                      16,
                                                                    ),
                                                              ),
                                                        ),
                                                        builder: (
                                                          BuildContext context,
                                                        ) {
                                                          return SizedBox(
                                                            height: 600,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        24,
                                                                  ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  const Text(
                                                                    'Төрлүүд',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 16,
                                                                  ),
                                                                  ...service.variants!.map((
                                                                    variant,
                                                                  ) {
                                                                    return Card(
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                      child: Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                              16,
                                                                            ),
                                                                        child: Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Column(
                                                                              crossAxisAlignment:
                                                                                  CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  variant.title,
                                                                                ),
                                                                                Text(
                                                                                  '${variant.duration} минут',
                                                                                ),
                                                                                // Text(
                                                                                //   '${variant.price} ₮',
                                                                                // ),
                                                                              ],
                                                                            ),
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                setState(
                                                                                  () {
                                                                                    _selectedServices.add(
                                                                                      TimeReserveItem(
                                                                                        service:
                                                                                            service,
                                                                                        price:
                                                                                            variant.price,
                                                                                        variant:
                                                                                            variant,
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                );
                                                                                Navigator.of(
                                                                                  context,
                                                                                ).pop();
                                                                              },
                                                                              child: const Icon(
                                                                                Icons.add,
                                                                                color:
                                                                                    Colors.pink,
                                                                                size:
                                                                                    24,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }
                                                  }
                                                });
                                              },
                                              child: Icon(
                                                !_selectedServices.any(
                                                      (item) =>
                                                          item.service.id ==
                                                          service.id,
                                                    )
                                                    ? Icons.add
                                                    : Icons.delete,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                  ],
                ),
              )
              : currentStep == 1
              ? Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.count(
                  crossAxisCount: 2,
                  children:
                      _workers.map((worker) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
                          child: GestureDetector(
                            onTap: () async {
                              setState(() {
                                selectedWorker = null;
                                selectedWorkerId = '';
                              });
                              await fetchAdditionalFees(worker);
                              showModalBottomSheet(
                                backgroundColor: Colors.white,
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                builder: (BuildContext context) {
                                  return SizedBox(
                                    height: 650,
                                    child: Padding(
                                      padding:
                                          MediaQuery.of(context).viewInsets,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 24,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              "Үйлчилгээнүүд",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Column(
                                              children: [
                                                ..._selectedServices.map((
                                                  service,
                                                ) {
                                                  return Row(
                                                    children: [
                                                      Image.network(
                                                        service.service.image,
                                                        width: 80,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      SizedBox(width: 40),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            service
                                                                .service
                                                                .title,
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          if (service.variant !=
                                                              null)
                                                            Text(
                                                              service
                                                                  .variant!
                                                                  .title,
                                                            ),
                                                          additionalFees.any(
                                                                (fee) =>
                                                                    fee.id ==
                                                                    service
                                                                        .service
                                                                        .id,
                                                              )
                                                              ? ((service.variant !=
                                                                      null
                                                                  ? Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                    NumberFormat.currency(
                                                                      locale:
                                                                          'en_US',
                                                                      symbol:
                                                                          '₮ ',
                                                                    ).format(
                                                                      service
                                                                              .variant!
                                                                              .price +
                                                                          additionalFees
                                                                              .firstWhere(
                                                                                (
                                                                                  fee,
                                                                                ) =>
                                                                                    fee.id ==
                                                                                    service.service.id,
                                                                              )
                                                                              .addPrice,
                                                                    ),
                                                                  )
                                                                  : Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                    NumberFormat.currency(
                                                                      locale:
                                                                          'en_US',
                                                                      symbol:
                                                                          '₮ ',
                                                                    ).format(
                                                                      service
                                                                              .variant!
                                                                              .price +
                                                                          additionalFees
                                                                              .firstWhere(
                                                                                (
                                                                                  fee,
                                                                                ) =>
                                                                                    fee.id ==
                                                                                    service.service.id,
                                                                              )
                                                                              .addPrice,
                                                                    ),
                                                                  )))
                                                              : (service.variant !=
                                                                      null
                                                                  ? Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                    NumberFormat.currency(
                                                                      locale:
                                                                          'en_US',
                                                                      symbol:
                                                                          '₮ ',
                                                                    ).format(
                                                                      service
                                                                          .variant!
                                                                          .price,
                                                                    ),
                                                                  )
                                                                  : Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                    NumberFormat.currency(
                                                                      locale:
                                                                          'en_US',
                                                                      symbol:
                                                                          '₮ ',
                                                                    ).format(
                                                                      service
                                                                          .service
                                                                          .price,
                                                                    ),
                                                                  )),
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                              ],
                                            ),
                                            const SizedBox(height: 24),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                OutlinedButton(
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.pink,
                                                        side: const BorderSide(
                                                          color: Colors.pink,
                                                          width: 2,
                                                        ),
                                                      ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Цуцлах'),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.pink,
                                                        foregroundColor:
                                                            Colors.white,
                                                      ),
                                                  onPressed: () {
                                                    setState(() {
                                                      selectedWorkerId =
                                                          worker.id;
                                                      selectedWorker = worker;
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    'Зөвшөөрөх',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color:
                                      selectedWorkerId == worker.id
                                          ? Colors.pink
                                          : Colors.grey,
                                  width: selectedWorkerId == worker.id ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      worker.avatar,
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    worker.firstName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    worker.level.level,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              )
              : currentStep == 2
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          DateFormat('y оны MM сар').format(currentDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                currentDate.isAtSameMomentAs(DateTime.now()) ||
                                        currentDate.isBefore(DateTime.now())
                                    ? null
                                    : setState(() {
                                      currentDate = currentDate.subtract(
                                        const Duration(days: 7),
                                      );
                                    });
                              },
                              icon: const Icon(Icons.chevron_left),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  currentDate = currentDate.add(
                                    const Duration(days: 7),
                                  );
                                });
                              },
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:
                                currentWeekDates
                                    .map(
                                      (date) => GestureDetector(
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              color:
                                                  selectedDate !=
                                                          DateFormat(
                                                            'yyyy-MM-dd',
                                                          ).format(date)
                                                      ? const Color.fromARGB(
                                                        255,
                                                        179,
                                                        168,
                                                        168,
                                                      )
                                                      : const Color.fromARGB(
                                                        255,
                                                        224,
                                                        36,
                                                        96,
                                                      ),
                                              width:
                                                  selectedDate !=
                                                          DateFormat(
                                                            'yyyy-MM-dd',
                                                          ).format(date)
                                                      ? 1
                                                      : 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              22,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: 22,
                                            backgroundColor: Colors.white,
                                            child: Text(
                                              '${date.day}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          selectedDate = DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(date);
                                          fetchPossibleTimes();
                                        },
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    loadingPossibleTimes
                        ? Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          ),
                        )
                        : _possibleTimes.isEmpty
                        ? Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 120),
                            alignment: Alignment.center,
                            child: const Text('Тухайн өдөр цаг байхгүй байна.'),
                          ),
                        )
                        : Expanded(
                          child: GridView.count(
                            crossAxisCount: 3,
                            children:
                                _possibleTimes.map((time) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedTime = time;
                                      });
                                    },
                                    child: Card(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color:
                                              selectedTime != time
                                                  ? const Color.fromARGB(
                                                    255,
                                                    179,
                                                    168,
                                                    168,
                                                  )
                                                  : const Color.fromARGB(
                                                    255,
                                                    224,
                                                    36,
                                                    96,
                                                  ),
                                          width: selectedTime != time ? 1 : 2,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          time,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: cardHolderController,
                      decoration: InputDecoration(
                        labelText: 'Карт эзэмшигчийн нэр',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: cardNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Картын дугаар',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cardEndDateController,
                            keyboardType: TextInputType.datetime,
                            decoration: InputDecoration(
                              labelText: 'Дуусах хугацаа (MM/YY)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: cvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Нийт үнийн дүн: ${NumberFormat.currency(locale: 'en_US', symbol: '₮ ').format(getTotalPrice(_selectedServices, additionalFees))}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class TimeReserveItem {
  final Service service;
  final ServiceVariant? variant;
  final int price;

  TimeReserveItem({required this.service, this.variant, required this.price});
}

class AdditionalFee {
  final int addPrice;
  final String title;
  final String id;

  AdditionalFee({
    required this.addPrice,
    required this.title,
    required this.id,
  });

  factory AdditionalFee.fromJson(Map<String, dynamic> json) {
    return AdditionalFee(
      addPrice: json['addPrice'],
      title: json['title'],
      id: json['_id'],
    );
  }
}
