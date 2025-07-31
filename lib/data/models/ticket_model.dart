class TicketModel {
  final int? id;
  final int passengerId;
  final int scheduleId;
  final String ticketNumber;
  final String passengerName;
  final String passengerIdNumber;
  final String trainNumber;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String trainClass;
  final double price;
  final String status;
  final DateTime createdAt;

  TicketModel({
    this.id,
    required this.passengerId,
    required this.scheduleId,
    required this.ticketNumber,
    required this.passengerName,
    required this.passengerIdNumber,
    required this.trainNumber,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.trainClass,
    required this.price,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'passenger_id': passengerId,
      'schedule_id': scheduleId,
      'ticket_number': ticketNumber,
      'passenger_name': passengerName,
      'passenger_id_number': passengerIdNumber,
      'train_number': trainNumber,
      'origin': origin,
      'destination': destination,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'train_class': trainClass,
      'price': price,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      id: map['id'],
      passengerId: map['passenger_id'],
      scheduleId: map['schedule_id'],
      ticketNumber: map['ticket_number'],
      passengerName: map['passenger_name'],
      passengerIdNumber: map['passenger_id_number'],
      trainNumber: map['train_number'],
      origin: map['origin'],
      destination: map['destination'],
      departureTime: DateTime.parse(map['departure_time']),
      arrivalTime: DateTime.parse(map['arrival_time']),
      trainClass: map['train_class'],
      price: map['price'].toDouble(),
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  TicketModel copyWith({
    int? id,
    int? passengerId,
    int? scheduleId,
    String? ticketNumber,
    String? passengerName,
    String? passengerIdNumber,
    String? trainNumber,
    String? origin,
    String? destination,
    DateTime? departureTime,
    DateTime? arrivalTime,
    String? trainClass,
    double? price,
    String? status,
    DateTime? createdAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      scheduleId: scheduleId ?? this.scheduleId,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      passengerName: passengerName ?? this.passengerName,
      passengerIdNumber: passengerIdNumber ?? this.passengerIdNumber,
      trainNumber: trainNumber ?? this.trainNumber,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      trainClass: trainClass ?? this.trainClass,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
