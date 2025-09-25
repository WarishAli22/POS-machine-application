import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:my_pos/models/ticket_model.dart';

class TicketStorageService {
  static const String _ticketsFileName = 'persistent_tickets.json';

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_ticketsFileName');
  }

  // Save all tickets to persistent storage
  Future<void> saveTickets(List<Ticket> tickets) async {
    try {
      final file = await _getLocalFile();
      final ticketsData = tickets.map((ticket) => ticket.toMap()).toList();
      final jsonString = jsonEncode({
        'tickets': ticketsData,
        'lastSaved': DateTime.now().millisecondsSinceEpoch,
      });
      await file.writeAsString(jsonString);
      print('Tickets persisted successfully: ${tickets.length} tickets');
    } catch (e) {
      print('Error saving tickets to persistent storage: $e');
    }
  }

  // Load all tickets from persistent storage
  Future<List<Ticket>> loadTickets() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonData = jsonDecode(contents);
        final List<dynamic> ticketsData = jsonData['tickets'];

        final tickets = ticketsData.map((data) => Ticket.fromMap(data)).toList();
        print('Loaded ${tickets.length} tickets from persistent storage');
        return tickets;
      }
    } catch (e) {
      print('Error loading tickets from persistent storage: $e');
    }
    return [];
  }

  // Save individual ticket (for your payment completion flow)
  Future<void> saveIndividualTicket(Ticket ticket) async {
    try {
      // Load existing tickets
      final existingTickets = await loadTickets();

      // Remove any existing ticket with the same ID (update case)
      final filteredTickets = existingTickets.where((t) => t.id != ticket.id).toList();

      // Add the new ticket
      filteredTickets.add(ticket);

      // Save all tickets back
      await saveTickets(filteredTickets);

      print('Individual ticket saved persistently: ${ticket.id}');
    } catch (e) {
      print('Error saving individual ticket: $e');
    }
  }
}