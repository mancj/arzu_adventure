import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class SpriteStateGenerator<T> {
  const SpriteStateGenerator();

  Future<Map<T, SpriteAnimation>> create();
}
