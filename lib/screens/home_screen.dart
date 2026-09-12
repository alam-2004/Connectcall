import 'package:connectcall/screens/a.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:connectcall/screens/call_history_screen.dart';
import 'package:connectcall/screens/contacts_screen.dart';
import 'package:connectcall/screens/profile_screen.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openContacts() {
    _changeTab(1);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _DashboardScreen(onNavigate: _changeTab, onOpenContacts: _openContacts),

      const ContactsScreen(),

      const CallHistoryScreen(),

      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),

      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: _currentIndex,
        onDestinationSelected: _changeTab,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Contacts',
          ),

          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Calls',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// DASHBOARD
// =====================================================

class _DashboardScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  final VoidCallback onOpenContacts;

  const _DashboardScreen({
    required this.onNavigate,
    required this.onOpenContacts,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello 👋',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.15),

                  child: const Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(24),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.phone_in_talk,
                    color: Colors.white,
                    size: 35,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Connect with\nanyone, anywhere.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Make secure audio and video calls.',
                    style: TextStyle(color: Colors.white.withOpacity(0.85)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.people_alt_outlined,
                    title: 'Contacts',
                    subtitle: 'Find people',
                    onTap: () {
                      onNavigate(1);
                    },
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.history_outlined,
                    title: 'Call History',
                    subtitle: 'Recent calls',
                    onTap: () {
                      onNavigate(2);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'Getting Started',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // ADD FRIEND
            _InfoTile(
              icon: Icons.person_add_alt_1,
              title: 'Add Your Friend',
              subtitle: 'Add a friend to your Connect list.',

              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddFriendScreen()),
                );

                if (result == true) {
                  onNavigate(1);
                }
              },
            ),

            _InfoTile(
              icon: Icons.call_outlined,
              title: 'Start calling',
              subtitle: 'Use audio or video call buttons.',
              onTap: () {
                onNavigate(1);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 28),

              const SizedBox(height: 15),

              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Material(
        color: Colors.white,
        elevation: 1,
        borderRadius: BorderRadius.circular(16),

        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),

          child: Padding(
            padding: const EdgeInsets.all(15),

            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Icon(icon, color: AppTheme.primaryColor),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
