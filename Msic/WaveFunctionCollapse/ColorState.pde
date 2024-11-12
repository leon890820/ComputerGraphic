public enum ColorState {
    B, I, P, E, N, D, A, W, R, O, Y, G, U, S, K, F, X
}

public enum TileState {
    Down, Line, Turn, Up, X, Empty
}

public Vector3 getVector3(ColorState s) {
    switch(s) {
    case B:
        return new Vector3(0.0 / 255.0, 0.0 / 255.0, 0.0 / 255.0);
    case I:
        return new Vector3(34.0 / 255.0, 46.0 / 255.0, 83.0 / 255.0);
    case P:
        return new Vector3(125.0 / 255.0, 41.0 / 255.0, 83.0 / 255.0);
    case E:
        return new Vector3(0.0 / 255.0, 133.0 / 255.0, 81.0 / 255.0);
    case N:
        return new Vector3(169.0 / 255.0, 82.0 / 255.0, 56.0 / 255.0);
    case D:
        return new Vector3(95.0 / 255.0, 87.0 / 255.0, 80.0 / 255.0);
    case A:
        return new Vector3(192.0 / 255.0, 193.0 / 255.0, 197.0 / 255.0);
    case W:
        return new Vector3(255.0 / 255.0, 241.0 / 255.0, 232.0 / 255.0);
    case R:
        return new Vector3(255.0 / 255.0, 7.0 / 255.0, 78.0 / 255.0);
    case O:
        return new Vector3(255.0 / 255.0, 161.0 / 255.0, 8.0 / 255.0);
    case Y:
        return new Vector3(254.0 / 255.0, 235.0 / 255.0, 44.0 / 255.0);
    case G:
        return new Vector3(0.0 / 255.0, 227.0 / 255.0, 57.0 / 255.0);
    case U:
        return new Vector3(44.0 / 255.0, 171.0 / 255.0, 254.0 / 255.0);
    case S:
        return new Vector3(130.0 / 255.0, 117.0 / 255.0, 154.0 / 255.0);
    case K:
        return new Vector3(255.0 / 255.0, 118.0 / 255.0, 166.0 / 255.0);
    case F:
        return new Vector3(255.0 / 255.0, 202.0 / 255.0, 168.0 / 255.0);
    }
    return new Vector3(0, 0, 0);
}
