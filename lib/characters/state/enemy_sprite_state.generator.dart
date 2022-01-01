import 'package:flame/game.dart';
import 'package:flame/src/sprite_animation.dart';
import 'package:the_arzo_flutter_flame/characters/enemy.dart';
import 'package:the_arzo_flutter_flame/characters/state/sprite_state_generator.dart';

class EnemySpriteStateGenerator extends SpriteStateGenerator<EnemyState> {
  final Game gameRef;
  final Function()? onDie;

  const EnemySpriteStateGenerator(this.gameRef, {this.onDie});

  @override
  Future<Map<EnemyState, SpriteAnimation>> create() async {
    final idle = await gameRef.loadSpriteAnimation(
      'enemy/minotaur-idle.png',
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: .07,
        textureSize: Vector2.all(48),
      ),
    );

    final walk = await gameRef.loadSpriteAnimation(
      'enemy/minotaur-walk.png',
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: .07,
        textureSize: Vector2.all(48),
      ),
    );

    final attack = await gameRef.loadSpriteAnimation(
      'enemy/minotaur-attack.png',
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: .07,
        textureSize: Vector2.all(48),
      ),
    );

    final gesture = await gameRef.loadSpriteAnimation(
      'enemy/minotaur-gesture.png',
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: .07,
        textureSize: Vector2.all(48),
      ),
    );

    final die = await gameRef.loadSpriteAnimation(
      'enemy/minotaur-die.png',
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: .04,
        loop: false,
        textureSize: Vector2.all(48),
      ),
    )
      ..onComplete = onDie;

    return {
      EnemyState.idle: idle,
      EnemyState.attack: attack,
      EnemyState.gesture: gesture,
      EnemyState.walk: walk,
      EnemyState.die: die,
    };
  }
}
