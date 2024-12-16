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

public class Boundary extends GameObject{
    Vector3 bondary;
    public Boundary(Vector3 bondary, Material mat) {
        this.bondary = bondary;        
        createMesh();
        hasProperties = new boolean[]{true,false,false,false};
        material = mat.setGameobject(this);
        meshRenderer = new MeshRenderer(mesh, material, this);
    }
    
    void createMesh(){
        mesh = new Mesh();
        mesh.verts.add(new Vector3(-bondary.x, -bondary.y , 0));
        mesh.verts.add(new Vector3( bondary.x, -bondary.y , 0));
        mesh.verts.add(new Vector3( bondary.x,  bondary.y , 0));
        mesh.verts.add(new Vector3(-bondary.x,  bondary.y , 0));
        
        mesh.addFace(0,1,2);
        mesh.addFace(0,2,3);
    }
    
    @Override
    public float[] getTrianglePosition(){
        float[] result = new float[]{-bondary.x, -bondary.y , 0.0, bondary.x, -bondary.y , 0.0,
                                      bondary.x, -bondary.y , 0.0, bondary.x,  bondary.y , 0.0,
                                      bondary.x,  bondary.y , 0.0,-bondary.x,  bondary.y , 0.0,
                                     -bondary.x,  bondary.y , 0.0,-bondary.x, -bondary.y , 0.0};
        
        return result;
    }
    
    @Override
    public int getNumber(){
        return 4;    
    }

}

public class Icosahedron extends Fluid {       

    public Icosahedron(Material mat,float radius, int resolution) {

        mesh = new Mesh();   
        this.radius = radius;
        createMesh(resolution);     
        hasProperties = new boolean[]{true,true,false,false};
        material =  mat.setGameobject(this);
        meshRenderer = new MeshRenderer(mesh, material,this);
    }


    void createMesh(int resolution) {
        Vector3[] icosahedronVertex = new Vector3[12];
        int num = (resolution + 1) * (resolution + 2) / 2;
        
        int num1 = num * 5 + 1;
        int num2 = resolution * (resolution + 1) / 2;
        int num3 = (resolution + 2) * (resolution + 3) / 2;

        float phi = (1 + sqrt(5)) * 0.5;
        icosahedronVertex[0] = new Vector3(0, 1, phi);
        icosahedronVertex[1] =(new Vector3(0, -1, phi));
        icosahedronVertex[2] =(new Vector3(0, -1, -phi));
        icosahedronVertex[3] =(new Vector3(0, 1, -phi));

        icosahedronVertex[4] =(new Vector3( phi, 0, 1));
        icosahedronVertex[5] =(new Vector3(-phi, 0, 1));
        icosahedronVertex[6] =(new Vector3(-phi, 0, -1));
        icosahedronVertex[7] =(new Vector3( phi, 0, -1));

        icosahedronVertex[8] =(new Vector3( 1, phi, 0));
        icosahedronVertex[9] =(new Vector3(-1, phi, 0));
        icosahedronVertex[10] =(new Vector3(-1, -phi, 0));
        icosahedronVertex[11] =(new Vector3( 1, -phi, 0));


        int[] index = {0, 1, 4, 0, 4, 8, 0, 8, 9, 0, 9, 5, 0, 5, 1,
            1, 10, 11, 1, 11, 4, 4, 11, 7, 4, 7, 8, 8, 7, 3,
            8, 3, 9, 9, 3, 6, 9, 6, 5, 5, 6, 10, 5, 10, 1,
            10, 2, 11, 11, 2, 7, 7, 2, 3, 3, 2, 6, 6, 2, 10};

        mesh.verts.add(icosahedronVertex[0].unit_vector().mult(radius));
        mesh.normals.add(icosahedronVertex[0].unit_vector().unit_vector());
        for (int k = 0; k < 10; k++) {
            int kd = k  <5 ? k : (2 * (k - 5) + 5);
            Vector3 p1 = icosahedronVertex[index[kd * 3 + 0]];
            Vector3 p2 = icosahedronVertex[index[kd * 3 + 1]];
            Vector3 p3 = icosahedronVertex[index[kd * 3 + 2]];
            for (int i = 0; i<resolution + 1; i++) {
                for (int j = 0; j < i + 1; j++) {
                    Vector3 c1 = lerp(p1, p2, float(i + 1) / float(resolution + 1));
                    Vector3 c2 = lerp(p1, p3, float(i + 1) / float(resolution + 1));
                    Vector3 c3 = lerp(c1, c2, float(j) / float(i + 1));
                    mesh.verts.add(c3.unit_vector().mult(radius));
                    mesh.normals.add(c3.unit_vector());
                }
            }
        }



        for (int k = 0; k < 10; k++) {
            int kd = k < 5 ? (2 * k + 6) : (k + 10);
            Vector3 p1 = icosahedronVertex[index[kd * 3 + 0]];
            Vector3 p2 = icosahedronVertex[index[kd * 3 + 1]];
            Vector3 p3 = icosahedronVertex[index[kd * 3 + 2]];
            for (int i = 0; i < resolution; i++) {
                for (int j = 0; j < resolution - i; j++) {
                    Vector3 c1 = lerp(p1, p2, float(i + 1) / float(resolution + 1));
                    Vector3 c2 = lerp(p3, p2, float(i + 1) / float(resolution + 1));
                    Vector3 c3 = lerp(c1, c2, float(j) / float(resolution - i));
                    mesh.verts.add(c3.unit_vector().mult(radius));
                    mesh.normals.add(c3.unit_vector());
                }
            }
        }
        mesh.verts.add(icosahedronVertex[2].unit_vector().mult(radius));
        mesh.normals.add(icosahedronVertex[2].unit_vector());

        for (int k = 0; k < 5; k++) {
            int[] ind = new int[num3];
            ind[0] = 0;
            for (int i = 0; i<resolution + 1; i++) {
                int i1 = (i + 1) * (i + 2) / 2;
                int i2 = i * (i + 1) / 2 + 1;
                for (int j = 0; j < i+1; j++) {
                    ind[i1 + j] = i2 + j + num * k;
                }
                ind[(i + 2) * (i + 3) / 2 - 1] = (i2 +  num * (k + 1) - 1) % (num * 5) + 1;
            }
            addTriangle(resolution, ind);
        }


        for (int k = 0; k < 5; k++) {
            int[] ind = new int[num3];
            ind[0] = resolution * (resolution + 1) / 2 + 1 + num * k;
            for (int i = 0; i<resolution + 1; i++) {
                int i1 = (i + 1) * (i + 2) / 2;
                int i2 = i * (i + 1) / 2 ;
                for (int j = 0; j < i+1; j++) {
                    ind[i1 + j] = i2 + j + num * k + num1;
                }
                ind[(i + 2) * (i + 3) / 2 - 1] = i == resolution ? (num2  + num * (k + 1)) % (num1 - 1) + num1 : (2 * num1 - 1 + num2 * (k + 1) - (resolution - i) * (resolution - i + 1)/2);
            }
            addTriangle(resolution, ind);
        }

        for (int k = 0; k < 5; k++) {
            int[] ind = new int[num3];
            for (int j = 0; j < resolution + 1; j++) {
                ind[num3 - j - 1] = num2 + 1 + j + k * num;
            }
            ind[num3 - resolution - 2] = (num * (k+1) + num2 ) % (num * 5) + 1;
            for (int i = 1; i < resolution +1; i++) {
                for(int j = 0; j < resolution + 1 -i; j ++){
                    ind[  + (resolution + 2 -i) * (resolution + 3 -i) / 2 - j - 1] = (2 * num1 - 1 + num2 * (k + 1) - (resolution - i + 1) * (resolution - i + 2)/2) + j;
                }
                ind[ (resolution + 2 -i) * (resolution + 3 -i) / 2 - resolution - 2 + i  ] = ((k + 1) * num + (i - 1) * i / 2 + 1) % (num * 5) + num * 5;
            }
            ind[0] = ( num * (k + 1) + num2  ) % (num*5) + num1;
            addTriangle(resolution, ind);
        }
        
        for (int k = 0; k < 5; k++) {
            int[] ind = new int[num3];
            for (int j = 0; j < resolution + 1; j++) {
                ind[ num3 - j - 1] = num1 + num2 + j + num * k;
            }
            ind[num3 - resolution - 2] = (num * 5 + num * (k + 1) + num2  - num * 5 ) % (num*5) + num *5 + 1;
            for(int i = 0; i < resolution; i++){
                for(int j = 0 ; j < resolution - i; j++){
                    ind[(resolution + 1 - i) * (resolution + 2 -i) / 2 - j - 1] = num * 10 + num2 * (6 + k) + 1 + j  - (resolution - i) * (resolution - i + 1) / 2;
                }
                ind[ (resolution + 1 - i) * (resolution + 2 -i) / 2 - resolution + i - 1] = (  num2 * (2 + k) + 1  - (resolution - i) * (resolution - i + 1) / 2  - 1) % (num2 * 5) + num * 10 + num2 * 5  + 1;
            }
            ind[0] = (num + num2) * 10 + 1;
            addTriangle(resolution, ind);
        }
        
        mesh.reCaculateNormal();
    }

    void addTriangle(int resolution, int[] ind) {

        for (int i = 0; i < resolution + 1; i++) {
            int i1 = i  * (i + 1) / 2;
            int i2 = (i + 1) * (i + 2) / 2;
            for (int j = 0; j < i + 1; j++) {
                mesh.addFace(ind[i1 + j], ind[i1 + j], ind[i2 + j], ind[i2 + j], ind[i2 + j + 1], ind[i2 + j + 1]);
               
            }
        }

        for (int i = 1; i < resolution + 1; i++) {
            int i1 = i  * (i + 1) / 2;
            int i2 = (i + 1) * (i + 2) / 2;
            for (int j = 0; j < i; j++) {
                mesh.addFace(ind[i1 + j], ind[i1 + j], ind[i2 + j + 1], ind[i2 + j + 1], ind[i1 + j + 1], ind[i1 + j + 1]);
            }
        }
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
