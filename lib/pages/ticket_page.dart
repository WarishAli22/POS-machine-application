import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_pos/providers/ticket_provider.dart';
import 'package:my_pos/models/ticket_model.dart';
import 'package:my_pos/models/food_model.dart';
import 'package:my_pos/components/save_button.dart';
import 'package:my_pos/pages/discount_page.dart';

class TicketPage extends StatelessWidget {
  final String ticketId;
  const TicketPage({required this.ticketId});

  @override
  Widget build(BuildContext context) {
    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        // Get the ticket from the provider instead of using the passed parameter
        final ticket = ticketProvider.tickets.firstWhere(
              (t) => t.id == ticketId,
          orElse: () => Ticket(
            id: '',
            name: 'Not Found',
            items: [],
            paymentMethod: '',
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text("Ticket: ${ticket.name}"),
            actions: [
            ],
          ),
          body: Column(
            children: [
              // Header Information
              _buildTicketHeader(context, ticket),

              // Items List
              Expanded(
                child: _buildItemsList(context, ticketProvider, ticket),
              ),

              // Discounts Section
              // _buildDiscountsSection(context, ticketProvider, ticket),
              // In your TicketPage's body Column, replace the _buildDiscountsSection with:
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiscountPage(
                        onDiscountSelected: (percentage) {
                          ticketProvider.applyPercentageDiscount(percentage);
                          Navigator.pop(context);
                        },
                        onCustomDiscount: () {
                          _showCustomDiscountDialog(context, ticketProvider, ticket);
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Apply Discount'),
              ),

              _buildAppliedDiscounts(context, ticket, ticketProvider),

              // Footer with Total
              _buildTicketFooter(context, ticket),
              SizedBox(height:5),
              SaveButton(ticket: ticket),
            ],
          ),
        );
      },
    );
  }

  // Add this new method to build the discounts section
  Widget _buildDiscountsSection(BuildContext context, TicketProvider ticketProvider, Ticket ticket) {
    return Card(
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discounts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),

            // Display applied discounts
            if (ticket.discounts.isNotEmpty)
              Column(
                children: ticket.discounts.map((discount) {
                  return ListTile(
                    leading: Icon(Icons.discount, color: Colors.green),
                    title: Text('${discount.percentage}% Discount'),
                    subtitle: Text('-TK${discount.amount.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        ticketProvider.removeDiscount(discount.id);
                      },
                    ),
                  );
                }).toList(),
              ),

            // Add discount buttons
            Wrap(
              spacing: 8,
              children: [
                _buildDiscountButton(context, ticketProvider, ticket, 10, '10% Off'),
                _buildDiscountButton(context, ticketProvider, ticket, 15, '15% Off'),
                _buildDiscountButton(context, ticketProvider, ticket, 20, '20% Off'),
                _buildCustomDiscountButton(context, ticketProvider, ticket),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create discount buttons
  Widget _buildDiscountButton(BuildContext context, TicketProvider ticketProvider, Ticket ticket, int percentage, String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        ticketProvider.applyPercentageDiscount(percentage);
      },
      child: Text(label),
    );
  }

  // Helper method to create custom discount button
  Widget _buildCustomDiscountButton(BuildContext context, TicketProvider ticketProvider, Ticket ticket) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        _showCustomDiscountDialog(context, ticketProvider, ticket);
      },
      child: Text('Custom %'),
    );
  }

  // Method to show custom discount dialog
  void _showCustomDiscountDialog(BuildContext context, TicketProvider ticketProvider, Ticket ticket) {
    TextEditingController discountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Apply Custom Discount'),
          content: TextField(
            controller: discountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Discount Percentage',
              suffixText: '%',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final percentage = int.tryParse(discountController.text);
                if (percentage != null && percentage > 0 && percentage <= 100) {
                  ticketProvider.applyPercentageDiscount(percentage);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid percentage (1-100)')),
                  );
                }
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }



  Widget _buildTicketHeader(BuildContext context, Ticket ticket) {
    return Card(
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ticket Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ticket ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(ticket.id, style: TextStyle(fontFamily: 'monospace')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Created:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_formatDateTime(ticket.createdAt)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${ticket.items.fold(0, (sum, item) => sum + item.quantity)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, TicketProvider ticketProvider, Ticket ticket) {
    if (ticket.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No items in this ticket',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12),
      itemCount: ticket.items.length,
      itemBuilder: (context, index) {
        final item = ticket.items[index];
        return _buildItemCard(context, item, ticketProvider);
      },
    );
  }

  // Add this widget to show applied discounts in your TicketPage
  Widget _buildAppliedDiscounts(BuildContext context, Ticket ticket, TicketProvider ticketProvider) {
    if (ticket.discounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Applied Discounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...ticket.discounts.map((discount) {
              return ListTile(
                leading: const Icon(Icons.discount, color: Colors.green),
                title: Text('${discount.percentage}% Discount'),
                subtitle: Text('-TK${discount.amount.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    ticketProvider.removeDiscount(discount.id);
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Food item, TicketProvider ticketProvider) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: item.imageUrl.isNotEmpty
            ? CircleAvatar(
          backgroundImage: AssetImage(item.imageUrl),
          radius: 20,
        )
            : CircleAvatar(
          child: Icon(Icons.fastfood),
          radius: 20,
        ),
        title: Text(item.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: TK${item.price.toStringAsFixed(2)} each'),
            Text('Quantity: ${item.quantity}'),
            Text('Subtotal: TK${(item.price * item.quantity).toStringAsFixed(2)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decrease quantity button
            IconButton(
              icon: Icon(Icons.remove, color: Colors.red),
              onPressed: () {
                if (item.quantity > 1) {
                  ticketProvider.updateItemQuantity(item.id, item.quantity - 1);
                } else {
                  ticketProvider.removeFoodItem(item.id);
                }
              },
            ),

            // Quantity display
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${item.quantity}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            // Increase quantity button
            IconButton(
              icon: Icon(Icons.add, color: Colors.green),
              onPressed: () {
                ticketProvider.updateItemQuantity(item.id, item.quantity + 1);
              },
            ),

            // Delete button
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                ticketProvider.removeFoodItem(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketFooter(BuildContext context, Ticket ticket) {
    final subtotal = ticket.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final discountAmount = ticket.discounts.fold(0.0, (sum, discount) => sum + discount.amount);
    final total = subtotal - discountAmount;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2E7D32),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              Text('TK${subtotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),

          // Discounts
          if (discountAmount > 0)
            Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discounts:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('-TK${discountAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),

          const Divider(thickness: 1, height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              Text('TK${total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

