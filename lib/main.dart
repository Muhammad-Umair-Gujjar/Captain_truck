import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'customer/services/firebase_service.dart' as firebase;
import 'customer/services/push_notification_service.dart'
    hide firebaseMessagingBackgroundHandler;
import 'customer/services/location_service.dart';
import 'customer/main.dart'
    show CustomerApp, firebaseMessagingBackgroundHandler;
import 'driver/main.dart' show DriverApp;
import 'app_role.dart';
import 'screens/role_selection_screen.dart';

export 'app_role.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase once for the whole app
  await firebase.FirebaseService.initialize();

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Push Notifications
  await PushNotificationService.initialize();

  // Initialize Location Services (request permissions)
  await LocationService.initialize();

  runApp(const CaptainTruckRoot());
}

class CaptainTruckRoot extends StatefulWidget {
  const CaptainTruckRoot({super.key});

  @override
  State<CaptainTruckRoot> createState() => _CaptainTruckRootState();
}

class _CaptainTruckRootState extends State<CaptainTruckRoot> {
  AppRole? _selectedRole;

  void _onRoleSelected(AppRole role) {
    setState(() => _selectedRole = role);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedRole == AppRole.customer) {
      return const CustomerApp();
    }
    if (_selectedRole == AppRole.driver) {
      return const DriverApp();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Captain Truck',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
      home: RoleSelectionScreen(onRoleSelected: _onRoleSelected),
    );
  }
}
