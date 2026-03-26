import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
import 'package:badges/badges.dart' as bg;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
import '../../../../domain/modals/xml/xml_event.dart';
import '../../../viewmodel/xml/event/detail_event_xml_view_model.dart';
import '../../../viewmodel/xml/event/events_xml_view_model.dart';

class DetailEventXmlView extends StatelessWidget {
  final TileXml tileXml;
  final Event event;
  final List<Event>? allEvents;

  const DetailEventXmlView({
    required this.tileXml,
    required this.event,
    this.allEvents,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widgets) {
          final detailEventXmlViewModel = ref.watch(detailEventXmlProvider);
          final isDarkMode = ref.watch(themeProvider).isDarkMode;

          detailEventXmlViewModel.initEventsXml(ref, tileXml, allEvents, event);
          return SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              drawerEnableOpenDragGesture: false,
              appBar: AtomAppBarWithSearch(
                title: 'Événements',
                isDarkMode: isDarkMode,
                searchController: detailEventXmlViewModel.searchController,
                onSearchChanged: (text) => detailEventXmlViewModel.onSearchTextChanged(ref, event, text),
                onSearchCleared: () => detailEventXmlViewModel.onSearchTextChanged(ref, event, ''),
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      detailEventXmlViewModel.isInitialized = false;
                      detailEventXmlViewModel.searchController.clear();
                      NavigationService.back(context, ref);
                    },
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                ),
                actions: [
                  NotificationIconBadge(
                    iconData: Icons.notifications_none_sharp,
                    onTap: () {
                      detailEventXmlViewModel.searchController.clear();
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
    final detailEventXmlViewModel = ref.watch(detailEventXmlProvider);
    final orderedFields = detailEventXmlViewModel.orderedFieldsListItem;

    final searchText = detailEventXmlViewModel.searchController.text;
    final isEmpty = detailEventXmlViewModel.isEmpty;

    return orderedFields.isEmpty
        ? const SizedBox()
        : isEmpty && searchText.isNotEmpty
            ? AtomNoResult(
                isDarkMode: isDarkMode,
                query: searchText,
                text: 'Event',
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
                          ..._buildEventContent(context, ref, isDarkMode, searchText),
                        ],
                      ),
                    ),
                    _buildRecommendedSection(context, ref, isDarkMode),
                  ],
                ),
              );
  }

  List<Widget> _buildEventContent(BuildContext context, WidgetRef ref, bool isDarkMode, String searchText) {
    final detailEventXmlViewModel = ref.watch(detailEventXmlProvider);
    final orderedFields = detailEventXmlViewModel.orderedFieldsListItem;

    final widgets = <Widget>[];

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
        ///titre
        case 'title':
          if (event.title.isNotEmpty) {
            widgets.addAll([
              15.ph,
              AtomHighlightedText(
                text: event.title,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.headlineLarge!,
                isDarkMode: isDarkMode,
                overflow: TextOverflow.visible,
              ),
              25.ph,
            ]);
          }
          break;

        ///chapeau
        case 'summary':
          if (event.summary.isNotEmpty) {
            widgets.addAll([
              25.ph,
              AtomHighlightedText(
                text: event.summary,
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

        ///image principale
        case 'mainimage':
          if (event.mainImage.isNotEmpty) {
            widgets.addAll([
              25.ph,
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: event.mainImage,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ]);
          }
          break;

        ///image principale légende
        case 'imagecaption':
          if (event.imageCaption.isNotEmpty) {
            widgets.addAll([
              10.ph,
              AtomHighlightedText(
                text: event.imageCaption,
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

        ///date de publication
        case 'pubdate':
          if (event.pubDate.isNotEmpty) {
            dateParts.add('Publié le ${_formatDate(event.pubDate)}');
          }
          break;

        ///date de mise à jour
        case 'updatedate':
          if (event.updateDate.isNotEmpty) {
            dateParts.add('Mis à jour le ${_formatDate(event.updateDate)}');
          }
          break;

        ///Event
        case 'content':
          if (event.content.isNotEmpty) {
            widgets.addAll([
              25.ph,
              AtomHighlightedText(
                text: event.content,
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

        ///Thématique
        case 'category':
          if (event.category.isNotEmpty) {
            widgets.addAll([
              20.ph,
              AtomHighlightedText(
                text: event.category,
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

        ///location - title
        case 'location - title':
          if (event.location.title.isNotEmpty) {
            locationTitle = event.location.title;
          }
          break;

        ///location - address
        case 'location - address':
          if (event.location.address.isNotEmpty) {
            locationAddress = event.location.address;
          }
          break;

        /// location - city
        case 'location - city':
          if (event.location.city.isNotEmpty) {
            locationCity = event.location.city;
          }
          break;

        /// location - postalcod
        case 'location - postalcod':
          if (event.location.postalCode.isNotEmpty) {
            locationPostalCode = event.location.postalCode;
          }
          break;
        case 'location - latitude':
          break;
        case 'location - longitude':
          if (event.location.latitude != 0.0 && event.location.longitude != 0.0) {
            widgets.addAll([
              25.ph,
              _buildGeoLocationWidget(context, ref, event, isDarkMode),
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
        case 'eventstarttime':
          if (event.eventStartTime.isNotEmpty) {
            eventTimeParts.add(event.eventStartTime);
          }
          break;
        case 'eventendtime':
          if (event.eventEndTime.isNotEmpty) {
            eventTimeParts.add(event.eventEndTime);
          }
          break;

        case 'eventstartdate':
          if (event.eventStartDate.isNotEmpty) {
            eventDateParts.add(event.eventStartDate);
          }
          break;
        case 'eventenddate':
          if (event.eventEndDate.isNotEmpty) {
            eventDateParts.add(event.eventEndDate);
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
    DateTime startDate = DateTime.tryParse(event.eventStartDate) ?? DateTime.now();
    DateTime endDate = event.eventEndDate.isNotEmpty ? DateTime.tryParse(event.eventEndDate) ?? startDate : startDate;

    if (event.eventStartTime.isNotEmpty) {
      final timeParts = event.eventStartTime.split(':');
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

    if (event.eventEndTime.isNotEmpty) {
      final timeParts = event.eventEndTime.split(':');
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
      title: event.title,
      description: event.summary,
      location: event.location.address,
      startDate: startDate,
      endDate: endDate,
    );

    calendar.Add2Calendar.addEvent2Cal(calendarEvent);
  }

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

  Widget _buildGeoLocationWidget(
    BuildContext context,
    WidgetRef ref,
    Event event,
    bool isDarkMode,
  ) =>
      Consumer(
        builder: (context, ref, child) {
          final detailEventXmlViewModel = ref.watch(detailEventXmlProvider);

          if (!detailEventXmlViewModel.hasGeoLocationInfo(event.location.latitude, event.location.longitude)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              detailEventXmlViewModel.fetchGeoLocationInfo(event.location.latitude, event.location.longitude);
            });
          }

          final isLoading = detailEventXmlViewModel.isLoadingGeoLocation(event.location.latitude, event.location.longitude);
          final locationInfo = detailEventXmlViewModel.getGeoLocationInfo(event.location.latitude, event.location.longitude);
          final mapController = MapController();

          return GeoLocationWidget(
            key: UniqueKey(),
            latitude: event.location.latitude,
            longitude: event.location.longitude,
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

  String _formatDate(String dateString) {
    try {
      return DateFormat('MM/dd/yyyy').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildRecommendedSection(BuildContext context, WidgetRef ref, bool isDarkMode) {
    final detailEventXmlViewModel = ref.watch(detailEventXmlProvider);
    final recommendedEvents = detailEventXmlViewModel.getRecommendedEvents(event, ref);

    if (recommendedEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: isDarkMode ? surfaceContainerDark : surfaceContainerLight,
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          50.ph,
          AtomText(
            data: 'À lire aussi...',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                ),
          ),
          20.ph,
          SizedBox(
            height: 410,
            child: ListView.separated(
              itemCount: recommendedEvents.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final event = recommendedEvents[index];
                final isLast = index == recommendedEvents.length - 1;
                if (isLast) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: _buildRecommendedCard(context, ref, event, isDarkMode),
                  );
                }
                return _buildRecommendedCard(context, ref, event, isDarkMode);
              },
              separatorBuilder: (context, index) => const SizedBox(width: 16),
            ),
          ),
          80.ph,
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context, WidgetRef ref, Event event, bool isDarkMode) => InkWell(
        onTap: () {
          final detailEventXmlViewModel = ref.read(detailEventXmlProvider);
          detailEventXmlViewModel.isInitialized = false;
          detailEventXmlViewModel.searchController.clear();
          NavigationService.push(
            context,
            ref,
            Paths.detailEventsXml,
            extra: {
              'tileXml': tileXml,
              'eventXml': event,
              'allEvents': allEvents,
            },
          );
        },
        child: SizedBox(
          width: Helpers.getResponsiveWidth(context) * .7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildRecommendedCardContent(context, ref, event, isDarkMode),
          ),
        ),
      );

  List<Widget> _buildRecommendedCardContent(BuildContext context, WidgetRef ref, Event event, bool isDarkMode) {
    final detailViewModel = ref.read(detailEventXmlProvider);
    final fieldsConfig = ref.watch(detailViewModel.fieldsConfiguration);
    final fieldsToUse = fieldsConfig.isNotEmpty ? fieldsConfig : ref.read(eventsXmlProvider).orderedFieldsSingleList;

    final widgets = <Widget>[];
    for (final field in fieldsToUse) {
      final fieldTag = (field.balise ?? '').toLowerCase();

      switch (fieldTag) {
        case 'title':
          if (event.title.isNotEmpty) {
            widgets.addAll([
              SizedBox(
                height: 80,
                child: AtomHighlightedText(
                  text: event.title,
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
          if (event.mainImage.isNotEmpty) {
            widgets.addAll([
              Material(
                elevation: 4,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: event.mainImage,
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
          if (event.category.isNotEmpty) {
            widgets.addAll([
              SizedBox(
                height: 30,
                child: AtomHighlightedText(
                  text: event.category,
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
        case 'eventenddate':
          break;
        case 'eventstartdate':
          String date = '';
          if (event.eventStartDate.isNotEmpty && event.eventEndDate.isNotEmpty) {
            date = 'Du ${_formatDate(event.eventStartDate)} au ${_formatDate(event.eventEndDate)}';
          } else if (event.eventStartDate.isNotEmpty) {
            date = 'Le ${_formatDate(event.eventStartDate)}';
          }
          if (date.isNotEmpty) {
            widgets.addAll([
              SizedBox(
                height: 60,
                child: AtomHighlightedText(
                  text: date,
                  searchQuery: '',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: isDarkMode ? primaryDark : primaryLight,
                      ),
                  maxLines: 2,
                  isDarkMode: isDarkMode,
                ),
              ),
              15.ph,
            ]);
          }
          break;
      }
    }

    return widgets;
  }

  Widget _buildFavoriteButton(WidgetRef ref, bool isDarkMode) {
    final detailEventXmlViewModel = ref.watch(detailEventXmlProvider);
    final isFavorite = ref.watch(detailEventXmlViewModel.isFavorite);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AtomFloatingActionButtonFavorite(
          heroTag: 'eventXmlViewWrapper${detailEventXmlViewModel.favoriteButtonTag}',
          onPressed: () => detailEventXmlViewModel.onPressFavorite(ref, tileXml, event),
          assetPath: Assets.assetsImageSaveDark,
          isDarkMode: isDarkMode,
          isFavorite: isFavorite,
        ),
        10.ph,
      ],
    );
  }
}
