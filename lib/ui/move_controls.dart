import 'package:flame/components.dart';
import 'package:flame/input.dart';

class MoveControls extends PositionComponent with Tappable {
  Function(MovementDirection direction)? onMove;
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
    debugMode = true;
  }

  @override
  bool onTapDown(TapDownInfo info) {
    final MovementDirection direction;

    final x = info.eventPosition.viewport.x;
    print(x);
    if (x < size.x / 2) {
      direction = MovementDirection.back;
    } else {
      direction = MovementDirection.forward;
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

enum MovementDirection {
  forward,
  back,
}
