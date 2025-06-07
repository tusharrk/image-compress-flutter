// env_manager.dart
import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Please specify an environment: dev or prod');
    return;
  }

  final env = args[0].toLowerCase();

  if (env != 'dev' && env != 'prod') {
    print('Error: Unknown environment "$env". Use dev or prod');
    return;
  }

  print('📁 Switching to $env environment...');

  // Copy the appropriate .env file
  final sourceFile = '.env.$env';
  const targetFile =
      '.env.dev'; // Always target .env.dev as that's what we use in the code

  try {
    final source = File(sourceFile);
    if (!source.existsSync()) {
      print('❌ Error: $sourceFile does not exist');
      return;
    }

    // Read and print the source file content
    final sourceContent = await source.readAsString();
    print('Source file (.env.$env) content:');
    print(sourceContent);

    source.copySync(targetFile);
    print('✅ Switched to $env environment');

    // Read and print the target file content to verify copy
    final targetContent = await File(targetFile).readAsString();
    print('Target file (.env.dev) content after copy:');
    print(targetContent);

    // Run build_runner to regenerate code
    print('🔄 Regenerating code with build_runner...');

    final result = await Process.run(
        Platform.isWindows ? 'flutter.bat' : 'flutter',
        ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
        runInShell: true);

    if (result.exitCode != 0) {
      print('❌ Error generating code:');
      print(result.stderr);
      return;
    }

    print('✅ Code regenerated successfully');
    print('🚀 Environment is now set to: $env');

    // Suggest clean build
    print(
        '💡 Tip: You may need to run "flutter clean" and rebuild the app for changes to take effect');
  } catch (e) {
    print('❌ Error: $e');
  }
}
