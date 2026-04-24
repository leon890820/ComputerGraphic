public class DirectionalLight extends Light {

    public float left = -5.0f;
    public float right = 5.0f;
    public float bottom = -5.0f;
    public float top = 5.0f;
    public float near = 0.01f;
    public float far = 200.0f;
    FBO shadowBuffer;
    Texture shadowMap;

    public DirectionalLight(Vector3 pos, Vector3 dir, Vector3 c) {
        super(pos, dir, c, new LightMaterial("Shaders/directionalLight.frag", "Shaders/quad.vert"));
        shadowBuffer = new FBO(width, height, 1, gl3.GL_LINEAR, true);
        setShadowMap(shadowBuffer.depthTex).setAlbedoTex(GBuffer.tex[0]).setNormalTex(GBuffer.tex[1]).setPositionTex(GBuffer.tex[2]);
    }

    @Override
    public Light setOrtho(float left, float right, float bottom, float top, float near, float far) {
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
    public void setShaderParameter(LightMaterial material){
        Matrix4 view = getViewMatrix();
        Matrix4 project = getProjectionMatrix();
        material.setVector3ToUniform("light_color", light_color);
        material.setMatrix4ToUniform("lightSpaceMatrix", project.mult(view));
        material.setVector3ToUniform("light_dir", light_dir);
        material.setFloatToUniform("lightFar", far);
        material.setVector3ToUniform("light_pos", transform.position);       
        material.setTexture("shadowMap", shadowMap, 3);
    }   
    
    @Override
    public float getLightFar(){
        return far;
    }
    
    @Override
    public void lightShadowPass(){
        shadowBuffer.bindFrameBuffer();
        shadowMaterial.setShadowMatrix(getProjectionMatrix().mult(getViewMatrix()));
        shadowMaterial.setLight(this);
        for(GameObject go : worldObject){
            go.runWithMaterial(shadowMaterial);    
        }    
        shadowBuffer.unbindFrameBuffer(width,height);
    }
    
    public Light setShadowMap(Texture tex) {
        shadowMap = tex;
        return this;
    }
}    
public class SpotLight extends Light {

    public float fov = 45.0f;
    public float aspect = 1.0f;
    public float near = 0.1f;
    public float far = 1000.0f;

    public float cutoff = 12.5f;
    public float outerCutoff = 17.5f;
    FBO shadowBuffer;
    Texture shadowMap;

    public SpotLight(Vector3 pos, Vector3 dir, Vector3 c) {
        super(pos, dir, c, new LightMaterial("Shaders/spotLight.frag", "Shaders/quad.vert"));
        shadowBuffer = new FBO(width, height, 1, gl3.GL_LINEAR, true);
        setShadowMap(shadowBuffer.depthTex).setAlbedoTex(GBuffer.tex[0]).setNormalTex(GBuffer.tex[1]).setPositionTex(GBuffer.tex[2]);
    }

    @Override
    public Light setPerspective(float fov, float aspect, float near, float far) {
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
    public void setShaderParameter(LightMaterial material) {
        Matrix4 view = getViewMatrix();
        Matrix4 project = getProjectionMatrix();
        material.setMatrix4ToUniform("lightSpaceMatrix", project.mult(view));
        material.setVector3ToUniform("light_color", light_color);
        material.setVector3ToUniform("light_dir", light_dir);  
        material.setVector3ToUniform("light_pos", transform.position);       
        material.setFloatToUniform("lightFar", far);
        material.setTexture("shadowMap", shadowMap, 3);
    }   
    
    @Override
    public float getLightFar(){
        return far;
    }
    
    @Override
    public void lightShadowPass(){
        shadowBuffer.bindFrameBuffer();
        shadowMaterial.setShadowMatrix(getProjectionMatrix().mult(getViewMatrix()));
        shadowMaterial.setLight(this);
        for(GameObject go : worldObject){
            go.runWithMaterial(shadowMaterial);    
        }    
        shadowBuffer.unbindFrameBuffer(width,height);
    }
    
    public Light setShadowMap(Texture tex) {
        shadowMap = tex;
        return this;
    }
    
}

public class PointLight extends Light {

    float radius = 10.0f;
    float near = 0.1f;
    float far = 1000.0f;
    float intensity = 1.0f;

    TextureCube shadowCubeMap;        
    CubeMapFBO pointShadowBuffer;

    public PointLight(Vector3 pos, Vector3 c) {
        super(pos, new Vector3(0, 0, 0), c,new LightMaterial("Shaders/pointLight.frag", "Shaders/quad.vert"));
        pointShadowBuffer = new CubeMapFBO(width,1,true);
        shadowCubeMap = pointShadowBuffer.depthTex;
        setAlbedoTex(GBuffer.tex[0]).setNormalTex(GBuffer.tex[1]).setPositionTex(GBuffer.tex[2]);
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
        near = n;
        far = f;
        return this;
    }

    public PointLight setShadowCubeMap(TextureCube tex) {
        shadowCubeMap = tex;
        return this;
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
        Matrix4 proj = Matrix4.Perspective(90.0f, 1.0f, near, far);

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
    public void setShaderParameter(LightMaterial mat) {
        mat.setVector3ToUniform("light_pos", transform.position);
        mat.setVector3ToUniform("light_color", light_color);
        //mat.setFloatToUniform("light_radius", radius);
        //mat.setFloatToUniform("light_intensity", intensity);
        mat.setFloatToUniform("lightFar", far);
                
        mat.setCubeTexture("shadowCubeMap", shadowCubeMap, 3);
        
    }

    
    public float getLightFar(){
        return far;
    }
    
    @Override
    public void lightShadowPass(){
        shadowMaterial.setLight(this);
        Matrix4[] shadowMatrices = getShadowMatrices();    
        gl3.glEnable(gl3.GL_DEPTH_TEST);    
        for (int face = 0; face < 6; face++) {
            pointShadowBuffer.bindFace(face);    
            gl3.glClear(gl3.GL_DEPTH_BUFFER_BIT); // ⭐ 必加    
            shadowMaterial.setShadowMatrix(shadowMatrices[face]);    
            for(GameObject go : worldObject){
                go.runWithMaterial(shadowMaterial);    
            }
        }    
        pointShadowBuffer.unbind(width, height); // ⭐ 必加
    }
    
}
