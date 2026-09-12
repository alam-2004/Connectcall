import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/call_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/calling_service.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().user;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login first', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 15),

              // =====================================================
              // HEADER
              // =====================================================
              const Row(
                children: [
                  Text(
                    'Call History',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  Spacer(),

                  Icon(Icons.history, color: AppTheme.primaryColor, size: 28),
                ],
              ),

              const SizedBox(height: 20),

              // =====================================================
              // CALL HISTORY
              // =====================================================
              Expanded(
                child: StreamBuilder<List<CallModel>>(
                  stream: CallingService().getCallHistory(currentUser.uid),

                  builder: (context, snapshot) {
                    // =================================================
                    // ERROR
                    // =================================================

                    if (snapshot.hasError) {
                      return _buildErrorState(snapshot.error.toString());
                    }

                    // =================================================
                    // LOADING
                    // =================================================

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final calls = snapshot.data ?? [];

                    // =================================================
                    // NO HISTORY MESSAGE
                    // =================================================

                    if (calls.isEmpty) {
                      return _buildEmptyState();
                    }

                    // =================================================
                    // HISTORY LIST
                    // =================================================

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),

                      padding: const EdgeInsets.only(bottom: 100),

                      itemCount: calls.length,

                      itemBuilder: (context, index) {
                        return _CallHistoryTile(
                          call: calls[index],
                          currentUser: currentUser,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // EMPTY STATE
  // ===============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 110,
              height: 110,

              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.call_outlined,
                size: 50,
                color: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'No Call History Yet',
              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              'Your audio and video calls will appear here.\n'
              'Start calling your contacts!',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ERROR STATE
  // ===============================================================

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.error_outline, size: 55, color: Colors.red),

            const SizedBox(height: 15),

            const Text(
              'Unable to Load Call History',
              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              error,
              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// CALL HISTORY TILE
// =================================================================

class _CallHistoryTile extends StatelessWidget {
  final CallModel call;
  final UserModel currentUser;

  const _CallHistoryTile({required this.call, required this.currentUser});

  // ===============================================================
  // OUTGOING OR INCOMING
  // ===============================================================

  bool get isOutgoing {
    return call.callerId == currentUser.uid;
  }

  // ===============================================================
  // OTHER USER NAME
  // ===============================================================

  String get otherUserName {
    final name = isOutgoing ? call.receiverName : call.callerName;

    if (name.isEmpty) {
      return 'Unknown User';
    }

    return name;
  }

  // ===============================================================
  // CALL ICON
  // ===============================================================

  IconData get callIcon {
    if (call.status == CallStatus.missed) {
      return Icons.call_missed;
    }

    if (call.status == CallStatus.rejected) {
      return Icons.call_missed_outgoing;
    }

    if (call.type == CallType.video) {
      return Icons.videocam;
    }

    return isOutgoing ? Icons.call_made : Icons.call_received;
  }

  // ===============================================================
  // CALL COLOR
  // ===============================================================

  Color get callColor {
    if (call.status == CallStatus.missed ||
        call.status == CallStatus.rejected) {
      return AppTheme.dangerColor;
    }

    if (call.status == CallStatus.connected ||
        call.status == CallStatus.ended) {
      return AppTheme.successColor;
    }

    return AppTheme.primaryColor;
  }

  // ===============================================================
  // CALL STATUS
  // ===============================================================

  String get callStatusText {
    if (call.status == CallStatus.missed) {
      return 'Missed Call';
    }

    if (call.status == CallStatus.rejected) {
      return 'Rejected Call';
    }

    if (call.status == CallStatus.connected) {
      return 'Connected';
    }

    if (call.status == CallStatus.ended) {
      return 'Completed';
    }

    return call.type == CallType.video ? 'Video Call' : 'Audio Call';
  }

  // ===============================================================
  // DATE AND TIME
  // ===============================================================

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final callDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final difference = today.difference(callDay).inDays;

    if (difference == 0) {
      return 'Today, ${formatTime(dateTime)}';
    }

    if (difference == 1) {
      return 'Yesterday, ${formatTime(dateTime)}';
    }

    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

  // ===============================================================
  // TIME FORMAT
  // ===============================================================

  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = hour >= 12 ? 'PM' : 'AM';

    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:$minute $period';
  }

  // ===============================================================
  // CALL DURATION
  // ===============================================================

  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;

    final minutes = (seconds % 3600) ~/ 60;

    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${remainingSeconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // ===============================================================
  // BUILD TILE
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final isVideoCall = call.type == CallType.video;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          // =========================================================
          // LEFT ICON
          // =========================================================
          Container(
            width: 54,
            height: 54,

            decoration: BoxDecoration(
              color: callColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),

            child: Icon(callIcon, color: callColor, size: 26),
          ),

          const SizedBox(width: 14),

          // =========================================================
          // CALL DETAILS
          // =========================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  otherUserName,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Icon(
                      isVideoCall
                          ? Icons.videocam_outlined
                          : Icons.call_outlined,

                      size: 15,

                      color: Colors.grey.shade600,
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(
                        callStatusText,

                        style: TextStyle(
                          fontSize: 13,
                          color: callColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  formatDateTime(call.createdAt),

                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // =========================================================
          // CALL TYPE + DURATION
          // =========================================================
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Container(
                padding: const EdgeInsets.all(7),

                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.08),

                  shape: BoxShape.circle,
                ),

                child: Icon(
                  isVideoCall ? Icons.videocam : Icons.call,

                  size: 18,

                  color: AppTheme.primaryColor,
                ),
              ),

              const SizedBox(height: 8),

              if (call.duration > 0)
                Text(
                  formatDuration(call.duration),

                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                )
              else
                Text(
                  call.status == CallStatus.missed ? 'Missed' : '',

                  style: TextStyle(fontSize: 10, color: callColor),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
