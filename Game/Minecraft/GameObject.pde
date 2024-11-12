public abstract class GameObject {
    String name;
    Transform transform;
    Mesh mesh;
    Material material;
    MeshRenderer meshRenderer;
    boolean[] hasProperties = new boolean[4];

    public GameObject() {
        transform = new Transform();
    }
    public GameObject setTransform(Transform trans) {
        transform = trans;
        return this;
    }
    public GameObject setTransform(Vector3 pos, Vector3 eular, Vector3 scale) {
        transform.setPosition(pos).setEular(eular).setScale(scale);
        return this;
    }

    public GameObject setPosition(Vector3 pos) {
        transform.setPosition(pos);
        return this;
    }

    public GameObject setEular(Vector3 eular) {
        transform.setEular(eular);
        return this;
    }
    public GameObject setScale(Vector3 scale) {
        transform.setScale(scale);
        return this;
    }

    public GameObject setPosition(float x, float y, float z) {
        transform.setPosition(x, y, z);
        return this;
    }

    public GameObject setEular(float x, float y, float z) {
        transform.setEular(x, y, z);
        return this;
    }
    public GameObject setScale(float x, float y, float z) {
        transform.setScale(x, y, z);
        return this;
    }

    public GameObject setMesh(Mesh m) {
        this.mesh = m;
        return this;
    }

    public GameObject setMeshRenderer(MeshRenderer mr) {
        this.meshRenderer = mr;
        return this;
    }


    Vector3 getPosition() {
        return transform.position;
    }
    Vector3 getEular() {
        return transform.eular;
    }
    Vector3 getScale() {
        return transform.scale;
    }

    public GameObject setMaterial(Material m) {
        material = m;
        return this;
    }

    public GameObject setName(String s) {
        name = s;
        return this;
    }
    
    public float[] getTrianglePosition(){
        return mesh.getTrianglePosition();
    }
    public float[] getTriangleNormal(){
        return mesh.getTriangleNormal();
    }
    public float[] getTriangleUV(){
        return mesh.getTriangleUV();
    }
    public float[] getTriangleTangent(){
        return mesh.getTriangleTangent();
    }
    
    public int getNumber(){
        return mesh.triangles.size();
    }


    public void update() {
    }
    public void run() {
        meshRenderer.render();
    }
    public void debugRun() {
        meshRenderer.debugRender();
    }


    public Matrix4 localToWorld() {
        Vector3 pos = getPosition();
        Vector3 eular = getEular();
        Vector3 scale = getScale();
        return Matrix4.Trans(pos).mult(Matrix4.RotY(eular.y)).mult(Matrix4.RotX(eular.x)).mult(Matrix4.RotZ(eular.z)).mult(Matrix4.Scale(scale));
    }
    public Matrix4 worldToLocal() {
        Vector3 pos = getPosition();
        Vector3 eular = getEular();
        Vector3 scale = getScale();
        return Matrix4.Scale(scale.inv()).mult(Matrix4.RotZ(-eular.z)).mult(Matrix4.RotX(-eular.x)).mult(Matrix4.RotY(-eular.y)).mult(Matrix4.Trans(pos.mult(-1)));
    }
    public Vector3 forward() {
        return localToWorld().mult(new Vector3(0, 0, -1));
    }
    public Vector3 right() {
        return localToWorld().mult(new Vector3(1, 0, 0));
    }

    

    public Matrix4 MVP() {
        return main_camera.Matrix().mult(localToWorld());
    }
}



public class PhongObject extends GameObject {

    public PhongObject() {
    }

    public PhongObject(String name, Material mat) {
        mesh = new Mesh(name);
        material = mat.setGameobject(this);
        meshRenderer = new MeshRenderer(mesh, material, this);
    }
}

public class Chunk extends GameObject {
    Voxel voxelMap[][][] = new Voxel[VoxelData.chunkWidth][VoxelData.chunkHeight][VoxelData.chunkWidth];
    ChunkCoord chunkCoord;
    World world;

    public Chunk(ChunkCoord cc, World world) {
        chunkCoord = cc;
        setPosition(cc.x * VoxelData.chunkWidth, 0 , cc.z * VoxelData.chunkWidth);
        this.world = world;
        //init();
    }
    public void init() {
        hasProperties = new boolean[]{true,true,true,false};
        initVoxelMap();
        initMesh();
    }
    
    public void initMesh(){
        mesh = new Mesh();
        
        for (int y = 0; y < VoxelData.chunkHeight; y++) {
            for (int z = 0; z < VoxelData.chunkWidth; z++) {
                for (int x = 0; x < VoxelData.chunkWidth; x++) {
                    Voxel voxel = voxelMap[x][y][z];
                    if(!voxel.isSolid) continue;                   
                    addMesh(new Vector3(x,y,z),voxel.textureID);
                }
            }
        }
        
        
        material = phongMaterial;
        meshRenderer = new MeshRenderer(mesh, material, this);        
    }
    
    
    public void addMesh(Vector3 position ,int[] textureID){
        int voxelIndex = mesh.verts.size();
        for(int i = 0; i < 6; i++){
            if(!checkVoxel(position ,VoxelData.faceCheck[i])) continue;
            
            for(int j = 0; j < VoxelData.voxelTriangles[0].length; j++){
                mesh.verts.add(position.add(VoxelData.voxelVertors[VoxelData.voxelTriangles[i][j]]));
            }
         
            float size = 1.0 / (float)VoxelData.textureSizeInBlock;
            float x = textureID[i] % VoxelData.textureSizeInBlock * size;
            float y = textureID[i] / VoxelData.textureSizeInBlock * size;
            mesh.uvs.add(new Vector3(x + size, y + size, 0));
            mesh.uvs.add(new Vector3(x + size, y , 0));
            mesh.uvs.add(new Vector3(x , y + size , 0));            
            mesh.uvs.add(new Vector3(x , y , 0));
                 
            int a = voxelIndex + 0;
            int b = voxelIndex + 1;
            int c = voxelIndex + 2;
            int d = voxelIndex + 3;
            mesh.addFace(a,a,a,b,b,b,c,c,c);
            mesh.addFace(c,c,c,b,b,b,d,d,d);
            voxelIndex += 4;
        }
    }
    
    public boolean checkVoxel(Vector3 position , Vector3 dir){
        int x = floor(position.x + dir.x);
        int y = floor(position.y + dir.y);
        int z = floor(position.z + dir.z);
        if(outOfChunk(x,y,z)) {
            return !world.checkChunkIsExist(chunkCoord.add(x,z));           
        }
        if(!voxelMap[x][y][z].isSolid) return true;        
        return false;
    }
    
    boolean outOfChunk(int x, int y, int z){
        if(x >= VoxelData.chunkWidth || x < 0) return true;
        if(z >= VoxelData.chunkWidth || z < 0) return true;
        if(y >= VoxelData.chunkHeight || y < 0) return true;
        return false;
    }

    public void initVoxelMap() {

        for (int y = 0; y < VoxelData.chunkHeight; y++) {
            for (int z = 0; z < VoxelData.chunkWidth; z++) {
                for (int x = 0; x < VoxelData.chunkWidth; x++) {
                    voxelMap[x][y][z] = world.getVoxelType(getWorldPosition(x,y,z));
                }
            }
        }
    }
    
    public Vector3 getWorldPosition(float x,float y,float z){
        return new Vector3(x + chunkCoord.x * VoxelData.chunkWidth , y , z + chunkCoord.z * VoxelData.chunkWidth);
    }
    
}
