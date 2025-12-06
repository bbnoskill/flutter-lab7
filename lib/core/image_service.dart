import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImageAndConvertToBase64() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return null;

      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      print('Помилка при виборі зображення: $e');
      return null;
    }
  }

  Future<String?> takePhotoAndConvertToBase64() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (photo == null) return null;

      final bytes = await photo.readAsBytes();
      final base64String = base64Encode(bytes);

      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      print('Помилка при зйомці фото: $e');
      return null;
    }
  }
}
