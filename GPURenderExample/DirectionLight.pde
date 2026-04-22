public class DirectionalLight extends Light {

    public float left = -5.0f;
    public float right = 5.0f;
    public float bottom = -5.0f;
    public float top = 5.0f;
    public float near = 0.01f;
    public float far = 200.0f;


    public DirectionalLight(Vector3 pos, Vector3 dir, Vector3 c) {
        super(pos, dir, c, new LightMaterial("Shaders/directionalLight.frag", "Shaders/quad.vert"));
    }

    public DirectionalLight setOrtho(float left, float right, float bottom, float top, float near, float far) {
        this.left = left;
        this.right = right;
        this.bottom = bottom;
        this.top = top;
        this.near = near;
        this.far = far;
        return this;
    }
    


    @Override
    public Matrix4 getProjectionMatrix() {
        return Matrix4.Ortho(left, right, bottom, top, near, far);
    }

    
    @Override
    public void setShaderParameter(){
        Matrix4 view = getViewMatrix();
        Matrix4 project = getProjectionMatrix();
        material.setVector3ToUniform("light_color", light_color);
        material.setMatrix4ToUniform("lightSpaceMatrix", project.mult(view));
        material.setVector3ToUniform("light_dir", light_dir);
        material.setTexture("shadowMap", shadowMap, 4);
    }    
}    
public class SpotLight extends Light {

    public float fov = 45.0f;
    public float aspect = 1.0f;
    public float near = 0.1f;
    public float far = 100.0f;

    public float cutoff = 12.5f;
    public float outerCutoff = 17.5f;

    public SpotLight(Vector3 pos, Vector3 dir, Vector3 c) {
        super(pos, dir, c, new LightMaterial("Shaders/spotLight.frag", "Shaders/quad.vert"));
    }

    public SpotLight setPerspective(float fov, float aspect, float near, float far) {
        this.fov = fov;
        this.aspect = aspect;
        this.near = near;
        this.far = far;
        return this;
    }

    public SpotLight setCutoff(float cutoff, float outerCutoff) {
        this.cutoff = cutoff;
        this.outerCutoff = outerCutoff;
        return this;
    }

    @Override
    public Matrix4 getProjectionMatrix() {
        return Matrix4.Perspective(fov, aspect, near, far);
    }
    

    @Override
    public void setShaderParameter() {
        Matrix4 view = getViewMatrix();
        Matrix4 project = getProjectionMatrix();
        material.setVector3ToUniform("light_color", light_color);
        material.setVector3ToUniform("light_dir", light_dir);
        material.setMatrix4ToUniform("lightSpaceMatrix", project.mult(view));
        material.setFloatToUniform("lightNear", near);
        material.setFloatToUniform("lightFar", far);
        material.setTexture("shadowMap", shadowMap, 4);
    }
    
    
}
