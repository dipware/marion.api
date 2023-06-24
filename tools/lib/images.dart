import 'dart:convert';
import 'dart:io';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

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

Future<void> processPhotos() async {
  final dirContents =
      await Directory('../gplaces/photos/').list(followLinks: false).toList();
  for (final dir in dirContents) {
    final stat = await dir.stat();
    final type = stat.type;
    if (type == FileSystemEntityType.directory) {
      final dirName = dir.path.split('/').last;
      final fileName = dirName.substring(dirName.length - 16);
      final glob = Glob('${dir.path}/$fileName.*');
      final matches = glob.listSync(followLinks: false);
      if (matches.isEmpty) {
        throw Exception('Error! This list should not be empty.');
      }
      for (final match in matches) {
        final file = await File(match.path).readAsBytes();
        final type = match.path.split('.').last;
        if (['jpeg', 'jpg'].contains(type.toLowerCase())) {
          final image = img.decodeJpg(file)!;
          final width = image.width;
          final large =
              img.copyResize(image, width: width > 1200 ? 1200 : width);
          final medium =
              img.copyResize(image, width: width > 600 ? 600 : width);
          final small = img.copyResize(image, width: width > 300 ? 300 : width);
          img.encodeJpgFile('${dir.path}/large.$type', large);
          img.encodeJpgFile('${dir.path}/medium.$type', medium);
          img.encodeJpgFile('${dir.path}/small.$type', small);
          File('${dir.path}/type.txt').writeAsString(type);
        } else if (['png'].contains(type.toLowerCase())) {
          final image = img.decodePng(file)!;
          final width = image.width;
          final large =
              img.copyResize(image, width: width > 1200 ? 1200 : width);
          final medium =
              img.copyResize(image, width: width > 600 ? 600 : width);
          final small = img.copyResize(image, width: width > 300 ? 300 : width);
          img.encodePngFile('${dir.path}/large.$type', large);
          img.encodePngFile('${dir.path}/medium.$type', medium);
          img.encodePngFile('${dir.path}/small.$type', small);
          File('${dir.path}/type.txt').writeAsString(type);
        } else {
          throw Exception('New Type: $type');
        }
      }
    }
  }
}
