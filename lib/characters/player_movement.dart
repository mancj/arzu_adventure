import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_arzo_flutter_flame/components/platform.dart';
import 'package:the_arzo_flutter_flame/game.dart';

class PlayerMovement extends SpriteAnimationGroupComponent
    with HasGameRef<TheGame>, HasHitboxes, Collidable {
  static const double movementSpeed = 180;
  static const double fallingSpeed = 40;

  final _velocity = Vector2(0, 0);
  double _landY = 0;
  bool isLanded = true;
  Platform? standingPlatform;
  Platform? lastStandedPlatform;
  Platform? sidePlatform;

  bool _canMoveLeft = true;
  bool _canMoveRight = true;

  late final Vector2 _cameraPosition;

  /// Used to smoothly stop the player
  /// by deceleration of moving x velocity
  late Timer _decelerationTimer;

  static const double _jumpHeight = 60;
  late Timer _jumpTimer;
  double _jumpDelta = 0;

  bool get isMovingForward => _velocity.x > 0;

  bool get isMovingBack => _velocity.x < 0;

  Camera get _camera => gameRef.camera;
  late final Timer _cameraYTimer;
  double _cameraYDelta = 0;

  PlayerMovement({
    required Vector2 position,
  }) : super(
          position: position,
        );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    addHitbox(HitboxRectangle(relation: Vector2(.4, 1)));

    setFalling(true);
    _landY = position.y;
    _cameraPosition = Vector2(position.x, _landY);
    _camera.followVector2(
      _cameraPosition,
      relativeOffset: const Anchor(.3, .5),
    );

    _createTimers();
  }

  void _createTimers() {
    _cameraYTimer = Timer(.5, autoStart: false);
    _jumpTimer = Timer(
      .7,
      repeat: false,
      autoStart: false,
    );
    _decelerationTimer = Timer(
      .2,
      onTick: () {
        _velocity.x = 0;
        _decelerationTimer.reset();
      },
      repeat: false,
      autoStart: false,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if ((isMovingForward && _canMoveRight) || (isMovingBack && _canMoveLeft)) {
      if (_decelerationTimer.isRunning()) {
        position.x += _velocity.x * (1 - _decelerationTimer.progress) * dt;
      } else {
        position.x += _velocity.x * dt;
      }
    }
    // gameRef.parallax.parallax?.baseVelocity = Vector2(_velocity.x * dt / 5, 0);
    _cameraPosition.x = x;

    if (isLanded) {
      position.y += _velocity.y;
    } else if (_jumpTimer.isRunning()) {
      // calculating jump y delta using sin function with pi offset
      _jumpDelta = sin(_jumpTimer.progress * pi) * _jumpHeight;
      position.y = (_landY - _jumpDelta);
    } else {
      position.y += _velocity.y * (dt * 10);
    }

    if (_cameraYTimer.isRunning()) {}

    _jumpTimer.update(dt);
    _decelerationTimer.update(dt);
    if (_cameraYTimer.isRunning()) {
      _cameraYTimer.update(dt);
      _cameraPosition.y = lastStandedPlatform!.absolutePosition.y -
          (_cameraYDelta - (_cameraYDelta * _cameraYTimer.progress));
    }
  }

  void move(AxisDirection direction) {
    if (_decelerationTimer.isRunning()) {
      _decelerationTimer.stop();
      _decelerationTimer.reset();
    }
    if (direction == AxisDirection.left) {
      _velocity.x = -movementSpeed;
    } else if (direction == AxisDirection.right) {
      _velocity.x = movementSpeed;
    }
  }

  void stop() {
    _decelerationTimer.start();
  }

  int jumpCount = 0;
  int maxJumpCount = 2;

  void jump() {
    if (jumpCount >= maxJumpCount) {
      return;
    }
    _landY = position.y;
    isLanded = false;
    _jumpTimer.reset();
    _jumpTimer.start();
    jumpCount++;
  }

  void setFalling(bool isFalling) {
    _velocity.y = isFalling ? fallingSpeed : 0;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Platform && other != standingPlatform) {
      final edge = other.getPlatformEdge(this, intersectionPoints);
      if (edge == PlatformEdge.top && other != sidePlatform) {
        isLanded = true;
        standingPlatform = other;
        final oldPlatformY =
            lastStandedPlatform?.absolutePosition.y ?? other.absolutePosition.y;
        _jumpTimer.stop();
        _jumpTimer.reset();

        _cameraYDelta = other.absolutePosition.y - oldPlatformY;
        _cameraYTimer.stop();
        _cameraYTimer.start();
        _camera.position.y =
            lastStandedPlatform?.absolutePosition.y ?? other.absolutePosition.y;

        _landY = standingPlatform!.absolutePosition.y;

        print(
          '\nlast standed platform: ${lastStandedPlatform?.absolutePosition}\n'
          'new platform: ${other.absolutePosition}\n'
          'camera\'s position: ${_camera.position.y}\n'
          'camera y delta: ${_cameraYDelta}\n',
        );

        position.y = _landY;
        setFalling(false);
        lastStandedPlatform = standingPlatform;
        jumpCount = 0;
      }
      if (edge == PlatformEdge.bottom) {
        setFalling(standingPlatform == null);
        _jumpTimer.stop();
        _jumpTimer.reset();
      }
      if ((edge == PlatformEdge.left || edge == PlatformEdge.right)) {
        sidePlatform = other;

        _canMoveLeft = edge != PlatformEdge.right;
        _canMoveRight = edge != PlatformEdge.left;
      }
    }
  }

  @override
  void onCollisionEnd(Collidable other) {
    super.onCollisionEnd(other);
    if (other is Platform && other == standingPlatform) {
      isLanded = false;
      standingPlatform = null;
      lastStandedPlatform = other;
      setFalling(true);
    }
    if (other == sidePlatform) {
      sidePlatform = null;
      _canMoveLeft = true;
      _canMoveRight = true;
    }
  }
}
