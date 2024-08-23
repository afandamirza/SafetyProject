import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:safetyreport/not_found_page.dart';
import 'package:safetyreport/page/detail_page.dart';
import 'package:safetyreport/page/home_page.dart';
import 'package:safetyreport/page/login_page.dart';
import 'firebase_options.dart';
import 'package:safetyreport/widget/auth_guard.dart';
import 'package:safetyreport/widget/login_check.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  //Inisialisasi agar flutter bisa tersambung ke firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirebaseMessaging messaging = FirebaseMessaging.instance;

  // NotificationSettings settings = await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );

  // print('User granted permission: ${settings.authorizationStatus}');

  // // TODO: replace with your own VAPID key
  // const vapidKey =
  //     "BGW04XbUXEZ6CfDXwTAPXn2XPhuNFSELmh5WqC1bccO4Kf0uU0Z2prX4mTvtjPej-64wOv8vlrKALskmjPZ0tPs";

  // // use the registration token to send messages to users from your trusted server environment
  // String? token;

  // try {
  //   if (DefaultFirebaseOptions.currentPlatform == DefaultFirebaseOptions.web) {
  //     token = await messaging.getToken(vapidKey: vapidKey);
  //   } else {
  //     token = await messaging.getToken();
  //     print(token);
  //   }

  //   if (kDebugMode) {
  //     print('Registration Token=$token');
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print('Error fetching token: $e');
  //     print('tokennya adalah $token');
  //   }
  // }
  // await FirebaseMessaging.instance.subscribeToTopic("report");
  // await messaging.subscribeToTopic('report');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // subscribeToTopic('report');
  usePathUrlStrategy();
  runApp(const MyApp());
}





// void subscribeToTopic(String topic) {
//   FirebaseMessaging.instance.subscribeToTopic(topic).then((_) {
//     print('Subscribed to topic $topic');
//   }).catchError((error) {
//     print('Error subscribing to topic: $error');
//   });
// }

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tambahkan MaterialApp.router
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safety Report',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF36618E)),
        useMaterial3: true,
      ),
      // initialRoute: '/login',
      // debugPrint(FirebaseAuth.instance.currentUser);
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',

      onGenerateRoute: (settings) {
        if (settings.name!.startsWith('/SafetyReport/')) {
          final id = settings.name!.split('/').last;
          final originalUrl = settings.name.toString();
          
          if(FirebaseAuth.instance.currentUser == null){
            return MaterialPageRoute(builder: (context) => LoginPage(redirectUrl: originalUrl));
          }

          return MaterialPageRoute(
            builder: (context) => FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('SafetyReport').doc(id).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Scaffold(body: Center(child: Text('Document not found')));
                }
                return DetailPage(documentSnapshot: snapshot.data!);
              },
            ),
            settings: settings,
          );
        }
        // Handle other routes if needed
        return null;
      },
      routes: {
        '/home': (context) => const AuthGuard(child: MyHomePage()),
        '/testnotfound': (context) => const NotFoundPage(),
        '/login': (context) => const LoginCheck(child: LoginPage()),
      },
    );
  }
}

// final router = GoRouter(
//   initialLocation: '/home',
//   routes: [
//     GoRoute(
//       path: '/home',
//       builder: (context, state) => const MyHomePage(),
//     ),
//     GoRoute(
//       path: '/SafetyReport/:id',
//       builder: (context, state) {
//         final id = state.pathParameters['id']!; // Use pathParameters to get the dynamic id
//         return FutureBuilder<DocumentSnapshot>(
//           future: FirebaseFirestore.instance
//               .collection('SafetyReport')
//               .doc(id)
//               .get(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Scaffold(
//                   body: Center(child: CircularProgressIndicator()));
//             }
//             if (snapshot.hasError) {
//               return Scaffold(
//                   body: Center(child: Text('Error: ${snapshot.error}')));
//             }
//             if (!snapshot.hasData || !snapshot.data!.exists) {
//               return const Scaffold(
//                   body: Center(child: Text('Document not found')));
//             }
//             return DetailPage(documentSnapshot: snapshot.data!);
//           },
//         );
//       },
//     ),
//        GoRoute(
//       path: '/testnotfound',
//       builder: (context, state) => const NotFoundPage(),
//     ),
//   ],
// );