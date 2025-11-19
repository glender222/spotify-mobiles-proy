import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harmonymusic/main.dart';
import 'package:harmonymusic/ui/home.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Mock PathProviderPlatform
class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationCachePath() async => null;

  @override
  Future<String?> getApplicationDocumentsPath() async {
    final tempDir = await Directory.systemTemp.createTemp('test_app_docs');
    return tempDir.path;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    final tempDir = await Directory.systemTemp.createTemp('test_app_support');
    return tempDir.path;
  }

  @override
  Future<String?> getDownloadsPath() async => null;

  @override
  Future<List<String>?> getExternalCachePaths() async => null;

  @override
  Future<String?> getExternalStoragePath() async => null;

  @override
  Future<List<String>?> getExternalStoragePaths(
          {StorageDirectory? type}) async =>
      null;

  @override
  Future<String?> getLibraryPath() async => null;

  @override
  Future<String?> getTemporaryPath() async {
    final tempDir = await Directory.systemTemp.createTemp('test_app_temp');
    return tempDir.path;
  }
}

void main() {
  // Disable font fetching from the internet in tests.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Set up a mock path provider for Hive initialization
  setUp(() async {
    PathProviderPlatform.instance = FakePathProviderPlatform();

    // Initialize Hive for testing
    await Hive.initFlutter('test');
    await Hive.openBox("SongsCache");
    await Hive.openBox("SongDownloads");
    await Hive.openBox('SongsUrlCache');
    await Hive.openBox("AppPrefs");
    await Hive.openBox("homeScreenData");
    await Hive.openBox('userHistory');
    await Hive.openBox('userPlaylists');
    await Hive.openBox('userArtists');
  });

  tearDown(() async {
    await Hive.close();
    Get.reset();
  });

  testWidgets('App starts without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Home widget is rendered.
    expect(find.byType(Home), findsOneWidget);
  });
}
