// widgets/tickets_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';

class TicketsDrawer extends StatelessWidget {
  const TicketsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        return Column(
          children: [
            // Header with close button
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Tickets',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Rest of the TicketsDrawer content remains the same
            Expanded(
              child: ListView.builder(
                itemCount: ticketProvider.tickets.length,
                itemBuilder: (context, index) {
                  final ticket = ticketProvider.tickets[index];
                  final isActive = ticketProvider.activeTicket?.id == ticket.id;

                  return ListTile(
                    leading: Icon(
                      Icons.receipt,
                      color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                    title: Text(ticket.name),
                    trailing: ticketProvider.tickets.length > 1
                        ? IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () {
                        _showDeleteDialog(context, ticketProvider, ticket.id);
                      },
                    )
                        : null,
                    tileColor: isActive ? Colors.blue[50] : null,
                    onTap: () {
                      ticketProvider.selectTicket(ticket.id);
                      Navigator.pop(context); // Close the drawer
                    },
                  );
                },
              ),
            ),

            // Add New Ticket Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('New Ticket'),
                onPressed: () {
                  ticketProvider.createNewTicket();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, TicketProvider ticketProvider, String ticketId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Ticket'),
          content: const Text('Are you sure you want to delete this ticket?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ticketProvider.deleteTicket(ticketId);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

// class TicketsDrawer extends StatelessWidget {
//   const TicketsDrawer({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Consumer<TicketProvider>(
//         builder: (context, ticketProvider, child) {
//           return Column(
//             children: [
//               // Header
//               DrawerHeader(
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).primaryColor,
//                 ),
//                 child: const Text(
//                   'Tickets',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//
//               // Tickets List
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: ticketProvider.tickets.length,
//                   itemBuilder: (context, index) {
//                     final ticket = ticketProvider.tickets[index];
//                     final isActive = ticketProvider.activeTicket?.id == ticket.id;
//
//                     return ListTile(
//                       leading: Icon(
//                         Icons.receipt,
//                         color: isActive ? Theme.of(context).primaryColor : Colors.grey,
//                       ),
//                       title: Text(ticket.name),
//                       trailing: ticketProvider.tickets.length > 1
//                           ? IconButton(
//                         icon: const Icon(Icons.delete, size: 20),
//                         onPressed: () {
//                           _showDeleteDialog(context, ticketProvider, ticket.id);
//                         },
//                       )
//                           : null,
//                       tileColor: isActive ? Colors.blue[50] : null,
//                       onTap: () {
//                         // Select the ticket when tapped
//                         ticketProvider.selectTicket(ticket.id);
//                         Navigator.pop(context); // Close the drawer
//                       },
//                     );
//                   },
//                 ),
//               ),
//
//               // Add New Ticket Button
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.add),
//                   label: const Text('New Ticket'),
//                   onPressed: () {
//                     ticketProvider.createNewTicket();
//                     Navigator.pop(context);
//                     // _showCreateTicketDialog(context, ticketProvider);
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   void _showDeleteDialog(BuildContext context, TicketProvider ticketProvider, String ticketId) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Ticket'),
//           content: const Text('Are you sure you want to delete this ticket?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 ticketProvider.deleteTicket(ticketId);
//                 Navigator.pop(context);
//               },
//               child: const Text('Delete', style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
// }