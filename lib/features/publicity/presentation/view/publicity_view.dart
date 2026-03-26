import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../core/extensions/tile_extension.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../design_system/atoms/atom_error_connexion.dart';
import '../../../../design_system/atoms/atom_text.dart';
import '../../../../design_system/atoms/atom_upload_image.dart';
import '../../../../router/routes.dart';
import '../../../../shared_widgets/custom_button.dart';
import '../viewmodel/publicity_list_view_model.dart';
import '../viewmodel/publicity_view_model.dart';

class PublicityView extends StatelessWidget {
  const PublicityView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        body: Consumer(
          builder: (context, ref, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(connectivityProvider).setContext(context);
            });

            final publicityViewModel = ref.watch(publicityProvider);

            return ref.watch(publicityListProvider).maybeMap(
                  orElse: () => const Center(child: CircularProgressIndicator(color: Color(0xFFCA542B))),
                  success: (publicity) {
                    publicity.data.fold((l) => Container(), (pub) async {
                      publicityViewModel.initialisePublicity(ref, pub);
                    });

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Consumer(
                            builder: (context, ref, widget) {
                              final publicityViewModel = ref.watch(publicityProvider);
                              final imgApp = ref.watch(publicityViewModel.publicity).imgPublicity;
                              if (imgApp == null || (imgApp.url == null && imgApp.localPath == null)) {
                                return const SizedBox();
                              }
                              return AtomUploadImage(
                                labelImage: imgApp.filename,
                                base64ImageData: imgApp.url,
                                localImagePath: imgApp.localPath,
                                fit: BoxFit.fill,
                              );
                            },
                          ),
                        ),
                        if (publicityViewModel.getPosition(ref) != 'Masquer')
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            alignment: publicityViewModel.positionedPublicity(ref),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  children: [
                                    if (publicityViewModel.positionedPublicity(ref) == Alignment.topCenter) (MediaQuery.of(context).size.height * .1).ph,
                                    Consumer(
                                      builder: (context, ref, widget) {
                                        final publicityViewModel = ref.watch(publicityProvider);
                                        return AtomText(
                                          data: ref.watch(publicityViewModel.publicity).titlePublicity ?? '',
                                          style: TextStyle(
                                            color: ref.watch(publicityViewModel.textColor),
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 28,
                                            height: 32 / 28,
                                          ),
                                          textAlign: TextAlign.center,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    Consumer(
                                      builder: (context, ref, widget) {
                                        final publicityViewModel = ref.watch(publicityProvider);
                                        return AtomText(
                                          data: ref.watch(publicityViewModel.publicity).leadPublicity ?? '',
                                          style: TextStyle(
                                            color: ref.watch(publicityViewModel.textColor),
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 24,
                                            height: 28 / 24,
                                          ),
                                          textAlign: TextAlign.center,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    Consumer(
                                      builder: (context, ref, widget) {
                                        final publicityViewModel = ref.watch(publicityProvider);
                                        return ref.watch(publicityViewModel.publicity).showButton ?? false
                                            ? CustomButtons.elevatePrimary(
                                                onPressed: () async {
                                                  publicityViewModel.cancelPublicityTimer();

                                                  if (ref.watch(publicityViewModel.publicity).typeLinkPublicity == '1') {
                                                    await context.redirectToTile(ref, ref.watch(publicityViewModel.publicity).tile ?? '', true);
                                                  } else if (ref.watch(publicityViewModel.publicity).typeLinkPublicity == '2') {
                                                    await goRouter.push(
                                                      Paths.urlTileWithScaffold,
                                                      extra: {
                                                        'url': ref.watch(publicityViewModel.publicity).urlLink ?? '',
                                                        'isTile': false,
                                                      },
                                                    );
                                                  }
                                                },
                                                buttonColor: kButtonColor1,
                                                title: ref.watch(publicityViewModel.publicity).buttonText ?? '',
                                                titleStyle: const TextStyle(
                                                  color: onPrimaryLight,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                width: 180,
                                                borderRadius: 50,
                                              )
                                            : const SizedBox();
                                      },
                                    ),
                                    if (publicityViewModel.positionedPublicity(ref) == Alignment.bottomCenter) (MediaQuery.of(context).size.height * .1).ph,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 50,
                          right: 30,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  publicityViewModel.cancelPublicityTimer();
                                  goRouter.pushReplacement(Paths.contentHome);
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: const Color(0xFFCCDAF5),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.close,
                                    color: Color(0xFF214FAB),
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  error: (error) => AtomErrorConnexion(
                    onTap: () {
                      ref.read(publicityViewModelStateNotifierProvider.notifier).getPublicityProjectFromLocal();
                    },
                  ),
                );
          },
        ),
      ),
    );
  }
}
