import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:the_arzo_flutter_flame/game.dart';

class Platform extends PositionComponent
    with HasGameRef, HasHitboxes, Collidable {
  String? name;
  PlatformEdge? collisionEdge;

  Platform({
    required Vector2 size,
    required Vector2 position,
    this.name,
  }) : super(
          size: size,
          position: position,
          anchor: Anchor.topLeft,
        );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    addHitbox(HitboxRectangle());
  }

  @override
  String toString() {
    return name ?? super.toString();
  }

  PlatformEdge? getPlatformEdge(
    PositionComponent other,
    Set<Vector2> points,
  ) {
    final Vector2 centerPoint = other.center;

    final right = absolutePosition.x + width;
    final bottom = absolutePosition.y + height - 2;

    if (centerPoint.y <= absolutePosition.y) {
      logger.d('Top collistion at ${centerPoint}');
      collisionEdge = PlatformEdge.top;
    } else if (centerPoint.y >= bottom) {
      logger.d('Bottom collistion at ${bottom}, ${centerPoint}');
      collisionEdge = PlatformEdge.bottom;
    } else if (other.x + other.width >= right) {
      logger.d('Right collistion at ${centerPoint} ');
      collisionEdge = PlatformEdge.right;
    } else if (other.x <= absolutePosition.x) {
      logger.d('Left collistion at ${centerPoint} ');
      collisionEdge = PlatformEdge.left;
    }
    return collisionEdge;
  }

  @override
  void onCollisionEnd(Collidable other) {
    collisionEdge = null;
  }
}

enum PlatformEdge { top, left, right, bottom }
