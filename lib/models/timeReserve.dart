import '../models/service.dart';
import '../models/serviceVariant.dart';
import '../models/customer.dart';

class TimeReserve {
  final String id;
  final String dateTitle;
  final String startTime;
  final int totalDuration;
  final int totalAmount;
  final String state;
  final String paymentState;
  final List<ServiceItem> services;
  final Customer customer;
  final String timeReserveNumber;

  TimeReserve({
    required this.id,
    required this.dateTitle,
    required this.startTime,
    required this.totalDuration,
    required this.totalAmount,
    required this.state,
    required this.paymentState,
    required this.services,
    required this.customer,
    required this.timeReserveNumber
  });

  factory TimeReserve.fromJson(Map<String, dynamic> json) {
    return TimeReserve(
        id: json['_id'],
        dateTitle: json['dateTitle'],
        startTime: json['startTime'],
        totalDuration: json['totalDuration'],
        totalAmount: json['totalAmount'],
        state: json['state'],
        paymentState: json['paymentState'],
        services: List<ServiceItem>.from(json['services'].map((service) => ServiceItem.fromJson(service) )),
        customer: Customer.fromJson(json['customer']),
        timeReserveNumber: json['timeReserveNumber']
        );
  }
}

class ServiceItem {
  final Service service;
  final ServiceVariant? variant;
  final int price;

  ServiceItem({ 
    required this.service , 
    this.variant,
    required this.price 
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      service: Service.fromJson(json['service']),
      variant: json['variant'] != null ? ServiceVariant.fromJson(json['variant']) : null,  
      price: json['price']);
  }
}