class UserModel {
  final int? id;
  final String username;
  final String pinHash;
  final String salt;
  final String role;
  final String createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.pinHash,
    required this.salt,
    this.role = 'docente',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'pin_hash': pinHash,
      'salt': salt,
      'role': role,
      'created_at': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      pinHash: map['pin_hash'] as String,
      salt: map['salt'] as String,
      role: map['role'] as String? ?? 'docente',
      createdAt: map['created_at'] as String,
    );
  }
}
