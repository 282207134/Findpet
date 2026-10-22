import 'package:flutter/material.dart';

import 'core/app_state.dart';
import 'core/theme.dart';
import 'features/auth/auth_screens.dart';
import 'features/catalog/catalog_screens.dart';
import 'features/checkout/order_screen.dart';
import 'features/messages/message_screens.dart';
import 'features/profile/profile_screen.dart';
import 'features/publishing/upload_screens.dart';

class FindpetApp extends StatelessWidget {
  const FindpetApp({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: MaterialApp(
      title: 'Findpet',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      builder: (context, child) => ColoredBox(
        color: const Color(0xFFF4F1ED),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child!,
          ),
        ),
      ),
      home: const EntryScreen(),
    ),
  );
}

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (!state.onboarded) return const WelcomeFlow();
    if (!state.signedIn) return const AuthScreen();
    return const Dashboard();
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int index = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: index,
      children: const [
        HomeScreen(),
        MessagesScreen(),
        UploadScreen(),
        OrdersScreen(),
        ProfileScreen(),
      ],
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Container(
        height: 76,
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final (i, icon, label) in [
              (0, Icons.home_outlined, 'Home'),
              (1, Icons.mail_outline_rounded, 'Messages'),
              (2, Icons.add_box_outlined, 'Upload'),
              (3, Icons.receipt_long_outlined, 'Orders'),
              (4, Icons.person_outline_rounded, 'Profile'),
            ])
              Semantics(
                selected: index == i,
                button: true,
                label: label,
                child: IconButton(
                  key: ValueKey('nav-$label'),
                  tooltip: label,
                  onPressed: () => setState(() => index = i),
                  style: IconButton.styleFrom(
                    backgroundColor: index == i ? cream : Colors.transparent,
                    fixedSize: const Size(54, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: Icon(
                    icon,
                    size: 28,
                    color: index == i ? orange : const Color(0xFFCED2D3),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
