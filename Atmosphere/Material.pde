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

    public void setTexture(String name,Texture tex , int c){
        gl3.glActiveTexture(gl3.GL_TEXTURE0 + c);
        gl3.glBindTexture(gl3.GL_TEXTURE_2D, tex.tex.get(0));
        int textureLocation = gl3.glGetUniformLocation(shader.glProgram, name);
        gl3.glUniform1i(textureLocation, c);   
    }

    abstract void run(GameObject go);
}

public class OceanMaterial extends Material {
    Texture main_tex;
    Texture main_tex2;
    Texture waveA;
    Texture waveB;
    
    float depthMultiplier;
    float alphaMultiplier;
    
    float smoothness;
    float waveStrength;
    float waveScale;
    float waveSpeed;
    
    Vector3 colA = new Vector3();
    Vector3 colB = new Vector3();
    Vector3 specularCol = new Vector3();
    
    public OceanMaterial(String frag) {
        super(frag);
    }
    public OceanMaterial(String frag, String vert) {
        super(frag, vert);
    }
    public void run(GameObject go) {
        shader(shader);
        setGameobject(go);
        setTexture("main_tex", main_tex, 2);
        setTexture("depth_tex", main_tex2, 3);
        
        shader.set("waveA", waveA.img);
        shader.set("waveB", waveB.img);
        
        shader.set("radius", go.transform.scale.x);
        shader.set("depthMultiplier", depthMultiplier);
        shader.set("alphaMultiplier", alphaMultiplier);
        shader.set("smoothness", smoothness);
        shader.set("waveStrength", waveStrength);
        shader.set("waveScale", waveScale);
        shader.set("waveSpeed", waveSpeed);
        shader.set("time", time);
        
        shader.set("colA", colA.x, colA.y, colA.z);
        shader.set("colB", colB.x, colB.y, colB.z);
        shader.set("specularCol", specularCol.x, specularCol.y, specularCol.z);
        
        shader.set("invProject", main_camera.projection.Inverse().transposed().toPMatrix());
        shader.set("camToWorld", main_camera.worldView.Inverse().transposed().toPMatrix());
        
        shader.set("cam_pos", main_camera.transform.position.x, main_camera.transform.position.y, main_camera.transform.position.z);
        shader.set("light_dir", main_light.light_dir.x, main_light.light_dir.y, main_light.light_dir.z);

    }
    
    public OceanMaterial setdepthMultiplier(float f) {
        depthMultiplier = f;
        return this;
    }
    
    public OceanMaterial setalphaMultiplier(float f) {
        alphaMultiplier = f;
        return this;
    }
    public OceanMaterial setSmoothness(float f) {
        smoothness = f;
        return this;
    }
    public OceanMaterial setWaveStrength(float f) {
        waveStrength = f;
        return this;
    }
    public OceanMaterial setWaveScale(float f) {
        waveScale = f;
        return this;
    }
    public OceanMaterial setWaveSpeed(float f) {
        waveSpeed = f;
        return this;
    }
    
    public OceanMaterial setMainTexture(Texture t) {
        main_tex = t;
        return this;
    }
    
    public OceanMaterial setMainTexture2(Texture t) {
        main_tex2 = t;
        return this;
    }
    public OceanMaterial setWaveA(Texture t) {
        waveA = t;
        return this;
    }
    public OceanMaterial setWaveB(Texture t) {
        waveB = t;
        return this;
    }
    
    public OceanMaterial setColA(float x, float y, float z) {
        colA.set(x, y, z);
        return this;
    }
    public OceanMaterial setColB(float x, float y, float z) {
        colB.set(x, y, z);
        return this;
    }   
    
     public OceanMaterial setSpecularCol(float x, float y, float z) {
        specularCol.set(x, y, z);
        return this;
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
        shader(shader);
        setGameobject(go);

    }

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
        shader(shader);
        setGameobject(go);
        shader.set("MVP", gameobject.MVP().transposed().toPMatrix());
        shader.set("modelMatrix", gameobject.localToWorld().transposed().toPMatrix());
        shader.set("light_dir", main_light.light_dir.x, main_light.light_dir.y, main_light.light_dir.z);

        shader.set("ambient_light", AMBIENT_LIGHT.x, AMBIENT_LIGHT.y, AMBIENT_LIGHT.z);
        shader.set("albedo", albedo.x, albedo.y, albedo.z);
        shader.set("light_color", main_light.light_color.x, main_light.light_color.y, main_light.light_color.z);
        shader.set("view_pos", main_camera.transform.position.x, main_camera.transform.position.y, main_camera.transform.position.z);

        if (texture!=null)shader.set("tex", texture.img);
    }
}

public class EarthMaterial extends Material {
    Vector3 albedo = new Vector3(0.0);
    Vector3 heightMinMax = new Vector3(0.0, 1.0, 0.0);
    
    Vector3 shoreLow = new Vector3(0.0);
    Vector3 shoreHigh = new Vector3(0.0);
    Vector3 flatLowA = new Vector3(0.0);
    Vector3 flatHighA = new Vector3(0.0);
    Vector3 flatLowB = new Vector3(0.0);
    Vector3 flatHighB = new Vector3(0.0);
    
    Vector3 steepLow = new Vector3(0.0);
    Vector3 steepHigh = new Vector3(0.0);
    float maxFlatHeight;


    public EarthMaterial(String frag) {
        super(frag);
    }
    public EarthMaterial(String frag, String vert) {
        super(frag, vert);
    }

    public EarthMaterial setAlbedo(Vector3 v) {
        albedo = v;
        return this;
    }

    public EarthMaterial setAlbedo(float x, float y, float z) {
        albedo.set(x, y, z);
        return this;
    }
    public EarthMaterial setShoreLow(float x, float y, float z) {
        shoreLow.set(x, y, z);
        return this;
    }
    public EarthMaterial setShoreHigh(float x, float y, float z) {
        shoreHigh.set(x, y, z);
        return this;
    }
    public EarthMaterial setFlatLowA(float x, float y, float z) {
        flatLowA.set(x, y, z);
        return this;
    }
    public EarthMaterial setFlatHighA(float x, float y, float z) {
        flatHighA.set(x, y, z);
        return this;
    }
    public EarthMaterial setFlatLowB(float x, float y, float z) {
        flatLowB.set(x, y, z);
        return this;
    }
    public EarthMaterial setFlatHighB(float x, float y, float z) {
        flatHighB.set(x, y, z);
        return this;
    }
    public EarthMaterial setSteepLow(float x, float y, float z) {
        steepLow.set(x, y, z);
        return this;
    }
    public EarthMaterial setSteepHigh(float x, float y, float z) {
        steepHigh.set(x, y, z);
        return this;
    }
    
    public EarthMaterial setHeightMinMax(float x, float y, float z) {
        heightMinMax.set(x, y, z);
        return this;
    }
    
    public EarthMaterial setHeightMinMax(Vector3 v) {
        heightMinMax = v;
        return this;
    }
    public EarthMaterial setMaxFlatHeight(float f) {
        maxFlatHeight = f;
        return this;
    }

    public void run(GameObject go) {
        shader(shader);
        setGameobject(go);
        shader.set("MVP", gameobject.MVP().transposed().toPMatrix());
        shader.set("modelMatrix", gameobject.localToWorld().transposed().toPMatrix());
        shader.set("light_dir", main_light.light_dir.x, main_light.light_dir.y, main_light.light_dir.z);

        shader.set("ambient_light", AMBIENT_LIGHT.x, AMBIENT_LIGHT.y, AMBIENT_LIGHT.z);
        shader.set("albedo", albedo.x, albedo.y, albedo.z);
        shader.set("light_color", main_light.light_color.x, main_light.light_color.y, main_light.light_color.z);
        shader.set("view_pos", main_camera.transform.position.x, main_camera.transform.position.y, main_camera.transform.position.z);
        
        setHeightMinMax(((Icosahedron)gameobject).heightMinMax);
        shader.set("heightMinMax", heightMinMax.x, heightMinMax.y, heightMinMax.z);
        shader.set("maxFlatHeight", maxFlatHeight);
        
        shader.set("shoreLow", shoreLow.x, shoreLow.y, shoreLow.z);
        shader.set("shoreHigh", shoreHigh.x, shoreHigh.y, shoreHigh.z);
        shader.set("flatLowA", flatLowA.x, flatLowA.y, flatLowA.z);
        shader.set("flatHighA", flatHighA.x, flatHighA.y, flatHighA.z);
        shader.set("flatLowB", flatLowB.x, flatLowB.y, flatLowB.z);
        shader.set("flatHighB", flatHighB.x, flatHighB.y, flatHighB.z);
        shader.set("steepLow", steepLow.x, steepLow.y, steepLow.z);
        shader.set("steepHigh", steepHigh.x, steepHigh.y, steepHigh.z);
        
    }
}



public class MoonMaterial extends Material {
    Vector3 albedo = new Vector3(0.0);
    Texture texture;
    Texture normal_texture1;
    Texture normal_texture2;

    Vector3 primaryA = new Vector3(0.0);
    Vector3 primaryB = new Vector3(0.0);
    Vector3 secondaryA = new Vector3(0.0);
    Vector3 secondaryB = new Vector3(0.0);

    Vector3 heightMinMax = new Vector3(0.0, 1.0, 0.0);

    Vector4 randomBiomeValues = new Vector4(0.0);

    float normal_bias = 0.0;

    public MoonMaterial(String frag) {
        super(frag);
    }
    public MoonMaterial(String frag, String vert) {
        super(frag, vert);
    }

    public MoonMaterial setAlbedo(Vector3 v) {
        albedo = v;
        return this;
    }

    public MoonMaterial setAlbedo(float x, float y, float z) {
        albedo.set(x, y, z);
        return this;
    }

    public MoonMaterial setPrimaryA(float x, float y, float z) {
        primaryA.set(x, y, z);
        return this;
    }

    public MoonMaterial setPrimaryB(float x, float y, float z) {
        primaryB.set(x, y, z);
        return this;
    }

    public MoonMaterial setSecondaryA(float x, float y, float z) {
        secondaryA.set(x, y, z);
        return this;
    }

    public MoonMaterial setSecondaryB(float x, float y, float z) {
        secondaryB.set(x, y, z);
        return this;
    }

    public MoonMaterial setHeightMinMax(Vector3 v) {
        heightMinMax = v;
        return this;
    }

    public MoonMaterial setHeightMinMax(float x, float y, float z) {
        heightMinMax.set(x, y, z);
        return this;
    }

    public MoonMaterial setrandomBiomeValues(float x, float y, float z, float w) {
        randomBiomeValues.set(x, y, z, w);
        return this;
    }

    public MoonMaterial setTexture(Texture t) {
        texture = t;
        return this;
    }

    public MoonMaterial setNormalTexture1(Texture t) {
        normal_texture1 = t;
        return this;
    }

    public MoonMaterial setNormalTexture2(Texture t) {
        normal_texture2 = t;
        return this;
    }

    public MoonMaterial setNormalBias(float f) {
        normal_bias = f;
        return this;
    }


    public void run(GameObject go) {
        shader(shader);
        setGameobject(go);
        shader.set("MVP", gameobject.MVP().transposed().toPMatrix());
        shader.set("modelMatrix", gameobject.localToWorld().transposed().toPMatrix());
        shader.set("light_dir", main_light.light_dir.x, main_light.light_dir.y, main_light.light_dir.z);

        shader.set("ambient_light", AMBIENT_LIGHT.x, AMBIENT_LIGHT.y, AMBIENT_LIGHT.z);
        shader.set("albedo", albedo.x, albedo.y, albedo.z);
        shader.set("light_color", main_light.light_color.x, main_light.light_color.y, main_light.light_color.z);
        shader.set("view_pos", main_camera.transform.position.x, main_camera.transform.position.y, main_camera.transform.position.z);

        setHeightMinMax(((Icosahedron)gameobject).heightMinMax);

        shader.set("heightMinMax", heightMinMax.x, heightMinMax.y, heightMinMax.z);

        shader.set("secondaryA", secondaryA.x, secondaryA.y, secondaryA.z);
        shader.set("secondaryB", secondaryB.x, secondaryB.y, secondaryB.z);
        shader.set("primaryA", primaryA.x, primaryA.y, primaryA.z);
        shader.set("primaryB", primaryB.x, primaryB.y, primaryB.z);

        shader.set("normal_bias", normal_bias);

        shader.set("randomBiomeValues", randomBiomeValues.x, randomBiomeValues.y, randomBiomeValues.z, randomBiomeValues.w);

        if (texture != null) shader.set("main_tex", texture.img);
        if (normal_texture1 != null) shader.set("normal_tex1", normal_texture1.img);
        if (normal_texture2 != null) shader.set("normal_tex2", normal_texture2.img);
    }
}
