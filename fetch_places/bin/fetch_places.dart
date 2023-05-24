import 'package:fetch_places/fetch_places.dart';

void main(List<String> arguments) async {
  if (arguments.isNotEmpty) {
    final cmd = arguments[0];
    switch (cmd) {
      case 'init':
        await call_nearby_places_api();
        break;
      case 'dev':
        await dev();
        break;
      default:
        break;
    }
  }
}
