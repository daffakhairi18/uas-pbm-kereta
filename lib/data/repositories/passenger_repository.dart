import '../database/database_helper.dart';
import '../models/passenger_model.dart';

class PassengerRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertPassenger(PassengerModel passenger) async {
    return await _databaseHelper.insertPassenger(passenger);
  }

  Future<List<PassengerModel>> getAllPassengers() async {
    return await _databaseHelper.getAllPassengers();
  }

  Future<PassengerModel?> getPassengerById(int id) async {
    return await _databaseHelper.getPassengerById(id);
  }

  Future<PassengerModel?> getPassengerByUsername(String username) async {
    return await _databaseHelper.getPassengerByUsername(username);
  }

  Future<int> updatePassenger(PassengerModel passenger) async {
    return await _databaseHelper.updatePassenger(passenger);
  }

  Future<int> deletePassenger(int id) async {
    return await _databaseHelper.deletePassenger(id);
  }

  Future<PassengerModel?> authenticateUser(String username, String password) async {
    final passenger = await _databaseHelper.getPassengerByUsername(username);
    if (passenger != null && passenger.password == password) {
      return passenger;
    }
    return null;
  }
} 