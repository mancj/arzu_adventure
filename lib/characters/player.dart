import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:the_arzo_flutter_flame/characters/player_movement.dart';
import 'package:the_arzo_flutter_flame/characters/state/arzu_sprite_state_generator.dart';
import 'package:the_arzo_flutter_flame/game.dart';

import 'enemy.dart';

class Player extends PlayerMovement with Tappable {
  static const attacks = [
    PlayerState.attack2,
    PlayerState.attack1,
    PlayerState.attack3,
  ];
  static const attackSfxList = [
    'sfx/Socapex - Swordsmall.mp3',
    'sfx/Socapex - Swordsmall_1.mp3',
    'sfx/Socapex - Swordsmall_2.mp3',
    'sfx/Socapex - Swordsmall_3.mp3',
  ];

  static const double scaleFactor = 1;

  Function? _pendingAction;

  int attachSfxIndex = 0;
  int attackIndex = 0;
  bool isBusy = false;


  late AudioPool pool;
  Enemy? _collidedEnemy;

  Player({required Vector2 position}) : super(position: position);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    final animations = await ArzuSpriteStateGenerator(
      gameRef: gameRef,
      onAttackComplete: _onActionComplete,
      onJumpComplete: _onActionComplete,
    ).create();

    this
      ..animations = animations
      ..current = PlayerState.idle
      ..scale = Vector2.all(scaleFactor)
      ..size = Vector2(50, 37)
      ..anchor = Anchor.bottomCenter;

    if (gameRef.soundsEnabled) {
      await FlameAudio.audioCache.loadAll(attackSfxList);
    }
  }

  @override
  void move(AxisDirection direction) {
    super.move(direction);
    current = PlayerState.running;
    final scaleX =
        direction == AxisDirection.right ? scaleFactor : -scaleFactor;
    scale = Vector2(scaleX, scaleFactor);
  }

  //
  //
  // void move(MovementDirection direction, {bool force = false}) {
  //   if (isBusy || isJumping || falling) return;
  //   isMoving = true;
  //   current = KingState.running;
  //   movementDirection = direction;
  //   final scaleX =
  //   direction == MovementDirection.forward ? scaleFactor : -scaleFactor;
  //   scale = Vector2(scaleX, scaleFactor);
  //   final double x = movementVelocityX.byDirection(movementDirection);
  //   velocity = Vector2(x, 0);
  // }

  @override
  void stop() {
    super.stop();
    if (isBusy) {
      logger.d('schedule pending action: idle');
      _pendingAction = stop;
      return;
    }
    current = PlayerState.idle;
    logger.d('Set idle state');
  }

  void attack() {
    if (isBusy) return;
    logger.d('Attack');
    gameRef.camera.shake(intensity: 3);
    if (attachSfxIndex > attackSfxList.length - 1) {
      attachSfxIndex = 0;
    }
    if (gameRef.soundsEnabled) {
      FlameAudio.audioCache.play(attackSfxList[attachSfxIndex]);
    }
    attachSfxIndex++;

    isBusy = true;
    current = attacks[attackIndex];
    attackIndex++;
    if (attackIndex > attacks.length - 1) {
      attackIndex = 0;
    }
    animation?.reset();
    _collidedEnemy?.hurt();
  }

  void _onActionComplete() {
    isBusy = false;
    if (_pendingAction != null) {
      _pendingAction?.call();
    } else if (isMovingForward || isMovingBack) {
      current = PlayerState.running;
    } else {
      current = PlayerState.idle;
    }
    _pendingAction = null;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
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

  @override
  void jump() {
    super.jump();
    current = PlayerState.jump;
    animation?.reset();
  }
}

enum PlayerState {
  idle,
  running,
  attack1,
  attack2,
  attack3,
  jump,
}
