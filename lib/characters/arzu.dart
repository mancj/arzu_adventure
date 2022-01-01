import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:the_arzo_flutter_flame/characters/main_character_collision.dart';
import 'package:the_arzo_flutter_flame/characters/state/arzu_sprite_state_generator.dart';
import 'package:the_arzo_flutter_flame/game.dart';
import 'package:the_arzo_flutter_flame/models/movement_direction.dart';
import 'package:the_arzo_flutter_flame/platform_map.dart';
import 'package:the_arzo_flutter_flame/utils/vector2_extensions.dart';

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

  // static const double jumpXVelocityX = 7;
  static const double jumpVelocityY = -30;
  static const double scaleFactor = 1;

  Function? _pendingAction;

  MovementDirection movementDirection = MovementDirection.forward;

  int attachSfxIndex = 0;
  double groundPos = 0;
  bool falling = false;
  int attackIndex = 0;
  var acceleration = Vector2(0, 1);
  var velocity = Vector2(0, 0);
  bool busy = false;
  bool jumping = false;

  late AudioPool pool;
  Enemy? _collidedEnemy;

  Arzu({required Vector2 position}) : super(position: position);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    gameRef.camera.speed = 1;
    gameRef.camera.followComponent(this, relativeOffset: const Anchor(.3, .5));
    final animations = await ArzuSpriteStateGenerator(
      gameRef: gameRef,
      onAttackComplete: _onActionComplete,
      onJumpComplete: _onActionComplete,
    ).create();

    this
      ..animations = animations
      ..current = KingState.idle
      ..scale = Vector2.all(scaleFactor)
      ..size = Vector2(50, 37)
      ..anchor = Anchor.bottomCenter;
    groundPos = y;

    add(
      MainCharacterCollision(
          position: Vector2(size.centerX, size.y),
          size: Vector2(10, 30),
          onPlatformHit: (platform, isCollided) {
            if (isCollided) {
              final possibleY = platform.absolutePosition.y + 10;
              if (absolutePosition.y <= possibleY) {
                print('falling to false');
                falling = false;
                groundPos = platform.absolutePosition.y;
                print('hit on the ground');
              } else {
                jumping = false;
                falling = true;
                idle();
              }
            } else {
              falling = true;
              logger.d('fall');
            }
          },
          onEnemyHit: (enemy, isCollided) =>
              _collidedEnemy = isCollided ? enemy : null),
    );

    if (gameRef.soundsEnabled) {
      await FlameAudio.audioCache.loadAll(attackSfxList);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * (dt * 10);
    if (y < groundPos || falling) {
      velocity += acceleration;
    } else {
      jumping = false;
      position.y = groundPos;
    }
  }

  void move(MovementDirection direction, {bool force = false}) {
    if (busy || jumping || falling) return;
    print('move');
    current = KingState.running;
    movementDirection = direction;
    final scaleX =
        direction == MovementDirection.forward ? scaleFactor : -scaleFactor;
    scale = Vector2(scaleX, scaleFactor);
    const double v = 10;
    final double x = direction == MovementDirection.forward ? v : -v;
    velocity = Vector2(x, 0);
  }

  void idle() {
    if (busy || jumping) {
      logger.d('schedule pending action: idle');
      _pendingAction = idle;
      return;
    }
    current = KingState.idle;
    velocity = Vector2.all(0);
    logger.d('Set idle state');
  }

  void attack() {
    if (busy) return;
    logger.d('Attack');
    gameRef.camera.shake(intensity: 3);
    if (attachSfxIndex > attackSfxList.length - 1) {
      attachSfxIndex = 0;
    }
    if (gameRef.soundsEnabled) {
      FlameAudio.audioCache.play(attackSfxList[attachSfxIndex]);
    }
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

  void _onActionComplete() {
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

  void jump() {
    if (jumping) return;
    current = KingState.jump;
    jumping = true;

    final double xv = velocity.x != 0 ? velocity.x : 0;
    velocity = Vector2(xv, jumpVelocityY);
    animation?.reset();
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
