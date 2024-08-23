import 'dart:async';

import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logging/logging.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:safetyreport/components/my_grid_inkwell.dart';
import 'package:safetyreport/components/my_list_inkwell.dart';
import 'package:safetyreport/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? image, location, detectionStatus;
  File? _imageFile;
  DateTimeRange? _selectedDateRange;
  bool _isDescending = false;
  bool _isGridView = false;
  String searchQuery = '';

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  final TextEditingController _searchController = TextEditingController();

  // Objek variabel Instance untuk memanggil Firebase
  final FirebaseFirestore db = FirebaseFirestore.instance;
  //

  final ImagePicker picker = ImagePicker();

  final Logger log = Logger('_MyHomePageState');

  void getLocation(String location) {
    this.location = location;
  }

  void getDetectionStatus(String status) {
    detectionStatus = status;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void setupFirebaseMessaging() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    await FirebaseMessaging.instance.subscribeToTopic("report");

    // Request permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Determine platform and execute relevant setup
    if (kIsWeb) {
      // Setup for web
      const String vapidKey =
          "BGW04XbUXEZ6CfDXwTAPXn2XPhuNFSELmh5WqC1bccO4Kf0uU0Z2prX4mTvtjPej-64wOv8vlrKALskmjPZ0tPs";

      String? token;
      try {
        token = await messaging.getToken(vapidKey: vapidKey);
        print('FCM token (Web): $token');
      } catch (e) {
        print('Error fetching token on web: $e');
      }
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Setup for Android or iOS
      String? token;
      try {
        token = await messaging.getToken();
        await messaging.subscribeToTopic("report");
        print('FCM token (Mobile): $token');
      } catch (e) {
        print('Error fetching token on mobile: $e');
      }
    } else {
      print('Unsupported platform for Firebase Messaging');
    }

    // Subscribe to topic
    print('Subscribed to topic "report"');
  }

  void setupPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    // final token = await fcm.getToken();
    await fcm.subscribeToTopic("report");
    // print('FCM device token : $token');
  }

  void setupVapidKey() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // TODO: replace with your own VAPID key
    const vapidKey =
        "BGW04XbUXEZ6CfDXwTAPXn2XPhuNFSELmh5WqC1bccO4Kf0uU0Z2prX4mTvtjPej-64wOv8vlrKALskmjPZ0tPs";

    // use the registration token to send messages to users from your trusted server environment
    String? token;

    try {
      if (DefaultFirebaseOptions.currentPlatform ==
          DefaultFirebaseOptions.web) {
        token = await messaging.getToken(vapidKey: vapidKey);
      } else {
        token = await messaging.getToken();
        print(token);
      }

      if (kDebugMode) {
        print('Registration Token=$token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching token: $e');
        print(token);
      }
    }
    await messaging.subscribeToTopic('report');
  }

  @override
  void initState() {
    super.initState();
    _selectedDateRange = DateTimeRange(
      start: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      end: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 23, 59, 59),
    );

    // Callback ketika notifikasi diterima saat aplikasi aktif
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Received a message while in foreground: ${message.messageId}');
    //   // Tampilkan notifikasi lokal atau lakukan aksi lain
    // });

    // // Callback ketika notifikasi diterima dan user mengklik notifikasi
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   print('User clicked the notification: ${message.messageId}');
    //   // Lakukan aksi lain seperti navigasi ke halaman tertentu
    // });

    // setupFirebaseMessaging();
    // setupVapidKey();
    setupPushNotification();

    _setupLogging();
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Stream<QuerySnapshot> instancesFirebase() {
    return _selectedDateRange == null
        // Fetching the collection from Firebase
        ? FirebaseFirestore.instance
            .collection("SafetyReport")
            .orderBy("Timestamp", descending: !_isDescending)
            .snapshots()
        : FirebaseFirestore.instance
            .collection("SafetyReport")
            .where("Timestamp",
                isGreaterThanOrEqualTo: _selectedDateRange!.start)
            .where("Timestamp", isLessThanOrEqualTo: _selectedDateRange!.end)
            .orderBy("Timestamp", descending: !_isDescending)
            .snapshots();
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        log.info('No item selected.');
      }
    });
  }

  // Compress image
  Future<File?> compressImage(File file) async {
    final bytes = file.readAsBytesSync();
    final img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      log.warning('Unable to decode image.');
      return null;
    }

    int width;
    int height;

    if (image.width > image.height) {
      width = 1000;
      height = (image.height / image.width * 1000).round();
    } else {
      height = 1000;
      width = (image.width / image.height * 1000).round();
    }

    img.Image resizedImage =
        img.copyResize(image, width: width, height: height);

    final compressedBytes = img.encodeJpg(resizedImage, quality: 100);

    // Save compressed image to temporary file
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/temp_image.jpg');
    tempFile.writeAsBytesSync(compressedBytes);

    return tempFile;
  }

  // Upload image to Firebase Storage and get URL
  Future<void> uploadImage() async {
    if (_imageFile == null) return;

    final compressedFile = await compressImage(_imageFile!);
    if (compressedFile == null) return;

    final originalFileName = _imageFile!.path.split('/').last;
    final destination = 'images/$originalFileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      await ref.putFile(compressedFile);
      String imageUrl = await ref.getDownloadURL();

      setState(() {
        image = imageUrl;
      });

      log.info('Image uploaded: $imageUrl');
    } catch (e) {
      log.severe('Error occurred while uploading image: $e');
    }
  }

  //Create dan submit data
  Future<void> createData() async {
    await uploadImage();

    DocumentReference documentReference = db.collection("SafetyReport").doc();

    Map<String, dynamic> mapData = {
      "Image": image,
      "Location": location,
      "Safety Report": detectionStatus,
      "Timestamp": Timestamp.now()
    };

    documentReference.set(mapData).whenComplete(() {
      log.finer("Document created with ID: ${documentReference.id}");
    });
  }

  // Show date range picker and set state for date range
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _handleMenuSelection(String value) {
    if (value == 'today') {
      setState(() {
        _selectedDateRange = DateTimeRange(
          start: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          end: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day, 23, 59, 59),
        );
      });
    } else if (value == 'all') {
      setState(() {
        _selectedDateRange = null;
      });
    } else if (value == 'logout') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm Logout"),
            content: const Text("Are you sure you want to log out?"),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child:
                    const Text("Log Out", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil("/login", (route) => false);
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _toggleSortOrder() {
    setState(() {
      _isDescending = !_isDescending;
    });
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void navigateToDetailPage(DocumentSnapshot documentSnapshot) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => DetailPage(documentSnapshot: documentSnapshot),
    //   ),
    // );
    Navigator.pushNamed(context, '/SafetyReport/${documentSnapshot.id}');
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final String email = user?.email ?? 'Unknown Email';

    return Scaffold(
      // Top Bar Menu Aplikasi Untuk Show All Data dan Grid/List View
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Safety Project'),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    'lib/images/safety.png',
                    fit: BoxFit.cover,
                    width: 90,
                    height: 90,
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF36618E),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('lib/images/profile-bg.jpg'),
                ),
              ),
            ),
            // ListTile(
            //   leading: const Icon(Icons.today_rounded),
            //   title: const Text('Show Today\'s Data'),
            //   onTap: () {
            //     String value = 'today';
            //     _handleMenuSelection(value);
            //     Navigator.pop(context);
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.all_inbox_rounded),
            //   title: const Text('Show All Data'),
            //   onTap: () {
            //     String value = 'all';
            //     _handleMenuSelection(value);
            //     Navigator.pop(context);
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Log Out'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm Logout"),
                      content: const Text("Are you sure you want to log out?"),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                        TextButton(
                          child: const Text("Log Out",
                              style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                "/login", (route) => false);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: const Color(0xFF36618E),
            title: InkWell(
              onTap: () {
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => const MyHomePage()),
                // );

                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('Safety Report',
                  style: TextStyle(color: Colors.white)),
            ),
            // actions: [

            //   // IconButton(
            //   //   color: Colors.white,
            //   //   icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            //   //   onPressed: _toggleViewMode,
            //   // ),
            //   PopupMenuButton<String>(
            //     color: Colors.white,
            //     onSelected: _handleMenuSelection,
            //     itemBuilder: (BuildContext context) {
            //       return [
            //         const PopupMenuItem<String>(
            //           value: 'today',
            //           child: Row(
            //             children: [
            //               Icon(
            //                 Icons.today_rounded,
            //                 color: Colors.black,
            //               ),
            //               SizedBox(width: 4),
            //               Text('Show Today\'s Data'),
            //             ],
            //           ),
            //         ),
            //         const PopupMenuItem<String>(
            //           value: 'all',
            //           child: Row(
            //             children: [
            //               Icon(
            //                 Icons.all_inbox_rounded,
            //                 color: Colors.black,
            //               ),
            //               SizedBox(width: 4),
            //               Text('Show All Data'),
            //             ],
            //           ),
            //         ),
            //         const PopupMenuItem<String>(
            //           value: 'logout',
            //           child: Row(
            //             children: [
            //               Icon(
            //                 Icons.logout_rounded,
            //                 color: Colors.black,
            //               ),
            //               SizedBox(width: 4),
            //               Text('Log Out'),
            //             ],
            //           ),
            //         ),
            //       ];
            //     },
            //   ),
            // ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Create Data Insert Image

                  // _imageFile == null
                  //     ? const Text('No image selected.')
                  //     : Image.file(_imageFile!,
                  //         height: 300, width: 300, fit: BoxFit.cover),
                  // const SizedBox(
                  //   height: 24,
                  // ),
                  // ElevatedButton(
                  //   onPressed: pickImage,
                  //   child: const Text('Pick Image'),
                  // ),

                  // //Input Form

                  // Padding(
                  //   padding: const EdgeInsets.all(8),
                  //   child: TextFormField(
                  //     decoration: const InputDecoration(
                  //         labelText: "Location",
                  //         fillColor: Colors.white,
                  //         focusedBorder: OutlineInputBorder(
                  //           borderSide:
                  //               BorderSide(color: Colors.blue, width: 2.0),
                  //         )),
                  //     onChanged: (String location) {
                  //       getLocation(location);
                  //     },
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8),
                  //   child: DropdownButtonFormField<String>(
                  //     decoration: const InputDecoration(
                  //       labelText: "Detection Status",
                  //       fillColor: Colors.white,
                  //       focusedBorder: OutlineInputBorder(
                  //         borderSide:
                  //             BorderSide(color: Colors.blue, width: 2.0),
                  //       ),
                  //     ),
                  //     items: const [
                  //       DropdownMenuItem(
                  //           value: "No Googles", child: Text("No Googles")),
                  //       DropdownMenuItem(
                  //           value: "No Coat", child: Text("No Coat")),
                  //       DropdownMenuItem(
                  //           value: "No Helmet", child: Text("No Helmet")),
                  //       DropdownMenuItem(
                  //           value: "No Boots", child: Text("No Boots")),
                  //     ],
                  //     onChanged: (String? status) {
                  //       setState(() {
                  //         getDetectionStatus(status!);
                  //       });
                  //     },
                  //   ),
                  // ),

                  // // // Create Data Insert Image

                  // Padding(
                  //   padding: const EdgeInsets.all(8),
                  //   child: Wrap(
                  //     spacing: 10,
                  //     children: <Widget>[
                  //       ElevatedButton(
                  //         style: ElevatedButton.styleFrom(
                  //           padding: const EdgeInsets.symmetric(
                  //               horizontal: 40, vertical: 2),
                  //           foregroundColor: Colors.green,
                  //         ),
                  //         child: const Text(
                  //           'Create',
                  //           textAlign: TextAlign.center,
                  //         ),
                  //         onPressed: () {
                  //           createData();
                  //         },
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  //
                  const SizedBox(
                    height: 24,
                  ),
                  //

                  /*Memilih Date Range */

                  TextButton.icon(
                    onPressed: () => _selectDateRange(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black.withOpacity(0.8),
                      side: const BorderSide(color: Colors.grey, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label: const Text('Select Date Range'),
                    icon: const Icon(
                      Icons.edit_calendar_rounded,
                      color: Color(0xFF1976D2),
                    ),
                  ),

                  //
                  const SizedBox(
                    height: 16,
                  ),
                  //

                  /* Text Date Range yang telah di pick */

                  if (_selectedDateRange != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: Align(
                        alignment: Alignment.center,
                        child: AutoSizeText(
                          isSameDate(_selectedDateRange!.start, DateTime.now())
                              ? 'Selected date range: Today ${DateFormat('d MMMM yyyy').format(_selectedDateRange!.start)}'
                              : 'Selected date range: ${DateFormat('d MMMM yyyy').format(_selectedDateRange!.start)} to ${DateFormat('d MMMM yyyy').format(_selectedDateRange!.end)}',
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ] else if (_selectedDateRange == null) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Selected date range: All Time',
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ],
                  //

                  /* Search TextBox */

                  SizedBox(
                    width: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? MediaQuery.of(context).size.width / 2
                        : MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: TextFormField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ),

                  //

                  StreamBuilder<QuerySnapshot>(
                    stream: instancesFirebase(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text('');
                      } else {
                        final docs = snapshot.data!.docs.where((doc) {
                          Map<String, dynamic> data =
                              doc.data() as Map<String, dynamic>;
                          String location =
                              data['Location']?.toString().toLowerCase() ?? '';
                          String safetyReport =
                              data['Safety Report']?.toString().toLowerCase() ??
                                  '';
                          String timestamp = (data['Timestamp'] is Timestamp)
                              ? DateFormat('MMMM d, yyyy \'at\' h:mm:ss a')
                                  .format(data['Timestamp'].toDate())
                                  .toLowerCase()
                              : '';
                          String docId = doc.id.toLowerCase();

                          return location.contains(searchQuery) ||
                              safetyReport.contains(searchQuery) ||
                              timestamp.contains(searchQuery) ||
                              docId.contains(searchQuery);
                        }).toList();

                        if (docs.isEmpty) {
                          return const Text('');
                        }

                        return Column(
                          children: [
                            SelectableText('Total Reports: ${docs.length}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        );
                      }
                    },
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(
                            'Report',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 20),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize
                              .min, // Prevents Row from taking extra space
                          children: [
                            IconButton(
                              icon: Icon(_isGridView
                                  ? Icons.view_list
                                  : Icons.grid_view),
                              onPressed: _toggleViewMode,
                            ),
                            IconButton(
                              icon: _isDescending
                                  ? Transform.flip(
                                      flipY: true,
                                      child: const Icon(Icons.sort),
                                    )
                                  : const Icon(Icons.sort),
                              onPressed: _toggleSortOrder,
                            ),
                            PopupMenuButton<String>(
                              color: Colors.white,
                              onSelected: _handleMenuSelection,
                              itemBuilder: (BuildContext context) {
                                return [
                                  const PopupMenuItem<String>(
                                    value: 'today',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.today_rounded,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: 4),
                                        Text('Show Today\'s Data'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'all',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.all_inbox_rounded,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: 4),
                                        Text('Show All Data'),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Streambuilder untuk menampilkan data dari Firebase

                  StreamBuilder<QuerySnapshot>(
                    stream: instancesFirebase(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('No reports.'),
                        );
                      } else {
                        final docs = snapshot.data!.docs.where((doc) {
                          Map<String, dynamic> data =
                              doc.data() as Map<String, dynamic>;
                          String location =
                              data['Location']?.toString().toLowerCase() ?? '';
                          String safetyReport =
                              data['Safety Report']?.toString().toLowerCase() ??
                                  '';
                          String timestamp = (data['Timestamp'] is Timestamp)
                              ? DateFormat('MMMM d, yyyy \'at\' h:mm:ss a')
                                  .format(data['Timestamp'].toDate())
                                  .toLowerCase()
                              : '';
                          String docId = doc.id.toLowerCase();

                          return location.contains(searchQuery) ||
                              safetyReport.contains(searchQuery) ||
                              timestamp.contains(searchQuery) ||
                              docId.contains(searchQuery);
                        }).toList();

                        if (docs.isEmpty) {
                          return const Center(
                            child: Text(
                                'No reports found or the search value may not valid.'),
                          );
                        }

                        // Me-return data Firebase dalam bentuk Grid/List
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            // Determine the number of items per row for GridView
                            int itemsPerRow;
                            // Define your desired item width
                            double itemWidth = 150;
                            double screenWidth = constraints.maxWidth;

                            // Calculate items per row based on screen width
                            itemsPerRow = (screenWidth / itemWidth).floor();
                            itemsPerRow = itemsPerRow > 6 ? 6 : itemsPerRow;
                            return SizedBox(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: _isGridView
                                  ? DynamicHeightGridView(
                                      shrinkWrap: true,
                                      physics: const BouncingScrollPhysics(),
                                      crossAxisCount: itemsPerRow,
                                      crossAxisSpacing: 4.0,
                                      mainAxisSpacing: 4.0,
                                      itemCount: docs.length,
                                      builder: (context, index) {
                                        DocumentSnapshot documentSnapshot =
                                            docs[index];
                                        return MyGridInkWell(
                                          documentSnapshot: documentSnapshot,
                                          onTap: navigateToDetailPage,
                                        );
                                      },
                                    )
                                  : ListView.builder(
                                      itemCount: docs.length,
                                      itemBuilder: (context, index) {
                                        DocumentSnapshot documentSnapshot =
                                            docs[index];
                                        return MyListInkWell(
                                          documentSnapshot: documentSnapshot,
                                          onTap: navigateToDetailPage,
                                        );
                                      },
                                    ),
                            );
                          },
                        );
                      }
                    },
                  ),

                  const SizedBox(
                    height: 48,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
