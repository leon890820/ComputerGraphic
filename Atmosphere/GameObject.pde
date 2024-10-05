public abstract class GameObject {
    String name;
    Transform transform;
    Mesh mesh;
    Material material;
    MeshRenderer meshRenderer;


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


    public void update() {
    }
    public void run() {

        meshRenderer.render();
    };



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
        Vector3 eular = getEular();
        return (Matrix4.RotZ(eular.z).mult(Matrix4.RotX(eular.y)).mult(Matrix4.RotY(eular.x)).zAxis()).mult(-1);
    }
    public Matrix4 MVP() {
        return main_camera.Matrix().mult(localToWorld());
    }
}

public class Quad extends GameObject{
    
    public Quad(String name, Material mat) {
        mesh = new Mesh(name);
        material = mat.setGameobject(this);
        meshRenderer = new MeshRenderer(mesh, material,this);
    }

}


public class PhongObject extends GameObject {

    public PhongObject() {
    }

    public PhongObject(String name, Material mat) {
        mesh = new Mesh(name);
        material = mat.setGameobject(this);
        meshRenderer = new MeshRenderer(mesh, material,this);
    }
}

public class Crater {
    Vector3 center;
    float radius;
    
    public Crater(Vector3 c, float r) {
        center = c;
        radius = r;
    }
}


public class Icosahedron extends PhongObject {

    float maxRadius = 0.20;
    float floor_height = -0.38;
    float smooth = 0.34;
    float rim_width = 0.7;
    float rim_steepness = 0.42;
    float size_distribution = 0.65;
    Vector3 heightMinMax;
    
    Crater[] craters;

    NoiseFilter noiseFilter;
    NoiseSetting noiseSetting;
    
    public Icosahedron(){
    
    }

    public Icosahedron(Material mat, int resolution ,int num) {
        noiseFilter = new NoiseFilter();
        mesh = new Mesh();
        craters = new Crater[num];
        createCrater();       
        createMesh(resolution);     
        heightMinMax = calcHeightMinMax();
        material =  mat.setGameobject(this);
        meshRenderer = new MeshRenderer(mesh, material,this);
    }
    public Icosahedron(Material mat, int resolution,int num ,NoiseSetting ns) {
        noiseSetting = ns;
        noiseFilter = new NoiseFilter();
        mesh = new Mesh();
        craters = new Crater[num];
        createCrater();       
        createMesh(resolution);     
        heightMinMax = calcHeightMinMax();
        material =  mat.setGameobject(this);
        meshRenderer = new MeshRenderer(mesh, material,this);
    }
    
    void createCrater() {
        for (int i = 0; i < craters.length; i++) {
            craters[i] = new Crater(random_unit_sphere_vector(), maxRadius * biasFunction(random(0.1,1),size_distribution));
        }
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

        mesh.verts.add(icosahedronVertex[0].unit_vector().mult(bias(icosahedronVertex[0].unit_vector())));
        mesh.normals.add(icosahedronVertex[0].unit_vector().unit_vector());
        mesh.tangents.add(icosahedronVertex[0].unit_vector().unit_vector());
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
                    mesh.verts.add(c3.unit_vector().mult(bias(c3.unit_vector())));
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
                    mesh.verts.add(c3.unit_vector().mult(bias(c3.unit_vector())));
                    mesh.normals.add(c3.unit_vector());
                }
            }
        }
        mesh.verts.add(icosahedronVertex[2].unit_vector().mult(bias(icosahedronVertex[2].unit_vector())));
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
    
    public float bias(Vector3 v){
        float n = noiseFilter.evaluate(v,noiseSetting);
        float c = craterValue(v);
        return  n + c + 1.0;
    }

    public float craterValue(Vector3 v) {
        float ch = 0.0;
        for (int i = 0; i < craters.length; i++) {
            float x = (v.sub(craters[i].center)).norm() / craters[i].radius ;
            float cavity = x * x - 1.0;
            float rimX = min(x - 1.0 - rim_width, 0.0);
            float rim = rim_steepness * rimX * rimX;

            float craterShape = smoothMax(cavity, floor_height,smooth);
            craterShape = smoothMin(craterShape, rim ,smooth);
            ch += craterShape * craters[i].radius;
        }

        return ch;
    }
    
    Vector3 calcHeightMinMax(){
        float minRecord =  1.0 / 0.0;
        float maxRecord = -1.0 / 0.0;
        for(int i = 0; i < mesh.verts.size(); i++){
            float radius = mesh.verts.get(i).length();
            minRecord = min(minRecord , radius);
            maxRecord = max(maxRecord , radius);
        } 
        
        return new Vector3(minRecord , maxRecord , 0.0);
    }


}


public class Earth extends Icosahedron{
    float oceanDepthMultiplier = 109.71;
    float oceanFloorDepth = 1.36;
    float oceanFloorSmoothing = 0.5;
    NoiseSetting ridgeNoiseSetting;
    public Earth(Material mat, int resolution ,int num){
        super(mat, resolution, num);
    }
    public Earth(Material mat, int resolution,int num ,NoiseSetting ns,NoiseSetting rns){
        noiseSetting = ns;
        ridgeNoiseSetting = rns;
        noiseFilter = new NoiseFilter();
        mesh = new Mesh();    
        createMesh(resolution);     
        heightMinMax = calcHeightMinMax();
        material =  mat.setGameobject(this);
        meshRenderer = new MeshRenderer(mesh, material,this);        
    }
    
    
    @Override
    public float bias(Vector3 v){
        float continentShape = noiseFilter.evaluate(v,noiseSetting);   
        continentShape = smoothMax(continentShape, -3.6, 0.6);
        
        if (continentShape < 0) {
            continentShape *= 1.0 + 3.4;
        }
        float ridgeNoise = noiseFilter.smoothedRidgidNoise(v, ridgeNoiseSetting);
        return  1.0 + continentShape * 0.01  + ridgeNoise * 0.01;
    }
    
}
