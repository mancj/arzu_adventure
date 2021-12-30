import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class PlatformMap extends Component {
  final double tileSize;

  PlatformMap(this.tileSize);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    final tiledMap =
        await TiledComponent.load('test.tmx', Vector2(tileSize, tileSize));
    final tiledComponent = PositionComponent(position: Vector2(0, 0))
      ..add(tiledMap);
  }
}
