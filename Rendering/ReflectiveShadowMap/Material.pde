import java.util.HashMap;

public abstract class Material {
    PShader shader;
    GameObject gameobject;

    private HashMap<String, Integer> uniformCache = new HashMap<String, Integer>();
    private FloatBuffer matrixBuffer = allocateDirectFloatBuffer(16);

    public Material(String frag) {
        shader = loadShader(frag);
    }

    public Material(String frag, String vert) {
        shader = loadShader(frag, vert);
    }

    public Material setGameobject(GameObject g) {
        gameobject = g;
        return this;
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
        if (tex == null || tex.tex == null) {
            println("[Material] Warning: texture is null -> " + name);
            return;
        }

        int location = getUniformLocation(name);
        if (location < 0) return;

        gl3.glActiveTexture(gl3.GL_TEXTURE0 + unit);
        gl3.glBindTexture(gl3.GL_TEXTURE_2D, tex.tex.get(0));
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

    abstract void run(GameObject go);

    void cleanup() {
    }
}


public class PhongMaterial extends Material {
    Vector3 albedo = new Vector3(0.0f);
    Matrix4 light_MVP;
    Texture texture;

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

    public void run(GameObject go) {
        setGameobject(go);

        Matrix4 model = gameobject.localToWorld();
        Matrix4 mvp = gameobject.MVP();

        setMatrix4ToUniform("MVP", mvp);
        setMatrix4ToUniform("modelMatrix", model);

        setVector3ToUniform("light_dir", main_light.light_dir);
        setVector3ToUniform("ambient_light", AMBIENT_LIGHT);
        setVector3ToUniform("light_color", main_light.light_color);
        setVector3ToUniform("view_pos", main_camera.transform.position);
        setVector3ToUniform("albedo", albedo);

        if (light_MVP != null) {
            setMatrix4ToUniform("light_MVP", light_MVP);
        }

        if (texture != null && texture.tex != null) {
            setTexture("tex", texture, 0);
        }
    }

    void cleanup() {
        if (texture != null && texture.tex != null) {
            unbindTexture(0);
        }
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
    
    public void run(GameObject go) {
        setGameobject(go); 
        setTexture("tex" , tex , 0);
    }
}

public class GBufferMaterial extends Material {
    public GBufferMaterial(String frag) {
        super(frag);
    }

    public GBufferMaterial(String frag, String vert) {
        super(frag, vert);
    }    

    public void run(GameObject go) {
        setGameobject(go);

        Matrix4 model = gameobject.localToWorld();
        Matrix4 view = main_camera.getViewMatrix();
        Matrix4 project = main_camera.getProjectionMatrix();
        
        setMatrix4ToUniform("modelMatrix", model);
        setMatrix4ToUniform("viewMatrix", view);
        setMatrix4ToUniform("projectMatrix", project);
        
    }

    void cleanup() {

    }
}

public class RSMBufferMaterial extends Material {
    public RSMBufferMaterial(String frag) {
        super(frag);
    }

    public RSMBufferMaterial(String frag, String vert) {
        super(frag, vert);
    }    

    public void run(GameObject go) {
        setGameobject(go);

        Matrix4 model = gameobject.localToWorld();
        Matrix4 view = main_camera.getViewMatrix();
        Matrix4 lightView = main_light.lookAt();
        Matrix4 lightProject = Matrix4.Ortho(-500,500,-500,500,0.1,1000);
        
        setMatrix4ToUniform("modelMatrix", model);
        setMatrix4ToUniform("viewMatrix", view);
        setMatrix4ToUniform("lightVPMatrix", lightProject.mult(lightView));
        
    }

    void cleanup() {

    }
}
