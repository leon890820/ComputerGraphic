public abstract class Light extends Quad {

    public Vector3 light_dir;
    public Vector3 light_color;

    protected float intensity = 1.0f;
    protected boolean castShadow = true;
    protected Vector3 up = new Vector3(0, 1, 0);

    protected Texture shadowMap;
    protected LightMaterial material;

    public Light(Vector3 pos, Vector3 ld, Vector3 lc, LightMaterial mat) {
        super(mat);
        this.material = mat;
        this.transform.position = pos;
        this.light_dir = ld.unit_vector();
        this.light_color = lc;
    }

    public Light setLightdirection(Vector3 v) {
        this.light_dir = v.unit_vector();
        return this;
    }
    public Light setLightdirection(float x, float y, float z) {
        this.light_dir.set(x, y, z);
        this.light_dir.normalize();
        return this;
    }

    public Light setShadowMap(Texture tex) {
        shadowMap = tex;
        return this;
    }

    public Light setAlbedoTex(Texture t) {
        material.setAlbedoTex(t);
        return this;
    }

    public Light setNormalTex(Texture t) {
        material.setNormalTex(t);
        return this;
    }

    public Light setPositionTex(Texture t) {
        material.setPositionTex(t);
        return this;
    }

    public Matrix4 getViewMatrix() {
        return Matrix4.LookAt( transform.position, transform.position.add(light_dir), up );
    }

    public abstract Matrix4 getProjectionMatrix();
    public abstract void setShaderParameter();
}
