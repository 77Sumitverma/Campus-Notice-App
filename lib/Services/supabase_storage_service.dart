import 'dart:io';
import 'package:uuid/uuid.dart';
import 'supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:storage_client/storage_client.dart';


final SupabaseClient supabase = Supabase.instance.client;

class SupabaseStorageService {
  static Future<String?> uploadFileToSupabase(File file,
      String folderName) async {
    try {
      final fileExt = file.path
          .split('.')
          .last;
      final fileName = const Uuid().v4(); // unique filename
      final filePath = '$folderName/$fileName.$fileExt';

      final bytes = await file.readAsBytes();

      final storage = Supabase.instance.client.storage;

      // ✅ Upload file
      await storage
          .from('noticemedia')
          .uploadBinary(
          filePath, bytes, fileOptions: FileOptions(upsert: true));

      // ✅ Get public URL
      final publicUrl = storage.from('noticemedia').getPublicUrl(filePath);

      print("✅ File uploaded to Supabase. Public URL: $publicUrl");
      return publicUrl;
    } catch (e) {
      print("❌ Supabase Upload Error: $e");
      return null;
    }
  }

  static Future<void> deleteFileFromSupabase(String fileUrl) async {
    try {
      final supabase = Supabase.instance.client;

// Supabase file URL se actual path nikalna
      final uri = Uri.parse(fileUrl);
      final filePath = uri.pathSegments.skip(1).join(
          '/'); // skips "storage/v1/object/public/"

      final response = await Supabase.instance.client.storage.from('noticemedia').list(path: '');

      if (response is List<FileObject>) {
        // 🟢 Success, handle list
        for (final file in response) {
          print(file.name);
        }
      } else {
        // ⚠️ Agar koi error mila ho, toh alag se handle kar
        print("Unexpected response type: $response");
      }

    } catch (e) {
      print("❌ Error deleting Supabase file: $e");
    }
  }

}

