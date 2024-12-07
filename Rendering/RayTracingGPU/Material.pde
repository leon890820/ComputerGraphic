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


public class QuadMaterial extends Material {

    Texture tex = new Texture(1,1);

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

public class RayTracingMaterial extends Material {

    Texture lastFrame = new Texture(1,1);
    Vector3 camPos = new Vector3(0,0,0);
    Texture earth = new Texture(1,1);
    boolean dark = false;

    public RayTracingMaterial(String frag) {
        super(frag);
    }
    public RayTracingMaterial(String frag, String vert) {
        super(frag, vert);
    }

    public RayTracingMaterial setLastFrame(Texture t) {
        lastFrame = t;
        return this;
    }
    
    public RayTracingMaterial setEarth(Texture t) {
        earth = t;
        return this;
    }
    public RayTracingMaterial setCamPos(float x, float y, float z) {
        camPos.set(x,y,z);
        return this;
    }
    
    public RayTracingMaterial setCamPos(Vector3 v) {
        camPos.set(v.x, v.y, v.z);
        return this;
    }
    public RayTracingMaterial setDark(boolean b) {
        dark = b;
        return this;
    }


    public void run(GameObject go) {
        setGameobject(go); 
        shader.set("earth", earth.img);
        setTexture("lastFrame", lastFrame ,1);       
        setMatrix4ToUniform("invProject", main_camera.projection.Inverse().transposed());
        setMatrix4ToUniform("camToWorld", main_camera.worldView.Inverse().transposed());
        setVector3ToUniform("camPos" , camPos.x , camPos.y , camPos.z);
        setVector2ToUniform("resolution", width, height);
        setFloatToUniform("rbias" , count);
        setIntToUniform("dark" , dark ? 1 : 0);
    }
}
