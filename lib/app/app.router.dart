// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i12;
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/ui/views/compress_image/compress_image_view.dart'
    as _i8;
import 'package:flutter_boilerplate/ui/views/compress_process/compress_process_view.dart'
    as _i9;
import 'package:flutter_boilerplate/ui/views/compress_result/compress_result_view.dart'
    as _i10;
import 'package:flutter_boilerplate/ui/views/example_page/example_page_view.dart'
    as _i3;
import 'package:flutter_boilerplate/ui/views/home/home_view.dart' as _i4;
import 'package:flutter_boilerplate/ui/views/list_albums/list_albums_view.dart'
    as _i6;
import 'package:flutter_boilerplate/ui/views/list_photos/list_photos_view.dart'
    as _i5;
import 'package:flutter_boilerplate/ui/views/paywall_subscription/paywall_subscription_view.dart'
    as _i11;
import 'package:flutter_boilerplate/ui/views/settings/settings_view.dart'
    as _i7;
import 'package:flutter_boilerplate/ui/views/startup/startup_view.dart' as _i2;
import 'package:photo_manager/photo_manager.dart' as _i13;
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i14;

class Routes {
  static const startupView = '/startup-view';

  static const examplePageView = '/example-page-view';

  static const homeView = '/home-view';

  static const listPhotosView = '/list-photos-view';

  static const listAlbumsView = '/list-albums-view';

  static const settingsView = '/settings-view';

  static const compressImageView = '/compress-image-view';

  static const compressProcessView = '/compress-process-view';

  static const compressResultView = '/compress-result-view';

  static const paywallSubscriptionView = '/paywall-subscription-view';

  static const all = <String>{
    startupView,
    examplePageView,
    homeView,
    listPhotosView,
    listAlbumsView,
    settingsView,
    compressImageView,
    compressProcessView,
    compressResultView,
    paywallSubscriptionView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.startupView,
      page: _i2.StartupView,
    ),
    _i1.RouteDef(
      Routes.examplePageView,
      page: _i3.ExamplePageView,
    ),
    _i1.RouteDef(
      Routes.homeView,
      page: _i4.HomeView,
    ),
    _i1.RouteDef(
      Routes.listPhotosView,
      page: _i5.ListPhotosView,
    ),
    _i1.RouteDef(
      Routes.listAlbumsView,
      page: _i6.ListAlbumsView,
    ),
    _i1.RouteDef(
      Routes.settingsView,
      page: _i7.SettingsView,
    ),
    _i1.RouteDef(
      Routes.compressImageView,
      page: _i8.CompressImageView,
    ),
    _i1.RouteDef(
      Routes.compressProcessView,
      page: _i9.CompressProcessView,
    ),
    _i1.RouteDef(
      Routes.compressResultView,
      page: _i10.CompressResultView,
    ),
    _i1.RouteDef(
      Routes.paywallSubscriptionView,
      page: _i11.PaywallSubscriptionView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.StartupView: (data) {
      return _i12.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.StartupView(),
        settings: data,
      );
    },
    _i3.ExamplePageView: (data) {
      return _i12.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.ExamplePageView(),
        settings: data,
      );
    },
    _i4.HomeView: (data) {
      return _i12.MaterialPageRoute<dynamic>(
        builder: (context) => const _i4.HomeView(),
        settings: data,
      );
    },
    _i5.ListPhotosView: (data) {
      final args = data.getArgs<ListPhotosViewArguments>(nullOk: false);
      return _i12.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i5.ListPhotosView(key: args.key, album: args.album),
        settings: data,
      );
    },
    _i6.ListAlbumsView: (data) {
      return _i12.MaterialPageRoute<dynamic>(
        builder: (context) => const _i6.ListAlbumsView(),
        settings: data,
      );
    },
    _i7.SettingsView: (data) {
      return _i12.MaterialPageRoute<dynamic>(
        builder: (context) => const _i7.SettingsView(),
        settings: data,
      );
    },
    _i8.CompressImageView: (data) {
      return _i12.MaterialPageRoute<dynamic>(
        builder: (context) => const _i8.CompressImageView(),
        settings: data,
      );
    },
    _i9.CompressProcessView: (data) {
      return _i12.MaterialPageRoute<dynamic>(
        builder: (context) => const _i9.CompressProcessView(),
        settings: data,
      );
    },
    _i10.CompressResultView: (data) {
      return _i12.MaterialPageRoute<dynamic>(
        builder: (context) => const _i10.CompressResultView(),
        settings: data,
      );
    },
    _i11.PaywallSubscriptionView: (data) {
      return _i12.MaterialPageRoute<dynamic>(
        builder: (context) => const _i11.PaywallSubscriptionView(),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class ListPhotosViewArguments {
  const ListPhotosViewArguments({
    this.key,
    required this.album,
  });

  final _i12.Key? key;

  final _i13.AssetPathEntity album;

  @override
  String toString() {
    return '{"key": "$key", "album": "$album"}';
  }

  @override
  bool operator ==(covariant ListPhotosViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.album == album;
  }

  @override
  int get hashCode {
    return key.hashCode ^ album.hashCode;
  }
}

extension NavigatorStateExtension on _i14.NavigationService {
  Future<dynamic> navigateToStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToExamplePageView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.examplePageView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToListPhotosView({
    _i12.Key? key,
    required _i13.AssetPathEntity album,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.listPhotosView,
        arguments: ListPhotosViewArguments(key: key, album: album),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToListAlbumsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.listAlbumsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSettingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.settingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCompressImageView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.compressImageView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCompressProcessView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.compressProcessView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCompressResultView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.compressResultView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPaywallSubscriptionView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.paywallSubscriptionView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithExamplePageView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.examplePageView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithListPhotosView({
    _i12.Key? key,
    required _i13.AssetPathEntity album,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.listPhotosView,
        arguments: ListPhotosViewArguments(key: key, album: album),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithListAlbumsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.listAlbumsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSettingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.settingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCompressImageView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.compressImageView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCompressProcessView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.compressProcessView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCompressResultView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.compressResultView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPaywallSubscriptionView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.paywallSubscriptionView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
