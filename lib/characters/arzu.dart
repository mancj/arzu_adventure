import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:logger/logger.dart';
import 'package:the_arzo_flutter_flame/characters/state/arzu_sprite_state_generator.dart';
import 'package:the_arzo_flutter_flame/game.dart';
import 'package:the_arzo_flutter_flame/ui/move_controls.dart';

import 'enemy.dart';

class Arzu extends SpriteAnimationGroupComponent
    with HasGameRef<TheGame>, Tappable, HasHitboxes, Collidable {
  static const attacks = [
    KingState.attack2,
    KingState.attack1,
    KingState.attack3,
  ];
  static const attackSfxList = [
    'sfx/Socapex - Swordsmall.mp3',
    'sfx/Socapex - Swordsmall_1.mp3',
    'sfx/Socapex - Swordsmall_2.mp3',
    'sfx/Socapex - Swordsmall_3.mp3',
  ];
  static const double jumpVelocityY = -10;
  static const scaleFactor = 1.5;

  final Vector2 initialPosition;
  Function? _pendingAction;
  late Timer _jumpTimer;

  MovementDirection _movementDirection = MovementDirection.forward;

  int attachSfxIndex = 0;
  double groundPos = 0;
  int attackIndex = 0;
  var acceleration = Vector2(0, .35);
  var velocity = Vector2(0, 0);
  bool busy = false;
  bool jumping = false;

  late AudioPool pool;
  Enemy? _collidedEnemy;

  Arzu(this.initialPosition);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    gameRef.camera.speed = 1;
    gameRef.camera.followComponent(this, relativeOffset: const Anchor(.3, .5));
    _jumpTimer = Timer(
      .65,
      onTick: onAttackComplete,
      repeat: false,
      autoStart: false,
    );
    final animations = await ArzuSpriteStateGenerator(
      gameRef: gameRef,
      onAttackComplete: onAttackComplete,
      onJumpComplete:  onAttackComplete,
    ).create();

    addHitbox(HitboxCircle());

    this
      ..animations = animations
      ..position = initialPosition
      ..current = KingState.idle
      ..scale = Vector2.all(scaleFactor)
      ..size = Vector2(50, 37)
      ..anchor = Anchor.bottomCenter;
    groundPos = y;

    for (var sfx in attackSfxList) {
      await FlameAudio.audioCache.load(sfx);
    }
  }

  void onAttackComplete() {
    busy = false;
    if (_pendingAction != null) {
      _pendingAction?.call();
    } else if (velocity.x != 0) {
      current = KingState.running;
    } else {
      current = KingState.idle;
    }
    _pendingAction = null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity;
    if (y < groundPos) {
      velocity += acceleration;
    } else {
      jumping = false;
      position.y = groundPos;
    }
    _jumpTimer.update(dt);
  }

  void move(MovementDirection direction, {bool force = false}) {
    if (busy || jumping) return;
    logger.d('move $direction');
    current = KingState.running;
    _movementDirection = direction;
    final scaleX =
    direction == MovementDirection.forward ? scaleFactor : -scaleFactor;
    scale = Vector2(scaleX, scaleFactor);
    const v = 1.8;
    final double x = direction == MovementDirection.forward ? v : -v;
    velocity = Vector2(x, 0);
  }

  void idle() {
    if (busy || jumping) {
      print('schedule pending action: idle');
      _pendingAction = idle;
      return;
    }
    current = KingState.idle;
    velocity = Vector2.all(0);
    print('set velocity to 0');
  }

  void attack() {
    if (busy) return;
    gameRef.camera.shake(intensity: 3);
    if (attachSfxIndex > attackSfxList.length - 1) {
      attachSfxIndex = 0;
    }
    // FlameAudio.audioCache.play(attackSfxList[attachSfxIndex]);
    attachSfxIndex++;

    busy = true;
    current = attacks[attackIndex];
    attackIndex++;
    if (attackIndex > attacks.length - 1) {
      attackIndex = 0;
    }
    animation?.reset();
    _collidedEnemy?.hurt();
  }

  void jump() {
    if (jumping) return;
    current = KingState.jump;
    jumping = true;
    // _jumpTimer.start();
    velocity = Vector2(velocity.x, jumpVelocityY);
    animation?.reset();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    if (other is Enemy) {
      _collidedEnemy = other;
    }
  }

  @override
  void onCollisionEnd(Collidable other) {
    super.onCollisionEnd(other);
    if (other is Enemy) {
      _collidedEnemy = null;
    }
  }
}

enum KingState {
  idle,
  running,
  attack1,
  attack2,
  attack3,
  jump,
}
