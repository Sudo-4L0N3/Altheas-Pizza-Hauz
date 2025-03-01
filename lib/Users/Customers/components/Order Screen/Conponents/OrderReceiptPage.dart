// Import necessary packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class OrderReceiptDialog extends StatelessWidget {
  final String orderId;

  const OrderReceiptDialog({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // More pronounced rounded corners
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600, // Limit the maximum width for larger screens
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Order').doc(orderId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    "No order found.",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              );
            }

            var data = snapshot.data!.data() as Map<String, dynamic>;
            var fullName = data['fullname'] ?? 'Unknown';
            var username = data['username'] ?? 'Unknown';
            var orderNumber = data['orderNumber']?.toString() ?? 'Unknown';
            var priority = data['priority'] ?? 'Normal';
            var items = List<Map<String, dynamic>>.from(data['items'] ?? []);

            // Updated total price calculation to avoid type conflict
            var totalPrice = items.fold(
                0.0,
                (double sum, item) =>
                    sum + (item['totalPrice'] as num? ?? 0).toDouble());

            // Retrieve and format the timestamp
            var timestamp = data['timestamp'] as Timestamp?;
            var formattedTimestamp = timestamp != null
                ? DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate())
                : 'Unknown';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Makes the dialog size dynamic
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Receipt',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Customer and Order Details
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              context,
                              icon: Icons.person,
                              label: 'Customer',
                              value: fullName,
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              context,
                              icon: Icons.account_circle,
                              label: 'Username',
                              value: username,
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              context,
                              icon: Icons.receipt_long,
                              label: 'Order Number',
                              value: '#$orderNumber',
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              context,
                              icon: Icons.priority_high,
                              label: 'Priority',
                              value: priority,
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              context,
                              icon: Icons.access_time,
                              label: 'Order Time',
                              value: formattedTimestamp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Items Ordered
                    Text(
                      'Items Ordered:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          var item = items[index];
                          var foodName = item['foodName'] ?? 'Unknown';
                          var quantity = item['quantity']?.toString() ?? '1';
                          var price = item['totalPrice']?.toString() ?? '0';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.pinkAccent,
                              child: Text(
                                quantity,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              foodName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              '₱ $price',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Total Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Price:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '₱ ${totalPrice.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Download Receipt Button with PDF Icon
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await _downloadReceiptPdf(
                              context,
                              fullName,
                              username,
                              orderNumber,
                              priority,
                              formattedTimestamp,
                              items,
                              totalPrice,
                            );
                          } catch (e) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error generating PDF: $e'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.red, // Button color
                        ),
                        icon: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Download Receipt',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to build detail rows with icons
  Widget _buildDetailRow(BuildContext context,
      {required IconData icon,
      required String label,
      required String value}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.pinkAccent,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Method to generate and download PDF with watermark
  Future<void> _downloadReceiptPdf(
    BuildContext context,
    String fullName,
    String username,
    String orderNumber,
    String priority,
    String orderTime,
    List<Map<String, dynamic>> items,
    double totalPrice,
  ) async {
    final pdf = pw.Document();

    // Load the logo image from assets
    pw.MemoryImage? imageLogo;
    try {
      final logoBytes = await rootBundle.load('assets/images/altheaslogo.png');
      imageLogo = pw.MemoryImage(
        logoBytes.buffer.asUint8List(),
      );
    } catch (e) {
      // Handle the error if the image fails to load
      // ignore: avoid_print
      print('Error loading logo image: $e');
      // Optionally, show a snackbar or alert to the user
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading logo image: $e'),
        ),
      );
      // Proceed without the logo
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a5, // Smaller paper size
        margin: const pw.EdgeInsets.all(20), // Adjusted margins
        build: (pw.Context context) {
          return [
            pw.Stack(
              children: [
                // Watermark: Centered, semi-transparent logo
                if (imageLogo != null)
                  pw.Center(
                    child: pw.Opacity(
                      opacity: 0.1, // Adjust transparency here (0.0 - 1.0)
                      child: pw.Image(
                        imageLogo,
                        width: 150, // Adjust the size as needed
                        height: 150,
                      ),
                    ),
                  ),
                // Main Content
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Order Receipt Header
                    pw.Text('Order Receipt',
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 12),
                    // Customer and Order Details
                    pw.Text('Customer: $fullName', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('Username: $username', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('Order Number: #$orderNumber',
                        style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('Priority: $priority', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('Order Time: $orderTime',
                        style: const pw.TextStyle(fontSize: 12)),
                    pw.SizedBox(height: 16),
                    // Items Ordered
                    pw.Text('Items Ordered:',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Table(
                      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(3),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(2),
                      },
                      children: [
                        // Table Header
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: PdfColors.pink),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('Food Name',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.white)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('Qty',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.white)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('Price',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.white)),
                            ),
                          ],
                        ),
                        // Table Rows
                        ...items.map((item) {
                          return pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(item['foodName'] ?? 'Unknown',
                                    style: const pw.TextStyle(fontSize: 10)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                    'x${item['quantity']?.toString() ?? '1'}',
                                    style: const pw.TextStyle(fontSize: 10)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                    'P${(item['totalPrice'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                    style: const pw.TextStyle(fontSize: 10)),
                              ),
                            ],
                          );
                        // ignore: unnecessary_to_list_in_spreads
                        }).toList(),
                      ],
                    ),
                    pw.SizedBox(height: 16),
                    // Total Price
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Price:',
                            style: pw.TextStyle(
                                fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        pw.Text('P${totalPrice.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Convert the PDF document to bytes
    final bytes = await pdf.save();

    // Trigger the download using the printing package
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'receipt_$orderNumber.pdf',
    );
  }
}
