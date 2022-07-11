import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_hotreload/shelf_hotreload.dart';
import 'package:shelf_router/shelf_router.dart';

import '../api/app_io.dart';




void main(List<String> arguments) async {
  // Connect and load collection
  final db = await Db.create('mongodb://127.0.0.1:27017/user?authSource=admin');
  await db.open();
  final coll = db.collection('users');
  print('Database opened');

  // Create server
  const port = 8081;
  final app = Router();

  // Create routes
  app.mount('/user/', UsersRestApi(coll).router);

  app.mount('/user-ws/', UserSocketApi(coll).routerWs);

  // Listen for incoming connections
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addHandler(app);

  withHotreload(() => serve(handler, InternetAddress.anyIPv4, port));
}
