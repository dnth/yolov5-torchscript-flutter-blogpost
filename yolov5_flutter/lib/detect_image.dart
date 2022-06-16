import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map> detectImage(String imageBase64) async {
  final response = await http.post(
    Uri.parse(
        'https://hf.space/embed/dnth/webdemo-microalgae-counting/+/api/predict/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, List<dynamic>>{
      'data': [imageBase64]
    }),
  );

  if (response.statusCode == 200) {
    final detectionResult = jsonDecode(response.body)["data"];

    final imageData =
        detectionResult[0].replaceAll('data:image/png;base64,', '');

    return {"count": detectionResult[1], "image": imageData};
    // If the server did return a 200 CREATED response,
    // then decode the image and return it.
  } else {
    // If the server did not return a 200 OKAY response,
    // then throw an exception.
    throw Exception('Failed to get results.');
  }
}
