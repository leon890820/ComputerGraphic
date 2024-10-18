public abstract class Voxel{
    int VoxelID;
    boolean isSolid;
    int[] textureID;
}

public class Air extends Voxel{    
    public Air(){
        VoxelID = 0;
        isSolid = false;
        textureID = null;
    }
}

public class Stone extends Voxel{    
    public Stone(){
        VoxelID = 1;
        isSolid = true;
        textureID = new int[]{0,0,0,0,0,0};
    }   
}

public class Grass extends Voxel{    
    public Grass(){
        VoxelID = 1;
        isSolid = true;
        textureID = new int[]{2,2,7,1,2,2};
    }   
}
