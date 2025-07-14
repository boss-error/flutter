class ReservationModel {
  final String id;
  final String userId;
  final String parkingSpotId;
  final DateTime startTime;
  final DateTime endTime;
  final ReservationStatus status;
  final double totalAmount;
  final String? paymentId;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final String? vehicleNumber;
  final VehicleType vehicleType;

  ReservationModel({
    required this.id,
    required this.userId,
    required this.parkingSpotId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalAmount,
    this.paymentId,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.vehicleNumber,
    this.vehicleType = VehicleType.car,
  });

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      parkingSpotId: map['parkingSpotId'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      status: ReservationStatus.values.firstWhere(
        (e) => e.toString() == 'ReservationStatus.${map['status']}',
        orElse: () => ReservationStatus.pending,
      ),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      paymentId: map['paymentId'],
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${map['paymentStatus']}',
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      notes: map['notes'],
      vehicleNumber: map['vehicleNumber'],
      vehicleType: VehicleType.values.firstWhere(
        (e) => e.toString() == 'VehicleType.${map['vehicleType']}',
        orElse: () => VehicleType.car,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'parkingSpotId': parkingSpotId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.toString().split('.').last,
      'totalAmount': totalAmount,
      'paymentId': paymentId,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType.toString().split('.').last,
    };
  }

  ReservationModel copyWith({
    String? id,
    String? userId,
    String? parkingSpotId,
    DateTime? startTime,
    DateTime? endTime,
    ReservationStatus? status,
    double? totalAmount,
    String? paymentId,
    PaymentStatus? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? vehicleNumber,
    VehicleType? vehicleType,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parkingSpotId: parkingSpotId ?? this.parkingSpotId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentId: paymentId ?? this.paymentId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
    );
  }

  Duration get duration => endTime.difference(startTime);
  
  bool get isActive => status == ReservationStatus.confirmed && 
                      DateTime.now().isAfter(startTime) && 
                      DateTime.now().isBefore(endTime);
  
  bool get isUpcoming => status == ReservationStatus.confirmed && 
                        DateTime.now().isBefore(startTime);
  
  bool get isPast => DateTime.now().isAfter(endTime);
  
  bool get canBeCancelled => status == ReservationStatus.confirmed && 
                            DateTime.now().isBefore(startTime.subtract(const Duration(hours: 1)));
}

enum ReservationStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled,
  expired,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
}

enum VehicleType {
  car,
  motorcycle,
  truck,
  van,
  bicycle,
  electric,
}
