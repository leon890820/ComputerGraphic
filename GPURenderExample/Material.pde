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
    Texture texture;   // 可選：手動指定時用
    Texture shadowMap;

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
    
    public PhongMaterial setShadowMap(Texture t) {
        shadowMap = t;
        return this;
    }

    public void run(GameObject go, SubMesh subMesh) {
        Matrix4 model = go.localToWorld();
        Matrix4 mvp = go.MVP();

        setMatrix4ToUniform("MVP", mvp);
        setMatrix4ToUniform("modelMatrix", model);

        setVector3ToUniform("light_dir", main_light.light_dir);
        setVector3ToUniform("ambient_light", AMBIENT_LIGHT);
        setVector3ToUniform("light_color", main_light.light_color);
        setVector3ToUniform("view_pos", main_camera.transform.position);
        setVector3ToUniform("albedo", albedo);        
        
        main_light.setShaderParameter(this);
        
        Texture useTex = texture;

        if (useTex == null && subMesh != null) {
            useTex = subMesh.textureKa;
        }
        
        if (useTex != null && useTex.isUploaded()) {            
            setTexture("tex", useTex, 0);
        }
        setTexture("shadowMap", shadowMap, 1);
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

public class ShadowMaterial extends Material {


    public ShadowMaterial(String frag) {
        super(frag);
    }

    public ShadowMaterial(String frag, String vert) {
        super(frag, vert);
    }

    @Override
    public void run(GameObject go, SubMesh subMesh) {
        Matrix4 model = go.localToWorld();
        Matrix4 view = main_light.getViewMatrix();
        Matrix4 project = main_light.getProjectionMatrix();
        
        setMatrix4ToUniform("Light_MVP", project.mult(view).mult(model));
    }

    void cleanup() {
        
    }
}
