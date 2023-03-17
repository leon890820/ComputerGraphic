class Camera {
    Matrix4 projection=new Matrix4();
    Matrix4 ortho = new Matrix4();
    Matrix4 worldView=new Matrix4();
    int wid;
    int hei;
    float near;
    float far;
    Vector3 pos;
    Vector3 forward;
    Camera() {
        wid=256;
        hei=256;
        worldView.makeIdentity();
        projection.makeIdentity();
    }

    Matrix4 inverseProjection() {
        Matrix4 invProjection = Matrix4.Zero();
        float a = projection.m[0];
        float b = projection.m[5];
        float c = projection.m[10];
        float d = projection.m[11];
        float e = projection.m[14];
        invProjection.m[0] = 1.0f / a;
        invProjection.m[5] = 1.0f / b;
        invProjection.m[11] = 1.0f / e;
        invProjection.m[14] = 1.0f / d;
        invProjection.m[15] = -c / (d * e);
        return invProjection;
    }
    Matrix4 Matrix() {
        return projection.mult(worldView);
    }
    
    Matrix4 Ortho(){
        return ortho.mult(worldView);
    }

    void setOrtho(float n, float r, float a, float e, float u, float o) {
        float i = 1 / (n - r);
        float s = 1 / (a - e);
        float c = 1 / (u - o);
        ortho.m[0] = -2 * i;
        ortho.m[1] = 0;
        ortho.m[2] = 0;
        ortho.m[3] = 0;
        ortho.m[4] = 0;
        ortho.m[5] = -2 * s;
        ortho.m[6] = 0;
        ortho.m[7] = 0;
        ortho.m[8] = 0;
        ortho.m[9] = 0;
        ortho.m[10] = 2 * c;
        ortho.m[11] = 0;
        ortho.m[12] = (n + r) * i;
        ortho.m[13] = (e + a) * s;
        ortho.m[14] = (o + u) * c;
        ortho.m[15] = 1;
    }

    void setSize(int w, int h, float n, float f) {
        wid = w;
        hei = h;
        near = n;
        far = f;

        float e = 1.0f / tan(GH_FOV * 2*PI / 360.0f);
        float a = float(height) / float(width);
        float d = near - far;


        projection.m[0] = e * a;
        projection.m[1] = 0.0f;
        projection.m[2] = 0.0f;
        projection.m[3] = 0.0f;
        projection.m[4] = 0.0f;
        projection.m[5] = e;
        projection.m[6] = 0.0f;
        projection.m[7] = 0.0f;
        projection.m[8] = 0.0f;
        projection.m[9] = 0.0f;
        projection.m[10] = (far+near) / d;
        projection.m[11] = 2*far * near / d;
        projection.m[12] = 0.0f;
        projection.m[13] = 0.0f;
        projection.m[14] = -1.0f;
        projection.m[15] = 0.0f;
    }
    void setPositionOrientation(Vector3 pos, float rotX, float rotY) {
        this.pos=pos;
        this.forward = Matrix4.RotX(rotX).mult(Matrix4.RotY(rotY)).mult(new Vector4(0, 0, 1, 0)).xyz();
        worldView = Matrix4.RotX(rotX).mult(Matrix4.RotY(rotY)).mult(Matrix4.Trans(pos.mult(-1)));
    }

    void setPositionOrientation(Vector3 pos, Vector3 la) {
        this.pos=pos;
        this.forward = la;
        float rotX = acos(Clamp(la.z(), -1.0, 1.0));
        float rotY = PI/2+atan2(la.y(), la.x());

        //println(rotX,rotY);
        worldView = Matrix4.RotX(rotX).mult(Matrix4.RotY(rotY)).mult(Matrix4.Trans(pos.mult(-1)));
    }

    void useViewport() {
    }


    void clipOblique(Vector3 pos, Vector3 normal) {
        Vector3 cpos = (worldView.mult(new Vector4(pos, 1)).xyz());
        Vector3 cnormal = (worldView.mult(new Vector4(normal, 0)).xyz());
        Vector4 cplane=new Vector4(cnormal.x, cnormal.y, cnormal.z, Vector3.dot(cpos.mult(-1), cnormal));

        Vector4 q = projection.Inverse().mult(new Vector4(
            (cplane.x < 0.0f ? 1.0f : -1.0f),
            (cplane.y < 0.0f ? 1.0f : -1.0f),
            1.0f,
            1.0f));
        Vector4 c = cplane.mult((2.0f / cplane.dot(q)));
        projection.m[8] = c.x - projection.m[12];
        projection.m[9] = c.y - projection.m[13];
        projection.m[10] = c.z - projection.m[14];
        projection.m[11] = c.w - projection.m[15];
    }
}
