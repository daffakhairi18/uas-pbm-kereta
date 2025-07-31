import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/models/ticket_model.dart';
import '../../../domain/usecases/ticket_usecase.dart';

class TicketManagementScreen extends StatefulWidget {
  const TicketManagementScreen({super.key});

  @override
  State<TicketManagementScreen> createState() => _TicketManagementScreenState();
}

class _TicketManagementScreenState extends State<TicketManagementScreen> {
  List<TicketModel> tickets = [];
  bool isLoading = true;
  String searchQuery = '';
  String statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() {
      isLoading = true;
    });

    try {
      final ticketUseCase = Provider.of<TicketUseCase>(context, listen: false);
      final allTickets = await ticketUseCase.getAllTickets();
      setState(() {
        tickets = allTickets;
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

  List<TicketModel> get filteredTickets {
    List<TicketModel> filtered = tickets;

    // Filter by status
    if (statusFilter != 'all') {
      filtered =
          filtered.where((ticket) => ticket.status == statusFilter).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((ticket) {
        return ticket.passengerName
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            ticket.ticketNumber
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            ticket.trainNumber
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            ticket.passengerIdNumber.contains(searchQuery);
      }).toList();
    }

    return filtered;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Tiket'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTickets,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari tiket...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Status: '),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: statusFilter,
                      items: [
                        const DropdownMenuItem(
                            value: 'all', child: Text('Semua')),
                        const DropdownMenuItem(
                            value: 'confirmed', child: Text('Dikonfirmasi')),
                        const DropdownMenuItem(
                            value: 'pending', child: Text('Pending')),
                        const DropdownMenuItem(
                            value: 'cancelled', child: Text('Dibatalkan')),
                        const DropdownMenuItem(
                            value: 'completed', child: Text('Selesai')),
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

          // Stats header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.confirmation_number,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total Tiket: ${tickets.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Dikonfirmasi: ${tickets.where((t) => t.status == 'confirmed').length}',
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
                const SizedBox(width: 8),
                Text(
                  'Pending: ${tickets.where((t) => t.status == 'pending').length}',
                  style: const TextStyle(fontSize: 14, color: Colors.orange),
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
                                child: Icon(
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
                                '${ticket.passengerName} - ${ticket.trainNumber}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Chip(
                                label: Text(
                                  ticket.status.toUpperCase(),
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
                                      _buildInfoRow(
                                          'Penumpang', ticket.passengerName),
                                      _buildInfoRow('ID Penumpang',
                                          ticket.passengerIdNumber),
                                      _buildInfoRow(
                                          'Kereta', ticket.trainNumber),
                                      _buildInfoRow('Rute',
                                          '${ticket.origin} → ${ticket.destination}'),
                                      _buildInfoRow(
                                          'Tanggal',
                                          DateFormat('dd/MM/yyyy')
                                              .format(ticket.departureTime)),
                                      _buildInfoRow('Waktu',
                                          '${DateFormat('HH:mm').format(ticket.departureTime)} - ${DateFormat('HH:mm').format(ticket.arrivalTime)}'),
                                      _buildInfoRow('Kelas', ticket.trainClass),
                                      _buildInfoRow('Harga',
                                          'Rp${NumberFormat('#,###').format(ticket.price)}'),
                                      _buildInfoRow('Status',
                                          ticket.status.toUpperCase()),
                                      _buildInfoRow(
                                          'Dibuat',
                                          DateFormat('dd/MM/yyyy HH:mm')
                                              .format(ticket.createdAt)),
                                      const SizedBox(height: 16),
                                      if (ticket.status == 'pending')
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    _updateTicketStatus(
                                                        ticket, 'confirmed'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('Konfirmasi'),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    _updateTicketStatus(
                                                        ticket, 'cancelled'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('Batalkan'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (ticket.status == 'confirmed')
                                        ElevatedButton(
                                          onPressed: () => _updateTicketStatus(
                                              ticket, 'completed'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Tandai Selesai'),
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

  Widget _buildInfoRow(String label, String value) {
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

  Future<void> _updateTicketStatus(TicketModel ticket, String newStatus) async {
    try {
      final ticketUseCase = Provider.of<TicketUseCase>(context, listen: false);
      final updatedTicket = ticket.copyWith(status: newStatus);
      await ticketUseCase.updateTicket(updatedTicket);
      _loadTickets();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status tiket berhasil diupdate menjadi $newStatus'),
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
