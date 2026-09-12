import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  String _countryCode = '+91';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ============================================================
  // NORMALIZE PHONE
  // ============================================================

  String _normalizePhone(String phone) {
    String number = phone.replaceAll(RegExp(r'[^0-9]'), '');

    String code = _countryCode.replaceAll('+', '');

    // Agar user ne country code bhi likh diya
    if (number.startsWith(code)) {
      return '+$number';
    }

    return '+$code$number';
  }

  // ============================================================
  // ADD CONTACT
  // ============================================================

  Future<void> _addContact() async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      _showMessage('Please login first.');
      return;
    }

    final enteredName = _nameController.text.trim();
    final enteredPhone = _phoneController.text.trim();

    // ==========================================================
    // VALIDATION
    // ==========================================================

    if (enteredName.isEmpty) {
      _showMessage('Please enter friend name.');
      return;
    }

    if (enteredPhone.isEmpty) {
      _showMessage('Please enter phone number.');
      return;
    }

    final digits = enteredPhone.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length < 6) {
      _showMessage('Please enter a valid phone number.');
      return;
    }

    final fullPhone = _normalizePhone(enteredPhone);

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('================================');
      debugPrint('ADD FRIEND');
      debugPrint('PHONE: $fullPhone');
      debugPrint('================================');

      // ========================================================
      // SEARCH REGISTERED USER
      // ========================================================

      final userQuery = await _firestore
          .collection('users')
          .where('phone', isEqualTo: fullPhone)
          .limit(1)
          .get();

      String? registeredUid;

      String finalName = enteredName;

      String finalEmail = '';

      bool isRegistered = false;

      // ========================================================
      // USER FOUND
      // ========================================================

      if (userQuery.docs.isNotEmpty) {
        final userDoc = userQuery.docs.first;

        final userData = userDoc.data();

        registeredUid = userDoc.id;

        isRegistered = true;

        finalName = (userData['name'] ?? enteredName).toString();

        finalEmail = (userData['email'] ?? '').toString();

        // Don't add yourself
        if (registeredUid == currentUser.uid) {
          _showMessage('You cannot add yourself.');

          setState(() {
            _isLoading = false;
          });

          return;
        }
      }

      // ========================================================
      // CHECK DUPLICATE
      // ========================================================

      final duplicateQuery = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('contacts')
          .where('phone', isEqualTo: fullPhone)
          .limit(1)
          .get();

      if (duplicateQuery.docs.isNotEmpty) {
        _showMessage('This number is already in your contacts.');

        setState(() {
          _isLoading = false;
        });

        return;
      }

      // ========================================================
      // CREATE CONTACT DOCUMENT ID
      // ========================================================

      final String contactId;

      if (isRegistered && registeredUid != null) {
        contactId = registeredUid;
      } else {
        contactId = _firestore.collection('users').doc().id;
      }

      // ========================================================
      // SAVE CONTACT
      // ========================================================

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('contacts')
          .doc(contactId)
          .set({
            'uid': registeredUid ?? '',
            'name': finalName,
            'phone': fullPhone,
            'email': finalEmail,
            'isRegistered': isRegistered,
            'countryCode': _countryCode,
            'addedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      // ========================================================
      // SUCCESS DIALOG
      // ========================================================

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: Icon(Icons.check_circle, color: Colors.green, size: 50),

            title: const Text('Contact Added!'),

            content: Text(
              isRegistered
                  ? '$finalName is now connected with you.\n\nYou can now make Audio and Video calls.'
                  : '$finalName has been added to your contacts.\n\nThis person is not registered on ConnectCall yet.',
            ),

            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Open Contacts'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('ADD CONTACT ERROR: $e');

      _showMessage('Error: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Your Friend',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 20),

              // ==================================================
              // ICON
              // ==================================================
              CircleAvatar(
                radius: 50,
                child: const Icon(Icons.person_add_alt_1, size: 50),
              ),

              const SizedBox(height: 20),

              const Text(
                'Add Your Friend',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                'Add a friend to your ConnectCall contacts',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 35),

              // ==================================================
              // NAME
              // ==================================================
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,

                decoration: InputDecoration(
                  labelText: 'Friend Name',
                  hintText: 'Enter friend name',
                  prefixIcon: const Icon(Icons.person_outline),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // COUNTRY + PHONE
              // ==================================================
              Row(
                children: [
                  SizedBox(
                    width: 105,

                    child: DropdownButtonFormField<String>(
                      value: _countryCode,

                      decoration: InputDecoration(
                        labelText: 'Code',

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      items: const [
                        DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91')),

                        DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),

                        DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),

                        DropdownMenuItem(
                          value: '+971',
                          child: Text('🇦🇪 +971'),
                        ),
                      ],

                      onChanged: _isLoading
                          ? null
                          : (value) {
                              if (value == null) return;

                              setState(() {
                                _countryCode = value;
                              });
                            },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: TextField(
                      controller: _phoneController,

                      keyboardType: TextInputType.phone,

                      maxLength: _countryCode == '+91' ? 10 : null,

                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '9634XXXXXX',
                        counterText: '',

                        prefixIcon: const Icon(Icons.phone_outlined),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ==================================================
              // PHONE PREVIEW
              // ==================================================
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _phoneController,

                builder: (context, value, child) {
                  final number = value.text.replaceAll(RegExp(r'[^0-9]'), '');

                  if (number.isEmpty) {
                    return const SizedBox();
                  }

                  final fullNumber = _normalizePhone(number);

                  return Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Row(
                      children: [
                        const Icon(Icons.phone, size: 20),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            fullNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 35),

              // ==================================================
              // ADD BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,
                height: 55,

                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _addContact,

                  icon: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,

                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add),

                  label: Text(_isLoading ? 'Adding Friend...' : 'Add Friend'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
