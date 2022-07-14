import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class UserSocketApi {
  UserSocketApi(this.store);

  final List<WebSocketChannel> _sockets = [];
  final DbCollection store;

  Handler get routerWs {
    return webSocketHandler((WebSocketChannel socket) {
      socket.stream.listen(
        (message) async {
          final data = json.decode(message);
          print(data);

          if (data['action'] == 'ADD') {
            await store.insert({
              'user_1': {'message': data['payload']}
            });
          }

          if (data['action'] == 'DELETE') {
            await store.deleteOne({
              '_id': ObjectId.fromHexString(data['payload']),
            });
          }
          final contacts = await store.find().toList();
          for (final ws in _sockets) {
            ws.sink.add(json.encode(contacts));
          }
        },
        onDone: () {
          _sockets.remove(socket);
        },
        onError: (_, s) {
          _sockets.remove(socket);
        },
      );

      _sockets.add(socket);
    });
  }
}
