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
        transform.forceDirty();
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

    public float[] getTrianglePosition() {
        return mesh.getTrianglePosition();
    }

    public float[] getTriangleNormal() {
        return mesh.getTriangleNormal();
    }

    public float[] getTriangleUV() {
        return mesh.getTriangleUV();
    }

    public float[] getTriangleTangent() {
        return mesh.getTriangleTangent();
    }

    public int getNumber() {
        return mesh.triangles.size();
    }

    public void update() {
    }

    public void run() {
        if (meshRenderer != null) {
            meshRenderer.render();
        }
    }

    public void debugRun() {
        if (meshRenderer != null) {
            meshRenderer.debugRender();
        }
    }

    public Matrix4 localToWorld() {
        return transform.localToWorld();
    }

    public Matrix4 worldToLocal() {
        return transform.worldToLocal();
    }

    public Vector3 forward() {
        return localToWorld().transformDirection(new Vector3(0, 0, -1)).unit_vector();
    }
    
    public Vector3 right() {
        return localToWorld().transformDirection(new Vector3(1, 0, 0)).unit_vector();
    }
    
    public Vector3 up() {
        return localToWorld().transformDirection(new Vector3(0, 1, 0)).unit_vector();
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
        hasProperties = new boolean[]{true, true, true, false};
        material = mat.setGameobject(this);
        meshRenderer = new MeshRenderer(mesh, material, this);
    }
}
