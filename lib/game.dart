import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:the_arzo_flutter_flame/characters/player.dart';
import 'package:the_arzo_flutter_flame/components/golden_coin.dart';
import 'package:the_arzo_flutter_flame/components/parallax_background.dart';
import 'package:the_arzo_flutter_flame/ui/attack_button.dart';
import 'package:the_arzo_flutter_flame/ui/jump_button.dart';
import 'package:the_arzo_flutter_flame/ui/move_controls.dart';
import 'package:the_arzo_flutter_flame/utils/vector2_extensions.dart';

import 'components/platform_map.dart';

final logger = Logger(printer: SimplePrinter());

class TheGame extends FlameGame
    with HasTappables, KeyboardEvents, HasCollidables {
  final _bgm = 'bgm.mp3';
  late Player _player;
  bool soundsEnabled = true;
  late final ParallaxComponent parallax;


  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    parallax = ParallaxBackground(size: size);
    add(parallax);

    print('Game onLoad size: ${size}');

    if (soundsEnabled) {
      await FlameAudio.bgm.load(_bgm);
      // FlameAudio.bgm.play(_bgm, volume: .2);
    }
    add(PositionComponent(size: Vector2(50, 50), position: Vector2(50, 50)));

    final map = PlatformMap(position: Vector2(0, size.centerY));
    await map.initialize();
    add(map);

    final y = (map.size.y / 25) * 18;
    _player = Player(position: Vector2(40, map.position.y + y));
    add(_player);

    add(
      MoveControls(
        size: Vector2(size.x / 2, size.y),
        onMove: (direction) => _player.move(direction),
        onStopMove: _player.stop,
      ),
    );
    add(
      AttackButton(
        position: Vector2(size.x - 34, size.y - 34),
        onAttack: _player.attack,
      ),
    );

    final jumpButton = JumpButton(
      position: Vector2(size.x - 164, size.y - 64),
      onJump: _player.jump,
    );
    add(jumpButton);

    camera.zoom = 1.6;

    for (var i = 0; i < 50; ++i) {
      add(GoldenCoin(
        position:
        Vector2(_player.position.x + (i * 30), _player.position.y + 10),
      ));
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    print('Game resized ${canvasSize}');
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event,
      Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is RawKeyDownEvent;
    final isKeyUp = event is RawKeyUpEvent;

    if (isKeyDown) {
      if (event.physicalKey == PhysicalKeyboardKey.keyD) {
        _player.move(AxisDirection.right);
      } else if (event.physicalKey == PhysicalKeyboardKey.keyA) {
        _player.move(AxisDirection.left);
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        _player.jump();
      }
    } else if (isKeyUp &&
        (event.physicalKey == PhysicalKeyboardKey.keyD ||
            event.physicalKey == PhysicalKeyboardKey.keyA)) {
      _player.stop();
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onRemove() {
    FlameAudio.bgm.stop();
    FlameAudio.bgm.clearAll();
    super.onRemove();
  }
}
