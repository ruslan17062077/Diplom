import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/drop_point.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/models/settlements.dart';
import 'package:molokosbor/Pages/AdministrartorPages/Settlements/DropPoint/add_drop_point.dart';
import 'package:molokosbor/Pages/AdministrartorPages/Settlements/DropPoint/edit_drop_point.dart';
import 'package:molokosbor/Pages/AdministrartorPages/Settlements/edit_settlement_page.dart';
import 'package:molokosbor/Pages/AdministrartorPages/Settlements/seetlements_list_page.dart';
import 'package:molokosbor/Pages/AdministrartorPages/administrator_message.dart';
import 'package:molokosbor/Pages/AdministrartorPages/clients/client_list_page.dart';
import 'package:molokosbor/Pages/AdministrartorPages/clients/edit_client_page.dart';
import 'package:molokosbor/Pages/AdministrartorPages/collectors/add_collector_page.dart';
import 'package:molokosbor/Pages/AdministrartorPages/collectors/collector_list_page.dart';
import 'package:molokosbor/Pages/AdministrartorPages/collectors/edit_collector_page.dart';
import 'package:molokosbor/Pages/CollectorPages/collector_delivere_page.dart';
import 'package:molokosbor/Pages/Landing/landing.dart';
import 'package:molokosbor/Pages/MessagePages/chat.dart';

var routes = {
  "/": (context) => AuthStateChecker(),
  "/clients": (context) => const ClientListPage(),
  "/collectors": (context) => CollectorListPage(),
  "/settlements": (context) => SettlementsListPage(),
  "/add_collector": (context) => AddCollectorPage(),
  "/milk_prices": (context) => AddCollectorPage(),
  "/message_administrator": (context) => ChatListAdministratorPage(),
  "/message_admin": (context) => AddCollectorPage(),
};

final Map<String, WidgetBuilder> parameterizedRoutes = {
  '/edit_client': (context) {
    final profile = ModalRoute.of(context)?.settings.arguments as Profile;
    return EditClientPage(profile: profile);
  },
  '/edit_collector': (context) {
    final profile = ModalRoute.of(context)?.settings.arguments as Profile;
    return EditCollectorPage(profile: profile);
  },
  '/edit_settlement': (context) {
    final settlement = ModalRoute.of(context)?.settings.arguments as Settlement;
    return EditSettlementPage(settlement: settlement);
  },
  '/edit_drop_point': (context) {
    final point = ModalRoute.of(context)?.settings.arguments as DropPoint;
    return EditDropPointPage(point: point);
  },
  '/add_drop_point': (context) {
    final settlement = ModalRoute.of(context)?.settings.arguments as Settlement;
    return AddDropPointPage(
      settlement: settlement,
    );
  },
  '/collector_delivery': (context) {
    final client = ModalRoute.of(context)?.settings.arguments as Profile;
    return CollectorDeliveryPage(client: client);
  },
'/chat': (context) {
  final rawArgs = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  final myId    = rawArgs['myProfileId']  as String;
  final otherId = rawArgs['otherProfileId'] as String;

  return ChatPage(
    myProfileId:    myId,
    otherProfileId: otherId,
  );
},
};
