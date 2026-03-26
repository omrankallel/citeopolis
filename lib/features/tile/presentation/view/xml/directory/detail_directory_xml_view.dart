import 'package:badges/badges.dart' as bg;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../../core/core.dart';
import '../../../../../../../core/services/geo_localion_info/geo_location_widget.dart';
import '../../../../../../../design_system/atoms/atom_app_bar.dart';
import '../../../../../../../design_system/atoms/atom_floating_action_button_favorite.dart';
import '../../../../../../../design_system/atoms/atom_highlighted_text.dart';
import '../../../../../../../design_system/atoms/atom_no_result.dart';
import '../../../../../../../design_system/atoms/atom_text.dart';
import '../../../../../../../router/routes.dart';
import '../../../../../../router/navigation_service.dart';
import '../../../../../home/presentation/view/widget/build_widget_popup_menu.dart';
import '../../../../../notifications/presentation/view/widgets/notification_badge_widget.dart';
import '../../../../domain/modals/tile_xml.dart';
import '../../../../domain/modals/xml/xml_contact.dart';
import '../../../../domain/modals/xml/xml_directory.dart';
import '../../../../domain/modals/xml/xml_schedule.dart';
import '../../../viewmodel/xml/directory/detail_directory_xml_view_model.dart';
import '../../../viewmodel/xml/directory/directories_xml_view_model.dart';

class DetailDirectoryXmlView extends StatelessWidget {
  final TileXml tileXml;
  final Directory directory;
  final List<Directory>? allDirectories;

  const DetailDirectoryXmlView({
    required this.tileXml,
    required this.directory,
    this.allDirectories,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widgets) {
          final detailDirectoryXmlViewModel = ref.watch(detailDirectoryXmlProvider);
          final isDarkMode = ref.watch(themeProvider).isDarkMode;

          detailDirectoryXmlViewModel.initDirectoriesXml(ref, tileXml, allDirectories, directory);
          return SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              drawerEnableOpenDragGesture: false,
              appBar: AtomAppBarWithSearch(
                title: 'Annuaires',
                isDarkMode: isDarkMode,
                searchController: detailDirectoryXmlViewModel.searchController,
                onSearchChanged: (text) => detailDirectoryXmlViewModel.onSearchTextChanged(ref, directory, text),
                onSearchCleared: () => detailDirectoryXmlViewModel.onSearchTextChanged(ref, directory, ''),
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      detailDirectoryXmlViewModel.isInitialized = false;
                      detailDirectoryXmlViewModel.searchController.clear();
                      NavigationService.back(context, ref);
                    },
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                ),
                actions: [
                  NotificationIconBadge(
                    iconData: Icons.notifications_none_sharp,
                    onTap: () {
                      detailDirectoryXmlViewModel.searchController.clear();
                      NavigationService.push(context, ref, Paths.notifications);
                    },
                  ),
                  25.pw,
                  InkWell(
                    onTap: () {},
                    child: const bg.Badge(
                      showBadge: false,
                      child: WidgetPopupMenu(),
                    ),
                  ),
                  20.pw,
                ],
              ),
              body: _buildContent(context, ref, isDarkMode),
              floatingActionButton: _buildFavoriteButton(ref, isDarkMode),
            ),
          );
        },
      );

  Widget _buildContent(BuildContext context, WidgetRef ref, bool isDarkMode) {
    final detailDirectoryXmlViewModel = ref.watch(detailDirectoryXmlProvider);
    final orderedFields = detailDirectoryXmlViewModel.orderedFieldsListItem;

    final searchText = detailDirectoryXmlViewModel.searchController.text;
    final isEmpty = detailDirectoryXmlViewModel.isEmpty;

    return orderedFields.isEmpty
        ? const SizedBox()
        : isEmpty && searchText.isNotEmpty
            ? AtomNoResult(
                isDarkMode: isDarkMode,
                query: searchText,
                text: 'Directory',
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._buildDirectoryContent(context, ref, isDarkMode, searchText),
                        ],
                      ),
                    ),
                    _buildRecommendedSection(context, ref, isDarkMode),
                  ],
                ),
              );
  }

  List<Widget> _buildDirectoryContent(BuildContext context, WidgetRef ref, bool isDarkMode, String searchText) {
    final detailDirectoryXmlViewModel = ref.watch(detailDirectoryXmlProvider);
    final orderedFields = detailDirectoryXmlViewModel.orderedFieldsListItem;

    final List<Widget> widgets = [];

    String locationTitle = '';
    String locationAddress = '';
    String locationCity = '';
    String locationPostalCode = '';

    final List<String> dateParts = [];
    bool dateWidgetAdded = false;

    final dateFields = orderedFields.map((e) => (e.balise ?? '').toLowerCase()).where((b) => b == 'pubdate' || b == 'updatedate').toList();
    final String? lastDateField = dateFields.isNotEmpty ? dateFields.last : null;

    for (final field in orderedFields) {
      final fieldTag = (field.balise ?? '').toLowerCase();

      switch (fieldTag) {
        case 'title':
          if (directory.title.isNotEmpty) {
            widgets.addAll([
              15.ph,
              AtomHighlightedText(
                text: directory.title,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.headlineLarge!,
                isDarkMode: isDarkMode,
                overflow: TextOverflow.visible,
              ),
              25.ph,
            ]);
          }
          break;

        case 'summary':
          if (directory.summary.isNotEmpty) {
            widgets.addAll([
              25.ph,
              AtomHighlightedText(
                text: directory.summary,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                    ),
                isDarkMode: isDarkMode,
                overflow: TextOverflow.visible,
              ),
              25.ph,
            ]);
          }
          break;

        case 'mainimage':
          if (directory.mainImage.isNotEmpty) {
            widgets.addAll([
              25.ph,
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: directory.mainImage,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 50,
                          color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                        ),
                        8.ph,
                        Text(
                          'Image non disponible',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]);
          }
          break;

        case 'imagecaption':
          if (directory.imageCaption.isNotEmpty) {
            widgets.addAll([
              10.ph,
              AtomHighlightedText(
                text: directory.imageCaption,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      letterSpacing: 0.5,
                    ),
                isDarkMode: isDarkMode,
                overflow: TextOverflow.visible,
              ),
              25.ph,
            ]);
          }
          break;

        case 'content':
          if (directory.content.isNotEmpty) {
            widgets.addAll([
              25.ph,
              AtomHighlightedText(
                text: directory.content,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.labelSmall!,
                isDarkMode: isDarkMode,
                isHtml: true,
                overflow: TextOverflow.visible,
              ),
              25.ph,
            ]);
          }
          break;

        case 'category':
          if (directory.category.isNotEmpty) {
            widgets.addAll([
              20.ph,
              AtomHighlightedText(
                text: directory.category,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: isDarkMode ? primaryDark : primaryLight,
                    ),
                isDarkMode: isDarkMode,
                overflow: TextOverflow.visible,
              ),
              20.ph,
            ]);
          }
          break;

        case 'additionalinformation':
          if (directory.additionalInformation.isNotEmpty) {
            widgets.addAll([
              25.ph,
              AtomHighlightedText(
                text: directory.additionalInformation,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                    ),
                isDarkMode: isDarkMode,
                overflow: TextOverflow.visible,
              ),
              25.ph,
            ]);
          }
          break;

        case 'schedule':
          if (directory.schedule.isNotEmpty) {
            widgets.addAll([
              25.ph,
              _buildScheduleWidget(context, ref, directory.schedule, searchText, isDarkMode),
              25.ph,
            ]);
          }
          break;

        case 'website':
          if (directory.website.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildWebsiteWidget(context, directory.website, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;

        case 'phone1':
          if (directory.phone1.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildPhoneWidget(context, directory.phone1, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;

        case 'phone2':
          if (directory.phone2.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildPhoneWidget(context, directory.phone2, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;

        case 'email':
          if (directory.email.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildEmailWidget(context, directory.email, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;

        case 'contact':
          if (directory.contact.fullName.trim().isNotEmpty) {
            widgets.addAll([
              25.ph,
              _buildContactWidget(context, directory.contact, searchText, isDarkMode),
              25.ph,
            ]);
          }
          break;

        case 'facebook':
          if (directory.facebook.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildSocialWidget(context, 'facebook', directory.facebook, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;
        case 'twitter':
          if (directory.twitter.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildSocialWidget(context, 'twitter', directory.twitter, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;
        case 'instagram':
          if (directory.instagram.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildSocialWidget(context, 'instagram', directory.instagram, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;
        case 'linkedin':
          if (directory.linkedin.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildSocialWidget(context, 'linkedin', directory.linkedin, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;
        case 'youtube':
          if (directory.youtube.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildSocialWidget(context, 'youtube', directory.youtube, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;

        case 'location - title':
          if (directory.location.title.isNotEmpty) {
            locationTitle = directory.location.title;
          }
          break;

        case 'location - address':
          if (directory.location.address.isNotEmpty) {
            locationAddress = directory.location.address;
          }
          break;

        case 'location - city':
          if (directory.location.city.isNotEmpty) {
            locationCity = directory.location.city;
          }
          break;

        case 'location - postalcod':
          if (directory.location.postalCode.isNotEmpty) {
            locationPostalCode = directory.location.postalCode;
          }
          break;

        case 'location - latitude':
          break;

        case 'location - longitude':
          if (directory.location.latitude != 0.0 && directory.location.longitude != 0.0) {
            widgets.addAll([
              25.ph,
              _buildGeoLocationWidget(context, ref, directory, isDarkMode),
              25.ph,
            ]);
          } else {
            final combinedLocationText = _buildCombinedLocationText(
              locationTitle,
              locationAddress,
              locationCity,
              locationPostalCode,
            );

            if (combinedLocationText.isNotEmpty) {
              widgets.addAll([
                25.ph,
                AtomHighlightedText(
                  text: combinedLocationText,
                  searchQuery: searchText,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                      ),
                  isDarkMode: isDarkMode,
                  overflow: TextOverflow.visible,
                ),
                25.ph,
              ]);
            }
          }
          break;

        ///date de publication
        case 'pubdate':
          if (directory.pubDate.isNotEmpty) {
            dateParts.add('Publié le ${_formatDate(directory.pubDate)}');
          }
          break;

        ///date de mise à jour
        case 'updatedate':
          if (directory.updateDate.isNotEmpty) {
            dateParts.add('Mis à jour le ${_formatDate(directory.updateDate)}');
          }
          break;
        default:
          break;
      }
      if (!dateWidgetAdded && fieldTag == lastDateField && dateParts.isNotEmpty) {
        widgets.addAll([
          25.ph,
          const Divider(),
          10.ph,
          AtomHighlightedText(
            text: dateParts.join(' - ').toUpperCase(),
            searchQuery: searchText,
            style: Theme.of(context).textTheme.labelSmall!,
            isDarkMode: isDarkMode,
          ),
          10.ph,
          const Divider(),
          25.ph,
        ]);

        dateWidgetAdded = true;
      }
    }

    return widgets;
  }

  Widget _buildGeoLocationWidget(
    BuildContext context,
    WidgetRef ref,
    Directory entry,
    bool isDarkMode,
  ) =>
      Consumer(
        builder: (context, ref, child) {
          final detailDirectoryXmlViewModel = ref.watch(detailDirectoryXmlProvider);

          if (!detailDirectoryXmlViewModel.hasGeoLocationInfo(entry.location.latitude, entry.location.longitude)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              detailDirectoryXmlViewModel.fetchGeoLocationInfo(entry.location.latitude, entry.location.longitude);
            });
          }

          final isLoading = detailDirectoryXmlViewModel.isLoadingGeoLocation(entry.location.latitude, entry.location.longitude);
          final locationInfo = detailDirectoryXmlViewModel.getGeoLocationInfo(entry.location.latitude, entry.location.longitude);
          final mapController = MapController();

          return GeoLocationWidget(
            key: UniqueKey(),
            latitude: entry.location.latitude,
            longitude: entry.location.longitude,
            locationInfo: locationInfo,
            isLoading: isLoading,
            backgroundColor: isDarkMode ? surfaceContainerDark : surfaceContainerLight,
            isDarkMode: isDarkMode,
            mapController: mapController,
            onClose: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Informations du lieu fermées'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          );
        },
      );

  Widget _buildSocialWidget(BuildContext context, String platform, String url, String searchQuery, bool isDarkMode) => Container(
        padding: const EdgeInsets.all(10.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDarkMode ? surfaceContainerDark : surfaceContainerLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            if (url.isNotEmpty) {
              launchUrl(Uri.parse(url));
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircleAvatar(
                  backgroundColor: isDarkMode ? primaryDark : primaryLight,
                  child: SvgPicture.asset(
                    getSocialLogo(platform, isDarkMode),
                  ),
                ),
              ),
              8.pw,
              AtomHighlightedText(
                text: _capitalizeFirst(url),
                searchQuery: searchQuery,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                    ),
                isDarkMode: isDarkMode,
                overflow: TextOverflow.visible,
                underline: true,
              ),
            ],
          ),
        ),
      );

  Widget _buildScheduleWidget(BuildContext context, WidgetRef ref, List<Schedule> schedules, String searchQuery, bool isDarkMode) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? surfaceContainerDark : surfaceContainerLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AtomText(
              data: 'Horaires',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            12.ph,
            ...schedules.map(
              (schedule) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AtomHighlightedText(
                      text: schedule.dayName,
                      searchQuery: searchQuery,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w700,
                            color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                          ),
                      isDarkMode: isDarkMode,
                      overflow: TextOverflow.visible,
                    ),
                    AtomHighlightedText(
                      text: schedule.datetime,
                      searchQuery: searchQuery,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                          ),
                      isDarkMode: isDarkMode,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildWebsiteWidget(BuildContext context, String website, String searchQuery, bool isDarkMode) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? surfaceContainerDark : surfaceContainerLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            if (website.isNotEmpty) {
              launchUrl(Uri.parse(website));
            }
          },
          child: Row(
            children: [
              Icon(
                Icons.language,
                color: isDarkMode ? onSurfaceDark : onSurfaceLight,
              ),
              12.pw,
              Expanded(
                child: AtomHighlightedText(
                  text: website,
                  searchQuery: searchQuery,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                      ),
                  isDarkMode: isDarkMode,
                  overflow: TextOverflow.visible,
                  underline: true,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildPhoneWidget(BuildContext context, String phone, String searchQuery, bool isDarkMode) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? surfaceContainerDark : surfaceContainerLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            final telUrl = 'tel:$phone';
            launchUrl(Uri.parse(telUrl));
          },
          child: Row(
            children: [
              Icon(
                Icons.phone,
                color: isDarkMode ? onSurfaceDark : onSurfaceLight,
              ),
              12.pw,
              Expanded(
                child: AtomHighlightedText(
                  text: phone,
                  searchQuery: searchQuery,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                      ),
                  isDarkMode: isDarkMode,
                  overflow: TextOverflow.visible,
                  underline: true,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildEmailWidget(BuildContext context, String email, String searchQuery, bool isDarkMode) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? surfaceContainerDark : surfaceContainerLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            final emailUrl = 'mailto:$email';
            launchUrl(Uri.parse(emailUrl));
          },
          child: Row(
            children: [
              Icon(
                Icons.email,
                color: isDarkMode ? onSurfaceDark : onSurfaceLight,
              ),
              12.pw,
              Expanded(
                child: AtomHighlightedText(
                  text: email,
                  searchQuery: searchQuery,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                      ),
                  isDarkMode: isDarkMode,
                  overflow: TextOverflow.visible,
                  underline: true,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildContactWidget(BuildContext context, Contact contact, String searchQuery, bool isDarkMode) => Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDarkMode ? surfaceContainerDark : surfaceContainerLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AtomText(
              data: 'Contact',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            8.ph,
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                ),
                12.pw,
                AtomHighlightedText(
                  text: contact.fullName,
                  searchQuery: searchQuery,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                      ),
                  isDarkMode: isDarkMode,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
            if (contact.phone.isNotEmpty) ...[
              4.ph,
              InkWell(
                onTap: () {
                  final telUrl = 'tel:${contact.phone}';
                  launchUrl(Uri.parse(telUrl));
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                    ),
                    12.pw,
                    AtomHighlightedText(
                      text: contact.phone,
                      searchQuery: searchQuery,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                          ),
                      isDarkMode: isDarkMode,
                      overflow: TextOverflow.visible,
                      underline: true,
                    ),
                  ],
                ),
              ),
            ],
            if (contact.email.isNotEmpty) ...[
              4.ph,
              InkWell(
                onTap: () {
                  final emailUrl = 'mailto:${contact.email}';
                  launchUrl(Uri.parse(emailUrl));
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                    ),
                    12.pw,
                    AtomHighlightedText(
                      text: contact.email,
                      searchQuery: searchQuery,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                          ),
                      isDarkMode: isDarkMode,
                      overflow: TextOverflow.visible,
                      underline: true,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  String _buildCombinedLocationText(String title, String address, String city, String postalCode) {
    final List<String> parts = [];

    if (title.isNotEmpty) {
      parts.add(title);
    }

    if (address.isNotEmpty) {
      parts.add(address);
    }

    final cityPostal = <String>[];
    if (postalCode.isNotEmpty) {
      cityPostal.add(postalCode);
    }
    if (city.isNotEmpty) {
      cityPostal.add(city);
    }

    if (cityPostal.isNotEmpty) {
      parts.add(cityPostal.join(' '));
    }

    return parts.join('\n');
  }

  String getSocialLogo(String platform, bool isDarkMode) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return isDarkMode ? Assets.assetsImageFacebookDark : Assets.assetsImageFaceBookLight;
      case 'twitter':
        return isDarkMode ? Assets.assetsImageTwitterDark : Assets.assetsImageTwitterLight;
      case 'instagram':
        return isDarkMode ? Assets.assetsImageInstagramDark : Assets.assetsImageInstagramLight;
      case 'linkedin':
        return isDarkMode ? Assets.assetsImageLinkedinDark : Assets.assetsImageLinkedinLight;
      case 'youtube':
        return isDarkMode ? Assets.assetsImageYoutubeDark : Assets.assetsImageYoutubeLight;
      default:
        return isDarkMode ? Assets.assetsImageFacebookDark : Assets.assetsImageFaceBookLight;
    }
  }

  String _formatDate(String dateString) {
    try {
      return DateFormat('MM/dd/yyyy').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  Widget _buildRecommendedSection(BuildContext context, WidgetRef ref, bool isDarkMode) {
    final detailDirectoryXmlViewModel = ref.watch(detailDirectoryXmlProvider);
    final recommendedDirectories = detailDirectoryXmlViewModel.getRecommendedDirectories(directory, ref);

    if (recommendedDirectories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: isDarkMode ? surfaceContainerDark : surfaceContainerLight,
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          30.ph,
          AtomText(
            data: 'À lire aussi...',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                ),
          ),
          15.ph,
          SizedBox(
            height: 325,
            child: ListView.separated(
              itemCount: recommendedDirectories.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final directory = recommendedDirectories[index];
                final isLast = index == recommendedDirectories.length - 1;
                if (isLast) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: _buildRecommendedCard(context, ref, directory, isDarkMode),
                  );
                }
                return _buildRecommendedCard(context, ref, directory, isDarkMode);
              },
              separatorBuilder: (context, index) => const SizedBox(width: 16),
            ),
          ),
          80.ph,
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context, WidgetRef ref, Directory directory, bool isDarkMode) => InkWell(
        onTap: () {
          final detailDirectoryXmlViewModel = ref.read(detailDirectoryXmlProvider);
          detailDirectoryXmlViewModel.isInitialized = false;
          detailDirectoryXmlViewModel.searchController.clear();
          NavigationService.push(
            context,
            ref,
            Paths.detailDirectoryXml,
            extra: {
              'tileXml': tileXml,
              'directoryXml': directory,
              'allDirectories': allDirectories,
            },
          );
        },
        child: SizedBox(
          width: Helpers.getResponsiveWidth(context) * .7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildRecommendedCardContent(context, ref, directory, isDarkMode),
          ),
        ),
      );

  List<Widget> _buildRecommendedCardContent(BuildContext context, WidgetRef ref, Directory directory, bool isDarkMode) {
    final detailViewModel = ref.read(detailDirectoryXmlProvider);
    final fieldsConfig = ref.watch(detailViewModel.fieldsConfiguration);
    final fieldsToUse = fieldsConfig.isNotEmpty ? fieldsConfig : ref.read(directoriesXmlProvider).orderedFieldsSingleList;

    final widgets = <Widget>[];
    for (final field in fieldsToUse) {
      final fieldTag = (field.balise ?? '').toLowerCase();

      switch (fieldTag) {
        case 'title':
          if (directory.title.isNotEmpty) {
            widgets.addAll([
              SizedBox(
                height: 80,
                child: AtomHighlightedText(
                  text: directory.title,
                  searchQuery: '',
                  style: Theme.of(context).textTheme.titleLarge!,
                  isDarkMode: isDarkMode,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              15.ph,
            ]);
          }
          break;

        case 'mainimage':
          if (directory.mainImage.isNotEmpty) {
            widgets.addAll([
              Material(
                elevation: 4,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: directory.mainImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 160,
                  ),
                ),
              ),
              15.ph,
            ]);
          }
          break;

        case 'category':
          if (directory.category.isNotEmpty) {
            widgets.addAll([
              SizedBox(
                height: 30,
                child: AtomHighlightedText(
                  text: directory.category,
                  searchQuery: '',
                  style: Theme.of(context).textTheme.titleMedium!,
                  isDarkMode: isDarkMode,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              15.ph,
            ]);
          } else {
            widgets.add(45.ph);
          }
          break;
      }
    }

    return widgets;
  }

  Widget _buildFavoriteButton(WidgetRef ref, bool isDarkMode) {
    final detailDirectoryXmlViewModel = ref.watch(detailDirectoryXmlProvider);
    final isFavorite = ref.watch(detailDirectoryXmlViewModel.isFavorite);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AtomFloatingActionButtonFavorite(
          heroTag: 'directoryXmlViewWrapper${detailDirectoryXmlViewModel.favoriteButtonTag}',
          onPressed: () => detailDirectoryXmlViewModel.onPressFavorite(ref, tileXml, directory),
          assetPath: Assets.assetsImageSaveDark,
          isDarkMode: isDarkMode,
          isFavorite: isFavorite,
        ),
        10.ph,
      ],
    );
  }
}
