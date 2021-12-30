import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:the_arzo_flutter_flame/characters/arzu.dart';
import 'package:the_arzo_flutter_flame/platform_map.dart';
import 'package:the_arzo_flutter_flame/ui/attack_button.dart';
import 'package:the_arzo_flutter_flame/ui/move_controls.dart';

import 'characters/enemy.dart';

final logger = Logger();

class TheGame extends FlameGame
    with HasTappables, KeyboardEvents, HasCollidables {
  late Arzu _arzu;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    final block = size.y / 10;

    _arzu = Arzu(Vector2(100, size.y - (block * 3)));
    add(_arzu);

    add(AttackButton(onAttack: _arzu.attack));

    for (var i = 0; i < 5; ++i) {
      // final gp = GroundPlatform(position: Vector2(i * 280, y * 5), blocks: 12);
      // add(gp);
      add(Enemy(position: Vector2(i * 150,  size.y - (block * 3))));
    }

    add(
      MoveControls(
        size: Vector2(size.x / 2, size.y),
        onMove: _arzu.move,
        onStopMove: _arzu.idle,
      ),
    );

    add(PlatformMap(block));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      Rect.fromLTRB(10, 10, size.x - 10, size.y - 10),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is RawKeyDownEvent;
    final isKeyUp = event is RawKeyUpEvent;

    if (isKeyDown) {
      if (event.physicalKey == PhysicalKeyboardKey.keyD) {
        _arzu.move(MovementDirection.forward);
      } else if (event.physicalKey == PhysicalKeyboardKey.keyA) {
        _arzu.move(MovementDirection.back);
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        _arzu.jump();
      }
    } else if (isKeyUp &&
        (event.physicalKey == PhysicalKeyboardKey.keyD ||
            event.physicalKey == PhysicalKeyboardKey.keyA)) {
      _arzu.idle();
    }

    return super.onKeyEvent(event, keysPressed);
  }
}
