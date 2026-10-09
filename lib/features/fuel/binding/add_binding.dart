import 'package:fuel_tracker/features/fuel/controllers/add_controller.dart';
import 'package:get/get.dart';

class AddBinding implements Bindings {
@override
void dependencies() {
  Get.lazyPut<AddController>(() => AddController());
  }
}