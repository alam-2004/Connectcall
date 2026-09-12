class UserModel {
  final String uid;

  final String name;

  final String email;

  // PHONE NUMBER
  final String phone;

  final String? photoUrl;

  final bool isOnline;

  UserModel({
    required this.uid,

    required this.name,

    required this.email,

    required this.phone,

    this.photoUrl,

    this.isOnline = false,
  });

  // ============================================================
  // CONVERT TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,

      'name': name,

      'email': email,

      // SAVE PHONE
      'phone': phone,

      'photoUrl': photoUrl,

      'isOnline': isOnline,
    };
  }

  // ============================================================
  // CREATE FROM FIRESTORE MAP
  // ============================================================

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',

      name: map['name'] ?? '',

      email: map['email'] ?? '',

      // GET PHONE
      phone: map['phone'] ?? '',

      photoUrl: map['photoUrl'],

      isOnline: map['isOnline'] ?? false,
    );
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  UserModel copyWith({
    String? uid,

    String? name,

    String? email,

    String? phone,

    String? photoUrl,

    bool? isOnline,
  }) {
    return UserModel(
      uid: uid ?? this.uid,

      name: name ?? this.name,

      email: email ?? this.email,

      phone: phone ?? this.phone,

      photoUrl: photoUrl ?? this.photoUrl,

      isOnline: isOnline ?? this.isOnline,
    );
  }
}
