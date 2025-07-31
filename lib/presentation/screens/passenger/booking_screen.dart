import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/models/ticket_model.dart';
import '../../../domain/usecases/schedule_usecase.dart';
import '../../../domain/usecases/ticket_usecase.dart';
import '../../providers/auth_provider.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<ScheduleModel> availableSchedules = [];
  bool isLoading = true;
  String? selectedOrigin;
  String? selectedDestination;
  DateTime? selectedDate;
  String? selectedClass;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      isLoading = true;
    });

    try {
      final scheduleUseCase =
          Provider.of<ScheduleUseCase>(context, listen: false);
      final allSchedules = await scheduleUseCase.getActiveSchedules();
      setState(() {
        availableSchedules = allSchedules;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  List<ScheduleModel> get filteredSchedules {
    List<ScheduleModel> filtered = availableSchedules;

    if (selectedOrigin != null) {
      filtered = filtered
          .where((schedule) => schedule.origin == selectedOrigin)
          .toList();
    }

    if (selectedDestination != null) {
      filtered = filtered
          .where((schedule) => schedule.destination == selectedDestination)
          .toList();
    }

    if (selectedDate != null) {
      filtered = filtered.where((schedule) {
        return schedule.departureTime.year == selectedDate!.year &&
            schedule.departureTime.month == selectedDate!.month &&
            schedule.departureTime.day == selectedDate!.day;
      }).toList();
    }

    if (selectedClass != null) {
      filtered = filtered
          .where((schedule) => schedule.trainClass == selectedClass)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan Tiket'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Column(
              children: [
                // Origin and destination
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedOrigin,
                        decoration: const InputDecoration(
                          labelText: 'Stasiun Asal',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Semua')),
                          ...AppConstants.stations.map((station) {
                            return DropdownMenuItem(
                                value: station, child: Text(station));
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedOrigin = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedDestination,
                        decoration: const InputDecoration(
                          labelText: 'Stasiun Tujuan',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Semua')),
                          ...AppConstants.stations.map((station) {
                            return DropdownMenuItem(
                                value: station, child: Text(station));
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedDestination = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date and class filters
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Tanggal'),
                        subtitle: Text(
                          selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                              : 'Pilih tanggal',
                        ),
                        leading: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date != null) {
                            setState(() {
                              selectedDate = date;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedClass,
                        decoration: const InputDecoration(
                          labelText: 'Kelas',
                          prefixIcon: Icon(Icons.class_),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Semua')),
                          ...AppConstants.trainClasses.map((trainClass) {
                            return DropdownMenuItem(
                                value: trainClass, child: Text(trainClass));
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedClass = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                // Clear filters button
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedOrigin = null;
                            selectedDestination = null;
                            selectedDate = null;
                            selectedClass = null;
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Bersihkan Filter'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ditemukan ${filteredSchedules.length} jadwal',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Schedules list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredSchedules.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.schedule_outlined,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Tidak ada jadwal tersedia',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredSchedules.length,
                        itemBuilder: (context, index) {
                          final schedule = filteredSchedules[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with train info
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        child: const Icon(Icons.train,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              schedule.trainNumber,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              schedule.trainClass,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: schedule.availableSeats > 0
                                              ? Colors.green
                                              : Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          schedule.availableSeats > 0
                                              ? '${schedule.availableSeats} Kursi'
                                              : 'Habis',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Route and time info
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Berangkat',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              schedule.origin,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              DateFormat('HH:mm').format(
                                                  schedule.departureTime),
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward,
                                          color: Colors.grey),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Tiba',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              schedule.destination,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.end,
                                            ),
                                            Text(
                                              DateFormat('HH:mm')
                                                  .format(schedule.arrivalTime),
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                              textAlign: TextAlign.end,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Price and book button
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Harga',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              'Rp${NumberFormat('#,###').format(schedule.price)}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: schedule.availableSeats > 0
                                            ? () => _showBookingDialog(
                                                schedule, currentUser!)
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text(
                                          schedule.availableSeats > 0
                                              ? 'Pesan'
                                              : 'Habis',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(ScheduleModel schedule, dynamic currentUser) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pemesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin memesan tiket untuk:'),
            const SizedBox(height: 8),
            Text('Kereta: ${schedule.trainNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Rute: ${schedule.origin} → ${schedule.destination}'),
            Text(
                'Tanggal: ${DateFormat('dd/MM/yyyy').format(schedule.departureTime)}'),
            Text(
                'Waktu: ${DateFormat('HH:mm').format(schedule.departureTime)} - ${DateFormat('HH:mm').format(schedule.arrivalTime)}'),
            Text('Kelas: ${schedule.trainClass}'),
            Text('Harga: Rp${NumberFormat('#,###').format(schedule.price)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Penumpang: ${currentUser.name}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _bookTicket(schedule, currentUser);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Pesan Tiket'),
          ),
        ],
      ),
    );
  }

  Future<void> _bookTicket(ScheduleModel schedule, dynamic currentUser) async {
    try {
      final ticketUseCase = Provider.of<TicketUseCase>(context, listen: false);

      final ticket = TicketModel(
        passengerId: currentUser.id!,
        scheduleId: schedule.id!,
        ticketNumber: ticketUseCase.generateTicketNumber(),
        passengerName: currentUser.name,
        passengerIdNumber: currentUser.idNumber,
        trainNumber: schedule.trainNumber,
        origin: schedule.origin,
        destination: schedule.destination,
        departureTime: schedule.departureTime,
        arrivalTime: schedule.arrivalTime,
        trainClass: schedule.trainClass,
        price: schedule.price,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await ticketUseCase.createTicket(ticket);
      _loadSchedules(); // Refresh to update available seats

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Tiket berhasil dipesan! Silakan cek di "Tiket Saya"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
