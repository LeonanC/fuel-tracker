import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotifController extends GetxController {
  final _storage = GetStorage();
  final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static const _kAllowAll = 'notif_allow_all';
  static const _kRefuel = 'notif_refuel';
  static const _kMaintenance = 'notif_maintenance';
  static const _kOilChange = 'notif_oil_change';
  static const _kPromotions = 'notif_promotions';
  static const _kNewStation = 'notif_station';
  static const _kNewVehicle = 'notif_vehicle';
  static const int _kTipsNotificationId = 200;

  final allowAllNotifications = true.obs;
  final refuelReminders = true.obs;
  final maintenanceReminders = true.obs;
  final oilChangeAlerts = true.obs;
  final promotionsAndTips = true.obs;
  final newStation = true.obs;
  final newVehicle = true.obs;

  @override
  void onInit() {
    super.onInit();
    tz.initializeTimeZones();
    _initNotications();
    _loadPreferences();
  }

  Future<void> _initNotications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);
    await _requestAndroidPermission();
  }

  Future<void> _requestAndroidPermission() async {
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if(androidPlugin != null){
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  void _loadPreferences(){
    allowAllNotifications.value = _storage.read(_kAllowAll) ?? true;
    refuelReminders.value = _storage.read(_kRefuel) ?? true;
    maintenanceReminders.value = _storage.read(_kMaintenance) ?? true;
    oilChangeAlerts.value = _storage.read(_kOilChange) ?? true;
    promotionsAndTips.value = _storage.read(_kPromotions) ?? true;
    newStation.value = _storage.read(_kNewStation) ?? true;
    newVehicle.value = _storage.read(_kNewVehicle) ?? true;
  }

  void toggleAll(bool value){
    allowAllNotifications.value = value;
    _storage.write(_kAllowAll, value);
    if(!value){
      refuelReminders.value = false;
      maintenanceReminders.value = false;
      oilChangeAlerts.value = false;
      promotionsAndTips.value = false;
      newStation.value = false;
      newVehicle.value = false;
      _notificationsPlugin.cancelAll();
    }else{
      _requestAndroidPermission();
      refuelReminders.value = false;
      maintenanceReminders.value = false;
      oilChangeAlerts.value = false;
      newStation.value = false;
      newVehicle.value = false;
    }

    _saveAll();
  }

  void _saveAll(){
    _storage.write(_kRefuel, refuelReminders.value);
    _storage.write(_kMaintenance, maintenanceReminders.value);
    _storage.write(_kOilChange, oilChangeAlerts.value);
    _storage.write(_kPromotions, promotionsAndTips.value);
    _storage.write(_kNewStation, newStation.value);
    _storage.write(_kNewVehicle, newVehicle.value);
  }

  void toggleRefuel(bool value){
    refuelReminders.value = value;
    _storage.write(_kRefuel, value);
    if(!value) _notificationsPlugin.cancel(id: 101);
  }

  void toggleMaintenance(bool value){
    maintenanceReminders.value = value;
    _storage.write(_kMaintenance, value);
    if(!value) _notificationsPlugin.cancel(id: 102);
  }
  void toggleOilChange(bool value){
    oilChangeAlerts.value = value;
    _storage.write(_kOilChange, value);
    if(!value) _notificationsPlugin.cancel(id: 103);
  }
  void toggleNewStation(bool value){
    newStation.value = value;
    _storage.write(_kNewStation, value);
    if(!value) _notificationsPlugin.cancel(id: 104);
  }
  void toggleNewVehicle(bool value){
    newVehicle.value = value;
    _storage.write(_kNewVehicle, value);
    if(!value) _notificationsPlugin.cancel(id: 105);
  }

  void togglePromotions(bool value){
    promotionsAndTips.value = value;
    _storage.write(_kPromotions, value);

    if(value && allowAllNotifications.value) {
      _scheduleWeeklyTip(); 
    }else{
      _notificationsPlugin.cancel(id: _kTipsNotificationId);
    }
  }

  Future<void> _scheduleWeeklyTip() async {
    const androidDetails = AndroidNotificationDetails(
      'fuel_tracker_tips_channel',
      'Dicas e Economia',
      channelDescription: 'Dicas semanais para economizar combustível e cuidar do veículo',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(Duration(days: 7));

    await _notificationsPlugin.zonedSchedule(
      id: _kTipsNotificationId,
      title: 'Dica de Economia 💡',
      body: 'Calibre os pneus regularmento! Pneus murchos podem aumentar o consumo de combustível em até 3%.',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> sendSampleTip() async {
    if(!allowAllNotifications.value || !promotionsAndTips.value) return;
    final tips = [
      'Mantenha a calibração dos pneus em dia para economizar até 3% de combustível!',
      'Evite acelerações bruscas e frenagens desnecessárias para melhorar a média de km/l.',
      'O uso do ar-condicionado em velocidades urbanas aumenta visivelmente o consumo.',
      'Faça a troca regular dos filtros de ar e de combustível conforme o manual do fabricante.',
      'Elimine peso desnecessário do porta-malas; cada 50kg extras aumentam o consumo.',
      'Planeie as suas rotas para evitar congestionamentos e trechos muito longos.',
      'Mantenha o alinhamento e o balanceamento em dia para reduzir o esforço do motor.',
      'Use a marcha correta para a velocidade: esticar demasiado as mudanças gasta mais.',
    ];

    final randomTip = (tips..shuffle()).first;

    await showNotification(
      id: _kTipsNotificationId,
      title: 'Dica Fuel Tracker ⛽',
      body: randomTip,
    );
  }

  Future<void> showNotification({required int id, required String title, required String body}) async {
    if(!allowAllNotifications.value) return;

    const androidDetails = AndroidNotificationDetails(
      'fuel_tracker_channel',
      'Alertas do Veículo',
      channelDescription: 'Lembretes de combustível, manutenção e trocas',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

}