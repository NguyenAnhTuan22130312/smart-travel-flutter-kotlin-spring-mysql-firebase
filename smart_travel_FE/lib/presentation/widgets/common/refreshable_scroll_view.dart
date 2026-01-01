import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/banner/banner_bloc.dart';
import 'package:smart_travel/presentation/blocs/banner/banner_event.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_event.dart';
import 'package:smart_travel/presentation/blocs/province/province_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/province_event.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_event.dart';

class RefreshableScrollView extends StatelessWidget {
  final List<Widget> slivers;
  final Color? color; // màu của RefreshIndicator

  const RefreshableScrollView({
    Key? key,
    required this.slivers,
    this.color,
  }) : super(key: key);

  /// Hàm refresh chung cho toàn app
  Future<void> _refreshAllData(BuildContext context) async {
    final destinationBloc = context.read<DestinationBloc>();
    final provinceBloc = context.read<ProvinceBloc>();
    final profileBloc = context.read<ProfileBloc>();
    final bannerBloc = context.read<BannerBloc>();


    // Bắt đồng thời tất cả event
    destinationBloc.add(LoadAllDestinations());
    provinceBloc.add(LoadProvince());
    profileBloc.add(LoadProfile());
    bannerBloc.add(LoadAllBanner());


    // Đợi một chút để UX load
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refreshAllData(context),
      color: color ?? Theme.of(context).colorScheme.primary,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: CustomScrollView(
        slivers: slivers,
      ),
    );
  }
}