import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSpotModel {
  final String id;
  final String name;
  final String description;
  final GeoPoint location;
  final String address;
  final String zone;
  final ParkingSpotType type;
  final ParkingSpotStatus status;
  final double pricePerHour;
  final List<String> features;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String ownerId;
  final int totalSpots;
  final int availableSpots;

  ParkingSpotModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.address,
    required this.zone,
    required this.type,
    required this.status,
    required this.pricePerHour,
    required this.features,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.ownerId,
    required this.totalSpots,
    required this.availableSpots,
  });

  factory ParkingSpotModel.fromMap(Map<String, dynamic> map) {
    return ParkingSpotModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? const GeoPoint(0, 0),
      address: map['address'] ?? '',
      zone: map['zone'] ?? '',
      type: ParkingSpotType.values.firstWhere(
        (e) => e.toString() == 'ParkingSpotType.${map['type']}',
        orElse: () => ParkingSpotType.outdoor,
      ),
      status: ParkingSpotStatus.values.firstWhere(
        (e) => e.toString() == 'ParkingSpotStatus.${map['status']}',
        orElse: () => ParkingSpotStatus.available,
      ),
      pricePerHour: (map['pricePerHour'] ?? 0.0).toDouble(),
      features: List<String>.from(map['features'] ?? []),
      imageUrl: map['imageUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      ownerId: map['ownerId'] ?? '',
      totalSpots: map['totalSpots'] ?? 1,
      availableSpots: map['availableSpots'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'address': address,
      'zone': zone,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'pricePerHour': pricePerHour,
      'features': features,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'ownerId': ownerId,
      'totalSpots': totalSpots,
      'availableSpots': availableSpots,
    };
  }

  ParkingSpotModel copyWith({
    String? id,
    String? name,
    String? description,
    GeoPoint? location,
    String? address,
    String? zone,
    ParkingSpotType? type,
    ParkingSpotStatus? status,
    double? pricePerHour,
    List<String>? features,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerId,
    int? totalSpots,
    int? availableSpots,
  }) {
    return ParkingSpotModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      address: address ?? this.address,
      zone: zone ?? this.zone,
      type: type ?? this.type,
      status: status ?? this.status,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      features: features ?? this.features,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerId: ownerId ?? this.ownerId,
      totalSpots: totalSpots ?? this.totalSpots,
      availableSpots: availableSpots ?? this.availableSpots,
    );
  }

  bool get isAvailable => status == ParkingSpotStatus.available && availableSpots > 0;
  
  double get occupancyRate => totalSpots > 0 ? (totalSpots - availableSpots) / totalSpots : 0.0;
}

enum ParkingSpotType {
  outdoor,
  indoor,
  covered,
  street,
  garage,
  lot,
}

enum ParkingSpotStatus {
  available,
  occupied,
  reserved,
  maintenance,
  disabled,
}
