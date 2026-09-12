import 'package:connectcall/screens/call/audio_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/call_model.dart';
import '../../models/user_model.dart';
import '../../providers/call_provider.dart';


class IncomingCallScreen extends StatelessWidget {
final CallModel call;
final UserModel caller;

const IncomingCallScreen({
super.key,
required this.call,
required this.caller,
});

Future<void> _acceptCall(BuildContext context) async {
final callProvider = context.read<CallProvider>();

await callProvider.acceptCall(call);

if (!context.mounted) return;

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => CallScreen(
      callID: call.id,
      userID: call.receiverId,
      userName: call.receiverName,
      isVideoCall: call.type == CallType.video,
    ),
  ),
);


}

Future<void> _rejectCall(BuildContext context) async {
await context.read<CallProvider>().rejectCurrentCall();
if (!context.mounted) return;

Navigator.pop(context);

}

@override
Widget build(BuildContext context) {
final photoUrl = caller.photoUrl ?? '';
final name = caller.name.isNotEmpty
? caller.name
: 'Unknown';

return Scaffold(
  backgroundColor: AppTheme.darkColor,
  body: SafeArea(
    child: Column(
      children: [
        const SizedBox(height: 70),

        Text(
          call.type == CallType.video
              ? 'Incoming Video Call'
              : 'Incoming Audio Call',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 35),

        CircleAvatar(
          radius: 75,
          backgroundColor: AppTheme.primaryColor,
          backgroundImage: photoUrl.isNotEmpty
              ? NetworkImage(photoUrl)
              : null,
          child: photoUrl.isEmpty
              ? Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),

        const SizedBox(height: 25),

        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Spacer(),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _CallButton(
                icon: Icons.call_end,
                text: 'Decline',
                color: AppTheme.dangerColor,
                onTap: () => _rejectCall(context),
              ),

              _CallButton(
                icon: call.type == CallType.video
                    ? Icons.videocam
                    : Icons.call,
                text: 'Accept',
                color: AppTheme.successColor,
                onTap: () => _acceptCall(context),
              ),
            ],
          ),
        ),

        const SizedBox(height: 60),
      ],
    ),
  ),
);


}
}

class _CallButton extends StatelessWidget {
final IconData icon;
final String text;
final Color color;
final VoidCallback onTap;

const _CallButton({
required this.icon,
required this.text,
required this.color,
required this.onTap,
});

@override
Widget build(BuildContext context) {
return Column(
children: [
InkWell(
onTap: onTap,
borderRadius: BorderRadius.circular(50),
child: Container(
width: 70,
height: 70,
decoration: BoxDecoration(
color: color,
shape: BoxShape.circle,
),
child: Icon(
icon,
color: Colors.white,
size: 30,
),
),
),


    const SizedBox(height: 10),

    Text(
      text,
      style: const TextStyle(
        color: Colors.white,
      ),
    ),
  ],
);


}
}
