enum MovementDirection {
  forward,
  back,
}

extension MovementDirectionInt on num {
  E byDirection<E extends num>(MovementDirection direction) {
    switch (direction) {
      case MovementDirection.forward:
        return abs() as E;
      case MovementDirection.back:
        return -abs() as E;
    }
  }
}
