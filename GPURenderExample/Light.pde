public abstract class Light extends Quad {

    public Vector3 light_dir;
    public Vector3 light_color;

    protected float intensity = 1.0f;
    protected boolean castShadow = true;
    protected Vector3 up = new Vector3(0, 1, 0);

    protected Texture shadowMap;

    public Light(Vector3 pos, Vector3 ld, Vector3 lc, LightMaterial mat) {
        super(mat);
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

    public abstract Matrix4 getProjectionMatrix();
    public abstract void setShaderParameter(LightMaterial material);
}

public class PointLight extends Light {

    float radius = 10.0f;
    float nearPlane = 0.1f;
    float farPlane = 25.0f;
    float intensity = 1.0f;

    TextureCube shadowCubeMap;

    public PointLight(Vector3 pos, Vector3 color) {
        super(pos, new Vector3(0, 0, 0), color,
              new PointLightMaterial("Shaders/pointLight.frag", "Shaders/quad.vert"));
    }

    public PointLight setRadius(float r) {
        radius = r;
        return this;
    }

    public PointLight setIntensity(float i) {
        intensity = i;
        return this;
    }

    public PointLight setNearFar(float n, float f) {
        nearPlane = n;
        farPlane = f;
        return this;
    }

    public PointLight setShadowCubeMap(TextureCube tex) {
        shadowCubeMap = tex;
        return this;
    }

    public float getFarPlane() {
        return farPlane;
    }

    public float getNearPlane() {
        return nearPlane;
    }

    public float getRadius() {
        return radius;
    }

    public float getIntensity() {
        return intensity;
    }

    public Vector3 getPosition() {
        return transform.position;
    }

    public Matrix4[] getShadowMatrices() {
        Vector3 pos = transform.position;
        Matrix4 proj = Matrix4.Perspective(radians(90.0f), 1.0f, nearPlane, farPlane);

        Matrix4[] mats = new Matrix4[6];

        mats[0] = proj.mult(Matrix4.LookAt(pos, pos.add(new Vector3( 1,  0,  0)), new Vector3(0, -1,  0)));
        mats[1] = proj.mult(Matrix4.LookAt(pos, pos.add(new Vector3(-1,  0,  0)), new Vector3(0, -1,  0)));
        mats[2] = proj.mult(Matrix4.LookAt(pos, pos.add(new Vector3( 0,  1,  0)), new Vector3(0,  0,  1)));
        mats[3] = proj.mult(Matrix4.LookAt(pos, pos.add(new Vector3( 0, -1,  0)), new Vector3(0,  0, -1)));
        mats[4] = proj.mult(Matrix4.LookAt(pos, pos.add(new Vector3( 0,  0,  1)), new Vector3(0, -1,  0)));
        mats[5] = proj.mult(Matrix4.LookAt(pos, pos.add(new Vector3( 0,  0, -1)), new Vector3(0, -1,  0)));

        return mats;
    }

    @Override
    public Matrix4 getViewMatrix() {
        return Matrix4.Identity();
    }

    @Override
    public Matrix4 getProjectionMatrix() {
        return Matrix4.Identity();
    }

    @Override
    public void setShaderParameter(Material mat) {
        mat.setVector3ToUniform("light_pos", transform.position);
        mat.setVector3ToUniform("light_color", light_color);
        mat.setFloatToUniform("light_radius", radius);
        mat.setFloatToUniform("light_intensity", intensity);
        mat.setFloatToUniform("farPlane", farPlane);

        if (shadowCubeMap != null && shadowCubeMap.isUploaded()) {
            mat.setCubeTexture("shadowCubeMap", shadowCubeMap, 4);
        }
    }

    public PointLight setAlbedoTex(Texture t) {
        ((PointLightMaterial) getMaterial()).setAlbedoTex(t);
        return this;
    }

    public PointLight setNormalTex(Texture t) {
        ((PointLightMaterial) getMaterial()).setNormalTex(t);
        return this;
    }

    public PointLight setPositionTex(Texture t) {
        ((PointLightMaterial) getMaterial()).setPositionTex(t);
        return this;
    }
}
