// build_release.dart
import 'dart:io';

void main() async {
  print('🚀 Starting release build with production environment...');

  // 1. Clean the project first
  print('🧹 Cleaning project...');
  final cleanResult = await Process.run(
      Platform.isWindows ? 'flutter.bat' : 'flutter', ['clean'],
      runInShell: true);

  if (cleanResult.exitCode != 0) {
    print('❌ Clean failed: ${cleanResult.stderr}');
    exit(1);
  }
  print('✅ Project cleaned');

  // 2. Get dependencies
  print('📦 Getting dependencies...');
  final getResult = await Process.run(
      Platform.isWindows ? 'flutter.bat' : 'flutter', ['pub', 'get'],
      runInShell: true);

  if (getResult.exitCode != 0) {
    print('❌ Pub get failed: ${getResult.stderr}');
    exit(1);
  }
  print('✅ Dependencies updated');

  // 3. Switch to production environment
  print('🔄 Switching to production environment...');
  const sourceFile = '.env.prod';
  const targetFile = '.env.dev';

  try {
    final source = File(sourceFile);
    if (!source.existsSync()) {
      print('❌ Error: $sourceFile does not exist');
      exit(1);
    }

    // Read and print the source file content
    final sourceContent = await source.readAsString();
    print('Production environment file contains:');
    print(sourceContent);

    source.copySync(targetFile);

    // Verify the copy
    final targetContent = await File(targetFile).readAsString();
    if (targetContent != sourceContent) {
      print('❌ Environment file was not copied correctly');
      exit(1);
    }

    print('✅ Environment switched to production');
  } catch (e) {
    print('❌ Error switching environment: $e');
    exit(1);
  }

  // 4. Generate environment code
  print('📝 Generating environment code...');
  final genResult = await Process.run(
    Platform.isWindows ? 'flutter.bat' : 'flutter',
    ['pub', 'run', 'build_runner', 'clean'],
    runInShell: true,
  );

  if (genResult.exitCode != 0) {
    print('❌ Error cleaning generated code: ${genResult.stderr}');
    exit(1);
  }

  final buildResult = await Process.run(
    Platform.isWindows ? 'flutter.bat' : 'flutter',
    ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    runInShell: true,
  );

  if (buildResult.exitCode != 0) {
    print('❌ Error generating code: ${buildResult.stderr}');
    exit(1);
  }
  print('✅ Environment code generated');

  // Verify the generated file contains production settings
  try {
    final envDir = Directory('lib/core/env');
    final generatedFiles = envDir
        .listSync()
        .where((entity) => entity is File && entity.path.endsWith('.g.dart'));

    if (generatedFiles.isEmpty) {
      print('⚠️ Warning: Could not find generated environment file to verify');
    } else {
      final genFile = generatedFiles.first as File;
      final content = await genFile.readAsString();

      // This is a basic check - adjust based on how your env.g.dart is structured
      if (!content.contains('production')) {
        print('⚠️ Warning: Generated file may not contain production settings');
      } else {
        print('✅ Verified production settings in generated file');
      }
    }
  } catch (e) {
    print('⚠️ Warning: Could not verify generated file: $e');
  }

  // 5. Build the release
  print('🏗️ Building release APK...');

  // For Android
  final releaseResult = await Process.run(
    Platform.isWindows ? 'flutter.bat' : 'flutter',
    ['build', 'apk', '--release'],
    runInShell: true,
  );

  if (releaseResult.exitCode != 0) {
    print('❌ Build failed: ${releaseResult.stderr}');
    exit(1);
  }

  print(releaseResult.stdout);

  // 6. For iOS - uncomment if needed
  // print('🏗️ Building release for iOS...');
  // final iosResult = await Process.run(
  //   Platform.isWindows ? 'flutter.bat' : 'flutter',
  //   ['build', 'ios', '--release'],
  //   runInShell: true,
  // );
  //
  // if (iosResult.exitCode != 0) {
  //   print('❌ iOS build failed: ${iosResult.stderr}');
  //   exit(1);
  // }

  print('✅ Release build completed successfully with production environment!');
  print(
      '📱 Your APK is located at: build/app/outputs/flutter-apk/app-release.apk');
}
