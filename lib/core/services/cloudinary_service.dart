import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  // Replace with your cloud name and unsigned upload preset
  final _cloudName = 'dnxr6gqav';
  final _preset = 'growme_preset';

  final CloudinaryPublic _cloudinary;

  CloudinaryService()
    : _cloudinary = CloudinaryPublic(
        'dnxr6gqav',
        'growme_preset',
        cache: false,
      );

  Future<String?> uploadImage(File imageFile) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      // print for debug
      print('Cloudinary upload error: $e');
      return null;
    }
  }
}
