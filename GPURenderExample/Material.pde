import java.util.HashMap;

public abstract class Material {
    PShader shader;

    private HashMap<String, Integer> uniformCache = new HashMap<String, Integer>();
    private FloatBuffer matrixBuffer = allocateDirectFloatBuffer(16);
    Light lightSource;

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
    
    public void setCubeTexture(String name, TextureCube tex, int unit) {
        if (tex == null || tex.tex == null || !tex.isUploaded()) {
            println("[Material] Warning: cube texture is null -> " + name);
            return;
        }
    
        int location = getUniformLocation(name);
        if (location < 0) return;
    
        gl3.glActiveTexture(gl3.GL_TEXTURE0 + unit);
        gl3.glBindTexture(gl3.GL_TEXTURE_CUBE_MAP, tex.tex.get(0));
    
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
    
    public Material setLight(Light l) {
        lightSource = l;
        return this;
    }

    abstract void run(GameObject go, SubMesh subMesh);

    void cleanup() {
    }
}

public class PhongMaterial extends Material {
    Texture texture;   // 可選：手動指定時用

    public PhongMaterial(String frag) {
        super(frag);
    }

    public PhongMaterial(String frag, String vert) {
        super(frag, vert);
    }


    public PhongMaterial setTexture(Texture t) {
        texture = t;
        return this;
    }


    public void run(GameObject go, SubMesh subMesh) {
        Matrix4 model = go.localToWorld();
        Matrix4 mvp = go.MVP();

        setMatrix4ToUniform("MVP", mvp);
        setMatrix4ToUniform("modelMatrix", model);
        
        setVector3ToUniform("ambient_light", AMBIENT_LIGHT);
        
        setVector3ToUniform("view_pos", main_camera.transform.position);     
        
        setVector3ToUniform("light_color", lightSource.light_color);
        setVector3ToUniform("light_dir", lightSource.light_dir);
        setVector3ToUniform("light_color", lightSource.light_color);
        
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

public class ShadowMaterial extends Material {
    Light lightSource;

    public ShadowMaterial(String frag) {
        super(frag);
    }

    public ShadowMaterial(String frag, String vert) {
        super(frag, vert);
    }
    
    public ShadowMaterial setLight(Light l) {
        lightSource = l;
        return this;
    }


    @Override
    public void run(GameObject go, SubMesh subMesh) {        
        Matrix4 model = go.localToWorld();
        Matrix4 shadowMatrix = lightSource.getProjectionMatrix().mult(lightSource.getViewMatrix());
        setMatrix4ToUniform("modelMatrix", model);
        setMatrix4ToUniform("shadowMatrix", shadowMatrix);
        setVector3ToUniform("lightPos", lightSource.transform.position);
        setFloatToUniform("lightFar", lightSource.getLightFar());    
        
    }

    void cleanup() {
        
    }
}

public class PointShadowMaterial extends ShadowMaterial {
    Matrix4 shadowMatrix;

    public PointShadowMaterial(String frag) {
        super(frag);
    }

    public PointShadowMaterial(String frag, String vert) {
        super(frag, vert);
    }
    
    public PointShadowMaterial setShadowMatrix(Matrix4 m){
        shadowMatrix = m;
        return this;
    }
    
    @Override
    public void run(GameObject go, SubMesh subMesh) {        
        Matrix4 model = go.localToWorld();
        setMatrix4ToUniform("modelMatrix", model);
        setMatrix4ToUniform("shadowMatrix", shadowMatrix);
        setVector3ToUniform("lightPos", lightSource.transform.position);
        setFloatToUniform("lightFar", lightSource.getLightFar());
        
    }
}

public class LightMaterial extends Material {

    Texture albedoTex = new Texture(1,1);
    Texture normalTex = new Texture(1,1);
    Texture positionTex = new Texture(1,1);
    Texture depthTex = new Texture(1,1);

    public LightMaterial(String frag) {
        super(frag);
    }

    public LightMaterial(String frag, String vert) {
        super(frag, vert);
    }

    public LightMaterial setAlbedoTex(Texture t) {
        albedoTex = t;
        return this;
    }
    public LightMaterial setNormalTex(Texture t) {
        normalTex = t;
        return this;
    }
    public LightMaterial setPositionTex(Texture t) {
        positionTex = t;
        return this;
    }
    public LightMaterial setDepthTex(Texture t) {
        depthTex = t;
        return this;
    }
    

    @Override
    public void run(GameObject go, SubMesh subMesh) {
        setTexture("albedo", albedoTex, 0);
        setTexture("worldNormal", normalTex, 1);
        setTexture("worldPos", positionTex, 2);
        setTexture("shadowMap", depthTex, 3);

        lightSource.setShaderParameter(this);
        
    }

    @Override
    void cleanup() {
        unbindTexture(0);
        unbindTexture(1);
        unbindTexture(2);
        unbindTexture(4); // shadowMap 如果有綁
    }
}

public class PointLightMaterial extends LightMaterial{
    TextureCube shadowCubeMap; 
    public PointLightMaterial(String frag) {
        super(frag);
    }

    public PointLightMaterial(String frag, String vert) {
        super(frag, vert);
    }
    
    public LightMaterial setDepthTex(TextureCube t) {
        shadowCubeMap = t;
        return this;
    }
    
    @Override
    public void run(GameObject go, SubMesh subMesh) {
        setTexture("albedo", albedoTex, 0);
        setTexture("worldNormal", normalTex, 1);
        setTexture("worldPos", positionTex, 2);
        setCubeTexture("shadowCubeMap", shadowCubeMap, 3);

        lightSource.setShaderParameter(this);
        
    }

}
