import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../design_system/atoms/atom_image.dart';
import '../../constants/assets.dart';
import '../../enums/image_enum.dart';
import 'geo_location_info.dart';
import 'loading_widgets.dart';

class GeoLocationWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final GeoLocationInfo? locationInfo;
  final bool isLoading;
  final double width;
  final double height;
  final Color? backgroundColor;
  final bool isDarkMode;
  final MapController? mapController;
  final VoidCallback? onClose;
  final String? fallbackImageAsset;
  final double imageWidth;
  final double imageHeight;
  final bool initialShowDetails;

  const GeoLocationWidget({
    required this.latitude,
    required this.longitude,
    this.locationInfo,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 600,
    this.backgroundColor,
    this.isDarkMode = false,
    this.mapController,
    this.onClose,
    this.fallbackImageAsset,
    this.imageWidth = 140,
    this.imageHeight = 100,
    this.initialShowDetails = false,
    super.key,
  });

  @override
  State<GeoLocationWidget> createState() => _GeoLocationWidgetState();
}

class _GeoLocationWidgetState extends State<GeoLocationWidget> with TickerProviderStateMixin {
  bool _showDetails = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _showDetails = widget.initialShowDetails;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    if (_showDetails) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDetails() {
    setState(() {
      _showDetails = !_showDetails;
      if (_showDetails) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _hideDetails() {
    if (_showDetails) {
      setState(() {
        _showDetails = false;
        _animationController.reverse();
      });
    }

    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? (widget.isDarkMode ? Colors.grey[800] : Colors.grey[100]),
          ),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  final mapHeight = _showDetails ? 380.0 : widget.height;

                  return SizedBox(
                    width: double.infinity,
                    height: mapHeight,
                    child: _buildMap(context),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  if (!_showDetails && _slideAnimation.value == 0.0) {
                    return const SizedBox.shrink();
                  }

                  final panelHeight = widget.height - 460.0;
                  final slideOffset = (1.0 - _slideAnimation.value) * panelHeight;

                  return Positioned(
                    bottom: -slideOffset,
                    left: 0,
                    right: 0,
                    height: panelHeight,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildLocationInfo(context),
                    ),
                  );
                },
              ),
              if (_showDetails)
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) => Positioned(
                    top: 320,
                    left: 20,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildOverlayImage(context),
                    ),
                  ),
                ),
              if (_showDetails)
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) => Positioned(
                    top: 360,
                    right: 20,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildCloseButton(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

  Widget _buildMap(BuildContext context) => FlutterMap(
        mapController: widget.mapController,
        options: MapOptions(
          maxZoom: 20.0,
          minZoom: 0,
          initialZoom: 15.0,
          initialCenter: LatLng(widget.latitude, widget.longitude),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            maxZoom: 20.0,
            userAgentPackageName: 'com.your.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(widget.latitude, widget.longitude),
                width: 48,
                height: 48,
                child: GestureDetector(
                  onTap: () {
                    if (_showDetails) {
                      _openItinerary();
                    } else {
                      _toggleDetails();
                    }
                  },
                  child: AnimatedScale(
                    scale: _showDetails ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: AtomImage(
                      imageType: ImageEnum.vectorAssets,
                      assetPath: Assets.assetsImageMarker,
                      size: const Size(48, 48),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildLocationInfo(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isLoading)
              const LoadingText(width: 120)
            else
              Text(
                widget.locationInfo?.displayType ?? 'Lieu',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
              ),
            const SizedBox(height: 8),
            if (widget.isLoading)
              const LoadingText(width: 200, height: 20)
            else
              Text(
                widget.locationInfo?.displayName ?? 'Nom inconnu',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            const SizedBox(height: 8),
            if (widget.isLoading)
              LoadingDescription(
                isDarkMode: widget.isDarkMode,
              )
            else
              Expanded(
                child: Text(
                  widget.locationInfo?.displayDescription ?? 'Informations sur ce lieu non disponibles.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[600],
                      ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      );

  Widget _buildOverlayImage(BuildContext context) => Align(
        alignment: const Alignment(-0.8, 0.2),
        child: widget.isLoading
            ? LoadingImage(
                width: widget.imageWidth,
                height: widget.imageHeight,
              )
            : _buildLocationImage(),
      );

  Widget _buildLocationImage() {
    if (widget.locationInfo?.imageUrl != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        child: CachedNetworkImage(
          imageUrl: widget.locationInfo!.imageUrl!,
          width: widget.imageWidth,
          height: widget.imageHeight,
          fit: BoxFit.cover,
          placeholder: (context, url) => LoadingImage(
            width: widget.imageWidth,
            height: widget.imageHeight,
          ),
          errorWidget: (context, url, error) => _buildFallbackImage(),
        ),
      );
    }

    return _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    if (widget.fallbackImageAsset != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        child: Image.asset(
          widget.fallbackImageAsset!,
          width: widget.imageWidth,
          height: widget.imageHeight,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultPlaceholder(),
        ),
      );
    }

    return _buildDefaultPlaceholder();
  }

  Widget _buildDefaultPlaceholder() => Container(
        width: widget.imageWidth,
        height: widget.imageHeight,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        ),
        child: const Icon(
          Icons.location_on,
          size: 32,
          color: Colors.white,
        ),
      );

  Widget _buildCloseButton(BuildContext context) => SizedBox(
        width: 40,
        height: 40,
        child: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: .9),
          child: IconButton(
            onPressed: _hideDetails,
            icon: Icon(
              Icons.close,
              color: widget.isDarkMode ? Colors.black : Colors.grey[700],
              size: 20,
            ),
          ),
        ),
      );

  Future<void> _openItinerary() async {
    try {
      final placeName = widget.locationInfo?.name ?? 'Destination';
      final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}&destination_place_id=$placeName',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Impossible d'ouvrir l'itinéraire pour: $placeName");
      }
    } catch (e) {
      debugPrint("Erreur lors de l'ouverture de l'itinéraire: $e");
    }
  }
}

extension GeoLocationWidgetExtensions on GeoLocationWidget {
  GeoLocationWidget compact({
    double? width,
    double? height,
    bool? initialShowDetails,
  }) =>
      GeoLocationWidget(
        latitude: latitude,
        longitude: longitude,
        locationInfo: locationInfo,
        isLoading: isLoading,
        width: width ?? 300,
        height: height ?? 400,
        backgroundColor: backgroundColor,
        isDarkMode: isDarkMode,
        mapController: mapController,
        onClose: onClose,
        fallbackImageAsset: fallbackImageAsset,
        imageWidth: 100,
        imageHeight: 75,
        initialShowDetails: initialShowDetails ?? this.initialShowDetails,
      );

  GeoLocationWidget withoutImage() => GeoLocationWidget(
        latitude: latitude,
        longitude: longitude,
        locationInfo: locationInfo,
        isLoading: isLoading,
        width: width,
        height: height,
        backgroundColor: backgroundColor,
        isDarkMode: isDarkMode,
        mapController: mapController,
        onClose: onClose,
        imageWidth: 0,
        imageHeight: 0,
        initialShowDetails: initialShowDetails,
      );

  GeoLocationWidget withInitialDetails(bool showDetails) => GeoLocationWidget(
        latitude: latitude,
        longitude: longitude,
        locationInfo: locationInfo,
        isLoading: isLoading,
        width: width,
        height: height,
        backgroundColor: backgroundColor,
        isDarkMode: isDarkMode,
        mapController: mapController,
        onClose: onClose,
        fallbackImageAsset: fallbackImageAsset,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        initialShowDetails: showDetails,
      );
}
