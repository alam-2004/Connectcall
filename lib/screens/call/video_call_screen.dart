import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/call_model.dart';
import '../../models/user_model.dart';
import '../../providers/call_provider.dart';

class VideoCallScreen extends StatefulWidget {
  final UserModel user;

  final CallModel call;

  const VideoCallScreen({super.key, required this.user, required this.call});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      context.read<CallProvider>().connectCall();
    });
  }

  @override
  Widget build(BuildContext context) {
    final callProvider = context.watch<CallProvider>();

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Stack(
          children: [
            /// Remote Video Placeholder
            Positioned.fill(
              child: Container(
                color: Colors.grey.shade900,

                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      CircleAvatar(
                        radius: 60,

                        backgroundColor: AppTheme.primaryColor,

                        backgroundImage:
                            widget.user.photoUrl != null &&
                                widget.user.photoUrl!.isNotEmpty
                            ? NetworkImage(widget.user.photoUrl!)
                            : null,

                        child: widget.user.photoUrl == null
                            ? Text(
                                widget.user.name[0].toUpperCase(),

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                ),
                              )
                            : null,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        widget.user.name,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        callProvider.currentCall?.status == CallStatus.connected
                            ? callProvider.formattedDuration()
                            : 'Connecting...',

                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// Local Camera Preview Placeholder
            Positioned(
              top: 20,
              right: 20,

              child: Container(
                width: 110,
                height: 150,

                decoration: BoxDecoration(
                  color: Colors.grey.shade800,

                  borderRadius: BorderRadius.circular(16),

                  border: Border.all(color: Colors.white24),
                ),

                child: callProvider.isCameraOn
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Icon(Icons.person, color: Colors.white, size: 45),

                          SizedBox(height: 8),

                          Text('You', style: TextStyle(color: Colors.white)),
                        ],
                      )
                    : const Icon(Icons.videocam_off, color: Colors.white),
              ),
            ),

            /// Bottom Controls
            Positioned(
              left: 0,
              right: 0,
              bottom: 30,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  _VideoControl(
                    icon: callProvider.isMuted ? Icons.mic_off : Icons.mic,

                    onTap: () {
                      context.read<CallProvider>().toggleMute();
                    },
                  ),

                  _VideoControl(
                    icon: callProvider.isCameraOn
                        ? Icons.videocam
                        : Icons.videocam_off,

                    onTap: () {
                      context.read<CallProvider>().toggleCamera();
                    },
                  ),

                  _VideoControl(
                    icon: Icons.flip_camera_ios,

                    onTap: () {
                      context.read<CallProvider>().switchCamera();
                    },
                  ),

                  _VideoControl(
                    icon: Icons.call_end,

                    backgroundColor: AppTheme.dangerColor,

                    onTap: () async {
                      await context.read<CallProvider>().endCurrentCall();

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoControl extends StatelessWidget {
  final IconData icon;

  final Color? backgroundColor;

  final VoidCallback onTap;

  const _VideoControl({
    required this.icon,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(50),

      child: Container(
        width: 58,
        height: 58,

        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white24,

          shape: BoxShape.circle,
        ),

        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
