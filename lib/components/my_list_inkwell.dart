// lib/widgets/my_grid_inkwell.dart

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Function to determine the status color
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

class MyListInkWell extends StatelessWidget {
  final DocumentSnapshot documentSnapshot;
  final Function(DocumentSnapshot) onTap;

  const MyListInkWell({
    super.key,
    required this.documentSnapshot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    dynamic timestamp = data['Timestamp'];
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

    return InkWell(
      onTap: () => onTap(documentSnapshot),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: Card(
          elevation: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: data['Image'] != null
                      ? Image.network(data['Image'],
                          height: 72, width: 72, fit: BoxFit.cover)
                      : const SizedBox(
                          height: 72,
                          width: 72,
                          child: Icon(Icons.image_not_supported, size: 72)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(data['Location'] ?? 'No Location',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    AutoSizeText(formattedDate,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    AutoSizeText('ID: ${documentSnapshot.id}',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                child: AutoSizeText('${data['Safety Report'] ?? 'No Status'}',
                    maxLines: 2,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: getStatusColor(data['Safety Report'] ?? ''),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
