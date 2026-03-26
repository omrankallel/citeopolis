/*import 'package:badges/badges.dart' as bg;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';

import '../../../../core/core.dart';
import '../viewmodel/access_token_firebase.dart';
import '../viewmodel/events_detail_view_model.dart';
import 'widgets/build_widget_bottom_app_bar.dart';
import 'widgets/organism_carousel.dart';
import 'widgets/build_widget_end_drawer.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await requestNotificationPermission();
      await getDeviceToken();
      setupFlutterNotifications();
      FirebaseMessaging.onMessage.listen(showFlutterNotification);
      ref.watch(homeProvider).appLanguage = LocalizationsService();
    });
  }

  final List<String> imgList = [
    Assets.assetsImageShutterStock,
    Assets.assetsImageConcert,
    Assets.assetsImageShutterStock,
    Assets.assetsImageConcert,
  ];

  String _token = '';
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void setupFlutterNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIos = DarwinInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIos,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title ?? ''),
        content: Text(body ?? ''),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
    );
  }

  void showFlutterNotification(RemoteMessage message) {
    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
    print('CCccccccccccccccccc');
  }

  Future<void> requestNotificationPermission() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    final NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('Permission denied');
    }
  }

  Future<void> getDeviceToken() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    final String? token = await messaging.getToken();

    if (token != null) {
      setState(() {
        _token = token;
      });
      debugPrint('Device Token: $token');
    } else {
      debugPrint('Failed to get token');
    }

    messaging.onTokenRefresh.listen((newToken) {
      setState(() {
        _token = newToken;
      });
      debugPrint('New Token: $newToken');
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProviderWatch = ref.watch(homeProvider);
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        key: homeProviderWatch.scaffoldKey,
        backgroundColor: kPrimaryColor,
        drawer: const WidgetDrawer(),
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text(
            'LyonFacile',
          ),
          actions: [
            InkWell(
              onTap: () {
                showSearch(
                  context: context,
                  delegate: CustomSearch(),
                );
              },
              child: const bg.Badge(
                showBadge: false,
                ignorePointer: true,
                child: Icon(
                  Icons.search,
                  color: Colors.black,
                  size: 23,
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            InkWell(
              onTap: () {},
              child: bg.Badge(
                badgeAnimation: const bg.BadgeAnimation.fade(
                  animationDuration: Duration(seconds: 1),
                  loopAnimation: true,
                ),
                badgeContent: Text(
                  '3',
                  style: AppFonts.poppinsI1Regular.copyWith(color: kNeutralColor100, fontSize: 10, fontWeight: FontWeight.w600),
                ),
                position: bg.BadgePosition.custom(start: 12, top: -7),
                badgeStyle: const bg.BadgeStyle(
                  badgeColor: Color(0xFFB71C1C),
                ),
                child: const Icon(
                  Icons.notifications_none_sharp,
                  color: Colors.black,
                  size: 23,
                ),
              ),
            ),
            const SizedBox(
              width: 25,
            ),
            InkWell(
              onTap: () {
                openPopup(context);
              },
              child: const bg.Badge(
                showBadge: false,
                child: Icon(
                  CupertinoIcons.text_aligncenter,
                  color: Colors.black,
                  size: 23,
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _token.isEmpty ? const CircularProgressIndicator() : Text('Device Token: $_token'),
                InkWell(
                  onTap: () async {
                    await sendFcmMessage(_token, 'Hello', 'This is a test message');
                  },
                  child: const Text('AAAAAAAAAAAAAAAAAAAAAAAAAAAA'),
                ),
                20.ph,
                const WidgetCarousel(),
                60.ph,
                WallLayout(
                  stones: homeProviderWatch.stones,
                  layersCount: 3,
                ),
                60.ph,
                const Divider(
                  color: Color(0XFFCAC4D0),
                ),
                60.ph,
                Row(
                  children: [
                    const Text(
                      'Actualité',
                      style: TextStyle(
                        color: Color(0xFF1D1B20),
                        fontFamily: 'Roboto',
                        fontSize: 32.0,
                        fontWeight: FontWeight.w400,
                        height: 40 / 32.0,
                      ),
                    ),
                    12.pw,
                    const Icon(
                      Icons.arrow_forward,
                      size: 24,
                      color: Color(0xFF1D1B20),
                    ),
                  ],
                ),
                20.ph,
                Container(
                  height: 325,
                  padding: const EdgeInsets.only(left: 15),
                  child: ListView.separated(
                    itemCount: 4,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (buildContext, index) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 280,
                          height: 185,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.asset(
                              index == 0
                                  ? Assets.assetsImageAlerte
                                  : index == 1
                                      ? Assets.assetsImageChantier
                                      : Assets.assetsImageNotification,
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Thématique ${index + 1}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Titre H1 lorem actualité',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    separatorBuilder: (context, index) => const SizedBox(
                      width: 5,
                    ),
                  ),
                ),

                  ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) => Consumer(
                  builder: (context, watch, child) => Slidable(
                    key: Key('Item ${index + 1}'),
                    startActionPane: ActionPane(
                      extentRatio: 0.2,
                      dragDismissible: false,
                      motion: CustomMotion(
                        onOpen: () {
                          ref.watch(homeViewModel.isSlid.notifier).update(
                                (state) => [
                                  for (int j = 0; j < state.length; j++)
                                    if (j == index) state[j] = true else state[j] = state[j],
                                ],
                              );
                        },
                        onClose: () {
                          ref.watch(homeViewModel.isSlid.notifier).update(
                                (state) => [
                                  for (int j = 0; j < state.length; j++)
                                    if (j == index) state[j] = false else state[j] = state[j],
                                ],
                              );
                        },
                        motionWidget: Container(
                          width: double.infinity,
                          height: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 16.0),
                          decoration: const BoxDecoration(
                            color: Color(0xFFB3261E),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 23.2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.delete_outline_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      children: [],
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 480,
                      margin: const EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: ref.watch(homeViewModel.isSlid)[index]
                            ? null
                            : const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                        boxShadow: [
                          const BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 23.2,
                          ),
                        ],
                      ),
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: ref.watch(homeViewModel.isSlid)[index]
                              ? BorderRadius.zero
                              : const BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '02/10/2024 - 10:27',
                                style: TextStyle(
                                  color: Color(0xFF1D1B20),
                                  fontFamily: 'Roboto',
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                  height: 16 / 11.0,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              16.ph,
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.asset(
                                  index == 0
                                      ? Assets.assetsImageAlerte
                                      : index == 1
                                          ? Assets.assetsImageChantier
                                          : Assets.assetsImageNotification,
                                  width: double.infinity,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              16.ph,
                              const Text(
                                'Thématique',
                                style: TextStyle(
                                  color: Color(0xFF214FAB),
                                  fontFamily: 'Roboto',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  height: 24.0 / 16.0,
                                  letterSpacing: 0.15,
                                ),
                              ),
                              16.ph,
                              const Text(
                                'Lorem ipsum dolor sit amet conestur elis passam filis poder',
                                style: TextStyle(
                                  color: Color(0xFF1D1B20),
                                  fontFamily: 'Roboto',
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w400,
                                  height: 28.0 / 22.0,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              16.ph,
                              const Text(
                                'Quisque nisl sapien, faucibus ac  vehicula vel, rhoncus sit amet leo. Duis at tincidunt lacus, sit amet  dapibus velit. Donec vel ante eget diam condimentum malesuada quis ac  tortor. Nunc commodo volutpat nibh nec consectetur. ',
                                style: TextStyle(
                                  color: Color(0xFF1D1B20),
                                  fontFamily: 'Roboto',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                  height: 20.0 / 14.0,
                                  letterSpacing: 0.25,
                                ),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    /* child: Container(
                      decoration: BoxDecoration(
                        color: ref.watch(homeProviderWatch.isSlid)[index] ? Colors.green : Colors.blueAccent,
                        borderRadius: ref.watch(homeProviderWatch.isSlid)[index]
                            ? null
                            : const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                      ),
                      margin: const EdgeInsets.only(right: 10.0, top: 10.0, bottom: 10.0),
                      child: ListTile(
                        title: Text('Item ${index + 1}'),
                      ),
                    ),*/
                  ),
                ),
              ),


                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) => Consumer(
                    builder: (context, watch, child) => Slidable(
                      key: Key('Item ${index + 1}'),
                      startActionPane: ActionPane(
                        extentRatio: 0.2,
                        dragDismissible: false,
                        motion: CustomMotion(
                          onOpen: () {
                            ref.watch(homeProviderWatch.isSlid.notifier).update(
                                  (state) => [
                                    for (int j = 0; j < state.length; j++)
                                      if (j == index) state[j] = true else state[j] = state[j],
                                  ],
                                );
                          },
                          onClose: () {
                            ref.watch(homeProviderWatch.isSlid.notifier).update(
                                  (state) => [
                                    for (int j = 0; j < state.length; j++)
                                      if (j == index) state[j] = false else state[j] = state[j],
                                  ],
                                );
                          },
                          motionWidget: Container(
                            width: double.infinity,
                            height: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 16.0),
                            decoration: const BoxDecoration(
                              color: Color(0xFFB3261E),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x26000000),
                                  blurRadius: 23.2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.delete_outline_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        children: [],
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 480,
                        margin: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          borderRadius: ref.watch(homeProviderWatch.isSlid)[index]
                              ? null
                              : const BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                          boxShadow: [
                            const BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 23.2,
                            ),
                          ],
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: ref.watch(homeProviderWatch.isSlid)[index]
                                ? BorderRadius.zero
                                : const BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '02/10/2024 - 10:27',
                                  style: TextStyle(
                                    color: Color(0xFF1D1B20),
                                    fontFamily: 'Roboto',
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w500,
                                    height: 16 / 11.0,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                16.ph,
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.asset(
                                    index == 0
                                        ? Assets.assetsImageAlerte
                                        : index == 1
                                            ? Assets.assetsImageChantier
                                            : Assets.assetsImageNotification,
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                16.ph,
                                const Text(
                                  'Thématique',
                                  style: TextStyle(
                                    color: Color(0xFF214FAB),
                                    fontFamily: 'Roboto',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    height: 24.0 / 16.0,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                                16.ph,
                                const Text(
                                  'Lorem ipsum dolor sit amet conestur elis passam filis poder',
                                  style: TextStyle(
                                    color: Color(0xFF1D1B20),
                                    fontFamily: 'Roboto',
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w400,
                                    height: 28.0 / 22.0,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                16.ph,
                                const Text(
                                  'Quisque nisl sapien, faucibus ac  vehicula vel, rhoncus sit amet leo. Duis at tincidunt lacus, sit amet  dapibus velit. Donec vel ante eget diam condimentum malesuada quis ac  tortor. Nunc commodo volutpat nibh nec consectetur. ',
                                  style: TextStyle(
                                    color: Color(0xFF1D1B20),
                                    fontFamily: 'Roboto',
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    height: 20.0 / 14.0,
                                    letterSpacing: 0.25,
                                  ),
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      /* child: Container(
                        decoration: BoxDecoration(
                          color: ref.watch(homeProviderWatch.isSlid)[index] ? Colors.green : Colors.blueAccent,
                          borderRadius: ref.watch(homeProviderWatch.isSlid)[index]
                              ? null
                              : const BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                        ),
                        margin: const EdgeInsets.only(right: 10.0, top: 10.0, bottom: 10.0),
                        child: ListTile(
                          title: Text('Item ${index + 1}'),
                        ),
                      ),*/
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            WidgetBottomAppBar(
              iconData: Icons.home_outlined,
              text: 'Accueil',
              index: 0,
            ),
            WidgetBottomAppBar(
              iconData: Icons.location_on_outlined,
              text: 'Carte',
              index: 1,
            ),
            WidgetBottomAppBar(
              iconData: Icons.star_border,
              text: 'FAVORIS',
              index: 2,
            ),
            WidgetBottomAppBar(
              iconData: Icons.more_vert,
              text: 'Autres',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openPopup(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Filtre par Thémtiques'),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: kButtonColor1,
                ),
                padding: const EdgeInsets.all(5),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        content: const ThematicCheckBoxList(),
        actions: [
          TextButton(
            child: const Text('Filtrer'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class ThematicCheckBoxList extends ConsumerStatefulWidget {
  const ThematicCheckBoxList({super.key});

  @override
  ConsumerState<ThematicCheckBoxList> createState() => _ThematicCheckBoxListState();
}

class _ThematicCheckBoxListState extends ConsumerState<ThematicCheckBoxList> {
  @override
  Widget build(BuildContext context) {
    final homeViewModel = ref.watch(homeProvider);
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        children: List.generate(
          5,
          (index) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: homeViewModel.checked[index],
                onChanged: (bool? value) {
                  setState(() {
                    homeViewModel.checked[index] = value ?? false;
                  });
                },
              ),
              Text('Thématique ${index + 1}'),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomSearch extends SearchDelegate {
  List<String> allData = [
    'Search1',
    'Search3',
    'Search3',
    'Search4',
    'Search5',
    'Search6',
    'Search7',
    'Search8',
    'Search9',
    'Search10',
  ];

  @override
  ThemeData appBarTheme(BuildContext context) => ThemeData(
        inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor,
        ),
      );

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear),
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () {
          close(context, null);
          query = '';
        },
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) {
    final List<String> matchQuery = [];
    for (var item in allData) {
      if (item.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        final String result = matchQuery[index];
        return Text(result);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: query.isEmpty
            ? const Center(
                child: Text('Tapez quelque chose pour commencer...'),
              )
            : ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Suggestion ${index + 1} pour "$query"'),
                ),
              ),
      );
}

class CustomMotion extends StatefulWidget {
  final VoidCallback onOpen;
  final VoidCallback onClose;
  final Widget motionWidget;

  const CustomMotion({
    required this.onOpen,
    required this.onClose,
    required this.motionWidget,
    super.key,
  });

  @override
  CustomMotionState createState() => CustomMotionState();
}

class CustomMotionState extends State<CustomMotion> {
  SlidableController? controller;
  VoidCallback? myListener;
  bool isClosed = true;

  void animationListener() {
    if (controller == null) return;

    if (controller!.ratio == 0 && !isClosed) {
      isClosed = true;
      widgets.onClose();
    }

    if (controller!.ratio == controller!.startActionPaneExtentRatio && isClosed) {
      isClosed = false;
      widgets.onOpen();
    }
  }

  @override
  void initState() {
    super.initState();
    controller = Slidable.of(context);
    myListener = animationListener;
    controller!.animation.addListener(myListener!);
  }

  @override
  void dispose() {
    if (controller != null) {
      controller!.animation.removeListener(myListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widgets.motionWidget;
}
*/