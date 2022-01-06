import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
    // if (other.anchor != Anchor.bottomLeft) {
    //   throw Exception(
    //     'Use Anchor.bottomLeft for the ${other}. '
    //     'Currently other anchors do not supported for this method',
    //   );
    // }
    final Vector2 centerPoint = other.center;

    final right = absolutePosition.x + width;
    final bottom = absolutePosition.y + height - 2;

    /*if (name != '1') {
      print('point at ${centerPoint.y}, ${bottom}');
      gameRef.add(CircleComponent(
        radius: 1,
        paint: customPaint,
        position: centerPoint,
        anchor: Anchor.center,
      ));
    }*/

    if (centerPoint.y <= absolutePosition.y) {
      print('Top collistion at ${centerPoint}');
      collisionEdge = PlatformEdge.top;
    } else if (centerPoint.y >= bottom) {
      print('Bottom collistion at ${bottom}, ${centerPoint}');
      collisionEdge = PlatformEdge.bottom;
    } else if (other.x + other.width >= right) {
      print('Right collistion at ${centerPoint} ');
      collisionEdge = PlatformEdge.right;
    } else if (other.x <= absolutePosition.x) {
      print('Left collistion at ${centerPoint} ');
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
