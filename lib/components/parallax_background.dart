import 'package:flame/components.dart';
import 'package:flame/parallax.dart';

class ParallaxBackground extends ParallaxComponent {
  ParallaxBackground({required Vector2 size}) : super(size: size);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    final parallaxImages = [
      ParallaxImageData('parallax/plx-1.png'),
      ParallaxImageData('parallax/plx-2.png'),
      ParallaxImageData('parallax/plx-3.png'),
      ParallaxImageData('parallax/plx-4.png'),
      ParallaxImageData('parallax/plx-5.png'),
    ];

    print('parallax onLoad size: ${size}');

    positionType = PositionType.viewport;
    parallax = await Parallax.load(
      parallaxImages,
      baseVelocity: Vector2(0, 0),
      velocityMultiplierDelta: Vector2(2, 1),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    print('parallax component resized: ${size}');
  }
}
