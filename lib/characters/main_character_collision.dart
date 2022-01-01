import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:the_arzo_flutter_flame/characters/enemy.dart';

import '../platform_map.dart';

typedef CollisionCallback<T> = Function(T collidable, bool isCollided);

class MainCharacterCollision extends PositionComponent
    with HasHitboxes, Collidable {
  Platform? standingPlatform;
  CollisionCallback<Platform>? onPlatformHit;
  CollisionCallback<Enemy>? onEnemyHit;

  MainCharacterCollision({
    required Vector2 position,
    required Vector2 size,
    this.onPlatformHit,
    this.onEnemyHit,
  }) : super(position: position, size: size);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    anchor = Anchor.bottomCenter;
    addHitbox(HitboxRectangle());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Platform && other != standingPlatform) {
      standingPlatform = other;
      onPlatformHit?.call(other, true);
    }
    if (other is Enemy) {
      onEnemyHit?.call(other, true);
    }
  }

  @override
  void onCollisionEnd(Collidable other) {
    super.onCollisionEnd(other);
    if (other is Platform && other == standingPlatform) {
      standingPlatform = null;
      onPlatformHit?.call(other, false);
    }
    if (other is Enemy) {
      onEnemyHit?.call(other, false);
    }
  }
}
