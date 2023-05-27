import '../../tools/lib/index.dart';
import '../../tools/lib/images.dart';

void main(List<String> arguments) async {
  if (arguments.isNotEmpty) {
    final cmd = arguments[0];
    switch (cmd) {
      case 'test':
        print('HEY!');
        break;
      case 'index':
        await indexDB();
        break;
      case 'clean':
        final subCmd = arguments[1];
        switch (subCmd) {
          case 'photos':
            await processPhotos();
            break;
        }
      default:
        break;
    }
  }
}
