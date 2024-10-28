public enum ColorState{
    B,I,P,E,N,D,A,W,R,O,Y,G,U,S,K,F,X
}

public int getColor(ColorState s){
    switch(s){
        case B:
            return color(0,0,0);
        case I:
            return color(34,46,83);
        case P:
            return color(125,41,83);
        case E:
            return color(0,133,81);
        case N:
            return color(169,82,56);
        case D:
            return color(95,87,80);
        case A:
            return color(192,193,197);
        case W:
            return color(255,241,232);
        case R:
            return color(255,7,78);
        case O:
            return color(255,161,8);
        case Y:
            return color(254,235,44);            
        case G:
            return color(0,227,57);            
        case U:
            return color(44,171,254);
        case S:
            return color(130,117,154);
        case K:
            return color(255,118,166);
        case F:
            return color(255,202,168);
    }
    return color(0,0,0);
}
