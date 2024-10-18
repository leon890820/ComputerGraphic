public class World {
    ArrayList<Chunk> chunks = new ArrayList<Chunk>();

    public World() {
        for (int z = -VoxelData.viewSize; z <= VoxelData.viewSize; z++ ) {
            for (int x = -VoxelData.viewSize; x <= VoxelData.viewSize; x++ ) {
                chunks.add(new Chunk(new ChunkCoord(x , z),this));
            }
        }
        
        chunks.forEach(Chunk::init);
        
    }

    public void run() {
        chunks.forEach(GameObject::run);
    }
    
    public Voxel getVoxelType(Vector3 position){
        float scale = 0.02;
        float h = noise(position.x * scale, position.z * scale) * 20 - 10;
        
        if(position.y > 70 + h) return new Air();
        if(position.y - 4 < 60) return new Stone();
        return new Grass();
                
    }
    
    public boolean checkChunkIsExist(ChunkCoord cc){

        for(Chunk chunk : chunks){
            if(chunk.chunkCoord.equals(cc)) {
                return true;
            }
        }
        return false;
    }
    
}


public class ChunkCoord {
    public int x;
    public int z;
    public ChunkCoord(int x, int z) {
        this.x = x;
        this.z = z;
    }
    
    public ChunkCoord add(int x1 , int z1 ,int x, int z){
        int xs = this.x * VoxelData.chunkWidth + x + x1;
        int zs = this.z * VoxelData.chunkWidth + z + z1;        
        int cx = xs / VoxelData.chunkWidth + (xs < 0 ? -1 : 0);
        int cz = zs / VoxelData.chunkWidth + (zs < 0 ? -1 : 0);
        
        return new ChunkCoord(cx , cz);   
    }
    
        public ChunkCoord add(int x, int z){
        int xs = this.x * VoxelData.chunkWidth + x ;
        int zs = this.z * VoxelData.chunkWidth + z ;       
        int cx = (xs + (xs < 0 ? 1 : 0)) / VoxelData.chunkWidth + (xs < 0 ? -1 : 0);
        int cz = (zs + (zs < 0 ? 1 : 0)) / VoxelData.chunkWidth + (zs < 0 ? -1 : 0);
        
        return new ChunkCoord(cx , cz);   
    }
    
    @Override
    public String toString(){
        return "Chunk x : " + x + " z : " + z;    
    }
    
    @Override
    public boolean equals(Object o) {
        if (o == this) return true;
        if (!(o instanceof ChunkCoord)) return false;                 
        ChunkCoord c = (ChunkCoord) o;
        return c.x == x && c.z == z;         
    }
    
}
