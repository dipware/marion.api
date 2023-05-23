import 'package:envied/envied.dart';

part 'fetch_places.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'MAPS_API_KEY', obfuscate: true)
  static final String key1 = _Env.key1;
}
