import 'package:envied/envied.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
part 'fetch_places.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'MAPS_API_KEY', obfuscate: true)
  static final String key1 = _Env.key1;
}

Future<List<Map<String, dynamic>>> call_nearby_places_api() async {
  final List<Map<String, dynamic>> returnList = [];
  final baseUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?';
  const lat = 35.684066;
  const long = -82.009008;
  final location = 'location=$lat,$long';
  final radius = '&radius=5000';
  final key = '&key=${Env.key1}';
  final builtString = '$baseUrl$location$radius$key';
  final uri = Uri.parse(builtString);
  print(uri.toString());
  final response = await http.read(uri);
  // await File('response0.json').writeAsString(response);
  var jSON = json.decode(response);
  var nPT = jSON['next_page_token'];
  for (final object in jSON['results']) {
    returnList.add(object as Map<String, dynamic>);
  }
  var i = 1;
  int retries = 0;
  while (nPT != null) {
    sleep(Duration(seconds: 1));
    final nextPageUrl = Uri.parse('${baseUrl}pagetoken=$nPT$key');
    print(nextPageUrl);
    final nextResponse = await http.read(nextPageUrl);
    jSON = json.decode(nextResponse);
    if (jSON['status'] == 'INVALID_REQUEST') {
      retries++;
      if (retries > 5) {
        throw Exception('Too many retries');
      }
      sleep(Duration(seconds: 1));
      continue;
    }
    for (final object in jSON['results']) {
      returnList.add(object as Map<String, dynamic>);
    }
    nPT = jSON['next_page_token'];
  }
  final Map<String, dynamic> outJSON = {};
  for (final object in returnList) {
    outJSON[object['place_id'].toString()] = object;
  }
  // print(returnList.length);
  await File('results.list.json').writeAsString(json.encode(outJSON));
  return returnList;
}

Future<void> dev() async {
  final input = await File('results.list.json').readAsString();
  Map<String, dynamic> jSON = json.decode(input);
  final Map<String, dynamic> outJSON = {};
  for (final entry in jSON.entries) {
    final placeJSON = entry.value as Map<String, dynamic>;
    outJSON[entry.key] = [];
    // print(placeJSON['photos']);
    final photos = placeJSON['photos'];
    if (photos != null) {
      for (final photo in photos) {
        outJSON[entry.key].add(photo);
      }
    }
  }
  for (final entry in outJSON.entries) {
    final List photos = entry.value;
    if (photos.isNotEmpty) {
      print(photos);
      int numPhotos = photos.length;
      for (int i = 0; i < numPhotos; i++) {
        final height = photos[i]['height'];
        print(height);
        final List html_attributions = photos[i]['html_attributions'];
        print(html_attributions);
        final photo_reference = photos[i]['photo_reference'];
        print(photo_reference);
        final width = photos[i]['width'];
        print(width);
      }
    }
  }
  // await File('photos.list.json').writeAsString(json.encode(outJSON));
}
