import '../../data/repositories/ticket_repository.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/models/ticket_model.dart';
import '../../data/models/schedule_model.dart';

class TicketUseCase {
  final TicketRepository _ticketRepository;
  final ScheduleRepository _scheduleRepository;

  TicketUseCase(this._ticketRepository, this._scheduleRepository);

  Future<List<TicketModel>> getAllTickets() async {
    return await _ticketRepository.getAllTickets();
  }

  Future<List<TicketModel>> getTicketsByPassengerId(int passengerId) async {
    return await _ticketRepository.getTicketsByPassengerId(passengerId);
  }

  Future<TicketModel?> getTicketById(int id) async {
    return await _ticketRepository.getTicketById(id);
  }

  Future<int> createTicket(TicketModel ticket) async {
    // Update available seats in schedule
    final schedule = await _scheduleRepository.getScheduleById(ticket.scheduleId);
    if (schedule != null && schedule.availableSeats > 0) {
      final updatedSchedule = schedule.copyWith(
        availableSeats: schedule.availableSeats - 1,
      );
      await _scheduleRepository.updateSchedule(updatedSchedule);
    }
    
    return await _ticketRepository.insertTicket(ticket);
  }

  Future<int> updateTicket(TicketModel ticket) async {
    return await _ticketRepository.updateTicket(ticket);
  }

  Future<int> deleteTicket(int id) async {
    return await _ticketRepository.deleteTicket(id);
  }

  String generateTicketNumber() {
    return _ticketRepository.generateTicketNumber();
  }
} 