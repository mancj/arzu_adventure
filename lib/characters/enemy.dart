import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:the_arzo_flutter_flame/characters/arzu.dart';
import 'package:the_arzo_flutter_flame/characters/state/enemy_sprite_state.generator.dart';
import 'package:the_arzo_flutter_flame/game.dart';
import 'package:the_arzo_flutter_flame/ui/move_controls.dart';

class Enemy extends SpriteAnimationGroupComponent
    with HasGameRef<TheGame>, HasHitboxes, Collidable {
  var velocity = Vector2(0, 0);
  static const double sf = 1;
  bool busy = false;

  double _health;
  late Timer _idleAfterGestureTimer;
  var _direction = MovementDirection.forward;

  set direction(MovementDirection direction) {
    _direction = direction;
    final xsf = _direction == MovementDirection.forward ? -sf : sf;
    scale = Vector2(xsf, sf);
  }

  Enemy({
    required Vector2 position,
    health = 3.0,
  })  : _health = health,
        super(position: position);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    final animations = await EnemySpriteStateGenerator(gameRef).create();
    addHitbox(HitboxRectangle());

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

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Arzu && !busy) {
      current = EnemyState.attack;
      _lookAtComponent(other);
    }
  }

  @override
  void onCollisionEnd(Collidable other) {
    super.onCollisionEnd(other);
    if (other is Arzu && !busy) {
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

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.x / 2, 10),
        width: _health.toDouble() * 4,
        height: 3,
      ),
      Paint()..color = Colors.red,
    );
  }

  void _lookAtComponent(PositionComponent component) {
    if (component.x < this.x) {
      direction = MovementDirection.back;
    } else {
      direction = MovementDirection.forward;
    }
  }

  void hurt() {
    if (_health <= 0) return;
    busy = true;
    _health--;
    if (_health <= 0) {
      current = EnemyState.die;
      //   // remove(this);ddddddd
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
