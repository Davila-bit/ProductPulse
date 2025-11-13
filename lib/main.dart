import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'theme/catppuccin_theme.dart';
import 'screens/product_list_screen.dart';
import 'screens/auth_screen.dart';

// Background message handler
Future<void> _messageHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.body}');
  print('Message data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FirebaseMessaging messaging;
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  void _initializeFirebaseMessaging() async {
    try {
      messaging = FirebaseMessaging.instance;
      print('📱 Initializing Firebase Cloud Messaging...');

      // Request notification permissions
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('✅ User granted permission: ${settings.authorizationStatus}');

      // Subscribe to a topic
      await messaging.subscribeToTopic("productpulse");
      print('✅ Subscribed to topic: productpulse');

      // Get and print FCM token with timeout
      print('⏳ Requesting FCM token...');
      fcmToken = await messaging.getToken().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ FCM token request timed out');
          return null;
        },
      );

      if (fcmToken != null) {
        print('=========================================');
        print('🔑 FCM Token: $fcmToken');
        print('=========================================');
        if (mounted) {
          setState(() {}); // Trigger rebuild to show token in UI
        }
      } else {
        print('❌ Failed to get FCM token (null)');
      }
    } catch (e) {
      print('❌ Error initializing FCM: $e');
      print('Stack trace: ${StackTrace.current}');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      _showNotificationDialog(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked - app opened from background!');
      _showNotificationDialog(message);
    });
  }

  void _showNotificationDialog(RemoteMessage message) {
    // Determine notification type from data payload
    String notificationType = message.data['type'] ?? 'regular';
    bool isImportant = notificationType == 'important';

    // Get custom quote if available
    String quote = message.data['quote'] ?? message.notification?.body ?? 'No message';
    String title = message.notification?.title ?? 'Notification';

    // Build context
    BuildContext? dialogContext = navigatorKey.currentContext;
    if (dialogContext == null) return;

    showDialog(
      context: dialogContext,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isImportant
              ? Colors.red.shade900.withOpacity(0.95)
              : Colors.blue.shade900.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isImportant ? Colors.red.shade300 : Colors.blue.shade300,
              width: 2,
            ),
          ),
          title: Row(
            children: [
              Icon(
                isImportant ? Icons.priority_high : Icons.notifications,
                color: isImportant ? Colors.red.shade200 : Colors.blue.shade200,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isImportant)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'IMPORTANT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              if (isImportant) const SizedBox(height: 12),
              Text(
                quote,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontStyle: isImportant ? FontStyle.normal : FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Type: ${isImportant ? 'Important' : 'Regular'}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: isImportant
                    ? Colors.red.shade600
                    : Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Product Pulse',
      theme: getCatppuccinMochaTheme(),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData) {
            return const ProductListScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

// Global navigator key for showing dialogs from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
