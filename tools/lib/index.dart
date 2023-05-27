import 'dart:io';

Future<void> indexDB() async {
  final gPlacesPhotosDirectory = Directory('../gplaces/photos/');
  final gPlacesPhotosList =
      await gPlacesPhotosDirectory.list(followLinks: false).toList();
  final indexList = [];
  for (final entry in gPlacesPhotosList) {
    if (!['n.txt', 'index.txt'].contains(entry.path.split('/').last)) {
      indexList.add(entry.path.split('/').last);
    }
  }
  final outIndex = '${gPlacesPhotosDirectory.path}index.txt';
  final outN = '${gPlacesPhotosDirectory.path}n.txt';
  File(outIndex).writeAsString(indexList.join('\n'));
  File(outN).writeAsString(indexList.length.toString());
}
