class PassengerModel {
  final int? id;
  final String name;
  final String idNumber;
  final String phone;
  final String email;
  final String userType;
  final String? username;
  final String? password;
  final DateTime createdAt;

  PassengerModel({
    this.id,
    required this.name,
    required this.idNumber,
    required this.phone,
    required this.email,
    required this.userType,
    this.username,
    this.password,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'id_number': idNumber,
      'phone': phone,
      'email': email,
      'user_type': userType,
      'username': username,
      'password': password,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PassengerModel.fromMap(Map<String, dynamic> map) {
    return PassengerModel(
      id: map['id'],
      name: map['name'],
      idNumber: map['id_number'],
      phone: map['phone'],
      email: map['email'],
      userType: map['user_type'],
      username: map['username'],
      password: map['password'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  PassengerModel copyWith({
    int? id,
    String? name,
    String? idNumber,
    String? phone,
    String? email,
    String? userType,
    String? username,
    String? password,
    DateTime? createdAt,
  }) {
    return PassengerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      idNumber: idNumber ?? this.idNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      username: username ?? this.username,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 