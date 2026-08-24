import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.phone,
    super.role,
    super.avatarUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, {required String email}) {
    return UserModel(
      id: map['id'] as String,
      email: email,
      fullName: map['full_name'] as String?,
      phone: map['phone'] as String?,
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.customer,
      ),
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'role': role.name,
      'avatar_url': avatarUrl,
    };
  }
}
