import java.util.HashMap;

public abstract class Material {
    PShader shader;

    private HashMap<String, Integer> uniformCache = new HashMap<String, Integer>();
    private FloatBuffer matrixBuffer = allocateDirectFloatBuffer(16);

    public Material(String frag) {
        shader = loadShader(frag);
    }

    public Material(String frag, String vert) {
        shader = loadShader(frag, vert);
    }

    protected int getUniformLocation(String name) {
        if (uniformCache.containsKey(name)) {
            return uniformCache.get(name);
        }

        int location = gl3.glGetUniformLocation(shader.glProgram, name);
        uniformCache.put(name, location);

        if (location == -1) {
            println("[Material] Warning: uniform not found -> " + name);
        }

        return location;
    }

    private FloatBuffer writeMatrixToBuffer(Matrix4 m) {
        matrixBuffer.rewind();
        matrixBuffer.put(m.m);
        matrixBuffer.rewind();
        return matrixBuffer;
    }

    public void setTexture(String name, Texture tex, int unit) {
        if (tex == null || tex.tex == null || !tex.isUploaded()) {
            println("[Material] Warning: texture is null or not uploaded -> " + name);
            return;
        }

        int location = getUniformLocation(name);
        if (location < 0) return;

        tex.bind(unit);
        gl3.glUniform1i(location, unit);
    }

    public void unbindTexture(int unit) {
        gl3.glActiveTexture(gl3.GL_TEXTURE0 + unit);
        gl3.glBindTexture(gl3.GL_TEXTURE_2D, 0);
    }

    public void setMatrix4ToUniform(String name, Matrix4 m) {
        int location = getUniformLocation(name);
        if (location < 0) return;

        gl3.glUniformMatrix4fv(location, 1, false, writeMatrixToBuffer(m));
    }

    public void setVector4ToUniform(String name, float x, float y, float z, float w) {
        int location = getUniformLocation(name);
        if (location < 0) return;

        gl3.glUniform4f(location, x, y, z, w);
    }

    public void setVector3ToUniform(String name, float x, float y, float z) {
        int location = getUniformLocation(name);
        if (location < 0) return;

        gl3.glUniform3f(location, x, y, z);
    }

    public void setVector3ToUniform(String name, Vector3 v) {
        if (v == null) return;
        setVector3ToUniform(name, v.x, v.y, v.z);
    }

    public void setVector2ToUniform(String name, float x, float y) {
        int location = getUniformLocation(name);
        if (location < 0) return;

        gl3.glUniform2f(location, x, y);
    }

    public void setFloatToUniform(String name, float x) {
        int location = getUniformLocation(name);
        if (location < 0) return;

        gl3.glUniform1f(location, x);
    }

    public void setIntToUniform(String name, int x) {
        int location = getUniformLocation(name);
        if (location < 0) return;

        gl3.glUniform1i(location, x);
    }

    public void clearUniformCache() {
        uniformCache.clear();
    }

    public void bind() {
        shader.bind();
    }

    public void unbind() {
        shader.unbind();
    }

    abstract void run(GameObject go, SubMesh subMesh);

    void cleanup() {
    }
}

public class PhongMaterial extends Material {
    Vector3 albedo = new Vector3(0.0f);
    Matrix4 light_MVP;
    Texture texture;   // 可選：手動指定時用

    public PhongMaterial(String frag) {
        super(frag);
    }

    public PhongMaterial(String frag, String vert) {
        super(frag, vert);
    }

    public PhongMaterial setAlbedo(Vector3 v) {
        albedo = v;
        return this;
    }

    public PhongMaterial setAlbedo(float x, float y, float z) {
        albedo.set(x, y, z);
        return this;
    }

    public PhongMaterial setTexture(Texture t) {
        texture = t;
        return this;
    }

    public PhongMaterial setLightMVP(Matrix4 m) {
        light_MVP = m;
        return this;
    }

    public void run(GameObject go, SubMesh subMesh) {
        Matrix4 model = go.localToWorld();
        Matrix4 mvp = go.MVP();

        setMatrix4ToUniform("MVP", mvp);
        setMatrix4ToUniform("modelMatrix", model);

        setVector3ToUniform("light_dir", main_light.getLightdirection());
        setVector3ToUniform("ambient_light", AMBIENT_LIGHT);
        setVector3ToUniform("light_color", main_light.light_color);
        setVector3ToUniform("view_pos", main_camera.transform.position);
        setVector3ToUniform("albedo", albedo);

        if (light_MVP != null) {
            setMatrix4ToUniform("light_MVP", light_MVP);
        }

        Texture useTex = texture;

        if (useTex == null && subMesh != null) {
            useTex = subMesh.textureKa;
        }

        if (useTex != null && useTex.isUploaded()) {
            setTexture("tex", useTex, 0);
        }
    }

    void cleanup() {
        unbindTexture(0);
    }
}

public class QuadMaterial extends Material {

    Texture tex = new Texture(1,1);

    public QuadMaterial(String frag) {
        super(frag);
    }

    public QuadMaterial(String frag, String vert) {
        super(frag, vert);
    }

    public QuadMaterial setTexture(Texture t) {
        tex = t;
        return this;
    }

    @Override
    public void run(GameObject go, SubMesh subMesh) {
        if (tex != null && tex.isUploaded()) {
            setTexture("tex", tex, 0);
        }
    }

    void cleanup() {
        if (tex != null && tex.tex != null) {
            unbindTexture(0);
        }
    }
}

public class GBufferMaterial extends Material {
    public GBufferMaterial(String frag) {
        super(frag);
    }

    public GBufferMaterial(String frag, String vert) {
        super(frag, vert);
    }

    public void run(GameObject go, SubMesh subMesh) {
        Matrix4 model = go.localToWorld();
        Matrix4 view = main_camera.getViewMatrix();
        Matrix4 project = main_camera.getProjectionMatrix();

        setMatrix4ToUniform("modelMatrix", model);
        setMatrix4ToUniform("viewMatrix", view);
        setMatrix4ToUniform("projectMatrix", project);

        if (subMesh != null && subMesh.textureKa != null && subMesh.textureKa.isUploaded()) {
            setTexture("tex", subMesh.textureKa, 0);
        }
    }

    void cleanup() {
        unbindTexture(0);
    }
}

public class RSMBufferMaterial extends Material {
    public RSMBufferMaterial(String frag) {
        super(frag);
    }

    public RSMBufferMaterial(String frag, String vert) {
        super(frag, vert);
    }

    public void run(GameObject go, SubMesh subMesh) {
        Matrix4 model = go.localToWorld();
        Matrix4 view = main_camera.getViewMatrix();
        Matrix4 lightView = main_light.lookAt();
        Matrix4 lightProject = Matrix4.Projection(60.0,1.0,0.01,3000);//Matrix4.Ortho(-1000, 1000, -1000, 1000, 0.1, 2000);

        setMatrix4ToUniform("modelMatrix", model);
        setMatrix4ToUniform("viewMatrix", view);
        setMatrix4ToUniform("lightVPMatrix", lightProject.mult(lightView));
        
        if (subMesh != null && subMesh.textureKa != null && subMesh.textureKa.isUploaded()) {
            setTexture("tex", subMesh.textureKa, 0);
        }
    }

    void cleanup() {
    }
}

public class ShadingWithRSMMaterial extends Material {
    Texture u_AlbedoTexture = new Texture(1,1);
    Texture u_NormalTexture = new Texture(1,1);
    Texture u_PositionTexture = new Texture(1,1);
    Texture u_RSMFluxTexture = new Texture(1,1);
    Texture u_RSMNormalTexture = new Texture(1,1);
    Texture u_RSMPositionTexture = new Texture(1,1);
    Texture u_RSMDepthTexture = new Texture(1,1);
        
    float u_MaxSampleRadius = 100;
       
    
    public ShadingWithRSMMaterial(String frag) {
        super(frag);
    }

    public ShadingWithRSMMaterial(String frag, String vert) {
        super(frag, vert);
    }
    
    public ShadingWithRSMMaterial setAlbedoTexture(Texture texture){
        u_AlbedoTexture = texture;
        return this;
    }
    
    public ShadingWithRSMMaterial setNormalTexture(Texture texture){
        u_NormalTexture = texture;
        return this;
    }
    
    public ShadingWithRSMMaterial setPositionTexture(Texture texture){
        u_PositionTexture = texture;
        return this;
    }
    
    public ShadingWithRSMMaterial setRSMFluxTexture(Texture texture){
        u_RSMFluxTexture = texture;
        return this;
    }
    
    public ShadingWithRSMMaterial setRSMNormalTexture(Texture texture){
        u_RSMNormalTexture = texture;
        return this;
    }
    
    public ShadingWithRSMMaterial setRSMPositionTexture(Texture texture){
        u_RSMPositionTexture = texture;
        return this;
    }
    
    public ShadingWithRSMMaterial setRSMDepthTexture(Texture texture){
        u_RSMDepthTexture = texture;
        return this;
    }

    public void run(GameObject go, SubMesh subMesh) {
        setTexture("u_AlbedoTexture", u_AlbedoTexture, 0);
        setTexture("u_NormalTexture", u_NormalTexture, 1);
        setTexture("u_PositionTexture", u_PositionTexture, 2);
        setTexture("u_RSMFluxTexture", u_RSMFluxTexture, 3);
        setTexture("u_RSMNormalTexture", u_RSMNormalTexture, 4);
        setTexture("u_RSMPositionTexture", u_RSMPositionTexture, 5);
        setTexture("u_RSMDepthTexture", u_RSMDepthTexture, 6);
        
        Matrix4 lightView = main_light.lookAt();
        Matrix4 lightProject = Matrix4.Projection(60.0,1.0,0.01,3000);//Matrix4.Ortho(-1000, 1000, -1000, 1000, 0.1, 2000);
        Matrix4 view = main_camera.getViewMatrix();
        
        setMatrix4ToUniform("u_LightVPMatrixMulInverseCameraViewMatrix", lightProject.mult(lightView).mult(view.Inverse()));        
        setFloatToUniform("u_MaxSampleRadius", u_MaxSampleRadius);
        setIntToUniform("u_RSMSize", height);
        setIntToUniform("u_VPLNum", VPL_NUM);
        setVector3ToUniform("u_LightDirInViewSpace", view.transformDirection(main_light.getLightdirection()));
        setVector3ToUniform("u_LightPosInViewSpace", view.transformPoint(main_light.getPosition()));
        setIntToUniform("RTX", RTX ? 1 : 0);
        
    }

    void cleanup() {
    }
}
