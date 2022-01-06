import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:the_arzo_flutter_flame/models/movement_direction.dart';

class MoveControls extends PositionComponent with Tappable {
  Function(AxisDirection direction)? onMove;
  Function()? onStopMove;

  MoveControls({
    required Vector2 size,
    this.onMove,
    this.onStopMove,
  }) : super(size: size);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    positionType = PositionType.viewport;
  }

  @override
  bool onTapDown(TapDownInfo info) {
    final AxisDirection direction;

    final x = info.eventPosition.viewport.x;
    if (x < size.x / 2) {
      direction = AxisDirection.left;
    } else {
      direction = AxisDirection.right;
    }

    onMove?.call(direction);
    return true;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    onStopMove?.call();
    return true;
  }

  @override
  bool onTapCancel() {
    onStopMove?.call();
    return super.onTapCancel();
  }
}
