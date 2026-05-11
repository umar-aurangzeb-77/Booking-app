import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'pages/splash_screen.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/navigation_page.dart';
import 'pages/filter_page.dart';
import 'pages/room_view_page.dart';
import 'pages/admin/admin_login_screen.dart';
import 'pages/admin/admin_dashboard_screen.dart';
import 'pages/admin/room_details_screen.dart';
import 'pages/admin/add_room_screen.dart';
import 'pages/admin/edit_room_screen.dart';
import 'pages/student/student_entry_screen.dart';
import 'pages/student/student_dashboard_screen.dart';
import 'pages/student/room_booking_screen.dart';
import 'pages/student/available_rooms_screen.dart';
import 'pages/student/booked_rooms_screen.dart';
import 'pages/student/my_bookings_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/room_provider.dart';
import 'providers/booking_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stackTrace) {
    debugPrint('Firebase initialization failed: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(const BookingApp());
}

class BookingApp extends StatelessWidget {
  const BookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          ThemeData theme;
          if (authProvider.role == 'admin') {
            theme = AppTheme.adminTheme;
          } else if (authProvider.role == 'student') {
            theme = AppTheme.studentTheme;
          } else {
            theme = AppTheme.lightTheme;
          }

          return MaterialApp(
            title: 'Room Booking App',
            theme: theme,
            initialRoute: '/', // Defaulting to splash screen
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginPage(),
              '/signup': (context) => const SignupPage(),
              '/home': (context) => const NavigationPage(),
              '/filter': (context) => const FilterPage(),
              '/room-view': (context) => const RoomViewPage(),
              '/admin-login': (context) => const AdminLoginScreen(),
              '/admin-dashboard': (context) => const AdminDashboardScreen(),
              '/room-details': (context) => const RoomDetailsScreen(),
              '/add-room': (context) => const AddRoomScreen(),
              '/edit-room': (context) => const EditRoomScreen(),
              '/student-entry': (context) => const StudentEntryScreen(),
              '/student-dashboard': (context) => const StudentDashboardScreen(),
              '/room-booking': (context) => const RoomBookingScreen(),
              '/available-rooms': (context) => const AvailableRoomsScreen(),
              '/booked-rooms': (context) => const BookedRoomsScreen(),
              '/my-bookings': (context) => const MyBookingsScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
