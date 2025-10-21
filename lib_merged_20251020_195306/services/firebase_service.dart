import 'firebase/client_auth_service.dart';
import 'firebase/menu_service.dart';
import 'firebase/order_service.dart';
import 'firebase/points_service.dart';
import 'firebase/archive_service.dart';

class FirebaseService {
  // Auth Clienti
  static final ClientAuthService clientAuth = ClientAuthService();
  
  // Menu
  static final MenuService menu = MenuService();
  
  // Ordini
  static final OrderService orders = OrderService();
  
  // Punti
  static final PointsService points = PointsService();
  
  // Archivi
  static final ArchiveService archive = ArchiveService();
  
  // Inizializzazione centrale
  static Future<void> inizializzaMenuData() async {
    await menu.inizializzaMenu();
  }
}