import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ticket_model.dart';
import '../models/food_model.dart';
import '../providers/ticket_provider.dart';

class EditTicketScreen extends StatefulWidget {
  const EditTicketScreen({super.key});

  @override
  State<EditTicketScreen> createState() => _EditTicketScreenState();
}

class _EditTicketScreenState extends State<EditTicketScreen> {
  final _nameCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // seed with current name
    // delay to ensure provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TicketProvider>();
      final t = provider.activeTicket;
      if (t != null) {
        _nameCtrl.text = t.name;
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, _) {
        final ticket = ticketProvider.activeTicket;
        if (ticket == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Ticket')),
            body: const Center(child: Text('No active ticket')),
          );
        }

        final subtotal = ticketProvider.getSubtotal();
        final discountTotal = ticketProvider.getDiscountTotal();
        final total = ticket.totalAmount;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Ticket'),
            actions: [
              TextButton(
                onPressed: () {
                  // persist name if changed, then pop
                  if (_nameCtrl.text.trim().isNotEmpty && _nameCtrl.text.trim() != ticket.name) {
                    ticketProvider.renameActiveTicket(_nameCtrl.text.trim());
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Ticket Name
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ticket Name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) {
                    ticketProvider.renameActiveTicket(v.trim());
                  }
                },
              ),
              const SizedBox(height: 16),

              // Payment Method
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: ticketProvider.selectedPaymentMethod.isEmpty
                        ? (ticket.paymentMethod.isEmpty ? 'CASH' : ticket.paymentMethod)
                        : ticketProvider.selectedPaymentMethod,
                    items: const [
                      DropdownMenuItem(value: 'CASH', child: Text('CASH')),
                      DropdownMenuItem(value: 'CARD', child: Text('CARD')),
                      DropdownMenuItem(value: 'BKASH', child: Text('bKash')),
                      DropdownMenuItem(value: 'NAGAD', child: Text('Nagad')),
                      DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      ticketProvider.setActiveTicketPaymentMethod(v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Items header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text('${ticket.items.fold<int>(0, (s, it) => s + it.quantity)} total'),
                ],
              ),
              const SizedBox(height: 8),

              // Items list
              ...ticket.items.map((it) => _ItemRow(
                title: it.title,
                price: it.price,
                quantity: it.quantity,
                onIncrement: () => ticketProvider.updateItemQuantity(it.id, it.quantity + 1),
                onDecrement: () => ticketProvider.updateItemQuantity(it.id, it.quantity - 1),
                onRemove: () => ticketProvider.removeItemFromActiveTicket(it.id),
              )),

              if (ticket.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No items yet.', style: TextStyle(color: Colors.grey)),
                ),

              const Divider(height: 32),

              // Discounts
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _discountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Add % Discount',
                        hintText: 'e.g. 10',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addDiscount(ticketProvider),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _addDiscount(ticketProvider),
                    child: const Text('Apply'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: ticket.discounts.isEmpty ? null : ticketProvider.clearAllDiscounts,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ticket.discounts
                    .map((d) => InputChip(
                  label: Text('${d.percentage}% (-${d.amount.toStringAsFixed(2)})'),
                  onDeleted: () => ticketProvider.removeDiscount(d.id),
                ))
                    .toList(),
              ),

              const Divider(height: 32),

              // Totals
              _TotalRow(label: 'Subtotal', value: subtotal),
              _TotalRow(label: 'Discounts', value: -discountTotal),
              const SizedBox(height: 8),
              const Divider(),
              _TotalRow(label: 'Total', value: total, isBold: true),
              const SizedBox(height: 24),

              // Done button
              FilledButton(
                onPressed: () {
                  if (_nameCtrl.text.trim().isNotEmpty && _nameCtrl.text.trim() != ticket.name) {
                    ticketProvider.renameActiveTicket(_nameCtrl.text.trim());
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addDiscount(TicketProvider provider) {
    final txt = _discountCtrl.text.trim();
    if (txt.isEmpty) return;
    final pct = int.tryParse(txt);
    if (pct == null || pct <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid percentage')),
      );
      return;
    }
    provider.applyPercentageDiscount(pct);
    _discountCtrl.clear();
  }
}

class _ItemRow extends StatelessWidget {
  final String title;
  final double price;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _ItemRow({
    required this.title,
    required this.price,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$title\n${price.toStringAsFixed(2)} each',
                style: const TextStyle(height: 1.3),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: onDecrement,
                ),
                Text('$quantity', style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onIncrement,
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;

  const _TotalRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.w600 : FontWeight.w400);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(
            value.toStringAsFixed(2),
            style: style,
          ),
        ],
      ),
    );
  }
}


// class EditTicketScreen extends StatefulWidget {
//   final Ticket ticket;
//
//   const EditTicketScreen({Key? key, required this.ticket}) : super(key: key);
//
//   @override
//   _EditTicketScreenState createState() => _EditTicketScreenState();
// }
//
// class _EditTicketScreenState extends State<EditTicketScreen> {
//   late TextEditingController _nameController;
//   late List<Food> _items;
//
//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.ticket.name);
//     _items = List<Food>.from(widget.ticket.items);
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }
//
//   void _saveChanges(BuildContext context) {
//     final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
//
//     // Update the ticket
//     final updatedTicket = widget.ticket.copyWith(
//       name: _nameController.text.trim(),
//       items: _items,
//     );
//
//     // Update in provider
//     ticketProvider.setTicket(updatedTicket);
//
//     Navigator.pop(context);
//   }
//
//   void _updateItemQuantity(int index, int quantity) {
//     if (quantity <= 0) {
//       setState(() {
//         _items.removeAt(index);
//       });
//     } else {
//       setState(() {
//         _items[index] = _items[index].copyWith(quantity: quantity);
//       });
//     }
//   }
//
//   void _removeItem(int index) {
//     setState(() {
//       _items.removeAt(index);
//     });
//   }
//
//   double _calculateSubtotal() {
//     return _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Ticket'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.save),
//             onPressed: () => _saveChanges(context),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Ticket Name
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: 'Ticket Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 20),
//
//             // Items List
//             Text('Items:', style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),),
//             SizedBox(height: 10),
//
//             Expanded(
//               child: _items.isEmpty
//                   ? Center(
//                 child: Text('No items in this ticket'),
//               )
//                   : ListView.builder(
//                 itemCount: _items.length,
//                 itemBuilder: (context, index) {
//                   final item = _items[index];
//                   return Card(
//                     margin: EdgeInsets.symmetric(vertical: 4),
//                     child: ListTile(
//                       leading: item.imageUrl.isNotEmpty
//                           ? Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
//                           : Icon(Icons.fastfood),
//                       title: Text(item.title),
//                       subtitle: Text('\$${item.price.toStringAsFixed(2)} each'),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.remove),
//                             onPressed: () => _updateItemQuantity(index, item.quantity - 1),
//                           ),
//                           Text('${item.quantity}'),
//                           IconButton(
//                             icon: Icon(Icons.add),
//                             onPressed: () => _updateItemQuantity(index, item.quantity + 1),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.delete, color: Colors.red),
//                             onPressed: () => _removeItem(index),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//
//             // Total
//             Divider(),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Subtotal:', style: TextStyle(fontWeight: FontWeight.bold)),
//                   Text('\$${_calculateSubtotal().toStringAsFixed(2)}',
//                       style: TextStyle(fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//}