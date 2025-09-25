import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_pos/providers/ticket_provider.dart';
import 'package:my_pos/models/ticket_model.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart'; // Add this dependency to pubspec.yaml

class TotalSalesPage extends StatefulWidget {
  const TotalSalesPage({super.key});

  @override
  State<TotalSalesPage> createState() => _TotalSalesPageState();
}

class _TotalSalesPageState extends State<TotalSalesPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Sales Report'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          // Filter completed tickets based on selected date
          final filteredTickets = _getFilteredTickets(ticketProvider.completedTickets);
          final salesData = _calculateSalesData(filteredTickets);

          return Column(
            children: [
              // Calendar Section
              _buildCalendarSection(),

              // Date Filter Info
              _buildDateFilterInfo(),

              // Sales Summary Cards
              Expanded(
                child: _buildSalesSummary(salesData, filteredTickets.length),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime(2020, 1, 1),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: true,
                titleTextStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blue[700],
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton('Today', () {
                  setState(() {
                    _selectedDay = DateTime.now();
                    _focusedDay = DateTime.now();
                  });
                }),
                _buildFilterButton('This Month', () {
                  final now = DateTime.now();
                  setState(() {
                    _selectedDay = null; // Show all days in month
                    _focusedDay = now;
                  });
                }),
                _buildFilterButton('All Time', () {
                  setState(() {
                    _selectedDay = null; // Show all tickets
                  });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue[700],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(text),
    );
  }

  Widget _buildDateFilterInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedDay == null
                ? 'Showing all completed tickets'
                : 'Showing tickets from ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _selectedDay = null;
                _focusedDay = DateTime.now();
              });
            },
            tooltip: 'Clear filter',
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSummary(Map<String, double> salesData, int ticketCount) {
    final totalSales = salesData.values.fold(0.0, (sum, value) => sum + value);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Total Sales Card
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Total Sales',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '৳${totalSales.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$ticketCount ${ticketCount == 1 ? 'ticket' : 'tickets'} completed',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Payment Method Breakdown
        const Text(
          'Payment Method Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Payment Method Cards
        _buildPaymentMethodCard(
          'Cash',
          salesData['cash'] ?? 0.0,
          totalSales,
          Icons.attach_money,
          Colors.green,
        ),
        _buildPaymentMethodCard(
          'bKash',
          salesData['bkash'] ?? 0.0,
          totalSales,
          Icons.phone_android,
          Colors.pink,
        ),
        _buildPaymentMethodCard(
          'Nagad',
          salesData['nagad'] ?? 0.0,
          totalSales,
          Icons.account_balance_wallet,
          Colors.purple,
        ),
        _buildPaymentMethodCard(
          'Card',
          salesData['card'] ?? 0.0,
          totalSales,
          Icons.credit_card,
          Colors.blue,
        ),

        const SizedBox(height: 16),

        // Additional Statistics
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatRow('Average Ticket Value',
                    totalSales / (ticketCount == 0 ? 1 : ticketCount)),
                _buildStatRow('Highest Payment Method',
                    _getHighestPaymentMethod(salesData)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(String method, double amount, double total, IconData icon, Color color) {
    final percentage = total > 0 ? (amount / total * 100) : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(method),
        subtitle: LinearProgressIndicator(
          value: total > 0 ? percentage / 100 : 0,
          backgroundColor: Colors.grey[300],
          color: color,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '৳${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          if (value is double)
            Text(
              '৳${value.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          else
            Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  String _getHighestPaymentMethod(Map<String, double> salesData) {
    if (salesData.isEmpty) return 'N/A';

    final highestEntry = salesData.entries.reduce(
            (a, b) => a.value > b.value ? a : b
    );

    return '${highestEntry.key.toUpperCase()} (৳${highestEntry.value.toStringAsFixed(2)})';
  }

  // Filter tickets based on selected date
  List<Ticket> _getFilteredTickets(List<Ticket> completedTickets) {
    if (_selectedDay == null) {
      return completedTickets; // Show all completed tickets
    }

    return completedTickets.where((ticket) {
      if (ticket.completedAt == null) return false;

      return isSameDay(ticket.completedAt!, _selectedDay!);
    }).toList();
  }

  // Calculate sales data by payment method
  Map<String, double> _calculateSalesData(List<Ticket> tickets) {
    final Map<String, double> salesData = {
      'cash': 0.0,
      'bkash': 0.0,
      'nagad': 0.0,
      'card': 0.0,
    };

    for (final ticket in tickets) {
      final subtotal = ticket.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
      final discountTotal = ticket.discounts.fold(0.0, (sum, discount) => sum + discount.amount);
      final totalAmount = subtotal - discountTotal;

      final paymentMethod = ticket.paymentMethod.toLowerCase();

      if (salesData.containsKey(paymentMethod)) {
        salesData[paymentMethod] = salesData[paymentMethod]! + totalAmount;
      } else {
        salesData[paymentMethod] = totalAmount;
      }
    }

    return salesData;
  }
}

// Helper function to check if two dates are the same day
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}