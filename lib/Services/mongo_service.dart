// import 'package:mongo_dart/mongo_dart.dart';

// class MongoService {
//   static var db, lecturerCollection;

//   static const _uri = "mongodb://192.168.0.30:27017/grading_bot";

//   static Future<void> connect() async {
//     db = await Db.create(_uri);
//     await db.open();
//     lecturerCollection = db.collection('lecturers');
//     print("✅ MongoDB connected");
//   }

// static Future<Map<String, dynamic>?> login(String email, String password) async {
//   final user = await lecturerCollection.findOne(
//     where.eq('email', email).eq('password', password),
//   );
//   return user;
// }

// }
