import 'package:flutter/material.dart';
import 'package:my_pos/components/appbar_icon.dart';
import 'package:my_pos/components/home_page_drawer.dart';
import 'package:my_pos/components/ticket_pill.dart';
import 'package:my_pos/components/open_tickets_card.dart';
import 'package:my_pos/components/filters_row.dart';
import 'package:my_pos/components/tickets_drawer.dart';
import 'package:my_pos/models/food_model.dart';
import 'package:my_pos/components/food_tile.dart';
import 'package:my_pos/models/ticket_model.dart';
import 'package:my_pos/pages/add_cust.dart';
import '../providers/ticket_provider.dart';
import 'package:provider/provider.dart';
import 'package:my_pos/components/food_tile.dart';
import 'package:my_pos/pages/receipts_page.dart';
import 'package:my_pos/pages/edit_tickets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <Food>[
      Food(id: '1', title:'বীফ চাপ', imageUrl: 'lib/images/beefchap.jpg', price:20),
      Food(id: '2', title:'চিকেন লিভার', imageUrl: 'lib/images/chickenliver.png', price:30),
      Food(id: '3', title:'চিল্লি কারি', imageUrl: 'lib/images/chillicurry.png', price:40),
      Food(id: '4', title:'চিকেন মশলা', imageUrl: 'lib/images/cmasala.jpg', price:50),
      Food(id: '5', title:'ডিম্ চপ', imageUrl: 'lib/images/dimchop.png', price:60),
      Food(id: '6', title:'অমলেট', imageUrl: 'lib/images/omlet.jpg', price:70),
      Food(id: '7', title:'অন্থন', imageUrl: 'lib/images/onthon.png', price:80),
      Food(id: '8', title:'সূপ', imageUrl: 'lib/images/soup.jpg', price:90),
      Food(id: '9', title:'চিকেন রোল', imageUrl: 'lib/images/croll.png', price:100),
      Food(id: '10', title:'কফি', imageUrl: 'lib/images/coffee.jpg', price:110),
    ];

    return Consumer<TicketProvider>(
        builder: (context, ticketProvider, child){
          String? activeTicketName = ticketProvider.activeTicket?.name;
          int activeTicketNum = ticketProvider.getActiveTicketIndex();
          return Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              title: Row(
                children: [
                  const SizedBox(width: 8),
                  TicketPill(ticketname: activeTicketName!, ticketnum: activeTicketNum),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.receipt_long), // Ticket drawer icon
                  onPressed: () {
                    _showTicketsDrawer(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddCustomerPage(),
                      ),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    _handleMenuSelection(context, value, ticketProvider);
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'discount',
                        child: Text('Discount'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'all_items',
                        child: Text('All Items'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'repeat_order',
                        child: Text('Repeat Order'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'edit_ticket',
                        child: Text('Edit Ticket'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'more_ticket',
                        child: Text('More Ticket'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'open_cash_drawer',
                        child: Text('Open Cash Drawer'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'scan',
                        child: Text('Scan'),
                      ),
                    ];
                  },
                ),
                SizedBox(width: 4),
              ],
            ),
            drawer: MainNavDrawer(),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              children: [
                OpenTicketsCard(ticket: ticketProvider.activeTicket,),
                const SizedBox(height: 16),
                FiltersRow(),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (_, i) => FoodTile(item: items[i],),
                ),
                ElevatedButton(
                    onPressed: (){
                      print(ticketProvider.tickets);
                    },
                    child: const Text("Check state of provider")),
                ElevatedButton(
                    onPressed: (){
                      print(ticketProvider.clearAllTickets);
                    },
                    child: const Text("Remove all tickets")),
                ElevatedButton(
                    onPressed: (){
                      if(ticketProvider.activeTicket?.totalAmount == null){
                        print("total amount is null");
                      }
                      print(ticketProvider.activeTicket);
                      print(ticketProvider.activeTicket?.totalAmount);
                    },
                    child: const Text("Print Active ticket"))
              ],
            ),
          );
        }
    );
  }

  void _showTicketsDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: TicketsDrawer(),
        );
      },
    );
  }
  void _handleMenuSelection(BuildContext context, String value, TicketProvider ticketProvider) {
    switch (value) {
      case 'discount':
      // Implement discount functionality
        break;
      case 'all_items':
      // Implement all items functionality
        break;
      case 'repeat_order':
      // Implement repeat order functionality
        break;
      case 'edit_ticket':
        _navigateToEditTicket(context, ticketProvider);
      // Implement edit ticket functionality
        break;
      case 'more_ticket':
      // Implement more ticket functionality
        break;
      case 'open_cash_drawer':
      // Implement open cash drawer functionality
        break;
      case 'scan':
      // Implement scan functionality
        break;
    }
  }
  void _navigateToEditTicket(BuildContext context, TicketProvider ticketProvider) {
    if (ticketProvider.activeTicket != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditTicketScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No active ticket to edit')),
      );
    }
  }
}




