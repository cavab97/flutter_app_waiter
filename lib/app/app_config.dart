import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/helpers/config.dart';

import '../main.dart';
import 'environment_config.dart';

enum AppEnvironment {
  development,
  staging,
  production,
  local,
}

class FlutterAppConfig {
  FlutterAppConfig({
    @required this.environment
  });

  final AppEnvironment environment;

  static Map<String, dynamic> _config;

  static void setEnvironment(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.local:
        Configrations.base_URL = Config.localConstants['SERVER_URL'];
        _config = Config.localConstants;
        break;
      case AppEnvironment.development:
        Configrations.base_URL = Config.developmentConstants['SERVER_URL'];
        _config = Config.developmentConstants;
        break;
      case AppEnvironment.staging:
        Configrations.base_URL = Config.stagingConstants['SERVER_URL'];
        _config = Config.stagingConstants;
        break;
      case AppEnvironment.production:
        Configrations.base_URL = Config.productionConstants['SERVER_URL'];
        _config = Config.productionConstants;
        break;
    }
  }

  static get CONFIG {
    return _config;
  }

  Future run() async {
      setEnvironment(environment);

      WidgetsFlutterBinding.ensureInitialized();

      WidgetsFlutterBinding.ensureInitialized();
      final bool isLogged = await CommunFun.isLogged();
      
      runApp(MyApp(islogin: isLogged));
  }
}
