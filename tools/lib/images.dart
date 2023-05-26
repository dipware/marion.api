import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> downloadImagesFromPlaces(String key) async {
  final apiUrlPhotos = 'https://maps.googleapis.com/maps/api/place/photo?';
  final dirContents =
      await Directory('../gplaces/').list(followLinks: false).toList();
  for (final entity in dirContents) {
    final split = entity.path.split('.');
    if (split[1] == 'json') {
      Map<String, dynamic> jSON =
          json.decode(await File(entity.path).readAsString());
      final List photos = jSON['photos'];
      if (photos.isNotEmpty) {
        if (!await Directory('../gplaces/photos').exists()) {
          Directory('../gplaces/photos').createSync();
        }
        int numPhotos = photos.length;
        for (int i = 0; i < numPhotos; i++) {
          final height = photos[i]['height'];
          // print(height);
          final List html_attributions = photos[i]['html_attributions'];
          // print(html_attributions);
          final String photo_reference = photos[i]['photo_reference'];
          // print(photo_reference);
          final width = photos[i]['width'];
          // print(width);
          if (!await Directory('../gplaces/photos/$photo_reference').exists()) {
            final urlString = Uri.parse(
                '${apiUrlPhotos}maxwidth=1600&maxwheight=1600&photo_reference=$photo_reference&key=$key');
            print('making network call!');
            print(urlString);
            final response = await http.get(urlString);
            final imageType = response.headers['content-type']!.split('/')[1];
            Directory('../gplaces/photos/$photo_reference').createSync();
            File('../gplaces/photos/$photo_reference/${photo_reference.substring(photo_reference.length - 16)}.$imageType')
                .writeAsBytes(response.bodyBytes);
          }
        }
      }
    }
  }
  // final input = await File('results.list.json').readAsString();
  // Map<String, dynamic> jSON = json.decode(input);
  // final Map<String, dynamic> outJSON = {};
  // for (final entry in jSON.entries) {
  //   final placeJSON = entry.value as Map<String, dynamic>;
  //   outJSON[entry.key] = [];
  //   // print(placeJSON['photos']);
  //   final photos = placeJSON['photos'];
  //   if (photos != null) {
  //     for (final photo in photos) {
  //       outJSON[entry.key].add(photo);
  //     }
  //   }
  // }
  // final Map<String, dynamic> outJSON2 = {};
  // for (final entry in outJSON.entries) {
  //   // if (debug > 1) break;
  //   final List photos = entry.value;
  //   if (photos.isNotEmpty) {
  //   }
  // }
  // await File('photos.list.json').writeAsString(json.encode(outJSON));
}
