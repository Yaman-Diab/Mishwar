import 'package:equatable/equatable.dart';

enum UserRole { customer, owner, admin }

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? fullName;
  final String? phone;
  final UserRole role;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.role = UserRole.customer,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, fullName, phone, role, avatarUrl];
}
