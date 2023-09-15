import 'package:flutter/material.dart';

//model
import 'package:muse_base/models/menu_option_model.dart';

//screns
import 'package:muse_base/screens/about_museum.dart';
import 'package:muse_base/screens/about_zone.dart';
import 'package:muse_base/screens/detail_image.dart';
import 'package:muse_base/screens/favorites.dart';
import 'package:muse_base/screens/gallery_timeline.dart';
import 'package:muse_base/screens/gallery_zone.dart';
import 'package:muse_base/screens/home.dart';
import 'package:muse_base/screens/home_navbar.dart';
import 'package:muse_base/screens/image_map.dart';
import 'package:muse_base/screens/image_timeline_map.dart';
import 'package:muse_base/screens/login.dart';
import 'package:muse_base/screens/map_museum.dart';
import 'package:muse_base/screens/news.dart';
import 'package:muse_base/screens/profile.dart';
import 'package:muse_base/screens/recover_password.dart';
import 'package:muse_base/screens/select_language.dart';
import 'package:muse_base/screens/sign_in.dart';
import 'package:muse_base/screens/sign_up.dart';
import 'package:muse_base/screens/splah.dart';
import 'package:muse_base/screens/staf.dart';
import 'package:muse_base/screens/tickets.dart';

class AppRoutes {
  static const String initialRoute = 'homeNav';

  static final routes = <MenuOption>[
    MenuOption(route: 'home', screen: const Home()),
    MenuOption(route: 'about_museum', screen: const AboutMuseum()),
    MenuOption(route: 'about_zone', screen: const AboutZone()),
    MenuOption(route: 'detail_image', screen: const Detail()),
    MenuOption(route: 'favorites', screen: const Favorites()),
    MenuOption(route: 'gallery_timeline', screen: const GalleryTimeLine()),
    MenuOption(route: 'gallery_zone', screen: const GalleryZone()),
    MenuOption(route: 'image_map', screen: const ImageMapZone()),
    MenuOption(route: 'image_timeline_map', screen: const ImageTimelineMap()),
     MenuOption(route: 'login', screen: const Login()),
    MenuOption(route: 'map_museum', screen: const MapMuseum()),
    MenuOption(route: 'news', screen: const News()),
    MenuOption(route: 'profile', screen: const Profile()),
    MenuOption(route: 'recover_password', screen: const RecoverPasword()),
    MenuOption(route: 'select_language', screen: const SelectLanguge()),
    MenuOption(route: 'sign_in', screen: const SignIn()),
    MenuOption(route: 'sign_up', screen: const SignUp()),
    MenuOption(route: 'splah', screen: const Splash()),
    MenuOption(route: 'staf', screen: const Staff()),
    MenuOption(route: 'tickets', screen: const Tickets()),
    MenuOption(route: 'homeNav', screen: const HomeNavBar()),
    
  ];

  static Map<String, Widget Function(BuildContext)> getAppRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};
    for (final r in routes) {
      appRoutes.addAll({r.route: (BuildContext context) => r.screen});
    }
    return appRoutes;
  }
}
