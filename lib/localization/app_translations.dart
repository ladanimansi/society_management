import 'package:get/get.dart';
import 'localization_service.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => LocalizationService.translations;
}
