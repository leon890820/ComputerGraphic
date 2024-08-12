abstract class GameObject {
    Vector3 pos;
    Vector3 eular;
    Vector3 scale;
    float p_scale;
    Vector3 albedo;
    
    
    PShape shape;
    PShader shader;


    GameObject() {
        pos=new Vector3(0);
        eular=new Vector3(0);
        scale=new Vector3(1);
        p_scale=1;
    }
    void reset() {
        pos.setZero();
        eular.setZero();
        scale.setOnes();
        p_scale=1;
    }

    void setPos(Vector3 v) {
        pos = v;
    }
    
    void setPos(float x,float y,float z) {
        pos.set(x,y,z);
    }

    void setEular(Vector3 v) {
        eular = v;
    }
    void setEular(float x,float y,float z) {
        eular.set(x,y,z);
    }
    
    void setScale(Vector3 v) {
        scale = v;
    }
    
    void setScale(float x,float y,float z) {
        scale.set(x,y,z);
    }


    abstract public void draw();
    public void update() {
    };
    void debugDraw() {
    }



    Matrix4 localToWorld() {
        return Matrix4.Trans(pos).mult(Matrix4.RotY(eular.y)).mult(Matrix4.RotX(eular.x)).mult(Matrix4.RotZ(eular.z)).mult(Matrix4.Scale(scale));
    }
    Matrix4 worldToLocal() {
        return Matrix4.Scale(scale.mult(p_scale).inv()).mult(Matrix4.RotZ(-eular.z)).mult(Matrix4.RotX(-eular.x)).mult(Matrix4.RotY(-eular.y)).mult(Matrix4.Trans(pos.mult(-1)));
    }
    Vector3 forward() {
        return (Matrix4.RotZ(eular.z).mult(Matrix4.RotX(eular.y)).mult(Matrix4.RotY(eular.x)).zAxis()).mult(-1);
    }
    Matrix4 MVP(){
        return main_camera.Matrix().mult(localToWorld());
    }
    
}
