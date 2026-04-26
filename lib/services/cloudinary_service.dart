import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = "daz3j5fwi";
  final String uploadPreset = "bookings_upload"; 
  // ممكن تغيره لاحقًا لـ generic preset

  Future<String> uploadImage({
    required Uint8List imageBytes,
    required String folder,
    required String fileName,
  }) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder // ✅ ده المهم
      ..fields['public_id'] = fileName
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: '$fileName.jpg',
        ),
      );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final secureUrl = RegExp(
        r'"secure_url":"(.*?)"',
      ).firstMatch(responseBody)?.group(1);

      if (secureUrl == null) {
        throw Exception("Secure URL not found");
      }

      return secureUrl;
    } else {
      throw Exception(
        "Cloudinary upload failed (${response.statusCode}): $responseBody",
      );
    }
  }
}
