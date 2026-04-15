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

    public Matrix4 Inverse() {
        // 你原本那版 inverse 可以留，但要確認它是對目前儲存格式正確。
        // 最保守做法是先保留原始實作，等畫面確認後再替換。
        // 這裡先給你一個占位，避免你直接貼上後忘記。
        throw new RuntimeException("Replace Inverse() with a tested column-major version.");
    }

    @Override
    public String toString() {
        return get(0,0)+" "+get(0,1)+" "+get(0,2)+" "+get(0,3)+"\n"
             + get(1,0)+" "+get(1,1)+" "+get(1,2)+" "+get(1,3)+"\n"
             + get(2,0)+" "+get(2,1)+" "+get(2,2)+" "+get(2,3)+"\n"
             + get(3,0)+" "+get(3,1)+" "+get(3,2)+" "+get(3,3)+"\n";
    }
}
