public static class Matrix4 {
    float[] m = new float[16];

    public Matrix4() {
        makeIdentity();
    }

    public Matrix4(float v) {
        fill(v);
    }

    public void fill(float v) {
        for (int i = 0; i < 16; i++) m[i] = v;
    }

    public void makeZero() {
        fill(0.0f);
    }

    public void makeIdentity() {
        makeZero();
        m[0] = 1.0f;
        m[5] = 1.0f;
        m[10] = 1.0f;
        m[15] = 1.0f;
    }

    public static Matrix4 Zero() {
        Matrix4 out = new Matrix4();
        out.makeZero();
        return out;
    }

    public static Matrix4 Identity() {
        return new Matrix4();
    }

    // column-major index helper
    private static int idx(int row, int col) {
        return col * 4 + row;
    }

    public float get(int row, int col) {
        return m[idx(row, col)];
    }

    public void set(int row, int col, float v) {
        m[idx(row, col)] = v;
    }

    public static Matrix4 Trans(Vector3 t) {
        Matrix4 out = Identity();
        out.m[idx(0, 3)] = t.x();
        out.m[idx(1, 3)] = t.y();
        out.m[idx(2, 3)] = t.z();
        return out;
    }

    public static Matrix4 Scale(Vector3 s) {
        Matrix4 out = Identity();
        out.m[idx(0, 0)] = s.x();
        out.m[idx(1, 1)] = s.y();
        out.m[idx(2, 2)] = s.z();
        return out;
    }

    public static Matrix4 Scale(float s) {
        return Scale(new Vector3(s, s, s));
    }

    public static Matrix4 RotX(float a) {
        Matrix4 out = Identity();
        float c = cos(a);
        float s = sin(a);

        out.m[idx(1, 1)] = c;
        out.m[idx(1, 2)] = -s;
        out.m[idx(2, 1)] = s;
        out.m[idx(2, 2)] = c;
        return out;
    }

    public static Matrix4 RotY(float a) {
        Matrix4 out = Identity();
        float c = cos(a);
        float s = sin(a);

        out.m[idx(0, 0)] = c;
        out.m[idx(0, 2)] = s;
        out.m[idx(2, 0)] = -s;
        out.m[idx(2, 2)] = c;
        return out;
    }

    public static Matrix4 RotZ(float a) {
        Matrix4 out = Identity();
        float c = cos(a);
        float s = sin(a);

        out.m[idx(0, 0)] = c;
        out.m[idx(0, 1)] = -s;
        out.m[idx(1, 0)] = s;
        out.m[idx(1, 1)] = c;
        return out;
    }

    // 正常數學語意：this * b
    public Matrix4 mult(Matrix4 b) {
        Matrix4 out = Zero();

        for (int row = 0; row < 4; row++) {
            for (int col = 0; col < 4; col++) {
                float sum = 0.0f;
                for (int k = 0; k < 4; k++) {
                    sum += this.get(row, k) * b.get(k, col);
                }
                out.set(row, col, sum);
            }
        }
        return out;
    }

    public Vector4 mult(Vector4 v) {
        return new Vector4(
            get(0, 0) * v.x + get(0, 1) * v.y + get(0, 2) * v.z + get(0, 3) * v.w,
            get(1, 0) * v.x + get(1, 1) * v.y + get(1, 2) * v.z + get(1, 3) * v.w,
            get(2, 0) * v.x + get(2, 1) * v.y + get(2, 2) * v.z + get(2, 3) * v.w,
            get(3, 0) * v.x + get(3, 1) * v.y + get(3, 2) * v.z + get(3, 3) * v.w
        );
    }

    // 明確：點
    public Vector3 transformPoint(Vector3 v) {
        Vector4 r = mult(new Vector4(v, 1.0f));
        if (abs(r.w) > 1e-8f) {
            return new Vector3(r.x / r.w, r.y / r.w, r.z / r.w);
        }
        return new Vector3(r.x, r.y, r.z);
    }

    // 明確：方向
    public Vector3 transformDirection(Vector3 v) {
        Vector4 r = mult(new Vector4(v, 0.0f));
        return new Vector3(r.x, r.y, r.z);
    }

    public Matrix4 transposed() {
        Matrix4 out = Zero();
        for (int row = 0; row < 4; row++) {
            for (int col = 0; col < 4; col++) {
                out.set(row, col, get(col, row));
            }
        }
        return out;
    }

    public PMatrix3D toPMatrix() {
        return new PMatrix3D(
            get(0,0), get(0,1), get(0,2), get(0,3),
            get(1,0), get(1,1), get(1,2), get(1,3),
            get(2,0), get(2,1), get(2,2), get(2,3),
            get(3,0), get(3,1), get(3,2), get(3,3)
        );
    }

    public Vector3 translation() {
        return new Vector3(get(0, 3), get(1, 3), get(2, 3));
    }

    public void setTranslation(Vector3 t) {
        set(0, 3, t.x());
        set(1, 3, t.y());
        set(2, 3, t.z());
    }
    
    public Matrix4 div(float value) {
        Matrix4 result = new Matrix4();
    
        if (abs(value) < 1e-8f) {
            println("[Matrix4] div failed: value is too close to zero.");
            return result;
        }
    
        for (int i = 0; i < 16; i++) {
            result.m[i] = m[i] / value;
        }
    
        return result;
    }

    public Matrix4 Inverse() {
        Matrix4 inv = new Matrix4();
    
        inv.m[0] = m[5] * m[10] * m[15] -
                   m[5] * m[11] * m[14] -
                   m[9] * m[6] * m[15] +
                   m[9] * m[7] * m[14] +
                   m[13] * m[6] * m[11] -
                   m[13] * m[7] * m[10];
    
        inv.m[4] = -m[4] * m[10] * m[15] +
                    m[4] * m[11] * m[14] +
                    m[8] * m[6] * m[15] -
                    m[8] * m[7] * m[14] -
                    m[12] * m[6] * m[11] +
                    m[12] * m[7] * m[10];
    
        inv.m[8] = m[4] * m[9] * m[15] -
                   m[4] * m[11] * m[13] -
                   m[8] * m[5] * m[15] +
                   m[8] * m[7] * m[13] +
                   m[12] * m[5] * m[11] -
                   m[12] * m[7] * m[9];
    
        inv.m[12] = -m[4] * m[9] * m[14] +
                     m[4] * m[10] * m[13] +
                     m[8] * m[5] * m[14] -
                     m[8] * m[6] * m[13] -
                     m[12] * m[5] * m[10] +
                     m[12] * m[6] * m[9];
    
        inv.m[1] = -m[1] * m[10] * m[15] +
                    m[1] * m[11] * m[14] +
                    m[9] * m[2] * m[15] -
                    m[9] * m[3] * m[14] -
                    m[13] * m[2] * m[11] +
                    m[13] * m[3] * m[10];
    
        inv.m[5] = m[0] * m[10] * m[15] -
                   m[0] * m[11] * m[14] -
                   m[8] * m[2] * m[15] +
                   m[8] * m[3] * m[14] +
                   m[12] * m[2] * m[11] -
                   m[12] * m[3] * m[10];
    
        inv.m[9] = -m[0] * m[9] * m[15] +
                    m[0] * m[11] * m[13] +
                    m[8] * m[1] * m[15] -
                    m[8] * m[3] * m[13] -
                    m[12] * m[1] * m[11] +
                    m[12] * m[3] * m[9];
    
        inv.m[13] = m[0] * m[9] * m[14] -
                    m[0] * m[10] * m[13] -
                    m[8] * m[1] * m[14] +
                    m[8] * m[2] * m[13] +
                    m[12] * m[1] * m[10] -
                    m[12] * m[2] * m[9];
    
        inv.m[2] = m[1] * m[6] * m[15] -
                   m[1] * m[7] * m[14] -
                   m[5] * m[2] * m[15] +
                   m[5] * m[3] * m[14] +
                   m[13] * m[2] * m[7] -
                   m[13] * m[3] * m[6];
    
        inv.m[6] = -m[0] * m[6] * m[15] +
                    m[0] * m[7] * m[14] +
                    m[4] * m[2] * m[15] -
                    m[4] * m[3] * m[14] -
                    m[12] * m[2] * m[7] +
                    m[12] * m[3] * m[6];
    
        inv.m[10] = m[0] * m[5] * m[15] -
                    m[0] * m[7] * m[13] -
                    m[4] * m[1] * m[15] +
                    m[4] * m[3] * m[13] +
                    m[12] * m[1] * m[7] -
                    m[12] * m[3] * m[5];
    
        inv.m[14] = -m[0] * m[5] * m[14] +
                     m[0] * m[6] * m[13] +
                     m[4] * m[1] * m[14] -
                     m[4] * m[2] * m[13] -
                     m[12] * m[1] * m[6] +
                     m[12] * m[2] * m[5];
    
        inv.m[3] = -m[1] * m[6] * m[11] +
                    m[1] * m[7] * m[10] +
                    m[5] * m[2] * m[11] -
                    m[5] * m[3] * m[10] -
                    m[9] * m[2] * m[7] +
                    m[9] * m[3] * m[6];
    
        inv.m[7] = m[0] * m[6] * m[11] -
                   m[0] * m[7] * m[10] -
                   m[4] * m[2] * m[11] +
                   m[4] * m[3] * m[10] +
                   m[8] * m[2] * m[7] -
                   m[8] * m[3] * m[6];
    
        inv.m[11] = -m[0] * m[5] * m[11] +
                     m[0] * m[7] * m[9] +
                     m[4] * m[1] * m[11] -
                     m[4] * m[3] * m[9] -
                     m[8] * m[1] * m[7] +
                     m[8] * m[3] * m[5];
    
        inv.m[15] = m[0] * m[5] * m[10] -
                    m[0] * m[6] * m[9] -
                    m[4] * m[1] * m[10] +
                    m[4] * m[2] * m[9] +
                    m[8] * m[1] * m[6] -
                    m[8] * m[2] * m[5];
    
        float det = m[0] * inv.m[0] +
                    m[1] * inv.m[4] +
                    m[2] * inv.m[8] +
                    m[3] * inv.m[12];
    
        if (abs(det) < 1e-8f) {
            println("[Matrix4] inverse failed: determinant is too close to zero.");
            return Matrix4.Identity();
        }
    
        return inv.div(det);
    }
    
    public static Matrix4 Perspective(float fov, float aspect, float near, float far){
        float fovRad = fov * PI / 180.0f;
        float f = 1.0f / tan(fovRad / 2.0f);
        Matrix4 projection = Matrix4.Zero();
        projection.set(0, 0, f / aspect);
        projection.set(1, 1, f);
        projection.set(2, 2, (far + near) / (near - far));
        projection.set(2, 3, (2.0f * far * near) / (near - far));
        projection.set(3, 2, -1.0f);
        projection.set(3, 3, 0.0f);
        
        return projection;
    }
    
    public static Matrix4 Ortho(float left, float right,
                           float bottom, float top,
                           float near, float far) {

        Matrix4 out = Matrix4.Identity();
    
        out.set(0, 0, 2.0f / (right - left));
        out.set(1, 1, 2.0f / (top - bottom));
        out.set(2, 2, -2.0f / (far - near));
    
        out.set(0, 3, -(right + left) / (right - left));
        out.set(1, 3, -(top + bottom) / (top - bottom));
        out.set(2, 3, -(far + near) / (far - near));
    
        return out;
    }
    public static Matrix4 LookAt(Vector3 eye, Vector3 target, Vector3 up) {

        Vector3 z = eye.sub(target).unit_vector();   // forward
        Vector3 x = Vector3.cross(up, z).unit_vector(); // right
        Vector3 y = Vector3.cross(z, x); // up
    
        Matrix4 out = Matrix4.Identity();
    
        // rotation
        out.set(0, 0, x.x()); out.set(0, 1, x.y()); out.set(0, 2, x.z());
        out.set(1, 0, y.x()); out.set(1, 1, y.y()); out.set(1, 2, y.z());
        out.set(2, 0, z.x()); out.set(2, 1, z.y()); out.set(2, 2, z.z());
    
        // translation
        out.set(0, 3, -Vector3.dot(x, eye));
        out.set(1, 3, -Vector3.dot(y, eye));
        out.set(2, 3, -Vector3.dot(z, eye));
    
        return out;
    }

    @Override
    public String toString() {
        return get(0,0)+" "+get(0,1)+" "+get(0,2)+" "+get(0,3)+"\n"
             + get(1,0)+" "+get(1,1)+" "+get(1,2)+" "+get(1,3)+"\n"
             + get(2,0)+" "+get(2,1)+" "+get(2,2)+" "+get(2,3)+"\n"
             + get(3,0)+" "+get(3,1)+" "+get(3,2)+" "+get(3,3)+"\n";
    }
}
