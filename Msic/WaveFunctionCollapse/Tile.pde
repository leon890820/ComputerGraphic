public abstract class Tile extends GameObject{
    Cube[][][] cubes;
    int rotation = 0;
    

    public Tile(ColorState[][][] c) {
        cubes = new Cube[c.length][c[0].length][c[0][0].length];
        init(c);
    }
    public Tile(ColorState[][][] c, int r) {
        cubes = new Cube[c.length][c[0].length][c[0][0].length];
        rotation = r;
        init(c);
    }

    public void init(ColorState[][][] c) {
        initMesh(c);
    }

    public void initMesh(ColorState[][][] c) {
        Vector3 position = getPosition();
        for (int y = 0; y < c[0].length; y++)  for (int z = 0; z < c.length; z++) for (int x = 0; x < c[0][0].length; x++) {
            if (c[z][y][x] == ColorState.X) continue;
            int rz = 0, rx = 0;
            
            if(rotation == 0) {rz = z; rx = x;}
            if(rotation == 3) {rx = z; rz = c[0][0].length - 1 - x;}
            if(rotation == 2) {rx = c[0][0].length - 1 - x; rz = c.length - 1 - z;}
            if(rotation == 1) {rx = c.length - 1 -z; rz = x;}
            
            cubes[rz][y][rx] = new Cube(c[z][y][x]);
            cubes[rz][y][rx].setPosition(position.x * c[0][0].length + rx,position.y * c[0].length + y, position.z * c.length + rz);
        }
    }
    
    @Override
    public Tile setPosition(float px, float py, float pz){        
        for (int y = 0; y < cubes[0].length; y++)  for (int z = 0; z < cubes.length; z++) for (int x = 0; x < cubes[0][0].length; x++) {
            if(cubes[z][y][x] == null) continue;
            cubes[z][y][x].setPosition(px * cubes[0][0].length + x,py * cubes[0].length + y, pz * cubes.length + z);
        }
        return this;
    }


    public void run() {
        for (int y = 0; y < cubes[0].length; y++)  for (int z = 0; z < cubes.length; z++) for (int x = 0; x < cubes[0][0].length; x++) {
            if (cubes[z][y][x] == null) continue;
            phongMaterial.setAlbedo(getVector3(cubes[z][y][x].state));
            cubes[z][y][x].run();
        }
    }
}


public class Down extends Tile{
    public Down(int r){
        super(TileData.Down , r);
    }
}

public class Line extends Tile{
    public Line(int r){
        super(TileData.Line , r);
    }
}

public class Turn extends Tile{
    public Turn(int r){
        super(TileData.Turn , r);
    }
}

public class Up extends Tile{
    public Up(int r){
        super(TileData.Up , r);
    }
}

public class X extends Tile{
    public X(int r){
        super(TileData.X , r);
    }
}

public class Empty extends Tile{
    public Empty(int r){
        super(TileData.Empty , r);
    }
}

public int getTileNumber(TileState a){
    switch(a){
        case Down:
            return 0;
        case Line:
            return 1;
        case Turn:
            return 2;
        case Up:
            return 3;
        case X:
            return 4;
        case Empty:
            return 5;
    }
    return 0;
}

public Tile getTile(TileState a , int r){    
    switch(a){
        case Down:
            return new Down(r);
        case Line:
            return new Line(r);
        case Turn:
            return new Turn(r);
        case Up:
            return new Up(r);
        case X:
            return new X(r);
        case Empty:
            return new Empty(r);
    }
    return new Empty(r);
}

public TileState getTileState(int a){    
    switch(a){
        case 0:
            return TileState.Down;
        case 1:
            return TileState.Line;
        case 2:
            return TileState.Turn;
        case 3:
            return TileState.Up;
        case 4:
            return TileState.X;
        case 5:
            return TileState.Empty;
    }
    return TileState.Empty;
}


public static class Neighbor{
    TileState tile;
    int rotation;
    public Neighbor(TileState t , int r){
        tile = t;
        rotation = r;
    }
    
    @Override
    public boolean equals(Object o) {
        if (o == this) return true;
        if (!(o instanceof Neighbor)) return false;                 
        Neighbor n = (Neighbor) o;
        return n.tile == tile && n.rotation == rotation;         
    }
    
    @Override
    public String toString(){
        return "Tile : " + tile + " Rotation : " + rotation;
    }

}


public class Wave{
    boolean done = false;
    boolean collapse = false;
    Vector3 position;
    
    ArrayList<Neighbor> state = new ArrayList<Neighbor>();
    
    public Wave(int x, int y, int z){
        position = new Vector3(x,y,z);
        for(int i = 0; i < 6 ; i++){
            for(int j = 0; j < 4; j++){
                state.add(new Neighbor( getTileState(i) , j));
            }
        }
    }
    
    
    
}
