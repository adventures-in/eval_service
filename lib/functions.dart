import 'dart:isolate';

import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

@CloudFunction()
Future<Response> function(Request request) async {
  final body = await request.readAsString();

  final uri = Uri.dataFromString(
    '''
    import "dart:isolate";

    void main(_, SendPort port) {
      port.send("$body");
    }
    ''',
    mimeType: 'application/dart',
  );

  final port = ReceivePort();
  final isolate = await Isolate.spawnUri(uri, [], port.sendPort);
  final String response = await port.first;

  port.close();
  isolate.kill();

  print('response:' + response);

  return Response.ok(body);
}
