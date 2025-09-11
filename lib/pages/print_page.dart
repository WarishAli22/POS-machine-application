import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:file_saver/file_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:my_pos/models/ticket_model.dart';
import 'package:my_pos/components/app_drawer.dart';
import 'package:my_pos/pages/add_cust.dart';

class PrintPage extends StatelessWidget {
  const PrintPage({super.key, required this.ticket});
  final Ticket ticket;

  Future<void> _downloadReceipt(BuildContext context) async {
    try {
      // 1) Build strings for date/time once (UI-safe formatting)
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}";
      final timeStr = TimeOfDay.fromDateTime(now).format(context);

      // 2) Generate the PDF and get bytes
      final pdf = await _generatePdfReceipt(
        ticket: ticket,
        dateStr: dateStr,
        timeStr: timeStr,
      );
      final Uint8List bytes = await pdf.save();

      final String fileName = 'receipt_${now.millisecondsSinceEpoch}.pdf';

      if (Platform.isAndroid) {
        // ANDROID: Save to public "Downloads" using SAF
        final String? savedPath = await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          ext: 'pdf',
          mimeType: MimeType.pdf,
        );

        if (savedPath == null || savedPath.isEmpty) {
          throw 'User cancelled or failed to save.';
        }

        // Try to open it
        await OpenFile.open(savedPath);
        _ok(context, 'Saved to Downloads:\n$fileName');
        return;
      }

      if (Platform.isIOS) {
        // IOS: Use share sheet so user picks Files/iCloud/etc.
        final Directory tmp = await getTemporaryDirectory();
        final file = File('${tmp.path}/$fileName');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([XFile(file.path)], subject: 'Receipt');
        _ok(context, 'Exported receipt — pick a location in the share sheet.');
        return;
      }

      // DESKTOP (optional): save to Downloads if available, else documents dir
      final downloadsDir = await getDownloadsDirectory(); // works on macOS/Windows/Linux
      final Directory targetDir = downloadsDir ?? await getApplicationDocumentsDirectory();
      final file = File('${targetDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
      _ok(context, 'Saved: ${file.path}');
    } catch (e) {
      _err(context, 'Failed to download receipt: $e');
    }
  }

  void _ok(BuildContext c, String msg) {
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  void _err(BuildContext c, String msg) {
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<pw.Document> _generatePdfReceipt({
    required Ticket ticket,
    required String dateStr,
    required String timeStr,
  }) async {
    final pdf = pw.Document();
    String pay = ticket.paymentMethod;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // keep your 80mm receipt size
        build: (pw.Context _) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'RECEIPT',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Your Company Name',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 10),

              pw.Text('Ticket: ${ticket.name}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Date: $dateStr', style: pw.TextStyle(fontSize: 12)),
              pw.Text('Time: $timeStr', style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 15),

              pw.Text('PAYMENT DETAILS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Payment Method:', style: pw.TextStyle(fontSize: 13)),
                  pw.Text(pay, style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Amount:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text('TK ${ticket.totalAmount.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 20),

              pw.Divider(thickness: 1),
              pw.SizedBox(height: 15),
              pw.Center(
                child: pw.Text('Thank you for your purchase!', style: pw.TextStyle(fontSize: 12)),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text('Contact: info@yourcompany.com', style: pw.TextStyle(fontSize: 10)),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(ticket.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadReceipt(context),
            tooltip: 'Download Receipt',
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
          const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.more_vert)),
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ... your preview card unchanged ...
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadReceipt(context),
                icon: const Icon(Icons.download),
                label: const Text('Download Receipt as PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _brandGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _EmailSendBar(
              hintText: 'Enter email to send receipt',
              onSend: (email) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Would send receipt to $email')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

const Color _brandGreen = Color(0xFF4CAF50);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _EmailSendBar extends StatefulWidget {
  const _EmailSendBar({
    required this.hintText,
    required this.onSend,
  });

  final String hintText;
  final void Function(String email) onSend;

  @override
  State<_EmailSendBar> createState() => _EmailSendBarState();
}

class _EmailSendBarState extends State<_EmailSendBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final email = _controller.text.trim();
    if (email.isEmpty) return;
    widget.onSend(email);
    FocusScope.of(context).unfocus();
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE6E8EE)),
        ),
        child: Row(
          children: [
            Icon(Icons.mail_outline, color: Colors.grey.shade600),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            InkWell(
              onTap: _handleSend,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_forward, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:my_pos/models/ticket_model.dart';
// import 'package:my_pos/providers/ticket_provider.dart';
//
// class PrintPage extends StatelessWidget {
//
//   const PrintPage({
//     super.key,
//     required this.ticket,
//   });
//
//   final Ticket ticket;
//
//   static const _brandGreen = Color(0xFF2E7D32);
//
//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final totalAmount = ticket.totalAmount;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       appBar: AppBar(
//         backgroundColor: _brandGreen,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Text(ticket.name),
//         leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
//         actions: const [
//           Padding(
//             padding: EdgeInsets.only(right: 4),
//             child: Icon(Icons.person_add_alt_1_outlined),
//           ),
//           Padding(
//             padding: EdgeInsets.only(right: 8),
//             child: Icon(Icons.more_vert),
//           ),
//         ],
//       ),
//
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
//         child: SizedBox(
//           height: 52,
//           child: ElevatedButton.icon(
//             icon: const Icon(Icons.check, size: 20),
//             label: const Text(
//               'NEW SALE',
//               style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: .6),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _brandGreen,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             onPressed: null,
//           ),
//         ),
//       ),
//
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
//           children: [
//             // Amount + subtitle
//             Column(
//               children: [
//                 Text(
//                   'TK $totalAmount',
//                   style: textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: .2,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   'Total paid',
//                   style: textTheme.bodyMedium?.copyWith(
//                     color: Colors.grey.shade600,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//
//             // Email entry row
//             _EmailSendBar(
//               hintText: 'Enter email',
//               onSend: (email) => null,
//             ),
//
//             const SizedBox(height: 12),
//
//             // Slim gray divider bar (like screenshot)
//             Container(
//               height: 6,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFEFF1F6),
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             // PRINT RECEIPT
//             Center(
//               child: OutlinedButton.icon(
//                 icon: const Icon(Icons.print, size: 20),
//                 label: const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   child: Text(
//                     'PRINT RECEIPT',
//                     style: TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                 ),
//                 style: OutlinedButton.styleFrom(
//                   side: BorderSide(color: Colors.grey.shade400),
//                   foregroundColor: Colors.grey.shade800,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                 ),
//                 onPressed: null,
//               ),
//             ),
//
//             const SizedBox(height: 240), // breathing room to match layout
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _EmailSendBar extends StatefulWidget {
//   const _EmailSendBar({
//     required this.hintText,
//     required this.onSend,
//   });
//
//   final String hintText;
//   final void Function(String email) onSend;
//
//   @override
//   State<_EmailSendBar> createState() => _EmailSendBarState();
// }
//
// class _EmailSendBarState extends State<_EmailSendBar> {
//   final _controller = TextEditingController();
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _handleSend() {
//     final email = _controller.text.trim();
//     if (email.isEmpty) return;
//     widget.onSend(email);
//     FocusScope.of(context).unfocus();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         height: 48,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: const Color(0xFFE6E8EE)),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.mail_outline, color: Colors.grey.shade600),
//             const SizedBox(width: 10),
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   border: InputBorder.none,
//                   hintText: widget.hintText,
//                   hintStyle: TextStyle(color: Colors.grey.shade500),
//                 ),
//                 onSubmitted: (_) => _handleSend(),
//               ),
//             ),
//             InkWell(
//               onTap: _handleSend,
//               borderRadius: BorderRadius.circular(20),
//               child: const Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Icon(Icons.arrow_forward, size: 22),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
