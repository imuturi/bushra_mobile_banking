import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'somali_material_localizations.dart';

class SomaliMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const SomaliMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'so';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return SomaliMaterialLocalizations();
  }

  @override
  bool shouldReload(SomaliMaterialLocalizationsDelegate old) => false;
}

class SomaliCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const SomaliCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'so';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return SomaliCupertinoLocalizations();
  }

  @override
  bool shouldReload(SomaliCupertinoLocalizationsDelegate old) => false;
}

class SomaliWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const SomaliWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'so';

  @override
  Future<WidgetsLocalizations> load(Locale locale) async {
    return SomaliWidgetsLocalizations();
  }

  @override
  bool shouldReload(SomaliWidgetsLocalizationsDelegate old) => false;
}