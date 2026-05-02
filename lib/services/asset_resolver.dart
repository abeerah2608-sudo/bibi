import 'package:firebase_storage/firebase_storage.dart';

class AssetResolver {
  static Future<String> resolve(String url) async {
    if (url.startsWith('gs://')) {
      return await FirebaseStorage.instance
          .refFromURL(url)
          .getDownloadURL();
    }
    return url;
  }
}