import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/core.dart';
import '../../../../../core/extensions/tile_extension.dart';
import '../../../../../design_system/atoms/atom_text.dart';
import '../../../../../design_system/atoms/atom_upload_image.dart';
import '../../../../../router/navigation_service.dart';
import '../../../../../router/routes.dart';
import '../../../domain/modals/menu/menu.dart';
import '../../viewmodel/home_view_model.dart';

class WidgetDrawer extends StatelessWidget {
  const WidgetDrawer({super.key});

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widget) {
          final homeViewModel = ref.watch(homeProvider);
          return Container(
            margin: const EdgeInsets.all(10.0),
            child: Drawer(
              width: Helpers.getResponsiveWidth(context) * .9,
              child: Stack(
                children: [
                  Column(
                    children: [
                      // 70.ph,
                      _buildLogo(context, homeViewModel),
                      // 30.ph,
                      ListTile(
                        contentPadding: const EdgeInsets.only(left: 36),
                        title: AtomText(
                          data: 'Accueil',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        onTap: () => homeViewModel.scaffoldKey.currentState?.closeDrawer(),
                      ),
                      Expanded(
                        child: ListView(
                          controller: ScrollController(),
                          padding: EdgeInsets.zero,
                          children: [
                            for (Menu menu in ref.watch(homeViewModel.menuList))
                              if (menu.publicMenu ?? false)
                                ListTile(
                                  contentPadding: const EdgeInsets.only(left: 36),
                                  title: AtomText(
                                    data: menu.title ?? '',
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  onTap: () async {
                                    homeViewModel.scaffoldKey.currentState?.closeDrawer();
                                    if ((menu.typeLinkMenu ?? '') == '1') {
                                      await context.redirectToTile(ref, menu.tile ?? '', true);
                                    } else if ((menu.typeLinkMenu ?? '') == '2') {
                                      NavigationService.go(context,ref,Paths.urlTileWithScaffold, extra: menu.urlLink ?? '');
                                    }
                                  },
                                ),
                          ],
                        ),
                      ),
                      40.ph,
                      const Divider(
                        endIndent: 25,
                        indent: 25,
                      ),
                      30.ph,
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 36),
                        child: Row(
                          children: [
                            if ((homeViewModel.configApp.configuration?.urlFacebook ?? '').isNotEmpty) ...[
                              InkWell(
                                onTap: () => homeViewModel.launchSocialUrl(homeViewModel.configApp.configuration?.urlFacebook ?? ''),
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircleAvatar(
                                    backgroundColor: ref.watch(themeProvider).isDarkMode ? primaryDark : primaryLight,
                                    child: SvgPicture.asset(
                                      ref.watch(themeProvider).isDarkMode ? Assets.assetsImageFacebookDark : Assets.assetsImageFaceBookLight,
                                    ),
                                  ),
                                ),
                              ),
                              4.pw,
                            ],
                            if ((homeViewModel.configApp.configuration?.urlTwitter ?? '').isNotEmpty) ...[
                              InkWell(
                                onTap: () => homeViewModel.launchSocialUrl(homeViewModel.configApp.configuration?.urlTwitter ?? ''),
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircleAvatar(
                                    backgroundColor: ref.watch(themeProvider).isDarkMode ? primaryDark : primaryLight,
                                    child: SvgPicture.asset(
                                      ref.watch(themeProvider).isDarkMode ? Assets.assetsImageTwitterDark : Assets.assetsImageTwitterLight,
                                    ),
                                  ),
                                ),
                              ),
                              4.pw,
                            ],
                            if ((homeViewModel.configApp.configuration?.urlLinkedin ?? '').isNotEmpty) ...[
                              InkWell(
                                onTap: () => homeViewModel.launchSocialUrl(homeViewModel.configApp.configuration?.urlLinkedin ?? ''),
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircleAvatar(
                                    backgroundColor: ref.watch(themeProvider).isDarkMode ? primaryDark : primaryLight,
                                    child: SvgPicture.asset(
                                      ref.watch(themeProvider).isDarkMode ? Assets.assetsImageLinkedinDark : Assets.assetsImageLinkedinLight,
                                    ),
                                  ),
                                ),
                              ),
                              4.pw,
                            ],
                            if ((homeViewModel.configApp.configuration?.urlYoutube ?? '').isNotEmpty) ...[
                              InkWell(
                                onTap: () => homeViewModel.launchSocialUrl(homeViewModel.configApp.configuration?.urlYoutube ?? ''),
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircleAvatar(
                                    backgroundColor: ref.watch(themeProvider).isDarkMode ? primaryDark : primaryLight,
                                    child: SvgPicture.asset(
                                      ref.watch(themeProvider).isDarkMode ? Assets.assetsImageYoutubeDark : Assets.assetsImageYoutubeLight,
                                    ),
                                  ),
                                ),
                              ),
                              4.pw,
                            ],
                            if ((homeViewModel.configApp.configuration?.urlInstagram ?? '').isNotEmpty) ...[
                              InkWell(
                                onTap: () => homeViewModel.launchSocialUrl(homeViewModel.configApp.configuration?.urlInstagram ?? ''),
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircleAvatar(
                                    backgroundColor: ref.watch(themeProvider).isDarkMode ? primaryDark : primaryLight,
                                    child: SvgPicture.asset(
                                      ref.watch(themeProvider).isDarkMode ? Assets.assetsImageInstagramDark : Assets.assetsImageInstagramLight,
                                    ),
                                  ),
                                ),
                              ),
                              4.pw,
                            ],
                          ],
                        ),
                      ),
                      30.ph,
                      ListTile(
                        contentPadding: const EdgeInsets.only(left: 36),
                        title: Text(
                          'Réalisation : STRATIS V1.0.0',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                  Positioned(
                    top: 50,
                    right: 30,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircleAvatar(
                        backgroundColor: ref.watch(themeProvider).isDarkMode ? primaryLight : primaryDark,
                        child: IconButton(
                          onPressed: () => homeViewModel.scaffoldKey.currentState?.closeDrawer(),
                          icon: Icon(
                            Icons.close,
                            color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Widget _buildLogo(BuildContext context, HomeProvider homeViewModel) {
    final imgApp = homeViewModel.configApp.configuration?.logoApp;
    if (imgApp == null || (imgApp.url == null && imgApp.localPath == null)) {
      return const SizedBox(height: 80, width: double.infinity);
    }

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 36),
      height: 120,
      width: double.infinity,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Helpers.getResponsiveWidth(context) * .4,
          maxHeight: 100,
        ),
        child: AtomUploadImage(
          labelImage: imgApp.filename,
          base64ImageData: imgApp.url,
          localImagePath: imgApp.localPath,
          width: Helpers.getResponsiveWidth(context) * .4,
          height: 100,
        ),
      ),
    );
  }
}
