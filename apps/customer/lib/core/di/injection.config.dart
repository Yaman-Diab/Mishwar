// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_current_user.dart' as _i111;
import '../../features/auth/domain/usecases/request_password_reset.dart'
    as _i956;
import '../../features/auth/domain/usecases/sign_in.dart' as _i920;
import '../../features/auth/domain/usecases/sign_out.dart' as _i568;
import '../../features/auth/domain/usecases/sign_up.dart' as _i190;
import '../../features/auth/domain/usecases/update_password.dart' as _i455;
import '../../features/auth/domain/usecases/verify_password_reset_code.dart'
    as _i717;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/auth/presentation/cubit/password_reset_cubit.dart'
    as _i271;
import '../../features/booking/data/datasources/booking_remote_datasource.dart'
    as _i810;
import '../../features/booking/data/repositories/booking_repository_impl.dart'
    as _i265;
import '../../features/booking/domain/repositories/booking_repository.dart'
    as _i912;
import '../../features/booking/domain/usecases/cancel_booking_request.dart'
    as _i38;
import '../../features/booking/domain/usecases/get_booking_status.dart'
    as _i360;
import '../../features/booking/domain/usecases/get_farm_availability.dart'
    as _i607;
import '../../features/booking/domain/usecases/request_booking.dart' as _i184;
import '../../features/booking/presentation/cubit/booking_cubit.dart' as _i329;
import '../../features/my_bookings/domain/usecases/get_my_bookings.dart'
    as _i609;
import '../../features/my_bookings/presentation/cubit/my_bookings_cubit.dart'
    as _i1009;
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart'
    as _i804;
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart'
    as _i452;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i430;
import '../../features/onboarding/domain/usecases/has_seen_onboarding.dart'
    as _i81;
import '../../features/onboarding/domain/usecases/mark_onboarding_seen.dart'
    as _i522;
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart'
    as _i807;
import '../../features/reviews/data/datasources/review_remote_datasource.dart'
    as _i130;
import '../../features/reviews/data/repositories/review_repository_impl.dart'
    as _i29;
import '../../features/reviews/domain/repositories/review_repository.dart'
    as _i985;
import '../../features/reviews/domain/usecases/submit_review.dart' as _i225;
import '../../features/reviews/presentation/cubit/submit_review_cubit.dart'
    as _i488;
import '../../features/splash/presentation/cubit/splash_cubit.dart' as _i125;
import 'injection.dart' as _i464;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i804.OnboardingLocalDataSource>(
      () => _i804.OnboardingLocalDataSource(),
    );
    gh.lazySingleton<_i430.OnboardingRepository>(
      () =>
          _i452.OnboardingRepositoryImpl(gh<_i804.OnboardingLocalDataSource>()),
    );
    gh.lazySingleton<_i161.AuthRemoteDataSource>(
      () => _i161.AuthRemoteDataSource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i810.BookingRemoteDataSource>(
      () => _i810.BookingRemoteDataSource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i130.ReviewRemoteDataSource>(
      () => _i130.ReviewRemoteDataSource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i912.BookingRepository>(
      () => _i265.BookingRepositoryImpl(gh<_i810.BookingRemoteDataSource>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(gh<_i161.AuthRemoteDataSource>()),
    );
    gh.factory<_i111.GetCurrentUser>(
      () => _i111.GetCurrentUser(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i956.RequestPasswordReset>(
      () => _i956.RequestPasswordReset(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i920.SignIn>(() => _i920.SignIn(gh<_i787.AuthRepository>()));
    gh.factory<_i568.SignOut>(() => _i568.SignOut(gh<_i787.AuthRepository>()));
    gh.factory<_i190.SignUp>(() => _i190.SignUp(gh<_i787.AuthRepository>()));
    gh.factory<_i455.UpdatePassword>(
      () => _i455.UpdatePassword(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i717.VerifyPasswordResetCode>(
      () => _i717.VerifyPasswordResetCode(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i985.ReviewRepository>(
      () => _i29.ReviewRepositoryImpl(gh<_i130.ReviewRemoteDataSource>()),
    );
    gh.factory<_i81.HasSeenOnboarding>(
      () => _i81.HasSeenOnboarding(gh<_i430.OnboardingRepository>()),
    );
    gh.factory<_i522.MarkOnboardingSeen>(
      () => _i522.MarkOnboardingSeen(gh<_i430.OnboardingRepository>()),
    );
    gh.factory<_i125.SplashCubit>(
      () => _i125.SplashCubit(gh<_i81.HasSeenOnboarding>()),
    );
    gh.factory<_i807.OnboardingCubit>(
      () => _i807.OnboardingCubit(gh<_i522.MarkOnboardingSeen>()),
    );
    gh.factory<_i271.PasswordResetCubit>(
      () => _i271.PasswordResetCubit(
        gh<_i956.RequestPasswordReset>(),
        gh<_i717.VerifyPasswordResetCode>(),
        gh<_i455.UpdatePassword>(),
      ),
    );
    gh.factory<_i225.SubmitReview>(
      () => _i225.SubmitReview(gh<_i985.ReviewRepository>()),
    );
    gh.factory<_i38.CancelBookingRequest>(
      () => _i38.CancelBookingRequest(gh<_i912.BookingRepository>()),
    );
    gh.factory<_i360.GetBookingStatus>(
      () => _i360.GetBookingStatus(gh<_i912.BookingRepository>()),
    );
    gh.factory<_i607.GetFarmAvailability>(
      () => _i607.GetFarmAvailability(gh<_i912.BookingRepository>()),
    );
    gh.factory<_i184.RequestBooking>(
      () => _i184.RequestBooking(gh<_i912.BookingRepository>()),
    );
    gh.factory<_i609.GetMyBookings>(
      () => _i609.GetMyBookings(gh<_i912.BookingRepository>()),
    );
    gh.factory<_i488.SubmitReviewCubit>(
      () => _i488.SubmitReviewCubit(gh<_i225.SubmitReview>()),
    );
    gh.factory<_i117.AuthCubit>(
      () => _i117.AuthCubit(
        gh<_i190.SignUp>(),
        gh<_i920.SignIn>(),
        gh<_i568.SignOut>(),
        gh<_i111.GetCurrentUser>(),
      ),
    );
    gh.factory<_i329.BookingCubit>(
      () => _i329.BookingCubit(
        gh<_i607.GetFarmAvailability>(),
        gh<_i184.RequestBooking>(),
        gh<_i360.GetBookingStatus>(),
        gh<_i38.CancelBookingRequest>(),
      ),
    );
    gh.factory<_i1009.MyBookingsCubit>(
      () => _i1009.MyBookingsCubit(gh<_i609.GetMyBookings>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i464.RegisterModule {}
