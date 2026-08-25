import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/favorite_farm_entity.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';
import '../widgets/favorite_farm_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FavoritesCubit>()..load(),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatefulWidget {
  const _FavoritesView();

  @override
  State<_FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<_FavoritesView> {
  void _showSnack(String message, {SnackBarAction? action}) {
    final colors = context.colors;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: action,
          backgroundColor: colors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          margin: EdgeInsets.only(left: 18.w, right: 18.w, bottom: 20.h),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  void _handleRemove(FavoriteFarmEntity farm) {
    final cubit = context.read<FavoritesCubit>();
    cubit.removeOptimistically(farm);

    final controller = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('favorites_removed_toast'.tr()),
        action: SnackBarAction(
          label: 'favorites_undo'.tr(),
          textColor: context.colors.secondary,
          onPressed: () {
            cubit.undoRemoval();
            _showSnack('favorites_restored_toast'.tr());
          },
        ),
        backgroundColor: context.colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        margin: EdgeInsets.only(left: 18.w, right: 18.w, bottom: 20.h),
        duration: const Duration(seconds: 4),
      ),
    );

    // نُثبّت الحذف فعلياً بالخادم فقط لو أُغلق SnackBar بغير زر
    // "تراجع" (مهلة انتهت، أو سُحب، أو استُبدل بآخر).
    controller.closed.then((reason) {
      if (!cubit.isClosed && reason != SnackBarClosedReason.action) {
        cubit.commitPendingRemoval();
      }
    });
  }

  void _openFarmDetails(FavoriteFarmEntity farm) {
    // ⚠️ لا مسار تفاصيل مزرعة بمعرّف حقيقي بعد — راجع تعليق
    // FarmDetailsPage. سيُستبدل بتنقّل فعلي فور دعم ذلك.
    _showSnack('favorites_details_pending_toast'.tr());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<FavoritesCubit, FavoritesState>(
      listener: (context, state) {
        if (state.errorMessageKey != null) {
          _showSnack(state.errorMessageKey!.tr());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(colors, state),
                Expanded(child: _buildBody(context, colors, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppSemanticColors colors, FavoritesState state) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 14.h),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
                color: colors.surface,
              ),
              child: const BackButtonIcon(),
            ),
          ),
          SizedBox(width: 11.w),
          Text(
            'favorites_title'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 22.sp,
              color: colors.textPrimary,
            ),
          ),
          if (state.favorites.isNotEmpty) ...[
            SizedBox(width: 10.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'favorites_count'.plural(state.favorites.length),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5.sp,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppSemanticColors colors, FavoritesState state) {
    if (state.loading && state.favorites.isEmpty) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }

    if (state.favorites.isEmpty) {
      return _buildEmpty(colors);
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 30.h),
      itemCount: state.favorites.length,
      separatorBuilder: (context, index) => SizedBox(height: 14.h),
      itemBuilder: (context, index) {
        final farm = state.favorites[index];
        return FavoriteFarmCard(
          farm: farm,
          onTap: () => _openFarmDetails(farm),
          onRemove: () => _handleRemove(farm),
        );
      },
    );
  }

  Widget _buildEmpty(AppSemanticColors colors) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(30.w, 60.h, 30.w, 40.h),
      children: [
        Icon(
          Icons.favorite_border_rounded,
          size: 72.sp,
          color: colors.primary.withValues(alpha: 0.45),
        ),
        SizedBox(height: 22.h),
        Text(
          'favorites_empty_title'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17.sp,
            height: 1.5,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: 7.h),
        Text(
          'favorites_empty_body'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.sp, height: 1.8, color: colors.textSecondary),
        ),
        SizedBox(height: 26.h),
        Center(
          child: ElevatedButton(
            onPressed: () => _showSnack('my_bookings_explore_placeholder_toast'.tr()),
            child: Text(
              'favorites_explore_cta'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5.sp),
            ),
          ),
        ),
      ],
    );
  }
}
