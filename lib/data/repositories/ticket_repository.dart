import '../database/database_helper.dart';
import '../models/ticket_model.dart';

class TicketRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertTicket(TicketModel ticket) async {
    return await _databaseHelper.insertTicket(ticket);
  }

  Future<List<TicketModel>> getAllTickets() async {
    return await _databaseHelper.getAllTickets();
  }

  Future<List<TicketModel>> getTicketsByPassengerId(int passengerId) async {
    return await _databaseHelper.getTicketsByPassengerId(passengerId);
  }

  Future<TicketModel?> getTicketById(int id) async {
    return await _databaseHelper.getTicketById(id);
  }

  Future<int> updateTicket(TicketModel ticket) async {
    return await _databaseHelper.updateTicket(ticket);
  }

  Future<int> deleteTicket(int id) async {
    return await _databaseHelper.deleteTicket(id);
  }

  String generateTicketNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'TKT${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}$random';
  }
} 