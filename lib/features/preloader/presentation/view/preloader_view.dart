import 'dart:async';

import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../design_system/atoms/atom_error_connexion.dart';
import '../../../../design_system/atoms/atom_upload_image.dart';
import '../../../../shared_widgets/custom_fade_in_animation.dart';
import '../viewmodel/preloader_list_view_model.dart';
import '../viewmodel/preloader_view_model.dart';

class PreloaderView extends ConsumerStatefulWidget {
  const PreloaderView({super.key});

  @override
  ConsumerState<PreloaderView> createState() => _PreloaderViewState();
}

class _PreloaderViewState extends ConsumerState<PreloaderView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );
      ref.read(preloaderProvider).timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
        ref.read(preloaderProvider).changeContainerProperties(context);
      });
    });
  }

  var visible = true;

  @override
  Widget build(BuildContext context) {
    final preloaderViewModel = ref.watch(preloaderProvider);
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: preloaderViewModel.step == 3
            ? ref.watch(preloaderListProvider).maybeMap(
                  orElse: () => Container(
                    alignment: Alignment.center,
                    color: const Color(0xff214FAB),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                  success: (preloader) {
                    preloader.data.fold((l) => Container(), (config) async {
                      await preloaderViewModel.initialisePreloader(ref, config);
                    });
                    return ColoredBox(
                      color: const Color(0xff214FAB),
                      child: Stack(
                        children: [
                          _buildBackgroundImage(preloaderViewModel),
                          // _buildBlurFilter(preloaderViewModel),
                          _buildMainContent(preloaderViewModel),
                          _buildPartnerLogos(preloaderViewModel),
                        ],
                      ),
                    );
                  },
                  error: (error) => AtomErrorConnexion(
                    onTap: () => ref.read(preloaderViewModelStateNotifierProvider.notifier).loadPreloaderConfig(),
                  ),
                )
            : Center(
                child: AnimatedContainer(
                  width: preloaderViewModel.width,
                  height: preloaderViewModel.height,
                  decoration: BoxDecoration(
                    color: const Color(0xff214FAB),
                    borderRadius: preloaderViewModel.borderRadius,
                  ),
                  duration: const Duration(milliseconds: 300),
                ),
              ),
      ),
    );
  }

  Widget _buildBackgroundImage(PreloaderProvider preloaderViewModel) {
    final imgApp = ref.watch(ref.read(preloaderProvider).configApp).configuration?.backgroundApp;

    if (imgApp == null || (imgApp.url == null && imgApp.localPath == null)) return const SizedBox.shrink();

    return Positioned.fill(
      child: Opacity(
        opacity: 0.3,
        child: AtomUploadImage(
          labelImage: imgApp.filename,
          base64ImageData: imgApp.url,
          localImagePath: imgApp.localPath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Widget _buildBlurFilter(PreloaderProvider preloaderViewModel) => Positioned.fill(
  //       child: BackdropFilter(
  //         filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
  //         child: Container(color: Colors.transparent),
  //       ),
  //     );

  Widget _buildMainContent(PreloaderProvider preloaderViewModel) {
    final configuration = ref.watch(preloaderViewModel.configApp).configuration;
    final positionTitle = configuration?.positionTitle;

    if (positionTitle == null || positionTitle == 'hide') {
      return const SizedBox.shrink();
    }

    final alignment = ref.read(preloaderProvider).positionedBloc(positionTitle);

    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: preloaderViewModel.getMainAxisAlignment(alignment),
          children: [
            if (alignment == Alignment.topCenter) SizedBox(height: Helpers.getResponsiveHeight(context) * 0.07),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(preloaderViewModel),
                  20.ph,
                  _buildTitle(preloaderViewModel),
                  10.ph,
                  _buildLead(preloaderViewModel),
                  20.ph,
                  const CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
            if (alignment == Alignment.bottomCenter) 120.ph,
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(PreloaderProvider preloaderViewModel) {
    final imgApp = ref.watch(preloaderViewModel.configApp).configuration?.logoApp;
    if (imgApp == null || (imgApp.url == null && imgApp.localPath == null)) {
      return const SizedBox();
    }

    double displayWidth = 200;
    double displayHeight = 200;

    final double? width = imgApp.width;
    final double? height = imgApp.height;
    if (width != null && height != null && width > 0 && height > 0) {
      final double ratio = width / height;

      if (width > height) {
        displayWidth = 200;
        displayHeight = 200 / ratio;
      } else {
        displayHeight = 200;
        displayWidth = 200 * ratio;
      }

      if (displayWidth > 200) {
        displayWidth = 200;
        displayHeight = 200 / ratio;
      }
      if (displayHeight > 200) {
        displayHeight = 200;
        displayWidth = 200 * ratio;
      }
    }

    return CustomFadeInAnimation(
      delay: 1,
      isTop: false,
      child: SizedBox(
        width: displayWidth,
        height: displayHeight,
        child: AtomUploadImage(
          labelImage: imgApp.filename,
          base64ImageData: imgApp.url,
          localImagePath: imgApp.localPath,
        ),
      ),
    );
  }

  Widget _buildTitle(PreloaderProvider preloaderViewModel) {
    final title = ref.watch(preloaderViewModel.configApp).configuration?.titleApp;
    if (title == null) return const SizedBox.shrink();

    return Text(
      title,
      style: const TextStyle(
        fontSize: 28,
        color: Colors.white,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        height: 36 / 28,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLead(PreloaderProvider preloaderViewModel) {
    final lead = ref.watch(preloaderViewModel.configApp).configuration?.leadApp;
    if (lead == null) return const SizedBox.shrink();

    return Text(
      lead,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPartnerLogos(PreloaderProvider preloaderViewModel) {
    final partners = ref.watch(ref.read(preloaderProvider).configApp).configuration?.partnerRepeater;

    if (partners == null || partners.isEmpty) {
      return const Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SizedBox.shrink(),
      );
    }

    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: partners.asMap().entries.map((entry) {
          final index = entry.key;
          final imgApp = entry.value;

          if (imgApp.url == null && imgApp.localPath == null) {
            return const SizedBox();
          }

          return Flexible(
            child: Entry.offset(
              xOffset: index > 1 ? 100 : -100,
              yOffset: 0,
              duration: const Duration(seconds: 2),
              child: SizedBox(
                width: 80,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AtomUploadImage(
                    labelImage: imgApp.filename,
                    base64ImageData: imgApp.url,
                    localImagePath: imgApp.localPath,
                    height: 80,
                    width: 80,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
