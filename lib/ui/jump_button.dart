import 'package:flame/components.dart';
import 'package:flame/input.dart';

class JumpButton extends PositionComponent with HasGameRef, Tappable {
  Function()? onJump;

  JumpButton({this.onJump});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    positionType = PositionType.viewport;
    final sprite = await gameRef.loadSprite('ui/attack_btn.png');

    size = Vector2(50, 50);
    position = Vector2(gameRef.size.x - 250, gameRef.size.y - 100);

    add(SpriteComponent(sprite: sprite)..size = Vector2(50, 50));
  }

  @override
  bool onTapDown(TapDownInfo info) {
    onJump?.call();
    return super.onTapDown(info);
  }
}
