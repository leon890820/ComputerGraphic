public abstract class GameObject {
    Vector3 pos;
    Vector3 eular;
    Vector3 scale;
    float p_scale;
    Vector3 albedo;


    PShape shape;
    PShader shader;


    public GameObject() {
        pos   = new Vector3(0);
        eular = new Vector3(0);
        scale = new Vector3(1);
        albedo = new Vector3(0);
        p_scale = 1;
    }
    public void reset() {
        pos.setZero();
        eular.setZero();
        scale.setOnes();
        p_scale = 1;
    }

    public GameObject setPos(Vector3 v) {
        pos = v;
        return this;
    }

    public GameObject setPos(float x, float y, float z) {
        pos.set(x, y, z);
        return this;
    }

    public GameObject setEular(Vector3 v) {
        eular = v;
        return this;
    }
    public GameObject setEular(float x, float y, float z) {
        eular.set(x, y, z);
        return this;
    }

    public GameObject setScale(Vector3 v) {
        scale = v;
        return this;
    }

    public GameObject setScale(float x, float y, float z) {
        scale.set(x, y, z);
        return this;
    }

    public GameObject setColor(Vector3 v) {
        albedo = v;
        return this;
    }

    public GameObject setColor(float x, float y, float z) {
        albedo.set(x, y, z);
        return this;
    }


    abstract public void draw();
    public void update() {}
    public void debugDraw() {}



    public Matrix4 localToWorld() {
        return Matrix4.Trans(pos).mult(Matrix4.RotY(eular.y)).mult(Matrix4.RotX(eular.x)).mult(Matrix4.RotZ(eular.z)).mult(Matrix4.Scale(scale));
    }
    public Matrix4 worldToLocal() {
        return Matrix4.Scale(scale.mult(p_scale).inv()).mult(Matrix4.RotZ(-eular.z)).mult(Matrix4.RotX(-eular.x)).mult(Matrix4.RotY(-eular.y)).mult(Matrix4.Trans(pos.mult(-1)));
    }
    public Vector3 forward() {
        return (Matrix4.RotZ(eular.z).mult(Matrix4.RotX(eular.y)).mult(Matrix4.RotY(eular.x)).zAxis()).mult(-1);
    }
    public Matrix4 MVP() {
        return main_camera.Matrix().mult(localToWorld());
    }
}
