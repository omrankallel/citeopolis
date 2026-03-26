import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'image_service.dart';

class ImageServiceImpl implements ImageService {
  @override
  Future<String?> saveImageToLocal(String imageUrl, String filename) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return await _saveImageBytes(response.bodyBytes, filename);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> saveBase64ImageToLocal(String base64Data, String filename) async {
    try {
      String cleanBase64 = base64Data;
      if (base64Data.contains(',')) {
        cleanBase64 = base64Data.split(',').last;
      }

      final Uint8List bytes = base64Decode(cleanBase64);
      return await _saveImageBytes(bytes, filename);
    } catch (e) {
      return null;
    }
  }

  Future<String?> _saveImageBytes(Uint8List bytes, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(directory.path, 'images'));

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      String uniqueFilename = filename;
      final extension = path.extension(filename).isNotEmpty ? path.extension(filename) : '.jpg';
      final baseName = path.basenameWithoutExtension(filename).isNotEmpty ? path.basenameWithoutExtension(filename) : 'image_${DateTime.now().millisecondsSinceEpoch}';

      uniqueFilename = '$baseName$extension';

      final filePath = path.join(imagesDir.path, uniqueFilename);
      final file = File(filePath);

      int counter = 1;
      while (await file.exists()) {
        uniqueFilename = '${baseName}_$counter$extension';
        final newFilePath = path.join(imagesDir.path, uniqueFilename);
        final newFile = File(newFilePath);
        if (!await newFile.exists()) {
          break;
        }
        counter++;
      }

      final finalFile = File(path.join(imagesDir.path, uniqueFilename));
      await finalFile.writeAsBytes(bytes);

      return finalFile.path;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> deleteLocalImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> imageExistsLocally(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<File?> getImageFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
