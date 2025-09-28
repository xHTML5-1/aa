import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../core/auth/jwt_token_manager.dart';
import '../core/cache/offline_cache.dart';
import '../core/network/api_client.dart';
import '../features/site_management/data/datasources/site_local_data_source.dart';
import '../features/site_management/data/datasources/site_remote_data_source.dart';
import '../features/site_management/data/repositories/site_repository_impl.dart';
import '../features/site_management/domain/repositories/site_repository.dart';
import '../features/site_management/domain/usecases/create_payment_intent.dart';
import '../features/site_management/domain/usecases/get_site.dart';
import '../features/site_management/domain/usecases/list_periods.dart';
import '../features/site_management/domain/usecases/mark_invoice_paid.dart';
import '../features/site_management/domain/usecases/publish_period.dart';
import '../features/site_management/domain/usecases/run_period.dart';
import '../core/utils/notification_service.dart';
import '../features/site_management/presentation/controllers/site_controller.dart';
import '../features/site_management/presentation/state/site_state.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8000',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );
  return dio;
});

final jwtTokenManagerProvider = Provider<JwtTokenManager>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return JwtTokenManager(prefs);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final tokenManager = ref.watch(jwtTokenManagerProvider);
  return ApiClient(dio, tokenManager);
});

final offlineCacheProvider = Provider<OfflineCache>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OfflineCache(prefs);
});

final siteRemoteDataSourceProvider = Provider<SiteRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return SiteRemoteDataSourceImpl(client);
});

final siteLocalDataSourceProvider = Provider<SiteLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final cache = ref.watch(offlineCacheProvider);
  return SiteLocalDataSourceImpl(prefs, cache);
});

final siteRepositoryProvider = Provider<SiteRepository>((ref) {
  final remote = ref.watch(siteRemoteDataSourceProvider);
  final local = ref.watch(siteLocalDataSourceProvider);
  return SiteRepositoryImpl(remote, local);
});

final getSiteProvider = Provider<GetSite>((ref) {
  final repository = ref.watch(siteRepositoryProvider);
  return GetSite(repository);
});

final listPeriodsProvider = Provider<ListPeriods>((ref) {
  final repository = ref.watch(siteRepositoryProvider);
  return ListPeriods(repository);
});

final runPeriodProvider = Provider<RunPeriod>((ref) {
  final repository = ref.watch(siteRepositoryProvider);
  return RunPeriod(repository);
});

final publishPeriodProvider = Provider<PublishPeriod>((ref) {
  final repository = ref.watch(siteRepositoryProvider);
  return PublishPeriod(repository);
});

final createPaymentIntentProvider = Provider<CreatePaymentIntent>((ref) {
  final repository = ref.watch(siteRepositoryProvider);
  return CreatePaymentIntent(repository);
});

final markInvoicePaidProvider = Provider<MarkInvoicePaid>((ref) {
  final repository = ref.watch(siteRepositoryProvider);
  return MarkInvoicePaid(repository);
});

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final messaging = ref.watch(firebaseMessagingProvider);
  return NotificationService(messaging);
});

final siteControllerProvider =
    StateNotifierProvider<SiteController, SiteState>((ref) {
  final controller = SiteController(
    getSite: ref.watch(getSiteProvider),
    listPeriods: ref.watch(listPeriodsProvider),
    runPeriod: ref.watch(runPeriodProvider),
    publishPeriod: ref.watch(publishPeriodProvider),
    createPaymentIntent: ref.watch(createPaymentIntentProvider),
    markInvoicePaid: ref.watch(markInvoicePaidProvider),
    notificationService: ref.watch(notificationServiceProvider),
  );
  return controller;
});
