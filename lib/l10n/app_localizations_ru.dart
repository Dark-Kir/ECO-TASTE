// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get cuisine => 'Кухня';

  @override
  String get schedule => 'Режим работы';

  @override
  String get phone => 'Телефон';

  @override
  String get ratePlace => 'Оцените заведение';

  @override
  String get menu => 'Меню';

  @override
  String get aboutPlace => 'О заведении';

  @override
  String get noDescription => 'Описание пока отсутствует';
}
