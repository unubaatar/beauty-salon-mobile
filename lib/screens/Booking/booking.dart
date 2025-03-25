import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../home_screen.dart';

import '../../models/service.dart';
import '../../models/serviceCategory.dart';
import '../../models/worker.dart';
import '../../models/serviceVariant.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

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

  bool loadingPossibleTimes = true;

  DateTime currentDate = DateTime.now();
  final List<TimeReserveItem> _selectedServices = [];

  Future fetchCategories() async {
    try {
      final url =
          Uri.parse('http://10.0.2.2:4004/api/v1/serviceCategories/list');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _serviceCategories = (jsonData['rows'] as List)
              .map((eachCategory) => ServiceCategory.fromJson(eachCategory))
              .toList();
          _tabController = TabController(
            length: _serviceCategories.length,
            vsync: this,
          );
          _tabController?.addListener(_onTabChanged);
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
          _services = (jsonData['rows'] as List)
              .map((eachService) => Service.fromJson(eachService))
              .toList();
          print(_services);
        });
      } else {
        print("Error fetching services: ${response.statusCode}");
      }
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
      final url =
          Uri.parse('http://10.0.2.2:4004/api/v1/services/getWorkerByService');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'services': servicesToSend}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _workers = (jsonData as List)
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
          'http://10.0.2.2:4004/api/v1/timeRequests/getPossibleTimes');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'dateTitle': selectedDate,
          'worker': selectedWorkerId,
          'duration': getTotalDuration(_selectedServices)
        }),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          selectedSchedule = jsonData['schedule'];
          _possibleTimes = (jsonData['rows'] as List)
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
          'http://10.0.2.2:4004/api/v1/workerLevels/getAdditionalFee');
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
          additionalFees = (jsonData as List)
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
          reqServices
              .add({"service": service.service.id, "price": service.price});
        }
      });

      final List<Map<String, dynamic>> reqAdditionalFees = [];

      additionalFees.forEach((addPrice) {
        reqAdditionalFees
            .add({'service': addPrice.id, 'price': addPrice.addPrice});
      });

      final url = Uri.parse('http://10.0.2.2:4004/api/v1/timeReserves/create');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer': '67a228bea4d6cb41926e2ea2',
          'schedule': selectedSchedule,
          'services': reqServices,
          'startTime': selectedTime,
          'additionalPrices': reqAdditionalFees
        }),
      );
      if (response.statusCode == 200) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        print('jiijii');
      }
    } catch (err) {
      print(err);
    }
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
    }
  }

  int getTotalPrice(List<TimeReserveItem> selectedServices) {
    int sum = 0;
    selectedServices.forEach((service) {
      sum += service.price;
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

  void _onTabChanged() {
    if (_tabController?.indexIsChanging ?? false) {
      setState(() {
        selectedCategoryId = _serviceCategories[_tabController!.index].id;
      });
      fetchServices();
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final currentWeekDates = getWeekDates(currentDate);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Booking'),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 80.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  minimumSize: const Size(56, 56),
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Нийт үйлчилгээнүүд',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center),
                        content:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          ..._selectedServices.map((service) {
                            return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('${service.service.title} '),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                              '${service.variant != null ? service.variant?.title : ''} '),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('${service.price}₮'),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                              '${service.variant != null ? service.variant?.duration : service.service.duration} минут '),
                                        ],
                                      ),
                                    ),
                                  ],
                                ));
                          }),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Нийт:'),
                              Text('${getTotalPrice(_selectedServices)}₮')
                            ],
                          )
                        ]),
                      );
                    });
              },
              child: const Icon(Icons.medical_services_outlined)),
        ),
        bottomSheet: SizedBox(
          height: 80,
          width: double.infinity,
          child: Card(
              color: Colors.white,
              elevation: 2,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(children: [
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
                      )),
                  const Expanded(flex: 1, child: const SizedBox()),
                  Expanded(
                    flex: 18,
                    child: ElevatedButton(
                      onPressed: (currentStep == 0 && _selectedServices.isEmpty)
                          ? null
                          : (currentStep == 1 && selectedWorkerId == '')
                              ? null
                              : (currentStep == 2 &&
                                      (selectedSchedule == '' ||
                                          selectedTime == ''))
                                  ? null
                                  : nextStep,
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 40),
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white),
                      child: Text(
                          ' ${currentStep == 2 ? 'Захиалах' : 'Үргэлжлүүлэх'}'),
                    ),
                  )
                ]),
              )),
        ),
        body: _serviceCategories.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : currentStep == 0
                ? DefaultTabController(
                    length: _serviceCategories.length,
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicatorSize: TabBarIndicatorSize.label,
                          tabAlignment: TabAlignment.center,
                          tabs: _serviceCategories.map((category) {
                            return Tab(text: category.title);
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                            child: ListView(
                          children: _services.map((service) {
                            return Card(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: !_selectedServices.any((item) =>
                                            item.service.id == service.id)
                                        ? const Color.fromARGB(
                                            255, 179, 168, 168)
                                        : const Color.fromARGB(
                                            255, 224, 36, 96),
                                    width: !_selectedServices.any((item) =>
                                            item.service.id == service.id)
                                        ? 1
                                        : 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Image.network(service.image,
                                          height: 120, fit: BoxFit.cover),
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
                                            children: [
                                              Text(
                                                service.title,
                                              ),
                                            ],
                                          ),
                                        )),
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
                                                              service.id)
                                                      ? const Color.fromARGB(
                                                          255, 179, 168, 168)
                                                      : const Color.fromARGB(
                                                          255, 224, 36, 96),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
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
                                                        service.id)) {
                                                  _selectedServices.removeWhere(
                                                      (item) =>
                                                          item.service.id ==
                                                          service.id);
                                                } else {
                                                  if (service.variants ==
                                                          null ||
                                                      service
                                                          .variants!.isEmpty) {
                                                    _selectedServices.add(
                                                        TimeReserveItem(
                                                            service: service,
                                                            price:
                                                                service.price));
                                                  } else {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'Variants'),
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: service
                                                                  .variants!
                                                                  .map(
                                                                      (variant) {
                                                                return Card(
                                                                    child:
                                                                        Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          16),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(variant
                                                                              .title),
                                                                          Text(
                                                                              '${variant.duration} минут'),
                                                                          Text(
                                                                              '${variant.price} ₮'),
                                                                        ],
                                                                      ),
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              _selectedServices.add(TimeReserveItem(service: service, price: variant.price, variant: variant));
                                                                              Navigator.of(context).pop();
                                                                            });
                                                                          },
                                                                          child:
                                                                              const Icon(Icons.add)),
                                                                    ],
                                                                  ),
                                                                ));
                                                              }).toList(),
                                                            ),
                                                          );
                                                        });
                                                  }
                                                }
                                              });
                                            },
                                            child: Icon(!_selectedServices.any(
                                                    (item) =>
                                                        item.service.id ==
                                                        service.id)
                                                ? Icons.add
                                                : Icons.delete)),
                                      ),
                                    )
                                  ],
                                ));
                          }).toList(),
                        ))
                      ],
                    ),
                  )
                : currentStep == 1
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: GridView.count(
                          crossAxisCount: 2,
                          children: _workers.map((worker) {
                            return Padding(
                                padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
                                child: GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      selectedWorker = null;
                                      selectedWorkerId = '';
                                    });
                                    await fetchAdditionalFees(worker);
                                    if (additionalFees.isEmpty) {
                                      setState(() {
                                        selectedWorker = worker;
                                        selectedWorkerId = worker.id;
                                      });
                                    } else {
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                                title: const Text(
                                                  "Нэмэлт төлбөрүүд",
                                                  textAlign: TextAlign.center,
                                                ),
                                                content: Container(
                                                  height: 200,
                                                  width: double.maxFinite,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                0, 16, 0, 16),
                                                        child: Column(
                                                          children:
                                                              additionalFees
                                                                  .map(
                                                                      (addFee) {
                                                            return Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(addFee
                                                                    .title),
                                                                Text(
                                                                    '${addFee.addPrice}'),
                                                              ],
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          OutlinedButton(
                                                              style:
                                                                  OutlinedButton
                                                                      .styleFrom(
                                                                foregroundColor:
                                                                    Colors.pink,
                                                                side: const BorderSide(
                                                                    color: Colors
                                                                        .pink,
                                                                    width: 2),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'Цуцлах')),
                                                          ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .pink,
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white),
                                                              onPressed: () {
                                                                setState(() {
                                                                  selectedWorkerId =
                                                                      worker.id;
                                                                  selectedWorker =
                                                                      worker;
                                                                });
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'Зөвшөөрөх'))
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ));
                                          });
                                    }
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                          color: selectedWorkerId == worker.id
                                              ? Colors.pink
                                              : Colors.grey,
                                          width: selectedWorkerId == worker.id
                                              ? 2
                                              : 1,
                                        )),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                          }).toList(),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  DateFormat('y оны MM сар')
                                      .format(currentDate),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        currentDate.isAtSameMomentAs(DateTime.now()) || currentDate.isBefore(DateTime.now()) ? 
                                        null :
                                        setState(() {
                                          currentDate = currentDate.subtract(
                                              const Duration(days: 7));
                                        });
                                      },
                                      icon: const Icon(Icons.chevron_left),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          currentDate = currentDate
                                              .add(const Duration(days: 7));
                                        });
                                      },
                                      icon: const Icon(Icons.chevron_right),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: currentWeekDates
                                        .map((date) => GestureDetector(
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    color: selectedDate !=
                                                            DateFormat(
                                                                    'yyyy-MM-dd')
                                                                .format(date)
                                                        ? const Color.fromARGB(
                                                            255, 179, 168, 168)
                                                        : const Color.fromARGB(
                                                            255, 224, 36, 96),
                                                    width: selectedDate !=
                                                            DateFormat(
                                                                    'yyyy-MM-dd')
                                                                .format(date)
                                                        ? 1
                                                        : 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(22),
                                                ),
                                                child: CircleAvatar(
                                                  radius: 22,
                                                  backgroundColor: Colors.white,
                                                  child: Text(
                                                    '${date.day}',
                                                    style: const TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                selectedDate =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(date);
                                                fetchPossibleTimes();
                                              },
                                            ))
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
                                            padding: const EdgeInsets.only(
                                                bottom: 120),
                                            alignment: Alignment.center,
                                            child: const Text(
                                                'Тухайн өдөр цаг байхгүй байна.')),
                                      )
                                    : Expanded(
                                        child: GridView.count(
                                        crossAxisCount: 3,
                                        children: _possibleTimes.map((time) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedTime = time;
                                              });
                                            },
                                            child: Card(
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    color: selectedTime != time
                                                        ? const Color.fromARGB(
                                                            255, 179, 168, 168)
                                                        : const Color.fromARGB(
                                                            255, 224, 36, 96),
                                                    width: selectedTime != time
                                                        ? 1
                                                        : 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Text(time),
                                                )),
                                          );
                                        }).toList(),
                                      ))
                          ],
                        ),
                      ));
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

  AdditionalFee(
      {required this.addPrice, required this.title, required this.id});

  factory AdditionalFee.fromJson(Map<String, dynamic> json) {
    return AdditionalFee(
        addPrice: json['addPrice'], title: json['title'], id: json['_id']);
  }
}