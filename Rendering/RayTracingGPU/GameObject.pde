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
        hasProperties = new boolean[]{true,true,false,false};
        material = mat.setGameobject(this);
        meshRenderer = new MeshRenderer(mesh, material, this);
    }
}

public class RayTracingObject extends GameObject {

    BoundingVolumeHierarchy BVH;
    ArrayList<Node> nodes = new ArrayList<Node>();
    ArrayList<Triangle> BVHTriangles = new ArrayList<Triangle>();
    
    public RayTracingObject() {
    }

    public RayTracingObject(String name, Material mat,int depth) {
        mesh = new Mesh(name);
        hasProperties = new boolean[]{true,true,false,false};
        material = mat.setGameobject(this);
        meshRenderer = new MeshRenderer(mesh, material, this);
        
        BVH = new BoundingVolumeHierarchy(mesh.triangles,depth);
        BVHRecord record = new BVHRecord();
        BVH.calcAverage(record,0);
        record.calcAverageTriangles();
        println(record);
        
        setNodeData();
        
        //for(Node n : nodes){
        //    println(n);
        //}
        //println(BVHTriangles.size());
    }
    
    public float[] getNodeData(){
        FloatList result = new FloatList();
        for(Node n : nodes){
            result.append(n.getNodeData());
        }
        return result.toArray();
    }
    
    void setNodeData(){
        ArrayList<BoundingVolumeHierarchy> stack = new ArrayList<BoundingVolumeHierarchy>();
        stack.add(BVH);
        int count = 0;
        while(stack.size() > 0){            
            BoundingVolumeHierarchy bvh = stack.remove(0);     
            int leftChildIndex = 0;
            int rightChildIndex = 0;
            int triIndex = 0;
            if(bvh.childA != null){
                stack.add(bvh.childA);
                stack.add(bvh.childB);
                leftChildIndex = count + 1;
                rightChildIndex = count + 2;
                count += 2;
            }else{
                triIndex = BVHTriangles.size();
                for(Triangle tri : bvh.triangles){
                    BVHTriangles.add(tri);
                }
            }
                        
            Node node = new Node(bvh.minB, bvh.maxB, triIndex, bvh.triangles.size(),leftChildIndex , rightChildIndex);
            nodes.add(node);
        }
    
    }
    
    
    public float[] getMeshTriangleData(){
        FloatList data = new FloatList();
        
        for(int i = 0; i < mesh.triangles.size(); i++){
            float[] d = getTriangleData(mesh.triangles.get(i).verts, 0, new Vector3(0.48, 0.83, 0.53), 0.0, 0.0);
            data.append(d);
        }
        
        return data.toArray();
    }
    
    public float[] getBVHTriangleData(){
        FloatList data = new FloatList();
        
        for(Triangle triangle : BVHTriangles){
            float[] d = getTriangleData(triangle.verts, 0, new Vector3(0.48, 0.83, 0.53), 0.0, 0.0);
            data.append(d);
        }
        
        return data.toArray();
    }
    
    
}


public class Quad extends GameObject {

    public Quad(Material mat) {
        mesh = new Mesh("Meshes/quad");
        hasProperties = new boolean[]{true,false,true,false};
        material = mat.setGameobject(this);
        meshRenderer = new MeshRenderer(mesh, material, this);
    }
}
