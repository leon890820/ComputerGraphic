public abstract class Material {
    PShader shader;
    GameObject gameobject;
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

    public void setTexture(String name, Texture tex, int c) {
        gl3.glActiveTexture(gl3.GL_TEXTURE0 + c);
        gl3.glBindTexture(gl3.GL_TEXTURE_2D, tex.tex.get(0));
        int textureLocation = gl3.glGetUniformLocation(shader.glProgram, name);
        gl3.glUniform1i(textureLocation, c);
    }

    void setMatrix4ToUniform(String s, Matrix4 m) {
        int location = gl3.glGetUniformLocation(shader.glProgram, s);
        gl3.glUniformMatrix4fv(location, 1, false, toFloatBuffer(m));
    }
    void setVector4ToUniform(String s, float x, float y, float z, float w) {
        int location = gl3.glGetUniformLocation(shader.glProgram, s);
        gl3.glUniform4f(location, x, y, z, w);
    }

    void setVector3ToUniform(String s, float x, float y, float z) {
        int location = gl3.glGetUniformLocation(shader.glProgram, s);
        gl3.glUniform3f(location, x, y, z);
    }
    void setVector2ToUniform(String s, float x, float y) {
        
        int location = gl3.glGetUniformLocation(shader.glProgram, s);        
        gl3.glUniform2f(location, x, y);
    }
    
    void setFloatToUniform(String s, float x) {
        int location = gl3.glGetUniformLocation(shader.glProgram, s);
        gl3.glUniform1f(location, x);
    }
    void setIntToUniform(String s, int x) {
        int location = gl3.glGetUniformLocation(shader.glProgram, s);
        gl3.glUniform1i(location, x);
    }

    abstract void run(GameObject go);
}

public class PhongMaterial extends Material {
    Vector3 albedo = new Vector3(0.0);
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
        setMatrix4ToUniform("MVP", gameobject.MVP().transposed());
        setVector3ToUniform("albedo", albedo.x, albedo.y, albedo.z);
    }
}

public class FluidMaterial extends PhongMaterial {
    Vector3 albedo = new Vector3(0.0);
    Matrix4 light_MVP;
    Texture texture;



    public FluidMaterial(String frag) {
        super(frag);
    }
    public FluidMaterial(String frag, String vert) {
        super(frag, vert);
    }

  
    @Override
    public void run(GameObject go) {
        Fluid fluid = (Fluid)go;
        setGameobject(go);
        setMatrix4ToUniform("MVP", gameobject.MVP().transposed());
        setVector3ToUniform("albedo", albedo.x, albedo.y, albedo.z);
        setVector3ToUniform("velosity", fluid.velosity.x, fluid.velosity.y, fluid.velosity.z);

    }
}

public class DensityMaterial extends Material {
    Vector3 camPos = new Vector3(0.0);
    Matrix4 light_MVP;

    
    public DensityMaterial(String frag) {
        super(frag);
    }
    public DensityMaterial(String frag, String vert) {
        super(frag, vert);
    }
    
    public DensityMaterial setCamPos(Vector3 v) {
        camPos = v;
        return this;
    }

    public void run(GameObject go) {

        setGameobject(go);
        setVector4ToUniform("camInfo", camPos.x, camPos.y, camPos.z , GH_FOV * PI / 180.0);
        setVector2ToUniform("boundary", boundSize.x, boundSize.y);
        setFloatToUniform("kernelRadius", kernelRadius);
    }
}


public class PropertyMaterial extends Material {
    Vector3 camPos = new Vector3(0.0);
    Matrix4 light_MVP;
    Texture texture = new Texture(1,1);
    Texture densityTex = new Texture(1,1);


    public PropertyMaterial(String frag) {
        super(frag);
    }
    public PropertyMaterial(String frag, String vert) {
        super(frag, vert);
    }


    
    public PropertyMaterial setCamPos(Vector3 v) {
        camPos = v;
        return this;
    }



    public PropertyMaterial setTexture(Texture t) {
        texture = t;
        return this;
    }
    public PropertyMaterial setDensityTexture(Texture t) {
        densityTex = t;
        return this;
    }

    public void run(GameObject go) {
        setGameobject(go);
        setVector4ToUniform("camInfo", camPos.x, camPos.y, camPos.z , GH_FOV * PI / 180.0);
        setVector2ToUniform("boundary", boundSize.x, boundSize.y);
        setFloatToUniform("kernelRadius", kernelRadius);
        setFloatToUniform("targetDensity", targetDensity);
        setFloatToUniform("pressureMutiplyer", pressureMutiplyer);
        setTexture("tex", texture, 0);
        setTexture("densityTex",densityTex,1);
    }
}
