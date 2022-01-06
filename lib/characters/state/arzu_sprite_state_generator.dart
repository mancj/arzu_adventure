import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:the_arzo_flutter_flame/characters/player.dart';
import 'package:the_arzo_flutter_flame/characters/state/sprite_state_generator.dart';

@immutable
class ArzuSpriteStateGenerator extends SpriteStateGenerator<PlayerState> {
  final Game gameRef;

  final Function() onAttackComplete;
  final Function() onJumpComplete;

  const ArzuSpriteStateGenerator({
    required this.gameRef,
    required this.onAttackComplete,
    required this.onJumpComplete,
  });

  @override
  Future<Map<PlayerState, SpriteAnimation>> create() async {
    final idle = await gameRef.loadSpriteAnimation(
      'adventurer/idle.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: .15,
        textureSize: Vector2(50, 37),
      ),
    );

    final run = await gameRef.loadSpriteAnimation(
      'adventurer/run.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: .1,
        textureSize: Vector2(50, 37),
      ),
    );

    final jump = await gameRef.loadSpriteAnimation(
      'adventurer/jump.png',
      SpriteAnimationData.variable(
        amount: 8,
        stepTimes: [.1, .1, .1, .1, .1, .1, .1, .3],
        // stepTime: .08,
        textureSize: Vector2(50, 37),
        loop: false,
      ),
    )
      ..onComplete = onJumpComplete;

    const attackStepTime = .1;

    final attack1 = await gameRef.loadSpriteAnimation(
      'adventurer/attack_1.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: attackStepTime,
        textureSize: Vector2(50, 37),
        loop: false,
      ),
    )
      ..onComplete = onAttackComplete;

    final attack2 = await gameRef.loadSpriteAnimation(
      'adventurer/attack_2.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: attackStepTime,
        textureSize: Vector2(50, 37),
        loop: false,
      ),
    )
      ..onComplete = onAttackComplete;

    final attack3 = await gameRef.loadSpriteAnimation(
      'adventurer/attack_3.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: attackStepTime,
        textureSize: Vector2(50, 37),
        loop: false,
      ),
    )
      ..onComplete = onAttackComplete;

    return {
      PlayerState.idle: idle,
      PlayerState.running: run,
      PlayerState.attack1: attack1,
      PlayerState.attack2: attack2,
      PlayerState.attack3: attack3,
      PlayerState.jump: jump,
    };
  }
}
