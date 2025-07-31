import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/schedule_model.dart';
import '../../../domain/usecases/schedule_usecase.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() =>
      _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  List<ScheduleModel> schedules = [];
  bool isLoading = true;

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
      final allSchedules = await scheduleUseCase.getAllSchedules();
      setState(() {
        schedules = allSchedules;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Jadwal'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSchedules,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with stats
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Total Jadwal: ${schedules.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Aktif: ${schedules.where((s) => s.isActive).length}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                // Schedules list
                Expanded(
                  child: schedules.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.schedule_outlined,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Belum ada jadwal',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: schedules.length,
                          itemBuilder: (context, index) {
                            final schedule = schedules[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: schedule.isActive
                                      ? Colors.green
                                      : Colors.grey,
                                  child: Icon(
                                    Icons.train,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  '${schedule.trainNumber} - ${schedule.trainClass}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${schedule.origin} → ${schedule.destination}'),
                                    Text(
                                      '${DateFormat('dd/MM/yyyy HH:mm').format(schedule.departureTime)} - ${DateFormat('HH:mm').format(schedule.arrivalTime)}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    Text(
                                      'Harga: Rp${NumberFormat('#,###').format(schedule.price)} | Kursi: ${schedule.availableSeats}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) =>
                                      _handleScheduleAction(value, schedule),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: schedule.isActive
                                          ? 'deactivate'
                                          : 'activate',
                                      child: Row(
                                        children: [
                                          Icon(schedule.isActive
                                              ? Icons.block
                                              : Icons.check_circle),
                                          const SizedBox(width: 8),
                                          Text(schedule.isActive
                                              ? 'Nonaktifkan'
                                              : 'Aktifkan'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Hapus',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditScheduleDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleScheduleAction(String action, ScheduleModel schedule) {
    switch (action) {
      case 'edit':
        _showAddEditScheduleDialog(schedule: schedule);
        break;
      case 'activate':
      case 'deactivate':
        _toggleScheduleStatus(schedule);
        break;
      case 'delete':
        _deleteSchedule(schedule);
        break;
    }
  }

  Future<void> _toggleScheduleStatus(ScheduleModel schedule) async {
    try {
      final scheduleUseCase =
          Provider.of<ScheduleUseCase>(context, listen: false);
      final updatedSchedule = schedule.copyWith(isActive: !schedule.isActive);
      await scheduleUseCase.updateSchedule(updatedSchedule);
      _loadSchedules();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Jadwal ${schedule.isActive ? 'dinonaktifkan' : 'diaktifkan'}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteSchedule(ScheduleModel schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus jadwal ${schedule.trainNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final scheduleUseCase =
            Provider.of<ScheduleUseCase>(context, listen: false);
        await scheduleUseCase.deleteSchedule(schedule.id!);
        _loadSchedules();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Jadwal berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _showAddEditScheduleDialog({ScheduleModel? schedule}) {
    final isEditing = schedule != null;
    final trainNumberController =
        TextEditingController(text: schedule?.trainNumber ?? '');
    final priceController =
        TextEditingController(text: schedule?.price.toString() ?? '');
    final seatsController =
        TextEditingController(text: schedule?.availableSeats.toString() ?? '');

    String? selectedOrigin = schedule?.origin;
    String? selectedDestination = schedule?.destination;
    String? selectedClass = schedule?.trainClass;
    DateTime? departureDate = schedule?.departureTime;
    TimeOfDay? departureTime = schedule != null
        ? TimeOfDay.fromDateTime(schedule.departureTime)
        : null;
    TimeOfDay? arrivalTime =
        schedule != null ? TimeOfDay.fromDateTime(schedule.arrivalTime) : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Jadwal' : 'Tambah Jadwal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: trainNumberController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Kereta',
                  prefixIcon: Icon(Icons.train),
                ),
              ),
              const SizedBox(height: 16),

              // Origin dropdown
              DropdownButtonFormField<String>(
                value: selectedOrigin,
                decoration: const InputDecoration(
                  labelText: 'Stasiun Asal',
                  prefixIcon: Icon(Icons.location_on),
                ),
                items: AppConstants.stations.map((station) {
                  return DropdownMenuItem(value: station, child: Text(station));
                }).toList(),
                onChanged: (value) => selectedOrigin = value,
              ),
              const SizedBox(height: 16),

              // Destination dropdown
              DropdownButtonFormField<String>(
                value: selectedDestination,
                decoration: const InputDecoration(
                  labelText: 'Stasiun Tujuan',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: AppConstants.stations.map((station) {
                  return DropdownMenuItem(value: station, child: Text(station));
                }).toList(),
                onChanged: (value) => selectedDestination = value,
              ),
              const SizedBox(height: 16),

              // Train class dropdown
              DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Kelas Kereta',
                  prefixIcon: Icon(Icons.class_),
                ),
                items: AppConstants.trainClasses.map((trainClass) {
                  return DropdownMenuItem(
                      value: trainClass, child: Text(trainClass));
                }).toList(),
                onChanged: (value) => selectedClass = value,
              ),
              const SizedBox(height: 16),

              // Date and time pickers
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Tanggal Berangkat'),
                      subtitle: Text(
                        departureDate != null
                            ? DateFormat('dd/MM/yyyy').format(departureDate!)
                            : 'Pilih tanggal',
                      ),
                      leading: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: departureDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          departureDate = date;
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Waktu Berangkat'),
                      subtitle: Text(
                        departureTime != null
                            ? departureTime!.format(context)
                            : 'Pilih waktu',
                      ),
                      leading: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: departureTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          departureTime = time;
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Waktu Tiba'),
                      subtitle: Text(
                        arrivalTime != null
                            ? arrivalTime!.format(context)
                            : 'Pilih waktu',
                      ),
                      leading: const Icon(Icons.access_time_filled),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: arrivalTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          arrivalTime = time;
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga Tiket',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: seatsController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Kursi Tersedia',
                  prefixIcon: Icon(Icons.airline_seat_recline_normal),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_validateScheduleForm(
                trainNumberController.text,
                selectedOrigin,
                selectedDestination,
                selectedClass,
                departureDate,
                departureTime,
                arrivalTime,
                priceController.text,
                seatsController.text,
              )) {
                await _saveSchedule(
                  isEditing,
                  schedule,
                  trainNumberController.text,
                  selectedOrigin!,
                  selectedDestination!,
                  selectedClass!,
                  departureDate!,
                  departureTime!,
                  arrivalTime!,
                  double.parse(priceController.text),
                  int.parse(seatsController.text),
                );
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Update' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  bool _validateScheduleForm(
    String trainNumber,
    String? origin,
    String? destination,
    String? trainClass,
    DateTime? departureDate,
    TimeOfDay? departureTime,
    TimeOfDay? arrivalTime,
    String price,
    String seats,
  ) {
    if (trainNumber.isEmpty) {
      _showError('Nomor kereta tidak boleh kosong');
      return false;
    }
    if (origin == null) {
      _showError('Pilih stasiun asal');
      return false;
    }
    if (destination == null) {
      _showError('Pilih stasiun tujuan');
      return false;
    }
    if (origin == destination) {
      _showError('Stasiun asal dan tujuan tidak boleh sama');
      return false;
    }
    if (trainClass == null) {
      _showError('Pilih kelas kereta');
      return false;
    }
    if (departureDate == null) {
      _showError('Pilih tanggal berangkat');
      return false;
    }
    if (departureTime == null) {
      _showError('Pilih waktu berangkat');
      return false;
    }
    if (arrivalTime == null) {
      _showError('Pilih waktu tiba');
      return false;
    }
    if (price.isEmpty || double.tryParse(price) == null) {
      _showError('Harga harus berupa angka');
      return false;
    }
    if (seats.isEmpty || int.tryParse(seats) == null) {
      _showError('Jumlah kursi harus berupa angka');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _saveSchedule(
    bool isEditing,
    ScheduleModel? schedule,
    String trainNumber,
    String origin,
    String destination,
    String trainClass,
    DateTime departureDate,
    TimeOfDay departureTime,
    TimeOfDay arrivalTime,
    double price,
    int seats,
  ) async {
    try {
      final scheduleUseCase =
          Provider.of<ScheduleUseCase>(context, listen: false);

      final departureDateTime = DateTime(
        departureDate.year,
        departureDate.month,
        departureDate.day,
        departureTime.hour,
        departureTime.minute,
      );

      final arrivalDateTime = DateTime(
        departureDate.year,
        departureDate.month,
        departureDate.day,
        arrivalTime.hour,
        arrivalTime.minute,
      );

      if (arrivalDateTime.isBefore(departureDateTime)) {
        arrivalDateTime.add(const Duration(days: 1));
      }

      if (isEditing && schedule != null) {
        final updatedSchedule = schedule.copyWith(
          trainNumber: trainNumber,
          origin: origin,
          destination: destination,
          departureTime: departureDateTime,
          arrivalTime: arrivalDateTime,
          trainClass: trainClass,
          price: price,
          availableSeats: seats,
        );
        await scheduleUseCase.updateSchedule(updatedSchedule);
      } else {
        final newSchedule = ScheduleModel(
          trainNumber: trainNumber,
          origin: origin,
          destination: destination,
          departureTime: departureDateTime,
          arrivalTime: arrivalDateTime,
          trainClass: trainClass,
          price: price,
          availableSeats: seats,
          isActive: true,
          createdAt: DateTime.now(),
        );
        await scheduleUseCase.createSchedule(newSchedule);
      }

      _loadSchedules();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Jadwal berhasil diupdate'
                : 'Jadwal berhasil ditambahkan'),
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
