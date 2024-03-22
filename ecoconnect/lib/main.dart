import 'package:env_assignment/screens/assign.dart';
import 'package:env_assignment/screens/assign_dept.dart';
import 'package:env_assignment/screens/home/complaints.dart';
import 'package:env_assignment/screens/home/complaints_beat.dart';
import 'package:env_assignment/screens/home/complaints_dept.dart';
import 'package:env_assignment/screens/home/complaints_public.dart';
import 'package:env_assignment/screens/complaints_public_add.dart';
import 'package:env_assignment/screens/auth/login.dart';
import 'package:env_assignment/screens/auth/register.dart';
import 'package:env_assignment/screens/submit_action.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:env_assignment/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Connect  - Enviornment Complaint System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (ctx) => LoginScreen(),
        RegisterScreen.routeName: (ctx) => RegisterScreen(),
        ComplaintsScreen.routeName: (ctx) => ComplaintsScreen(),
        AssignScreen.routeName: (ctx) => AssignScreen(),
        ComplaintsPublic.routeName: (ctx) => ComplaintsPublic(),
        ComplaintsPublicAdd.routeName: (ctx) => ComplaintsPublicAdd(),
        ComplaintsDept.routeName: (ctx) => ComplaintsDept(),
        AssignDept.routeName: (ctx) => AssignDept(),
        ComplaintsBeat.routeName: (ctx) => ComplaintsBeat(),
        SubmitAction.routeName: (ctx) => SubmitAction()
      },
    );
  }
}
