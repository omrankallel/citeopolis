class Services {
  Services._();

  static String getConfigProject(int id) => 'configuration_project?id=$id';

  static String getPublicity(int id) => 'publicity?id_project=$id';

  static String buildPage(int idProject) => 'build_page?id_project=$idProject';

  static String getTabBarProject(int id) => 'tab_bar?id_project=$id';

  static String getMenuProject(int id) => 'menu?id_project=$id';

  static String getNotificationProject(int id) => 'get_notif?id_project=$id';

  static String getThematicProject(int id) => 'get_terms_notif?id_project=$id';

  static String getTileProject(int id) => 'get_tiles?id_project=$id';

  static String getDetailTileProject(int id) => 'build_tile?id=$id';
  static const String getFeed = 'get_feeds';
  static const String getTerm = 'get_terms_xml';

  static const String getFlux = 'get_flux';
  static const String deviceRegistration = 'device-registration';
}
