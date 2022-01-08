import 'package:flame/components.dart';
import 'package:flame/input.dart';

class JumpButton extends ButtonComponent with HasGameRef {
  Function()? onJump;

  JumpButton({this.onJump, required Vector2 position})
      : super(
          position: position,
          button: CircleComponent(radius: 40),
          anchor: Anchor.bottomRight,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.bottomRight;
    positionType = PositionType.viewport;
    final sprite = await gameRef.loadSprite('ui/attack_btn.png');

    size = Vector2(50, 50);

    // add(SpriteComponent(sprite: sprite)..size = Vector2(50, 50));
  }

  @override
  bool onTapDown(TapDownInfo info) {
    onJump?.call();
    return super.onTapDown(info);
  }
}
