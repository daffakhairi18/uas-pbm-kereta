class ScheduleModel {
  final int? id;
  final String trainNumber;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String trainClass;
  final double price;
  final int availableSeats;
  final bool isActive;
  final DateTime createdAt;

  ScheduleModel({
    this.id,
    required this.trainNumber,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.trainClass,
    required this.price,
    required this.availableSeats,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'train_number': trainNumber,
      'origin': origin,
      'destination': destination,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'train_class': trainClass,
      'price': price,
      'available_seats': availableSeats,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'],
      trainNumber: map['train_number'],
      origin: map['origin'],
      destination: map['destination'],
      departureTime: DateTime.parse(map['departure_time']),
      arrivalTime: DateTime.parse(map['arrival_time']),
      trainClass: map['train_class'],
      price: map['price'].toDouble(),
      availableSeats: map['available_seats'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  ScheduleModel copyWith({
    int? id,
    String? trainNumber,
    String? origin,
    String? destination,
    DateTime? departureTime,
    DateTime? arrivalTime,
    String? trainClass,
    double? price,
    int? availableSeats,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      trainNumber: trainNumber ?? this.trainNumber,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      trainClass: trainClass ?? this.trainClass,
      price: price ?? this.price,
      availableSeats: availableSeats ?? this.availableSeats,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 