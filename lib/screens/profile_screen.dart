import 'package:connectcall/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String getInitials(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    await authProvider.logout();

    if (!context.mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 10),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),

              // PROFILE IMAGE
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,

                    backgroundColor: AppTheme.primaryColor.withOpacity(0.15),

                    backgroundImage:
                        user.photoUrl != null && user.photoUrl!.isNotEmpty
                        ? NetworkImage(user.photoUrl!)
                        : null,

                    child: user.photoUrl == null || user.photoUrl!.isEmpty
                        ? Text(
                            getInitials(user.name),
                            style: const TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          )
                        : null,
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,

                    child: Material(
                      color: AppTheme.successColor,
                      shape: const CircleBorder(),

                      child: InkWell(
                        customBorder: const CircleBorder(),

                        onTap: () {
                          _showMessage(
                            context,
                            'Profile photo editing coming soon',
                          );
                        },

                        child: const Padding(
                          padding: EdgeInsets.all(9),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                user.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                user.email,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),

              const SizedBox(height: 35),

              // USER INFORMATION
              _ProfileCard(
                children: [
                  _ProfileItem(
                    icon: Icons.person_outline,
                    title: 'Full Name',
                    value: user.name,
                  ),

                  const Divider(height: 1),

                  _ProfileItem(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: user.email,
                  ),

                  const Divider(height: 1),

                  _ProfileItem(
                    icon: Icons.circle,
                    title: 'Status',
                    value: user.isOnline ? 'Online' : 'Offline',
                    valueColor: user.isOnline
                        ? AppTheme.successColor
                        : Colors.grey,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // SETTINGS
              _ProfileCard(
                children: [
                  _ProfileButton(
                    icon: Icons.security_outlined,
                    title: 'Privacy',
                    onTap: () {
                      _showMessage(context, 'Privacy settings coming soon');
                    },
                  ),

                  const Divider(height: 1),

                  _ProfileButton(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      _showMessage(
                        context,
                        'Notification settings coming soon',
                      );
                    },
                  ),

                  const Divider(height: 1),

                  _ProfileButton(
                    icon: Icons.info_outline,
                    title: 'About App',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'ConnectCall',
                        applicationVersion: '1.0.0',
                        applicationLegalese: 'Audio & Video Calling App',
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // LOGOUT BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.dangerColor,
                    foregroundColor: Colors.white,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  icon: authProvider.isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.logout),

                  label: authProvider.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                  onPressed: authProvider.isLoading
                      ? null
                      : () => _logout(context),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================
// PROFILE CARD
// ===============================

class _ProfileCard extends StatelessWidget {
  final List<Widget> children;

  const _ProfileCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      elevation: 2,

      shadowColor: Colors.black.withOpacity(0.08),

      borderRadius: BorderRadius.circular(18),

      clipBehavior: Clip.antiAlias,

      child: Column(children: children),
    );
  }
}

// ===============================
// PROFILE INFORMATION ITEM
// ===============================

class _ProfileItem extends StatelessWidget {
  final IconData icon;

  final String title;

  final String value;

  final Color? valueColor;

  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),

              shape: BoxShape.circle,
            ),

            child: Icon(icon, color: AppTheme.primaryColor, size: 21),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================
// PROFILE BUTTON
// ===============================

class _ProfileButton extends StatelessWidget {
  final IconData icon;

  final String title;

  final VoidCallback onTap;

  const _ProfileButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,

      splashColor: AppTheme.primaryColor.withOpacity(0.10),

      hoverColor: AppTheme.primaryColor.withOpacity(0.05),

      leading: Container(
        width: 42,
        height: 42,

        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),

          shape: BoxShape.circle,
        ),

        child: Icon(icon, color: AppTheme.primaryColor, size: 21),
      ),

      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),

      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade500),
    );
  }
}
