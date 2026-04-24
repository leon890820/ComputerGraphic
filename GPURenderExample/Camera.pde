public class Camera extends Quad {
    Matrix4 projection = new Matrix4();
    Matrix4 worldView = new Matrix4();

    float wid;
    float hei;
    float near;
    float far;

    private Matrix4 cachedVP = new Matrix4();

    private boolean projectionDirty = true;
    private boolean viewDirty = true;
    private boolean vpDirty = true;

    Camera() {
        super(null);
        wid = 256.0f;
        hei = 256.0f;
        near = 0.1f;
        far = 10000.0f;

        worldView.makeIdentity();
        projection.makeIdentity();
        cachedVP.makeIdentity();

        projectionDirty = true;
        viewDirty = true;
        vpDirty = true;
    }

    private void markProjectionDirty() {
        projectionDirty = true;
        vpDirty = true;
    }

    private void markViewDirty() {
        viewDirty = true;
        vpDirty = true;
    }

    private float clampPitch(float pitch) {
        float limit = radians(89.0f);
        return constrain(pitch, -limit, limit);
    }

    private void rebuildProjectionIfNeeded() {
        if (!projectionDirty) return;

        float fovRad = GH_FOV * PI / 180.0f;
        float f = 1.0f / tan(fovRad / 2.0f);
        float aspect = wid / hei;

        projection.makeZero();

        // column-major + column-vector
        projection.set(0, 0, f / aspect);
        projection.set(1, 1, f);
        projection.set(2, 2, (far + near) / (near - far));
        projection.set(2, 3, (2.0f * far * near) / (near - far));
        projection.set(3, 2, -1.0f);
        projection.set(3, 3, 0.0f);

        projectionDirty = false;
    }

    private void rebuildViewIfNeeded() {
        if (!viewDirty) return;

        Vector3 pos = transform.position;
        Vector3 rot = transform.eular;

        // 統一：rot.y = yaw, rot.x = pitch
        // View = Ry(-yaw) * Rx(-pitch) * T(-pos)
        worldView =
            Matrix4.RotX(-rot.x())
            .mult(Matrix4.RotY(-rot.y()))
            .mult(Matrix4.Trans(pos.mult(-1.0f)));

        viewDirty = false;
    }

    private void rebuildVPIfNeeded() {
        if (!vpDirty) return;

        rebuildProjectionIfNeeded();
        rebuildViewIfNeeded();

        cachedVP = projection.mult(worldView);
        vpDirty = false;
    }

    Matrix4 inverseProjection() {
        rebuildProjectionIfNeeded();

        // 這裡先保留你原本的快速寫法
        // 前提是 projection 形式固定為標準透視矩陣
        Matrix4 invProjection = Matrix4.Zero();

        float a = projection.get(0, 0);
        float b = projection.get(1, 1);
        float c = projection.get(2, 2);
        float d = projection.get(2, 3);
        float e = projection.get(3, 2);

        invProjection.set(0, 0, 1.0f / a);
        invProjection.set(1, 1, 1.0f / b);
        invProjection.set(2, 3, 1.0f / e);
        invProjection.set(3, 2, 1.0f / d);
        invProjection.set(3, 3, -c / (d * e));

        return invProjection;
    }

    void draw() {
    }

    Matrix4 Matrix() {
        rebuildVPIfNeeded();
        return cachedVP;
    }

    Matrix4 getProjectionMatrix() {
        rebuildProjectionIfNeeded();
        return projection;
    }

    Matrix4 getViewMatrix() {
        rebuildViewIfNeeded();
        return worldView;
    }

    void ortho(float left, float right, float bottom, float top, float near, float far) {
        projection.makeZero();

        projection.set(0, 0, 2.0f / (right - left));
        projection.set(1, 1, 2.0f / (top - bottom));
        projection.set(2, 2, -2.0f / (far - near));

        projection.set(0, 3, -(right + left) / (right - left));
        projection.set(1, 3, -(top + bottom) / (top - bottom));
        projection.set(2, 3, -(far + near) / (far - near));

        projection.set(3, 3, 1.0f);

        projectionDirty = false;
        vpDirty = true;
    }

    void setSize(float w, float h, float n, float f) {
        wid = w;
        hei = h;
        near = n;
        far = f;
        markProjectionDirty();
    }

    void setPositionOrientation(Vector3 pos, float rotX, float rotY) {
        transform.setPosition(pos);
        transform.setEular(clampPitch(rotX), rotY, 0.0f);
        markViewDirty();
    }

    void setPositionOrientation(Vector3 pos, Vector3 la) {
        transform.setPosition(pos);

        Vector3 f = la.sub(pos).unit_vector();

        // pitch: 上下
        float rotX = asin(f.y());

        // yaw: 左右
        float rotY = atan2(-f.x(), -f.z());

        transform.setEular(clampPitch(rotX), rotY, 0.0f);
        markViewDirty();
    }

    void update() {
        if (transform.isDirty()) {
            markViewDirty();
        }

        rebuildViewIfNeeded();
    }

    void useViewport() {
    }

    void clipOblique(Vector3 pos, Vector3 normal) {
        rebuildProjectionIfNeeded();
        rebuildViewIfNeeded();

        Vector3 cpos = worldView.mult(new Vector4(pos, 1.0f)).xyz();
        Vector3 cnormal = worldView.mult(new Vector4(normal, 0.0f)).xyz();

        Vector4 cplane = new Vector4(
            cnormal.x(),
            cnormal.y(),
            cnormal.z(),
            Vector3.dot(cpos.mult(-1.0f), cnormal)
        );

        Vector4 q = projection.Inverse().mult(new Vector4(
            (cplane.x < 0.0f ? 1.0f : -1.0f),
            (cplane.y < 0.0f ? 1.0f : -1.0f),
            1.0f,
            1.0f
        ));

        Vector4 c = cplane.mult(2.0f / cplane.dot(q));

        // 用 set(row,col) 避免 row/column 再搞混
        projection.set(2, 0, c.x - projection.get(3, 0));
        projection.set(2, 1, c.y - projection.get(3, 1));
        projection.set(2, 2, c.z - projection.get(3, 2));
        projection.set(2, 3, c.w - projection.get(3, 3));

        vpDirty = true;
    }
    
    
    
}
