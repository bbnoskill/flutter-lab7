import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StorageRepository {
  final FirebaseStorage _storage;

  StorageRepository({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadImage(File image, String userId) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('users/$userId/images/$fileName');

    final uploadTask = ref.putFile(image);
    await uploadTask;

    return await ref.getDownloadURL();
  }

  Future<void> deleteImage(String url) async {
    final ref = _storage.refFromURL(url);
    await ref.delete();
  }

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}