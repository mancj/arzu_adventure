import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:the_arzo_flutter_flame/characters/main_character_collision.dart';
import 'package:the_arzo_flutter_flame/characters/player_movement.dart';
import 'package:the_arzo_flutter_flame/characters/state/enemy_sprite_state.generator.dart';
import 'package:the_arzo_flutter_flame/components/golden_coin.dart';
import 'package:the_arzo_flutter_flame/game.dart';
import 'package:the_arzo_flutter_flame/models/movement_direction.dart';
import 'package:the_arzo_flutter_flame/utils/vector2_extensions.dart';

class Enemy extends SpriteAnimationGroupComponent
    with HasGameRef<TheGame>, HasHitboxes, Collidable {
  var velocity = Vector2(0, 0);
  static const double sf = 1;
  bool busy = false;

  double _health;
  final double _fullHealth;
  late Timer _idleAfterGestureTimer;
  var _direction = AxisDirection.right;

  set direction(AxisDirection direction) {
    _direction = direction;
    final xsf = _direction == AxisDirection.right ? -sf : sf;
    scale = Vector2(xsf, sf);
  }

  Enemy({
    required Vector2 position,
    health = 3.0,
  })  : _health = health,
        _fullHealth = health,
        super(position: position);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    final animations = await EnemySpriteStateGenerator(gameRef).create();
    addHitbox(HitboxRectangle());

    animations[EnemyState.die]?.onComplete = addCoins;
    this
      ..animations = animations
      ..current = EnemyState.idle
      ..scale = Vector2.all(sf)
      ..size = Vector2.all(48)
      ..anchor = Anchor.bottomCenter;

    _idleAfterGestureTimer = Timer(
      1,
      autoStart: false,
      repeat: false,
      onTick: () {
        current = EnemyState.idle;
      },
    );
  }

  void addCoins() {
    parent?.remove(this);
    for (var i = 0; i < _fullHealth; ++i) {
      parent?.add(
        GoldenCoin(
          position: Vector2(
            position.x + (i * 16),
            position.y,
          ),
        ),
      );
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is PlayerMovement && !busy) {
      current = EnemyState.attack;
      _lookAtComponent(other);
    }
  }

  @override
  void onCollisionEnd(Collidable other) {
    super.onCollisionEnd(other);
    if (other is PlayerMovement && !busy) {
      current = EnemyState.gesture;
      _idleAfterGestureTimer.start();
      _lookAtComponent(other);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity;
    _idleAfterGestureTimer.update(dt);
  }

  final _fullHealthPaint = Paint()..color = Colors.pink.withOpacity(.4);
  final _healthPaint = Paint()..color = Colors.pink;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      Rect.fromLTWH(size.centerX, 10, _fullHealth * 4, 3),
      _fullHealthPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.centerX, 10, _health * 4, 3),
      _healthPaint,
    );
  }

  void _lookAtComponent(PositionComponent component) {
    if (component.absolutePosition.x < x) {
      direction = AxisDirection.left;
    } else {
      direction = AxisDirection.right;
    }
  }

  void hurt() {
    if (_health <= 0) return;
    busy = true;
    _health--;
    if (_health <= 0) {
      current = EnemyState.die;
    }
  }
}

enum EnemyState {
  idle,
  gesture,
  walk,
  attack,
  die,
}
