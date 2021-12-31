import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:the_arzo_flutter_flame/characters/arzu.dart';
import 'package:the_arzo_flutter_flame/platform_map.dart';
import 'package:the_arzo_flutter_flame/ui/attack_button.dart';
import 'package:the_arzo_flutter_flame/ui/move_controls.dart';
import 'package:the_arzo_flutter_flame/utils/vector2_extensions.dart';

final logger = Logger(printer: SimplePrinter());

class TheGame extends FlameGame
    with HasTappables, KeyboardEvents, HasCollidables {
  final _bgm = 'bgm.mp3';
  late Arzu _arzu;
  bool soundsEnabled = false;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    if (soundsEnabled) {
      await FlameAudio.bgm.load(_bgm);
      FlameAudio.bgm.play(_bgm, volume: .5);
    }

    add(PositionComponent(size: Vector2(50, 50), position: Vector2(50, 50)));

    final map = PlatformMap(position: Vector2(0, size.centerY));
    await map.initialize();
    add(map);

    // final y = map.firstPlatformPosition.y;
    final y = (map.size.y /  10) * 7;
    print(y);

    _arzu = Arzu(position: Vector2(50, map.position.y + y ));
    add(_arzu);

    add(MoveControls(
      size: Vector2(size.x / 2, size.y),
      onMove: _arzu.move,
      onStopMove: _arzu.idle,
    ));
    add(AttackButton(onAttack: _arzu.attack));

    // camera.zoom = 1.2;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
      Rect.fromLTRB(10, 10, size.x - 10, size.y - 10),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.centerY),
      Offset(size.x, size.centerY),
      paint,
    );
    canvas.drawLine(
      Offset(size.centerX, 0),
      Offset(size.centerX, size.y),
      paint,
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

  @override
  void onRemove() {
    FlameAudio.bgm.stop();
    FlameAudio.bgm.clearAll();
    super.onRemove();
  }
}
