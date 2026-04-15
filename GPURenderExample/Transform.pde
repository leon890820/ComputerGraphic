public class Transform {
    Vector3 position;
    Vector3 eular;
    Vector3 scale;

    private boolean dirty = true;
    private Matrix4 cachedLocalToWorld;
    private Matrix4 cachedWorldToLocal;

    Transform() {
        position = Vector3.Zero();
        eular = Vector3.Zero();
        scale = Vector3.Ones();

        cachedLocalToWorld = Matrix4.Identity();
        cachedWorldToLocal = Matrix4.Identity();

        dirty = true;
    }

    private void markDirty() {
        dirty = true;
    }

    private void rebuildMatricesIfNeeded() {
        if (!dirty) return;

        Vector3 pos = position;
        Vector3 rot = eular;
        Vector3 scl = scale;

        cachedLocalToWorld =
            Matrix4.Trans(position)
            .mult(Matrix4.RotY(eular.y()))
            .mult(Matrix4.RotX(eular.x()))
            .mult(Matrix4.RotZ(eular.z()))
            .mult(Matrix4.Scale(scale));

        cachedWorldToLocal =
            Matrix4.Scale(scale.inv())
            .mult(Matrix4.RotZ(-eular.z()))
            .mult(Matrix4.RotX(-eular.x()))
            .mult(Matrix4.RotY(-eular.y()))
            .mult(Matrix4.Trans(position.mult(-1.0f)));

        dirty = false;
    }

    public Matrix4 localToWorld() {
        rebuildMatricesIfNeeded();
        return cachedLocalToWorld;
    }

    public Matrix4 worldToLocal() {
        rebuildMatricesIfNeeded();
        return cachedWorldToLocal;
    }

    public Transform setPosition(Vector3 position) {
        this.position = position;
        markDirty();
        return this;
    }

    public Transform setEular(Vector3 eular) {
        this.eular = eular;
        markDirty();
        return this;
    }

    public Transform setScale(Vector3 scale) {
        this.scale = scale;
        markDirty();
        return this;
    }

    public Transform setPosition(float x, float y, float z) {
        this.position.set(x, y, z);
        markDirty();
        return this;
    }

    public Transform setEular(float x, float y, float z) {
        this.eular.set(x, y, z);
        markDirty();
        return this;
    }

    public Transform setScale(float x, float y, float z) {
        this.scale.set(x, y, z);
        markDirty();
        return this;
    }

    // 如果你外部有直接改 transform.position.x 這種寫法，
    // 改完記得手動呼叫這個
    public Transform forceDirty() {
        markDirty();
        return this;
    }

    public boolean isDirty() {
        return dirty;
    }
}
