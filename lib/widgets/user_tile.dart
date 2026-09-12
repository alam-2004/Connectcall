import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/user_model.dart';
import 'call_button.dart';

class UserTile extends StatelessWidget {
  final UserModel user;

  final VoidCallback onAudioCall;
  final VoidCallback onVideoCall;

  const UserTile({
    super.key,
    required this.user,
    required this.onAudioCall,
    required this.onVideoCall,
  });

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,

                backgroundColor: AppTheme.primaryColor.withOpacity(0.12),

                backgroundImage:
                    user.photoUrl != null && user.photoUrl!.isNotEmpty
                    ? NetworkImage(user.photoUrl!)
                    : null,

                child: user.photoUrl == null || user.photoUrl!.isEmpty
                    ? Text(
                        getInitials(user.name),

                        style: const TextStyle(
                          fontWeight: FontWeight.bold,

                          color: AppTheme.primaryColor,
                        ),
                      )
                    : null,
              ),

              Positioned(
                right: 0,
                bottom: 0,

                child: Container(
                  width: 15,
                  height: 15,

                  decoration: BoxDecoration(
                    color: user.isOnline ? AppTheme.successColor : Colors.grey,

                    shape: BoxShape.circle,

                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  user.name,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  user.isOnline ? 'Online' : 'Offline',

                  style: TextStyle(
                    fontSize: 13,

                    color: user.isOnline ? AppTheme.successColor : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          CallButton(
            icon: Icons.call_rounded,

            color: AppTheme.successColor,

            tooltip: 'Audio Call',

            onTap: onAudioCall,
          ),

          const SizedBox(width: 8),

          CallButton(
            icon: Icons.videocam_rounded,

            color: AppTheme.primaryColor,

            tooltip: 'Video Call',

            onTap: onVideoCall,
          ),
        ],
      ),
    );
  }
}
