import 'package:cloud_firestore/cloud_firestore.dart';

class Establishment {
  final String name;
  final String number;
  final String municipality;
  final String? barangay;
  final bool isApproved;

  const Establishment({
    required this.name,
    required this.number,
    required this.municipality,
    required this.barangay,
    required this.isApproved
  });

  factory Establishment.fromJson(QueryDocumentSnapshot<Object?> json) {
    return Establishment(
      name: json['name'], 
      number: json['number'], 
      municipality: json['municipality'], 
      barangay: json['barangay'], 
      isApproved: json['isApproved']
    );
  }
}