import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/core.dart';

class AtomUploadImage extends StatefulWidget {
  const AtomUploadImage({
    this.labelImage,
    this.base64ImageData,
    this.localImagePath,
    this.uploadIcon,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.preferLocalImage = true,
    super.key,
  });

  final String? labelImage;
  final String? base64ImageData;
  final String? localImagePath;
  final IconData? uploadIcon;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool preferLocalImage;

  static final Map<String, Uint8List> _memoryCache = {};

  static void clearCache() => _memoryCache.clear();

  @override
  State<AtomUploadImage> createState() => _AtomUploadImageState();
}

class _AtomUploadImageState extends State<AtomUploadImage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Uint8List? _cachedBytes;
  bool _localFileExists = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(AtomUploadImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localImagePath != widget.localImagePath || oldWidget.base64ImageData != widget.base64ImageData) {
      _initialized = false;
      _initialize();
    }
  }

  Future<void> _initialize() async {
    if (_initialized) return;

    if (widget.preferLocalImage && widget.localImagePath != null && widget.localImagePath!.isNotEmpty) {
      if (AtomUploadImage._memoryCache.containsKey(widget.localImagePath!)) {
        if (mounted) {
          setState(() {
            _cachedBytes = AtomUploadImage._memoryCache[widget.localImagePath!];
            _localFileExists = true;
            _initialized = true;
          });
        }
        return;
      }

      try {
        final file = File(widget.localImagePath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          AtomUploadImage._memoryCache[widget.localImagePath!] = bytes;
          if (mounted) {
            setState(() {
              _cachedBytes = bytes;
              _localFileExists = true;
              _initialized = true;
            });
          }
          return;
        }
      } catch (_) {}
    }

    if (widget.base64ImageData != null && Helpers.isValidBase64(widget.base64ImageData)) {
      final cacheKey = widget.base64ImageData!.substring(
        0,
        widget.base64ImageData!.length.clamp(0, 40),
      );

      if (AtomUploadImage._memoryCache.containsKey(cacheKey)) {
        if (mounted) {
          setState(() {
            _cachedBytes = AtomUploadImage._memoryCache[cacheKey];
            _initialized = true;
          });
        }
        return;
      }

      try {
        String clean = widget.base64ImageData!;
        if (clean.contains(',')) clean = clean.split(',').last;
        final bytes = base64Decode(clean);
        AtomUploadImage._memoryCache[cacheKey] = bytes;
        if (mounted) {
          setState(() {
            _cachedBytes = bytes;
            _initialized = true;
          });
        }
        return;
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.uploadIcon != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Icon(widget.uploadIcon, color: kNeutralColor),
      );
    }

    if (_localFileExists && _cachedBytes != null) {
      final isSvg = Helpers.isSvgData(null, widget.labelImage);
      if (isSvg) {
        return SvgPicture.memory(
          _cachedBytes!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
      }
      return Image.memory(
        _cachedBytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _buildRemoteImage(),
      );
    }

    if (_cachedBytes != null) {
      return Image.memory(
        _cachedBytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    if (!_initialized) {
      return _buildLoadingPlaceholder();
    }

    return _buildRemoteImage();
  }

  Widget _buildRemoteImage() {
    if (widget.base64ImageData == null) {
      return SizedBox(width: widget.width, height: widget.height);
    }

    final isSvg = Helpers.isSvgData(widget.base64ImageData, widget.labelImage);

    if (isSvg) {
      return SvgPicture.network(
        widget.base64ImageData!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholderBuilder: (_) => _buildLoadingPlaceholder(),
      );
    }

    if (widget.base64ImageData!.contains('http')) {
      return CachedNetworkImage(
        imageUrl: widget.base64ImageData!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholder: (_, __) => _buildLoadingPlaceholder(),
        errorWidget: (_, __, ___) => _buildPlaceholder(),
        fadeInDuration: const Duration(milliseconds: 150),
        fadeOutDuration: const Duration(milliseconds: 150),
      );
    }

    return SizedBox(width: widget.width, height: widget.height);
  }

  Widget _buildLoadingPlaceholder() => Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey.withValues(alpha: .1),
      );

  Widget _buildPlaceholder() => Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey.withValues(alpha: 0.1),
        child: const Center(child: CircularProgressIndicator()),
      );
}
