import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/network/connectivity_provider.dart';
import '../../../../router/routes.dart';
import '../../domain/modals/publicity.dart';

final publicityProvider = ChangeNotifierProvider((ref) => PublicityProvider());

class PublicityProvider extends ChangeNotifier {
  final textColor = StateProvider<Color>((ref) => Colors.black);

  String? getPosition(WidgetRef ref) {
    final String position = ref.watch(publicity).positionTitlePublicity ?? '';
    switch (position) {
      case 'hide':
        return 'Masquer';
      case 'top':
        return 'Haut';
      case 'medium':
        return 'Milieu';
      case 'bottom':
        return 'Bas';
    }
    return null;
  }

  AlignmentGeometry positionedPublicity(WidgetRef ref) {
    final position = getPosition(ref);
    switch (position) {
      case 'Haut':
        return Alignment.topCenter;
      case 'Milieu':
        return Alignment.center;
      case 'Bas':
        return Alignment.bottomCenter;
      default:
        return Alignment.topCenter;
    }
  }

  bool? statusConnection;
  final publicity = StateProvider<Publicity>((ref) => Publicity());

  Timer? _publicityTimer;

  void initialisePublicity(WidgetRef ref, Publicity publicity) {
    final isConnected = ref.watch(isConnectedProvider);
    if (publicity.id != null && isConnected != statusConnection) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(this.publicity.notifier).state = publicity;
        if (publicity.imgPublicity?.localPath != null) {
          final localFile = File(publicity.imgPublicity!.localPath!);
          if (await localFile.exists()) {
            await _analyzeLocalImage(ref, localFile);
          } else if (publicity.imgPublicity?.url != null) {
            await _analyzeRemoteImage(ref, publicity.imgPublicity!.url!);
          }
        } else if (publicity.imgPublicity?.url != null) {
          await _analyzeRemoteImage(ref, publicity.imgPublicity!.url!);
        }

        statusConnection = isConnected;
        _publicityTimer?.cancel();
        if ((publicity.displayTimeSeconds ?? '').isNotEmpty) {
          final int displayTime = int.tryParse(publicity.displayTimeSeconds!) ?? 1;

          _publicityTimer = Timer(
            Duration(seconds: displayTime),
            () {
                goRouter.pushReplacement(Paths.contentHome);

            },
          );
        }
      });
    }
  }
  void cancelPublicityTimer() {
    _publicityTimer?.cancel();
    _publicityTimer = null;
  }

  Future<void> _analyzeLocalImage(WidgetRef ref, File imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final Color adaptiveColor = await _getAdaptiveTextColor(imageBytes);
      ref.read(textColor.notifier).state = adaptiveColor;
    } catch (e) {
      debugPrint("Erreur lors de l'analyse de l'image locale: $e");
      final publicityData = ref.read(publicity);
      if (publicityData.imgPublicity?.url != null) {
        await _analyzeRemoteImage(ref, publicityData.imgPublicity!.url!);
      }
    }
  }

  Future<void> _analyzeRemoteImage(WidgetRef ref, String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Uint8List imageBytes = response.bodyBytes;
        final Color adaptiveColor = await _getAdaptiveTextColor(imageBytes);
        ref.read(textColor.notifier).state = adaptiveColor;
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement de l'image distante: $e");
      ref.read(textColor.notifier).state = Colors.white;
    }
  }

  Future<Color> _getAdaptiveTextColor(Uint8List imageBytes) async {
    try {
      final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      final ByteData? byteData = await image.toByteData();
      if (byteData == null) return Colors.white;

      final Uint8List pixels = byteData.buffer.asUint8List();

      double totalLuminance = 0;
      int sampleCount = 0;

      for (int i = 0; i < pixels.length; i += 80) {
        if (i + 3 < pixels.length) {
          final int r = pixels[i];
          final int g = pixels[i + 1];
          final int b = pixels[i + 2];

          final double luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
          totalLuminance += luminance;
          sampleCount++;
        }
      }

      final double averageLuminance = sampleCount > 0 ? totalLuminance / sampleCount : 0.5;

      return averageLuminance > 0.5 ? Colors.black : Colors.white;
    } catch (e) {
      debugPrint('Erreur lors du calcul de la couleur adaptative: $e');
      return Colors.white;
    }
  }
}
