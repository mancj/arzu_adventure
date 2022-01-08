import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/geometry.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/animation.dart';
import 'package:the_arzo_flutter_flame/characters/player.dart';

class GoldenCoin extends SpriteAnimationComponent
    with HasGameRef, HasHitboxes, Collidable {
  GoldenCoin({required Vector2 position}) : super(position: position);

  static const sfx = 'sfx/shine_coin.mp3';
  late final Timer _removeTimer;
  bool isRemoving = false;

  static const double _translateEffectDuration = 1;
  static const double _opacityEffectDuration = .4;
  static const double _opacityEffectDelay = .4;

  double get _removeTimerDuration =>
      _translateEffectDuration + _opacityEffectDuration;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    size = Vector2(16, 16);
    anchor = Anchor.bottomCenter;
    animation = await gameRef.loadSpriteAnimation(
      'items/golden_coin.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: .07,
        textureSize: Vector2.all(16),
      ),
    );

    addHitbox(HitboxCircle());
    _removeTimer = Timer(_removeTimerDuration, autoStart: false, onTick: () {
      parent?.remove(this);
    });
    await FlameAudio.audioCache.load(sfx);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _removeTimer.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player && !isRemoving) {
      isRemoving = true;
      FlameAudio.audioCache.play(sfx);
      add(
        MoveEffect.by(
          Vector2(0, -30),
          EffectController(
            duration: _translateEffectDuration,
            curve: Curves.elasticOut,
          ),
        ),
      );
      add(OpacityEffect.fadeOut(
        EffectController(
          duration: _opacityEffectDuration,
          startDelay: _opacityEffectDelay,
        ),
      ));
      _removeTimer.start();
    }
  }
}
