import '../../data/repositories/passenger_repository.dart';
import '../../data/models/passenger_model.dart';

class AuthUseCase {
  final PassengerRepository _passengerRepository;

  AuthUseCase(this._passengerRepository);

  Future<PassengerModel?> login(String username, String password) async {
    return await _passengerRepository.authenticateUser(username, password);
  }

  Future<int> register(PassengerModel passenger) async {
    return await _passengerRepository.insertPassenger(passenger);
  }

  Future<PassengerModel?> getPassengerById(int id) async {
    return await _passengerRepository.getPassengerById(id);
  }

  Future<PassengerModel?> getPassengerByUsername(String username) async {
    return await _passengerRepository.getPassengerByUsername(username);
  }

  Future<List<PassengerModel>> getAllPassengers() async {
    return await _passengerRepository.getAllPassengers();
  }

  Future<int> updatePassenger(PassengerModel passenger) async {
    return await _passengerRepository.updatePassenger(passenger);
  }

  Future<int> deletePassenger(int id) async {
    return await _passengerRepository.deletePassenger(id);
  }
} 