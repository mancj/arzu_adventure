import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:the_arzo_flutter_flame/game.dart';

class AttackButton extends SpriteComponent
    with HasGameRef<TheGame>, Tappable {
  Function()? onAttack;

  AttackButton({this.onAttack});

  static const _size = 80.0;

  @override
  Future<void> onLoad() async {
    positionType = PositionType.widget;

    final sprite = await gameRef.loadSprite('ui/attack_btn.png');
    this.sprite = sprite;
    size = Vector2(_size, _size);
    position = Vector2(gameRef.size.x - 100, gameRef.size.y - 100);
    anchor = Anchor.center;
    return super.onLoad();
  }

  @override
  bool onTapDown(TapDownInfo info) {
    onAttack?.call();
    const scf = .95;
    scale = Vector2(scf, scf);
    return true;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    scale = Vector2(1, 1);
    return super.onTapUp(info);
  }

  @override
  bool onTapCancel() {
    scale = Vector2(1, 1);
    return super.onTapCancel();
  }
}
