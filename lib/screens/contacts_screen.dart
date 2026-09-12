import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:connectcall/core/constants/app_constants.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// ============================================================
// CONTACTS SCREEN
// ============================================================

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // CREATE CALL ID
  // ============================================================

  String _createCallID(String uid1, String uid2) {
    final ids = [uid1, uid2];

    ids.sort();

    return 'connectcall_${ids[0]}_${ids[1]}';
  }

  // ============================================================
  // START AUDIO CALL
  // ============================================================

  void _startAudioCall({
    required String targetUid,
    required String targetName,
    required bool isRegistered,
  }) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      _showMessage('Please login first.');
      return;
    }

    if (!isRegistered || targetUid.isEmpty) {
      _showMessage('$targetName is not registered on ConnectCall yet.');
      return;
    }

    final callID = _createCallID(currentUser.uid, targetUid);

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) {
          return ZegoUIKitPrebuiltCall(
            appID: ZegoConfig.appID,

            appSign: ZegoConfig.appSign,

            userID: currentUser.uid,

            userName: currentUser.displayName ?? 'User',

            callID: callID,

            config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
          );
        },
      ),
    );
  }

  // ============================================================
  // START VIDEO CALL
  // ============================================================

  void _startVideoCall({
    required String targetUid,
    required String targetName,
    required bool isRegistered,
  }) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      _showMessage('Please login first.');
      return;
    }

    if (!isRegistered || targetUid.isEmpty) {
      _showMessage('$targetName is not registered on ConnectCall yet.');
      return;
    }

    final callID = _createCallID(currentUser.uid, targetUid);

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) {
          return ZegoUIKitPrebuiltCall(
            appID: ZegoConfig.appID,

            appSign: ZegoConfig.appSign,

            userID: currentUser.uid,

            userName: currentUser.displayName ?? 'User',

            callID: callID,

            config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
          );
        },
      ),
    );
  }

  // ============================================================
  // DELETE CONTACT
  // ============================================================

  Future<void> _deleteContact(String contactId, String contactName) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Contact'),

          content: Text('Remove $contactName from your contacts?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('contacts')
          .doc(contactId)
          .delete();

      _showMessage('Contact deleted successfully.');
    } catch (e) {
      _showMessage('Error deleting contact.');
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // CONTACT CARD
  // ============================================================

  Widget _buildContactCard(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? {};

    final contactId = document.id;

    final uid = (data['uid'] ?? '').toString();

    final name = (data['name'] ?? 'Unknown User').toString();

    final phone = (data['phone'] ?? '').toString();

    final email = (data['email'] ?? '').toString();

    final isRegistered = data['isRegistered'] == true && uid.isNotEmpty;

    // ==========================================================
    // SEARCH
    // ==========================================================

    if (_searchText.isNotEmpty) {
      final search = _searchText.toLowerCase();

      final matches =
          name.toLowerCase().contains(search) ||
          phone.contains(search) ||
          email.toLowerCase().contains(search);

      if (!matches) {
        return const SizedBox();
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          children: [
            // ==================================================
            // AVATAR
            // ==================================================
            CircleAvatar(
              radius: 28,

              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',

                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ==================================================
            // DETAILS
            // ==================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // REGISTERED BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),

                        decoration: BoxDecoration(
                          color: isRegistered
                              ? Colors.green.withOpacity(0.12)
                              : Colors.orange.withOpacity(0.12),

                          borderRadius: BorderRadius.circular(8),
                        ),

                        child: Text(
                          isRegistered ? 'Connected' : 'Not Registered',

                          style: TextStyle(
                            fontSize: 10,

                            fontWeight: FontWeight.bold,

                            color: isRegistered ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    phone,

                    style: TextStyle(
                      fontSize: 13,

                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  if (email.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),

                      child: Text(
                        email,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: 11,

                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ==================================================
            // CALL BUTTONS
            // ==================================================
            Column(
              children: [
                // AUDIO
                IconButton(
                  tooltip: 'Audio Call',

                  onPressed: () {
                    _startAudioCall(
                      targetUid: uid,

                      targetName: name,

                      isRegistered: isRegistered,
                    );
                  },

                  icon: Icon(
                    Icons.call,

                    color: isRegistered ? Colors.green : Colors.grey,
                  ),
                ),

                // VIDEO
                IconButton(
                  tooltip: 'Video Call',

                  onPressed: () {
                    _startVideoCall(
                      targetUid: uid,

                      targetName: name,

                      isRegistered: isRegistered,
                    );
                  },

                  icon: Icon(
                    Icons.videocam,

                    color: isRegistered ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),

            // ==================================================
            // MENU
            // ==================================================
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteContact(contactId, name);
                }
              },

              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: 'delete',

                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),

                        SizedBox(width: 8),

                        Text('Delete'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please login first.')));
    }

    return Scaffold(
      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        title: const Text(
          'Connect',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: Column(
        children: [
          // ======================================================
          // SEARCH
          // ======================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),

            child: TextField(
              controller: _searchController,

              onChanged: (value) {
                setState(() {
                  _searchText = value.trim();
                });
              },

              decoration: InputDecoration(
                hintText: 'Search contacts...',

                prefixIcon: const Icon(Icons.search),

                suffixIcon: _searchText.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),

                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _searchText = '';
                          });
                        },
                      ),

                filled: true,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),

                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ======================================================
          // CONTACT LIST
          // ======================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('contacts')
                  .orderBy('addedAt', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),

                      child: Text(
                        'Error loading contacts:\n\n'
                        '${snapshot.error}',

                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final documents = snapshot.data?.docs ?? [];

                // ================================================
                // EMPTY
                // ================================================

                if (documents.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Icon(
                            Icons.people_outline,

                            size: 70,

                            color: Theme.of(context).colorScheme.primary,
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'No contacts yet',

                            style: TextStyle(
                              fontSize: 20,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Go to Home and tap Add Your Friends to add a contact.',

                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ================================================
                // LIST
                // ================================================

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 5, bottom: 100),

                  itemCount: documents.length,

                  itemBuilder: (context, index) {
                    return _buildContactCard(documents[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
