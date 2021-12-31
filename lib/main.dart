import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:the_arzo_flutter_flame/game.dart';
import 'package:the_arzo_flutter_flame/game_settings.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();

  GetIt.I.registerSingleton(GamePreferencesManager());
  runApp(GameWidget(game: TheGame()));
}
