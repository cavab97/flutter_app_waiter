import '../app_config.dart';

void main() async {
  await FlutterAppConfig(
    environment: AppEnvironment.staging
  ).run();
}
