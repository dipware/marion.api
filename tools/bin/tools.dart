import 'package:tools/index.dart';
import 'package:tools/places.dart';
import 'package:tools/images.dart';
import 'package:envied/envied.dart';
part 'tools.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'MAPS_API_KEY', obfuscate: true)
  static final String key1 = _Env.key1;
}

void main(List<String> arguments) async {
  if (arguments.isNotEmpty) {
    final cmd = arguments[0];
    switch (cmd) {
      case 'index':
        await indexDB();
        break;
      case 'init':
        await callNearbyPlacesAPI(Env.key1);
        break;
      case 'dev':
        // await downloadImagesFromPlaces(Env.key1);
        await processPhotos();
        break;
      default:
        break;
    }
  }
}
