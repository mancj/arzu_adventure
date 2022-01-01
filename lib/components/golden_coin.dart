import 'package:flame/components.dart';

class GoldenCoin extends PositionComponent with HasGameRef {
  GoldenCoin({required Vector2 position}) : super(position: position);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    print('coin position: ${position}, parent: $parent');
    size = Vector2(16, 16);
    anchor = Anchor.bottomCenter;
    final animation = await gameRef.loadSpriteAnimation(
      'items/golden_coin.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: .1,
        textureSize: Vector2.all(16),
      ),
    );
    add(
      SpriteAnimationComponent(
        animation: animation,
        size: size,
      ),
    );
  }
}
