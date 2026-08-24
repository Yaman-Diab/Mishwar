import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:mashwar_core/mashwar_core.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String identifier,
    required String password,
    required String fullName,
  }) async {
    try {
      final user = await _remoteDataSource.signUp(
        identifier: identifier,
        password: password,
        fullName: fullName,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String identifier,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signIn(
        identifier: identifier,
        password: password,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset({required String identifier}) async {
    try {
      await _remoteDataSource.requestPasswordReset(identifier);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> verifyPasswordResetCode({
    required String identifier,
    required String code,
  }) async {
    try {
      await _remoteDataSource.verifyPasswordResetCode(identifier, code);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({required String newPassword}) async {
    try {
      await _remoteDataSource.updatePassword(newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
