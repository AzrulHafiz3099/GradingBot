import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dart_backend/mongo_service.dart'; // Adjust import if needed

void main() async {
  await MongoService.connect(); // Connect to MongoDB

  final router = Router();

  // Test route
  router.get('/', (Request request) {
    return Response.ok('✅ Dart backend is running');
  });

  // POST login route
  router.post('/login', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);

    final email = data['email'];
    final password = data['password'];

    final user = await MongoService.login(email, password);

    if (user != null) {
      return Response.ok(jsonEncode({'status': 'success', 'user': user}),
        headers: {'Content-Type': 'application/json'});
    } else {
      return Response.forbidden(jsonEncode({'status': 'fail', 'message': 'Invalid credentials'}),
        headers: {'Content-Type': 'application/json'});
    }
  });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);

  print('🚀 Server running on http://localhost:$port');
}
