import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
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
import '../../../../router/navigation_service.dart';
import '../../../home/presentation/view/widget/build_widget_popup_menu.dart';
import '../../../notifications/presentation/view/widgets/notification_badge_widget.dart';
import '../../domain/modals/tile_map.dart';
import '../../domain/modals/xml_map.dart';
import '../viewmodel/detail_map_xml_view_model.dart';
import '../viewmodel/map_view_model.dart';

class DetailMapXmlView extends StatelessWidget {
  final TileMap tileMap;
  final MapXml map;
  final List<MapXml>? allMap;

  const DetailMapXmlView({
    required this.tileMap,
    required this.map,
    this.allMap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widgets) {
          final detailMapXmlViewModel = ref.watch(detailMapXmlProvider);
          final isDarkMode = ref.watch(themeProvider).isDarkMode;

          detailMapXmlViewModel.initMapXml(ref, tileMap, allMap, map);
          return SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              drawerEnableOpenDragGesture: false,
              appBar: AtomAppBarWithSearch(
                title: 'Cartes',
                isDarkMode: isDarkMode,
                searchController: detailMapXmlViewModel.searchController,
                onSearchChanged: (text) => detailMapXmlViewModel.onSearchTextChanged(ref, map, text),
                onSearchCleared: () => detailMapXmlViewModel.onSearchTextChanged(ref, map, ''),
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      detailMapXmlViewModel.isInitialized = false;
                      detailMapXmlViewModel.searchController.clear();
                      NavigationService.back(context, ref);
                    },
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                ),
                actions: [
                  NotificationIconBadge(
                    iconData: Icons.notifications_none_sharp,
                    onTap: () {
                      detailMapXmlViewModel.searchController.clear();
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
    final detailMapXmlViewModel = ref.watch(detailMapXmlProvider);
    final orderedFields = detailMapXmlViewModel.orderedFieldsListItem;

    final searchText = detailMapXmlViewModel.searchController.text;
    final isEmpty = detailMapXmlViewModel.isEmpty;

    return orderedFields.isEmpty
        ? const SizedBox()
        : isEmpty && searchText.isNotEmpty
            ? AtomNoResult(
                isDarkMode: isDarkMode,
                query: searchText,
                text: 'MapXml',
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
                          ..._buildMapXmlContent(context, ref, isDarkMode, searchText),
                        ],
                      ),
                    ),
                    _buildRecommendedSection(context, ref, isDarkMode),
                  ],
                ),
              );
  }

  List<Widget> _buildMapXmlContent(BuildContext context, WidgetRef ref, bool isDarkMode, String searchText) {
    final detailMapXmlViewModel = ref.watch(detailMapXmlProvider);
    final orderedFields = detailMapXmlViewModel.orderedFieldsListItem;

    final List<Widget> widgets = [];

    String locationTitle = '';
    String locationAddress = '';
    String locationCity = '';
    String locationPostalCode = '';

    final List<String> dateParts = [];
    bool dateWidgetAdded = false;

    final dateFields = orderedFields.map((e) => (e.balise ?? '').toLowerCase()).where((b) => b == 'pubdate' || b == 'updatedate').toList();
    final String? lastDateField = dateFields.isNotEmpty ? dateFields.last : null;

    final List<String> eventDateParts = [];
    bool eventDateWidgetAdded = false;

    final eventDateFields = orderedFields.map((e) => (e.balise ?? '').toLowerCase()).where((b) => b == 'eventstartdate' || b == 'eventenddate').toList();

    final String? lastEventDateField = eventDateFields.isNotEmpty ? eventDateFields.last : null;

    final List<String> eventTimeParts = [];
    bool eventTimeWidgetAdded = false;

    final eventTimeFields = orderedFields.map((e) => (e.balise ?? '').toLowerCase()).where((b) => b == 'eventstarttime' || b == 'eventendtime').toList();

    final String? lastEventTimeField = eventTimeFields.isNotEmpty ? eventTimeFields.last : null;

    for (final field in orderedFields) {
      final fieldTag = (field.balise ?? '').toLowerCase();

      switch (fieldTag) {
        case 'title':
          if (map.title.isNotEmpty) {
            widgets.addAll([
              15.ph,
              AtomHighlightedText(
                text: map.title,
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
          if (map.summary.isNotEmpty) {
            widgets.addAll([
              25.ph,
              AtomHighlightedText(
                text: map.summary,
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
          if (map.mainImage.isNotEmpty) {
            widgets.addAll([
              25.ph,
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: map.mainImage,
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
          if (map.imageCaption.isNotEmpty) {
            widgets.addAll([
              10.ph,
              AtomHighlightedText(
                text: map.imageCaption,
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
          if (map.content.isNotEmpty) {
            widgets.addAll([
              25.ph,
              AtomHighlightedText(
                text: map.content,
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
          if (map.category.isNotEmpty) {
            widgets.addAll([
              20.ph,
              AtomHighlightedText(
                text: map.category,
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
          if (map.additionalInformation.isNotEmpty) {
            widgets.addAll([
              25.ph,
              AtomHighlightedText(
                text: map.additionalInformation,
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
          if (map.schedule.isNotEmpty) {
            widgets.addAll([
              25.ph,
              _buildScheduleWidget(context, ref, map.schedule, searchText, isDarkMode),
              25.ph,
            ]);
          }
          break;

        case 'website':
          if (map.website.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildWebsiteWidget(context, map.website, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;

        case 'phone1':
          if (map.phone1.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildPhoneWidget(context, map.phone1, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;

        case 'phone2':
          if (map.phone2.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildPhoneWidget(context, map.phone2, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;

        case 'email':
          if (map.email.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildEmailWidget(context, map.email, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;

        case 'contact':
          if (map.contact.fullName.trim().isNotEmpty) {
            widgets.addAll([
              25.ph,
              _buildContactWidget(context, map.contact, searchText, isDarkMode),
              25.ph,
            ]);
          }
          break;

        case 'facebook':
          if (map.facebook.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildSocialWidget(context, 'facebook', map.facebook, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;
        case 'twitter':
          if (map.twitter.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildSocialWidget(context, 'twitter', map.twitter, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;
        case 'instagram':
          if (map.instagram.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildSocialWidget(context, 'instagram', map.instagram, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;
        case 'linkedin':
          if (map.linkedin.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildSocialWidget(context, 'linkedin', map.linkedin, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;
        case 'youtube':
          if (map.youtube.isNotEmpty) {
            widgets.addAll([
              15.ph,
              _buildSocialWidget(context, 'youtube', map.youtube, searchText, isDarkMode),
              15.ph,
            ]);
          }
          break;

        case 'location - title':
          if (map.location.title.isNotEmpty) {
            locationTitle = map.location.title;
          }
          break;

        case 'location - address':
          if (map.location.address.isNotEmpty) {
            locationAddress = map.location.address;
          }
          break;

        case 'location - city':
          if (map.location.city.isNotEmpty) {
            locationCity = map.location.city;
          }
          break;

        case 'location - postalcod':
          if (map.location.postalCode.isNotEmpty) {
            locationPostalCode = map.location.postalCode;
          }
          break;

        case 'location - latitude':
          break;

        case 'location - longitude':
          if (map.location.latitude != 0.0 && map.location.longitude != 0.0) {
            widgets.addAll([
              25.ph,
              _buildGeoLocationWidget(context, ref, map, isDarkMode),
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
        case 'download':
          break;
        case 'download - icon':
          break;
        case 'download - title':
          break;
        case 'download - type':
          break;
        case 'download - size':
          break;
        case 'download - link':
          if (_shouldShowDownloadWidget(map.downloadFile)) {
            widgets.addAll([
              25.ph,
              _buildDownloadWidget(context, map.downloadFile, searchText, isDarkMode),
              25.ph,
            ]);
          }
          break;

        ///date de publication
        case 'pubdate':
          if (map.pubDate.isNotEmpty) {
            dateParts.add('Publié le ${_formatDate(map.pubDate)}');
          }
          break;

        ///date de mise à jour
        case 'updatedate':
          if (map.updateDate.isNotEmpty) {
            dateParts.add('Mis à jour le ${_formatDate(map.updateDate)}');
          }
          break;
        case 'eventstarttime':
          if (map.eventStartTime.isNotEmpty) {
            eventTimeParts.add(map.eventStartTime);
          }
          break;
        case 'eventendtime':
          if (map.eventEndTime.isNotEmpty) {
            eventTimeParts.add(map.eventEndTime);
          }
          break;

        case 'eventstartdate':
          if (map.eventStartDate.isNotEmpty) {
            eventDateParts.add(map.eventStartDate);
          }
          break;
        case 'eventenddate':
          if (map.eventEndDate.isNotEmpty) {
            eventDateParts.add(map.eventEndDate);
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
      if (!eventDateWidgetAdded && fieldTag == lastEventDateField && eventDateParts.isNotEmpty) {
        if (eventDateParts.length == 2) {
          eventDateParts[0] = 'Du ${_formatDate(eventDateParts[0])}';
          eventDateParts[1] = 'au ${_formatDate(eventDateParts[1])}';
        } else if (eventDateParts.length == 1) {
          eventDateParts[0] = 'Le ${_formatDate(eventDateParts[0])}';
        }
        widgets.addAll([
          15.ph,
          InkWell(
            onTap: () => _addToCalendar(),
            child: AtomHighlightedText(
              text: eventDateParts.join(' '),
              searchQuery: searchText,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: isDarkMode ? primaryDark : primaryLight,
                  ),
              isDarkMode: isDarkMode,
              maxLines: 3,
            ),
          ),
          10.ph,
        ]);

        eventDateWidgetAdded = true;
      }

      if (!eventTimeWidgetAdded && fieldTag == lastEventTimeField && eventTimeParts.isNotEmpty) {
        if (eventTimeParts.length == 2) {
          eventTimeParts[0] = 'de ${eventTimeParts[0]}';
          eventTimeParts[1] = 'à ${eventTimeParts[1]}';
        } else if (eventTimeParts.length == 1) {
          eventTimeParts[0] = 'à ${eventTimeParts[0]}';
        }
        widgets.addAll([
          0.ph,
          AtomHighlightedText(
            text: eventTimeParts.join(' '),
            searchQuery: searchText,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: isDarkMode ? primaryDark : primaryLight,
                ),
            isDarkMode: isDarkMode,
            maxLines: 2,
          ),
          20.ph,
        ]);

        eventTimeWidgetAdded = true;
      }
    }

    return widgets;
  }

  void _addToCalendar() {
    DateTime startDate = DateTime.tryParse(map.eventStartDate) ?? DateTime.now();
    DateTime endDate = map.eventEndDate.isNotEmpty ? DateTime.tryParse(map.eventEndDate) ?? startDate : startDate;

    if (map.eventStartTime.isNotEmpty) {
      final timeParts = map.eventStartTime.split(':');
      if (timeParts.length >= 2) {
        startDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          int.tryParse(timeParts[0]) ?? 0,
          int.tryParse(timeParts[1]) ?? 0,
        );
      }
    }

    if (map.eventEndTime.isNotEmpty) {
      final timeParts = map.eventEndTime.split(':');
      if (timeParts.length >= 2) {
        endDate = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          int.tryParse(timeParts[0]) ?? 0,
          int.tryParse(timeParts[1]) ?? 0,
        );
      }
    }

    final calendar.Event calendarEvent = calendar.Event(
      title: map.title,
      description: map.summary,
      location: map.location.address,
      startDate: startDate,
      endDate: endDate,
    );

    calendar.Add2Calendar.addEvent2Cal(calendarEvent);
  }

  Widget _buildGeoLocationWidget(
    BuildContext context,
    WidgetRef ref,
    MapXml entry,
    bool isDarkMode,
  ) =>
      Consumer(
        builder: (context, ref, child) {
          final detailMapXmlViewModel = ref.watch(detailMapXmlProvider);

          if (!detailMapXmlViewModel.hasGeoLocationInfo(entry.location.latitude, entry.location.longitude)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              detailMapXmlViewModel.fetchGeoLocationInfo(entry.location.latitude, entry.location.longitude);
            });
          }

          final isLoading = detailMapXmlViewModel.isLoadingGeoLocation(entry.location.latitude, entry.location.longitude);
          final locationInfo = detailMapXmlViewModel.getGeoLocationInfo(entry.location.latitude, entry.location.longitude);
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

  bool _shouldShowDownloadWidget(DownloadFile downloadFile) => downloadFile.link.isNotEmpty || downloadFile.title.isNotEmpty || downloadFile.type.isNotEmpty || downloadFile.size.isNotEmpty;

  Widget _buildDownloadWidget(BuildContext context, DownloadFile downloadFile, String searchQuery, bool isDarkMode) => Container(
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: isDarkMode ? onPrimaryDark : onPrimaryLight,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            const BoxShadow(
              color: Color(0x26000000),
              blurRadius: 23.2,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (downloadFile.title.isNotEmpty) ...[
                    AtomHighlightedText(
                      text: downloadFile.title,
                      searchQuery: searchQuery,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                          ),
                      isDarkMode: isDarkMode,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    8.ph,
                  ],
                  Row(
                    children: [
                      if (downloadFile.type.isNotEmpty) ...[
                        AtomHighlightedText(
                          text: downloadFile.type.toUpperCase(),
                          searchQuery: searchQuery,
                          style: Theme.of(context).textTheme.labelSmall!,
                          isDarkMode: isDarkMode,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                      if (downloadFile.type.isNotEmpty && downloadFile.size.isNotEmpty) ...[
                        AtomHighlightedText(
                          text: ' - ',
                          searchQuery: searchQuery,
                          style: Theme.of(context).textTheme.labelSmall!,
                          isDarkMode: isDarkMode,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                      if (downloadFile.size.isNotEmpty) ...[
                        AtomHighlightedText(
                          text: downloadFile.size,
                          searchQuery: searchQuery,
                          style: Theme.of(context).textTheme.labelSmall!,
                          isDarkMode: isDarkMode,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (downloadFile.link.isNotEmpty) ...[
              16.pw,
              GestureDetector(
                onTap: () => _downloadFile(context, downloadFile.link),
                child: Icon(
                  Icons.save_alt,
                  color: isDarkMode ? primaryDark : primaryLight,
                ),
              ),
            ],
          ],
        ),
      );

  Future<void> _downloadFile(BuildContext context, String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Impossible d'ouvrir le lien de téléchargement"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    final detailMapXmlViewModel = ref.watch(detailMapXmlProvider);
    final recommendedMap = detailMapXmlViewModel.getRecommendedMapXml(map, ref);

    if (recommendedMap.isEmpty) {
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
              itemCount: recommendedMap.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final map = recommendedMap[index];
                final isLast = index == recommendedMap.length - 1;
                if (isLast) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: _buildRecommendedCard(context, ref, map, isDarkMode),
                  );
                }
                return _buildRecommendedCard(context, ref, map, isDarkMode);
              },
              separatorBuilder: (context, index) => const SizedBox(width: 16),
            ),
          ),
          80.ph,
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context, WidgetRef ref, MapXml map, bool isDarkMode) => InkWell(
        onTap: () {
          final detailMapXmlViewModel = ref.read(detailMapXmlProvider);
          detailMapXmlViewModel.isInitialized = false;
          detailMapXmlViewModel.searchController.clear();
          NavigationService.push(
            context,
            ref,
            Paths.detailCarte,
            extra: {
              'tileMap': tileMap,
              'map': map,
              'allMap': allMap,
            },
          );
        },
        child: SizedBox(
          width: Helpers.getResponsiveWidth(context) * .7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildRecommendedCardContent(context, ref, map, isDarkMode),
          ),
        ),
      );

  List<Widget> _buildRecommendedCardContent(BuildContext context, WidgetRef ref, MapXml map, bool isDarkMode) {
    final detailViewModel = ref.read(detailMapXmlProvider);
    final fieldsConfig = ref.watch(detailViewModel.fieldsConfiguration);
    final fieldsToUse = fieldsConfig.isNotEmpty ? fieldsConfig : ref.read(mapProvider).orderedFieldsSingleList;

    final widgets = <Widget>[];
    for (final field in fieldsToUse) {
      final fieldTag = (field.balise ?? '').toLowerCase();

      switch (fieldTag) {
        case 'title':
          if (map.title.isNotEmpty) {
            widgets.addAll([
              SizedBox(
                height: 80,
                child: AtomHighlightedText(
                  text: map.title,
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
          if (map.mainImage.isNotEmpty) {
            widgets.addAll([
              Material(
                elevation: 4,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: map.mainImage,
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
          if (map.category.isNotEmpty) {
            widgets.addAll([
              SizedBox(
                height: 30,
                child: AtomHighlightedText(
                  text: map.category,
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
    final detailMapXmlViewModel = ref.watch(detailMapXmlProvider);
    final isFavorite = ref.watch(detailMapXmlViewModel.isFavorite);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AtomFloatingActionButtonFavorite(
          heroTag: 'mapXmlViewWrapper${detailMapXmlViewModel.favoriteButtonTag}',
          onPressed: () => detailMapXmlViewModel.onPressFavorite(ref, tileMap, map),
          assetPath: Assets.assetsImageSaveDark,
          isDarkMode: isDarkMode,
          isFavorite: isFavorite,
        ),
        10.ph,
      ],
    );
  }
}
