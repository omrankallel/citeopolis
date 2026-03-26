import 'dart:io';

abstract class ImageService {
  Future<String?> saveImageToLocal(String imageUrl, String filename);

  Future<String?> saveBase64ImageToLocal(String base64Data, String filename);

  Future<bool> deleteLocalImage(String path);

  Future<bool> imageExistsLocally(String path);

  Future<File?> getImageFile(String path);
}
