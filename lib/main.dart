import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'features/login_page_new.dart';
import 'features/bottomnavbar.dart';
import 'features/admin/admin_page.dart';
import 'features/welcome_page.dart';
import 'providers/block_provider.dart';
import 'config/admin_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => BlockProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            final uid = snapshot.data!.uid;

            // Admin bypasses ban check entirely
            if (uid == kAdminUid) {
              return const AdminPage();
            }

            // For regular users, check ban status before routing
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final data =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final banned = data['banned'] as bool? ?? false;

                  if (banned) {
                    // Sign out and return to login with a ban message
                    Future.microtask(() async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Your account has been banned. Please contact support.',
                          ),
                          backgroundColor: Color(0xFFEF4444),
                          duration: Duration(seconds: 5),
                        ),
                      );
                    });
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                }

                // Not banned — load blocked users and go to app
                Future.microtask(
                  () => context.read<BlockProvider>().loadBlockedUsers(),
                );
                return const AppBottomNavBar();
              },
            );
          }

          Future.microtask(() => context.read<BlockProvider>().clear());
          return const WelcomePage();
        },
      ),
    );
  }
}
