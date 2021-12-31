import 'package:flame/components.dart';

extension Vector2Centers on Vector2 {
  double get centerX => x / 2;

  double get centerY => y / 2;

  Vector2 get center => Vector2(x / 2, y / 2);
}
