import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SomaliMaterialLocalizations extends DefaultMaterialLocalizations {
  SomaliMaterialLocalizations();

  @override
  String get moreButtonTooltip => 'Dheeraad';

  @override
  String get aboutListTileTitleRaw => 'Ku saabsan \$applicationName';

  @override
  String get alertDialogLabel => 'Digniin';

// Add more Somali translations as needed
// You can override all methods from MaterialLocalizations
}

class SomaliCupertinoLocalizations extends DefaultCupertinoLocalizations {
  SomaliCupertinoLocalizations();

  @override
  String get alertDialogLabel => 'Digniin';

  @override
  String get todayLabel => 'Maanta';

// Add more Somali translations
}

class SomaliWidgetsLocalizations extends DefaultWidgetsLocalizations {
  SomaliWidgetsLocalizations();

  @override
  String get reorderItemDown => 'U dhoof hoose';

  @override
  String get reorderItemLeft => 'U dhoof bidix';

  @override
  String get reorderItemRight => 'U dhoof midig';

  @override
  String get reorderItemToEnd => 'U dhoof dhamaadka';

  @override
  String get reorderItemToStart => 'U dhoof bilawga';

  @override
  String get reorderItemUp => 'U dhoof sare';
}