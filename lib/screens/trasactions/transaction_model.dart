import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userID;
  final String userName;
  final double totalAmount;
  final String paymentMethod;
  final DateTime timestamp;

  final List<dynamic> items;

  TransactionModel({
    required this.id,
    required this.userID,
    required this.userName,
    required this.totalAmount,
    required this.paymentMethod,
    required this.timestamp,
    required this.items,
  });

  factory TransactionModel.fromMap(String id, Map<String, dynamic> data) {
    final rawTimestamp = data['timestamp'];
    DateTime parsedTimestamp;

    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is DateTime) {
      parsedTimestamp = rawTimestamp;
    } else {
      parsedTimestamp = DateTime.now(); // fallback
    }

    return TransactionModel(
      id: id,
      userID: data['userID'] ?? '',
      userName: data['userName'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      timestamp: parsedTimestamp,
      items: List.from(data['items'] ?? []),
    );
  }

}
