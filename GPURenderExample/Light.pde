public abstract class Light extends GameObject {

    public Vector3 light_dir;
    public Vector3 light_color;

    protected float intensity = 1.0f;
    protected boolean castShadow = true;
    protected Vector3 up = new Vector3(0, 1, 0);
    
    protected Texture shadowMap;

    public Light(Vector3 pos, Vector3 ld, Vector3 lc) {
        this.transform.position = pos;
        this.light_dir = ld.unit_vector();
        this.light_color = lc;
    }

    public Light setLightColor(Vector3 v) {
        this.light_color = v;
        return this;
    }

    public Light setLightColor(float x, float y, float z) {
        this.light_color.set(x, y, z);
        return this;
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

    public Light setIntensity(float intensity) {
        this.intensity = intensity;
        return this;
    }

    public float getIntensity() {
        return intensity;
    }

    public Light setCastShadow(boolean castShadow) {
        this.castShadow = castShadow;
        return this;
    }

    public boolean isCastShadow() {
        return castShadow;
    }
    
    public void setShadowMap(Texture tex){
        shadowMap = tex;
    }

    public Light setUp(Vector3 up) {
        this.up = up;
        return this;
    }

    public Vector3 getLightDirection() {
        return light_dir;
    }

    public Vector3 getLightColor() {
        return light_color;
    }

    public Matrix4 getViewMatrix() {
        return Matrix4.LookAt(
            transform.position,
            transform.position.add(light_dir),
            up
        );
    }

    public abstract Matrix4 getProjectionMatrix();
    public abstract void setShaderParameter(Material material);
}
