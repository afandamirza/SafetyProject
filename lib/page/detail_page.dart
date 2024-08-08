import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart'; 
import 'package:universal_html/html.dart' as html; // 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart'; // Import for Clipboard

class DetailPage extends StatelessWidget {
  final DocumentSnapshot documentSnapshot;
  

  const DetailPage({super.key, required this.documentSnapshot});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    dynamic timestamp = data['Time stamp'];
    String formattedDate;

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      formattedDate =
          DateFormat('MMMM d, yyyy \'at\' h:mm:ss a').format(dateTime);
    } else if (timestamp is int) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      formattedDate =
          DateFormat('MMMM d, yyyy \'at\' h:mm:ss a').format(dateTime);
    } else {
      formattedDate = 'No Timestamp';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              if (data['Image'] != null) {
                await _downloadImage(data['Image'], context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No image to download")),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareContent(context, data);
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              _copyLinkToClipboard(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: data['Image'] != null
                    ? Image.network(
                        data['Image'],
                        height: 300,
                        width: 300,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox(
                        height: 300,
                        width: 300,
                        child: Icon(Icons.image_not_supported, size: 300),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                'Location: ${data['Location'] ?? 'No Location'}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Date: $formattedDate',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Safety Report: ',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: '${data['Safety Report'] ?? 'No Status'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: getStatusColor(
                            data['Safety Report'] ?? ''), // Custom color
                        fontWeight: FontWeight.w500, // Bold
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              AutoSizeText(
                'ID: ${documentSnapshot.id}', // Display document ID
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Confirmation"),
          content: const Text("Are you sure you want to delete this report?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteReport(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // Delete the report from Firestore
  void _deleteReport(BuildContext context) {
    documentSnapshot.reference.delete().then((_) {
      Navigator.of(context).pop(); // Close the confirmation dialog
      Navigator.of(context).pop(); // Go back to the previous screen
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete report: $error")),
      );
      Navigator.of(context).pop(); // Close the confirmation dialog
    });
  }

  Future<void>  _downloadImage(String url, BuildContext context) async {
    try {
      if (kIsWeb) {
        // Web-specific code to download image
        var imgReq = html.HttpRequest();
        imgReq.open('GET', url);
        imgReq.responseType = 'blob';
        imgReq.onLoadEnd.listen((e) {
          final blob = imgReq.response;
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute("download", "image.png")
            ..click();
          html.Url.revokeObjectUrl(url);
        });
        imgReq.send();
      } else {
        // Mobile-specific code to download image
        // Get the application documents directory
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;

        // Create the file path to save the image
        String fileName = url.split('/').last;
        String filePath = '$appDocPath/$fileName';

        // Download the image
        Dio dio = Dio();
        await dio.download(url, filePath);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image downloaded successfully")),
        );
      }
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download image: $error")),
      );
    }
  }

  void _shareContent(BuildContext context, Map<String, dynamic> data) {
    String shareText = '''
      ${documentSnapshot.reference.path}
      Location: ${data['Location'] ?? 'No Location'}
      Date: ${data['Time stamp'] != null ? DateFormat('MMMM d, yyyy \'at\' h:mm:ss a').format((data['Time stamp'] as Timestamp).toDate()) : 'No Timestamp'}
      Safety Report: ${data['Safety Report'] ?? 'No Status'}
    ''';

    if (kIsWeb) {
      // Web-specific code to share content
      html.window.navigator.share({
        'title': 'Detail Page',
        'text': shareText,
        'url': documentSnapshot.reference.path, // Share URL if needed
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to share content: $error")),
        );
      });
    } else {
      Share.share(shareText);
    }
  }

  void _copyLinkToClipboard(BuildContext context) {
    Clipboard.setData(
      ClipboardData(text: documentSnapshot.reference.path),
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Link copied to clipboard")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to copy link: $error")),
      );
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "No Googles":
        return Colors.blue;
      case "No Coat":
        return Colors.orange;
      case "No Helmet":
        return Colors.red;
      case "No Boots":
        return Colors.brown;
      default:
        return Colors.black;
    }
  }
}
