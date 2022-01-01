import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:the_arzo_flutter_flame/characters/enemy.dart';
import 'package:tiled/tiled.dart';

class PlatformMap extends PositionComponent {
  final double tileSize = 32;
  static const double originalTileSize = 32;

  late List<TiledObject> collisions;
  late List<TiledObject> enemies;
  late TiledComponent _tiledComponent;

  late Vector2 firstPlatformPosition;

  PlatformMap({required Vector2 position}) : super(position: position);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    anchor = Anchor.topLeft;
    add(_tiledComponent);

    for (var collision in collisions) {
      add(
        Platform(
          Vector2(collision.x, collision.y),
          Vector2(collision.width, collision.height),
        ),
      );
    }

    for (var enemy in enemies) {
      add(Enemy(position: Vector2(enemy.x, enemy.y)));
    }
  }

  Future<void> initialize() async {
    _tiledComponent = await TiledComponent.load(
      'test.tmx',
      Vector2(tileSize, tileSize),
    );
    size = Vector2(
      _tiledComponent.tileMap.map.width * tileSize,
      _tiledComponent.tileMap.map.height * tileSize,
    );
    collisions =
        _tiledComponent.tileMap.getObjectGroupFromLayer('collision').objects;

    enemies =
        _tiledComponent.tileMap.getObjectGroupFromLayer('enemies').objects;
  }
}

class Platform extends PositionComponent with HasHitboxes, Collidable {
  Platform(
    Vector2 position,
    Vector2 size,
  ) : super(
          position: position,
          size: size,
        );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    addHitbox(HitboxRectangle());
  }
}
