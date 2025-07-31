import '../../data/repositories/schedule_repository.dart';
import '../../data/models/schedule_model.dart';

class ScheduleUseCase {
  final ScheduleRepository _scheduleRepository;

  ScheduleUseCase(this._scheduleRepository);

  Future<List<ScheduleModel>> getAllSchedules() async {
    return await _scheduleRepository.getAllSchedules();
  }

  Future<List<ScheduleModel>> getSchedulesByRoute(String origin, String destination) async {
    return await _scheduleRepository.getSchedulesByRoute(origin, destination);
  }

  Future<ScheduleModel?> getScheduleById(int id) async {
    return await _scheduleRepository.getScheduleById(id);
  }

  Future<int> createSchedule(ScheduleModel schedule) async {
    return await _scheduleRepository.insertSchedule(schedule);
  }

  Future<int> updateSchedule(ScheduleModel schedule) async {
    return await _scheduleRepository.updateSchedule(schedule);
  }

  Future<int> deleteSchedule(int id) async {
    return await _scheduleRepository.deleteSchedule(id);
  }

  Future<List<ScheduleModel>> getActiveSchedules() async {
    return await _scheduleRepository.getActiveSchedules();
  }
} 