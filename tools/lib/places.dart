import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

Future<void> callNearbyPlacesAPI(String key) async {
  final outDir = Directory('../gplaces/');
  if (!await outDir.exists()) {
    await outDir.create();
  }

  final baseUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?';

  const lat = 35.684066;
  const long = -82.009008;
  final location = 'location=$lat,$long';
  final radius = '&radius=5000';
  final builtString = '$baseUrl$location$radius&key=$key';
  final uri = Uri.parse(builtString);

  print(uri.toString());

  final List<Map<String, dynamic>> fetchedList = [];

  final response = await http.read(uri);
  var jSON = json.decode(response);
  for (final object in jSON['results']) {
    fetchedList.add(object as Map<String, dynamic>);
  }

  String? nPT = jSON['next_page_token'];
  int retries = 0;

  while (nPT != null) {
    sleep(Duration(seconds: 1));
    final nextUrlString = '${baseUrl}pagetoken=$nPT&key=$key';
    final nextPageUrl = Uri.parse(nextUrlString);
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
      fetchedList.add(object as Map<String, dynamic>);
    }
    nPT = jSON['next_page_token'];
  }
  final outIndex = [];
  for (final object in fetchedList) {
    await File('${outDir.path}${object['place_id'].toString()}.json')
        .writeAsString(json.encode(object));
    outIndex.add(object['place_id'].toString());
  }
  await File('${outDir.path}n.txt')
      .writeAsString(fetchedList.length.toString());
  await File('${outDir.path}index.txt').writeAsString(outIndex.join('\n'));
}
