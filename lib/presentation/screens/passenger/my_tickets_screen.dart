import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/models/ticket_model.dart';
import '../../../domain/usecases/ticket_usecase.dart';
import '../../providers/auth_provider.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  List<TicketModel> myTickets = [];
  bool isLoading = true;
  String statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadMyTickets();
  }

  Future<void> _loadMyTickets() async {
    setState(() {
      isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser != null) {
        final ticketUseCase =
            Provider.of<TicketUseCase>(context, listen: false);
        final tickets =
            await ticketUseCase.getTicketsByPassengerId(currentUser.id!);
        setState(() {
          myTickets = tickets;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
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

  List<TicketModel> get filteredTickets {
    if (statusFilter == 'all') {
      return myTickets;
    }
    return myTickets.where((ticket) => ticket.status == statusFilter).toList();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'cancelled':
        return 'Dibatalkan';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiket Saya'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyTickets,
          ),
        ],
      ),
      body: Column(
        children: [
          // User info
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser?.name ?? 'Penumpang',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currentUser?.email ?? '',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stats and filter
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.confirmation_number,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total Tiket: ${myTickets.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Dikonfirmasi: ${myTickets.where((t) => t.status == 'confirmed').length}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Filter Status: '),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: statusFilter,
                      items: [
                        const DropdownMenuItem(
                            value: 'all', child: Text('Semua')),
                        const DropdownMenuItem(
                            value: 'pending', child: Text('Menunggu')),
                        const DropdownMenuItem(
                            value: 'confirmed', child: Text('Dikonfirmasi')),
                        const DropdownMenuItem(
                            value: 'completed', child: Text('Selesai')),
                        const DropdownMenuItem(
                            value: 'cancelled', child: Text('Dibatalkan')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          statusFilter = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tickets list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTickets.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.confirmation_number_outlined,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Tidak ada tiket',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Silakan pesan tiket terlebih dahulu',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = filteredTickets[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: getStatusColor(ticket.status),
                                child: const Icon(
                                  Icons.confirmation_number,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                ticket.ticketNumber,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${ticket.trainNumber} - ${ticket.trainClass}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Chip(
                                label: Text(
                                  getStatusText(ticket.status),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                backgroundColor: getStatusColor(ticket.status),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Ticket details
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            _buildDetailRow('Nomor Tiket',
                                                ticket.ticketNumber),
                                            _buildDetailRow(
                                                'Kereta', ticket.trainNumber),
                                            _buildDetailRow(
                                                'Kelas', ticket.trainClass),
                                            _buildDetailRow('Rute',
                                                '${ticket.origin} → ${ticket.destination}'),
                                            _buildDetailRow(
                                                'Tanggal',
                                                DateFormat('dd/MM/yyyy').format(
                                                    ticket.departureTime)),
                                            _buildDetailRow('Waktu',
                                                '${DateFormat('HH:mm').format(ticket.departureTime)} - ${DateFormat('HH:mm').format(ticket.arrivalTime)}'),
                                            _buildDetailRow('Harga',
                                                'Rp${NumberFormat('#,###').format(ticket.price)}'),
                                            _buildDetailRow('Status',
                                                getStatusText(ticket.status)),
                                            _buildDetailRow(
                                                'Dipesan',
                                                DateFormat('dd/MM/yyyy HH:mm')
                                                    .format(ticket.createdAt)),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Action buttons
                                      if (ticket.status == 'pending')
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () =>
                                                    _cancelTicket(ticket),
                                                icon: const Icon(Icons.cancel),
                                                label: const Text(
                                                    'Batalkan Tiket'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                      if (ticket.status == 'confirmed')
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.green[200]!),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.check_circle,
                                                  color: Colors.green),
                                              const SizedBox(width: 8),
                                              const Expanded(
                                                child: Text(
                                                  'Tiket Anda telah dikonfirmasi. Silakan datang ke stasiun sesuai jadwal.',
                                                  style: TextStyle(
                                                      color: Colors.green),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      if (ticket.status == 'completed')
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.blue[200]!),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.done_all,
                                                  color: Colors.blue),
                                              const SizedBox(width: 8),
                                              const Expanded(
                                                child: Text(
                                                  'Perjalanan telah selesai. Terima kasih telah menggunakan layanan kami.',
                                                  style: TextStyle(
                                                      color: Colors.blue),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelTicket(TicketModel ticket) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembatalan'),
        content: Text('Yakin ingin membatalkan tiket ${ticket.ticketNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final ticketUseCase =
            Provider.of<TicketUseCase>(context, listen: false);
        final updatedTicket = ticket.copyWith(status: 'cancelled');
        await ticketUseCase.updateTicket(updatedTicket);
        _loadMyTickets();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tiket berhasil dibatalkan'),
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
}
