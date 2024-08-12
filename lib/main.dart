import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safetyreport/not_found_page.dart';
import 'package:safetyreport/page/detail_page.dart';
import 'package:safetyreport/page/home_page.dart';
import 'package:safetyreport/page/login_page.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  //Inisialisasi agar flutter bisa tersambung ke firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safety Report',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        if (settings.name!.startsWith('/SafetyReport/')) {
          final id = settings.name!.split('/').last;
          debugPrint("ini idnya sama dengan : ");
          debugPrint(id);
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
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => DetailPage(documentSnapshot: snapshot.data!)),
                // );
                // return DetailPage(documentSnapshot: snapshot.data!);
              },
            ),
            settings: settings,
          );
        }
        // Handle other routes if needed
        return null;
      },
      routes: {
        '/home': (context) => const MyHomePage(),
        '/testnotfound': (context) => const NotFoundPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}