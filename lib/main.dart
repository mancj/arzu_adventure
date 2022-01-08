import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:the_arzo_flutter_flame/game.dart';
import 'package:the_arzo_flutter_flame/game_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();

  GetIt.I.registerSingleton(GamePreferencesManager());
  runApp(GameWrapperWidget());
}

class GameWrapperWidget extends StatefulWidget {
  @override
  State<GameWrapperWidget> createState() => _GameWrapperWidgetState();
}

class _GameWrapperWidgetState extends State<GameWrapperWidget> {
  TheGame? game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      print('create game');
      setState(() {
        game = TheGame();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return game == null ? Container() : GameWidget(game: game!);
  }
}
