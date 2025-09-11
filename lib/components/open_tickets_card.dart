import 'package:flutter/material.dart';
import 'package:my_pos/providers/ticket_provider.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import 'package:my_pos/pages/ticket_page.dart';
import 'package:my_pos/models/ticket_model.dart';

class OpenTicketsCard extends StatelessWidget {
  final Ticket? ticket;
  const OpenTicketsCard({required this.ticket});
  @override
  Widget build(BuildContext context) {
    final ticketId = ticket?.id;
    return GestureDetector(
      onTap:(){
        if(ticket == null){
          return;
        }
        else{
          Navigator.push(context, MaterialPageRoute(
              builder: (context){
                return TicketPage(ticketId: ticketId!);
              }
          )
          );
        }

      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Consumer<TicketProvider>(
          builder:(context, ticketProvider, child){
            final activeTicket = ticketProvider.activeTicket;
            final totalAmount = activeTicket?.totalAmount ?? 0.0;
            return Row(
              children: [
                Expanded(
                  child: Text('OPEN TICKETS',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6)),
                ),
                Text("tk\n$totalAmount",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.2)),
              ],
            );
          }
        )

      ),
    );
  }
}