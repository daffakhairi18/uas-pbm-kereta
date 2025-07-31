import '../database/database_helper.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertSchedule(ScheduleModel schedule) async {
    return await _databaseHelper.insertSchedule(schedule);
  }

  Future<List<ScheduleModel>> getAllSchedules() async {
    return await _databaseHelper.getAllSchedules();
  }

  Future<List<ScheduleModel>> getSchedulesByRoute(
      String origin, String destination) async {
    return await _databaseHelper.getSchedulesByRoute(origin, destination);
  }

  Future<ScheduleModel?> getScheduleById(int id) async {
    return await _databaseHelper.getScheduleById(id);
  }

  Future<int> updateSchedule(ScheduleModel schedule) async {
    return await _databaseHelper.updateSchedule(schedule);
  }

  Future<int> deleteSchedule(int id) async {
    return await _databaseHelper.deleteSchedule(id);
  }

  Future<List<ScheduleModel>> getActiveSchedules() async {
    final allSchedules = await _databaseHelper.getAllSchedules();
    return allSchedules.where((schedule) => schedule.isActive).toList();
  }
}
