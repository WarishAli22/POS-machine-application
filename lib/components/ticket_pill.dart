import 'package:flutter/material.dart';
import 'package:my_pos/models/ticket_model.dart';
import 'package:my_pos/pages/receipts_page.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import 'package:my_pos/models/ticket_model.dart';

class TicketPill extends StatelessWidget {
  final int ticketnum;
  const TicketPill({required this.ticketnum});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Consumer<TicketProvider>(
          builder:(context, ticketProvider, child){
            if(ticketnum==-1){
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.confirmation_number, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  const Text('No active ticket', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 6),]
            );
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.confirmation_number, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                const Text('Ticket', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$ticketnum',
                      style: const TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w600)),
                ),
              ],
            );
          }
        )

      ),
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context){
            return ReceiptsPage();
          })
        );
      },
    );
  }
}