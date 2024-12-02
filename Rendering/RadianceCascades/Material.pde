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
        shader.set("modelMatrix", gameobject.localToWorld().transposed().toPMatrix());
        shader.set("light_dir", main_light.light_dir.x, main_light.light_dir.y, main_light.light_dir.z);

        shader.set("ambient_light", AMBIENT_LIGHT.x, AMBIENT_LIGHT.y, AMBIENT_LIGHT.z);
        setVector3ToUniform("albedo", albedo.x, albedo.y, albedo.z);
        shader.set("light_color", main_light.light_color.x, main_light.light_color.y, main_light.light_color.z);
        shader.set("view_pos", main_camera.transform.position.x, main_camera.transform.position.y, main_camera.transform.position.z);

        if (texture!=null)shader.set("tex", texture.img);
    }
}

public class ScreenMaterial extends Material {
    
    Vector3 resolution = new Vector3(0,0,0);
    Vector3 brushPos = new Vector3(0,0,0);
    float brushRadius;
    Vector3 brushColour = new Vector3(0,0,0);
    
    Texture sdfTexture = new Texture(1,1);

    public ScreenMaterial(String frag) {
        super(frag);
    }
    public ScreenMaterial(String frag, String vert) {
        super(frag, vert);
    }

    public ScreenMaterial setBrushPos(float x, float y, float z) {
        brushPos.set(x, y, z);
        return this;
    }
    
    public ScreenMaterial setBrushRadius(float x) {
        brushRadius = x;
        return this;
    }
    
    public ScreenMaterial setBrushColour(float x, float y, float z) {
        brushColour.set(x, y, z);
        return this;
    }
    public ScreenMaterial setSDFTexture(Texture t) {
        sdfTexture = t;
        return this;
    }

    public void run(GameObject go) {
        setGameobject(go); 
        setVector2ToUniform("resolution", width,height);
        
        setVector2ToUniform("brushPos", brushPos.x, brushPos.y);
        setFloatToUniform("brushRadius", brushRadius);
        setVector3ToUniform("brushColour", brushColour.x, brushColour.y, brushColour.z);
        setTexture("sdfTexture" , sdfTexture , 0);
    }
}

public class CascadeMaterial extends Material {
    
    Vector3 sceneResolution = new Vector3(0,0,0); 
    Texture sdfTexture = new Texture(1,1);
    int cascadeLevel;
    int cascade0_Dims;
    float cascade0_Range;
    Vector3 cascadeResolution = new Vector3(0,0,0);

    public CascadeMaterial(String frag) {
        super(frag);
    }
    public CascadeMaterial(String frag, String vert) {
        super(frag, vert);
    }
    
    public CascadeMaterial setCascadeLevel(int i) {
        cascadeLevel = i;
        return this;
    }

    public CascadeMaterial setCascade0_Dims(int i) {
        cascade0_Dims = i;
        return this;
    }
    
    public CascadeMaterial setCascade0_Range(float f) {
        cascade0_Range = f;
        return this;
    }
    
    public CascadeMaterial setSDFTexture(Texture t) {
        sdfTexture = t;
        return this;
    }

    public void run(GameObject go) {
        setGameobject(go); 
        setVector2ToUniform("cascadeResolution", width,height);
        setVector2ToUniform("sceneResolution", width,height);
        setFloatToUniform("cascade0_Range", cascade0_Range);
        setIntToUniform("cascade0_Dims", cascade0_Dims);
        setIntToUniform("cascadeLevel", cascadeLevel);
        setTexture("sdfTexture" , sdfTexture , 0);
    }
}

public class MergeMaterial extends Material {
    
    Vector3 sceneResolution = new Vector3(0,0,0); 
    Texture nextCascadeMergedTexture = new Texture(1,1);
    Texture cascadeRealTexture = new Texture(1,1);
    int numCascadeLevels;
    int currentCascadeLevel;

    int cascade0_Dims;
    float cascade0_Range;
    Vector3 cascadeResolution = new Vector3(0,0,0);

    public MergeMaterial(String frag) {
        super(frag);
    }
    public MergeMaterial(String frag, String vert) {
        super(frag, vert);
    }
    

    public MergeMaterial setCascade0_Dims(int i) {
        cascade0_Dims = i;
        return this;
    }
    
    public MergeMaterial setCascade0_Range(float f) {
        cascade0_Range = f;
        return this;
    }
    
    public MergeMaterial setNextCascadeMergedTexture(Texture t) {
        nextCascadeMergedTexture = t;
        return this;
    }
    
    public MergeMaterial setCascadeRealTexture(Texture t) {
        cascadeRealTexture = t;
        return this;
    }
    
    public MergeMaterial setNumCascadeLevels(int i) {
        numCascadeLevels = i;
        return this;
    }
    
    public MergeMaterial setCurrentCascadeLevel(int i) {
        currentCascadeLevel = i;
        return this;
    }

    public void run(GameObject go) {
        setGameobject(go); 
        setVector2ToUniform("cascadeResolution", width,height);
        setVector2ToUniform("sceneResolution", width,height);
        setFloatToUniform("cascade0_Range", cascade0_Range);
        setIntToUniform("cascade0_Dims", cascade0_Dims);
        setTexture("nextCascadeMergedTexture" , nextCascadeMergedTexture , 0);
        setTexture("cascadeRealTexture" , cascadeRealTexture , 1);
        setIntToUniform("numCascadeLevels", numCascadeLevels);
        setIntToUniform("currentCascadeLevel", currentCascadeLevel);
    }
}

public class RadianceFieldMaterial extends Material {
    

    Texture mergedCascade0Texture = new Texture(1,1);


    int cascade0_Dims;
    float cascade0_Range;
    Vector3 cascadeResolution = new Vector3(0,0,0);

    public RadianceFieldMaterial(String frag) {
        super(frag);
    }
    public RadianceFieldMaterial(String frag, String vert) {
        super(frag, vert);
    }
    

    public RadianceFieldMaterial setCascade0_Dims(int i) {
        cascade0_Dims = i;
        return this;
    }
    
    public RadianceFieldMaterial setCascade0_Range(float f) {
        cascade0_Range = f;
        return this;
    }
    
    public RadianceFieldMaterial setMergedCascade0Texture(Texture t) {
        mergedCascade0Texture = t;
        return this;
    }



    public void run(GameObject go) {
        setGameobject(go); 
        setVector2ToUniform("cascadeResolution", width,height);
        setFloatToUniform("cascade0_Range", cascade0_Range);
        setIntToUniform("cascade0_Dims", cascade0_Dims);
        setTexture("mergedCascade0Texture" , mergedCascade0Texture , 0);

    }
}

public class FinalComposeMaterial extends Material {
    

    Texture radianceTexture = new Texture(1,1);
    Texture sceneTexture = new Texture(1,1);
    Texture sdfTexture = new Texture(1,1);

    Vector3 resolution = new Vector3(0,0,0);

    public FinalComposeMaterial(String frag) {
        super(frag);
    }
    public FinalComposeMaterial(String frag, String vert) {
        super(frag, vert);
    }
    


    
    public FinalComposeMaterial setRadianceTexture(Texture t) {
        radianceTexture = t;
        return this;
    }
    public FinalComposeMaterial setSceneTexture(Texture t) {
        sceneTexture = t;
        return this;
    }
    public FinalComposeMaterial setSDFTexture(Texture t) {
        sdfTexture = t;
        return this;
    }



    public void run(GameObject go) {
        setGameobject(go); 
        setVector2ToUniform("resolution", width,height);
        setTexture("radianceTexture" , radianceTexture , 0);
        setTexture("sceneTexture" , sceneTexture , 1);
        setTexture("sdfTexture" , sdfTexture , 2);

    }
}

public class CopySDFMaterial extends Material {
    
    Vector3 resolution = new Vector3(0,0,0);
    Vector3 brushPos1 = new Vector3(0,0,0);
    Vector3 brushPos2 = new Vector3(0,0,0);
    float brushRadius;
    Vector3 brushColour = new Vector3(0,0,0);
    
    Texture sdfSource = new Texture(1,1);


    public CopySDFMaterial(String frag) {
        super(frag);
    }
    public CopySDFMaterial(String frag, String vert) {
        super(frag, vert);
    }

     public CopySDFMaterial setBrushPos1(float x, float y, float z) {
        brushPos1.set(x, y, z);
        return this;
    }
    
    public CopySDFMaterial setBrushPos2(float x, float y, float z) {
        brushPos2.set(x, y, z);
        return this;
    }
    
    public CopySDFMaterial setBrushRadius(float x) {
        brushRadius = x;
        return this;
    }
    
    public CopySDFMaterial setBrushColour(float x, float y, float z) {
        brushColour.set(x, y, z);
        return this;
    }
    
    public CopySDFMaterial setSDFSource(Texture t) {
        sdfSource = t;
        return this;
    }



    public void run(GameObject go) {
        setGameobject(go); 
        setVector2ToUniform("resolution", width,height);
        setVector2ToUniform("brushPos1", brushPos1.x, brushPos1.y);
        setVector2ToUniform("brushPos2", brushPos2.x, brushPos2.y);
        setFloatToUniform("brushRadius", brushRadius);
        setVector3ToUniform("brushColour", brushColour.x, brushColour.y, brushColour.z);
        
        setTexture("sdfSource" , sdfSource , 0);
        
    }
}
public class QuadMaterial extends Material {

    Texture tex;

    public QuadMaterial(String frag) {
        super(frag);
    }
    public QuadMaterial(String frag, String vert) {
        super(frag, vert);
    }

    public QuadMaterial setFinalTexture(Texture t) {
        tex = t;
        return this;
    }
    



    public void run(GameObject go) {
        setGameobject(go); 
        setTexture("tex" , tex , 0);
    }
}

public class SDFMaterial extends Material {

    Texture tex;
    float size;

    public SDFMaterial(String frag) {
        super(frag);
    }
    public SDFMaterial(String frag, String vert) {
        super(frag, vert);
    }

    public SDFMaterial setTexture(Texture t) {
        tex = t;
        return this;
    }
    
    public SDFMaterial setsize(float t) {
        size = t;
        return this;
    }


    public void run(GameObject go) {
        setGameobject(go); 
        shader.set("size", size);
        shader.set("tex", tex.img);
    }
}


public class RayMarchingMaterial extends Material {

    Texture sdf_tex;
    Texture light_tex;

    public RayMarchingMaterial(String frag) {
        super(frag);
    }
    public RayMarchingMaterial(String frag, String vert) {
        super(frag, vert);
    }

    public RayMarchingMaterial setSDFTexture(Texture t) {
        sdf_tex = t;
        return this;
    }
    
    public RayMarchingMaterial setLightTexture(Texture t) {
        light_tex = t;
        return this;
    }



    public void run(GameObject go) {
        setGameobject(go); 
        shader.set("sdf_tex", sdf_tex.img);
        shader.set("light_tex", light_tex.img);
    }
}
