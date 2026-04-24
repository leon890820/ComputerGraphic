public abstract class Light extends Quad {

    public Vector3 light_dir;
    public Vector3 light_color;

    protected float intensity = 1.0f;
    protected boolean castShadow = true;
    protected Vector3 up = new Vector3(0, 1, 0);

    ShadowMaterial shadowMaterial;

    public Light(Vector3 pos, Vector3 ld, Vector3 lc, LightMaterial mat) {
        super(mat);
        this.transform.position = pos;
        this.light_dir = ld.unit_vector();
        this.light_color = lc;        
        shadowMaterial = new ShadowMaterial("Shaders/Shadow.frag", "Shaders/Shadow.vert");        
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


    public Light setAlbedoTex(Texture t) {
        LightMaterial material = (LightMaterial)getMaterial();
        material.setAlbedoTex(t);
        return this;
    }

    public Light setNormalTex(Texture t) {
        LightMaterial material = (LightMaterial)getMaterial();
        material.setNormalTex(t);
        return this;
    }

    public Light setPositionTex(Texture t) {
        LightMaterial material = (LightMaterial)getMaterial();
        material.setPositionTex(t);
        return this;
    }

    public Matrix4 getViewMatrix() {
        return Matrix4.LookAt( transform.position, transform.position.add(light_dir), up );
    }
    
    public Light setPerspective(float fov, float aspect, float near, float far) {
        return this;
    }
    
    public Light setOrtho(float left, float right, float bottom, float top, float near, float far) {
        return this;
    }
    
    public abstract void lightShadowPass();
    public abstract Matrix4 getProjectionMatrix();
    public abstract void setShaderParameter(LightMaterial material);
    public abstract float getLightFar();
}
