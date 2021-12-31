import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:the_arzo_flutter_flame/game.dart';

class GroundPlatform extends PositionComponent with HasGameRef<TheGame> {
  static const double SIZE = 48;
  final int blocks;

  GroundPlatform({
    required Vector2 position,
    required this.blocks,
  }) : super(position: position, size: Vector2(blocks * SIZE, SIZE));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final img = await gameRef.images.load('tx_tileset_ground.png');
    final ss = SpriteSheet.fromColumnsAndRows(
      image: img,
      columns: 16,
      rows: 16,
    );
    for (var i = 0; i < blocks; ++i) {
      int col = 0;
      if (i == blocks - 1) col = 2;
      if (i > 0 && i < blocks - 1) col = 1;

      final sc = SpriteComponent(sprite: ss.getSprite(12, col))
        ..scale = Vector2(1.5, 1.5);
      sc.position = Vector2(SIZE * i, 0);
      add(sc);
    }
  }

// @override
// void render(Canvas canvas) {
//   super.render(canvas);
//   canvas.drawRect(
//     Rect.fromLTRB(0, 0, size.x, size.y),
//     Paint()..color = Colors.indigo[800]!,
//   );
// }
}
