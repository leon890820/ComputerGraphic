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

    abstract void run(GameObject go);
}

public class PhongMaterial extends Material {
    Vector3 albedo = new Vector3(0.0);
    Matrix4 light_MVP;
    Texture texture;
    Texture ligth_depth;


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
    public PhongMaterial setLightDepth(Texture t) {
        ligth_depth = t;
        return this;
    }


    public void run(GameObject go) {
        shader(shader);
        setGameobject(go);
        Camera light_cam = new Camera();
        light_cam.setPositionOrientation(main_light.getPosition(),main_light.getPosition().add(main_light.light_dir));
        light_cam.ortho(-10,10,-10,10,1,1000);    
        
        setMatrix4ToUniform("MVP", gameobject.MVP().transposed());
        setMatrix4ToUniform("uLightMV", light_cam.Matrix().transposed());
        setMatrix4ToUniform("modelMatrix", gameobject.localToWorld().transposed());
        setVector3ToUniform("light_dir", main_light.light_dir.x, main_light.light_dir.y, main_light.light_dir.z);
        setVector3ToUniform("ambient_light", AMBIENT_LIGHT.x, AMBIENT_LIGHT.y, AMBIENT_LIGHT.z);
        setVector3ToUniform("albedo", albedo.x, albedo.y, albedo.z);
        setVector3ToUniform("light_color", main_light.light_color.x, main_light.light_color.y, main_light.light_color.z);
        setVector3ToUniform("view_pos", main_camera.transform.position.x, main_camera.transform.position.y, main_camera.transform.position.z);

        if (texture!=null)shader.set("tex", texture.img);
        setTexture("light_depth_tex", ligth_depth, 1);
    }
}


public class SSRMaterial extends Material {
    Vector3 albedo = new Vector3(0.0);
    Matrix4 light_MVP;
    Texture kds;

    Texture depth;
    Texture normal;
    Texture worldPos;
    Texture shadow;
    
    Vector3 cam_position = new Vector3(0.0);

    public SSRMaterial(String frag) {
        super(frag);
    }
    public SSRMaterial(String frag, String vert) {
        super(frag, vert);
    }

    public SSRMaterial setAlbedo(Vector3 v) {
        albedo = v;
        return this;
    }

    public SSRMaterial setAlbedo(float x, float y, float z) {
        albedo.set(x, y, z);
        return this;
    }

    public SSRMaterial setKds(Texture t) {
        kds = t;
        return this;
    }

    public SSRMaterial setDepth(Texture t) {
        depth = t;
        return this;
    }
    public SSRMaterial setWorldPos(Texture t) {
        worldPos = t;
        return this;
    }
    
    public SSRMaterial setNormal(Texture t) {
        normal = t;
        return this;
    }
    public SSRMaterial setShadow(Texture t) {
        shadow = t;
        return this;
    }

    public SSRMaterial setLightMVP(Matrix4 m) {
        light_MVP = m;
        return this;
    }


    public void run(GameObject go) {

        setGameobject(go);
        setMatrix4ToUniform("MVP", gameobject.MVP().transposed());
        setMatrix4ToUniform("VP", main_camera.Matrix().transposed());
        setMatrix4ToUniform("modelMatrix", gameobject.localToWorld().transposed());
        setTexture("kds_tex", kds, 0);        
        setTexture("normal_tex", normal, 1);
        setTexture("depth_tex", depth, 2);
        setTexture("worldPos_tex", worldPos, 3);
        setTexture("shadow_tex", shadow, 4);
        shader.set("time",(float)frameCount / (float)1000);
        
        setVector3ToUniform("cam_position" , main_camera.transform.position.x , main_camera.transform.position.y , main_camera.transform.position.z);
        
    }    
}

public class ShadowMaterial extends Material{
    public ShadowMaterial(String frag){
         super(frag);
    }
    public ShadowMaterial(String frag,String vert){
         super(frag,vert);
    }
    
    public void run(GameObject go){
        setGameobject(go);
        Camera light_cam = new Camera();
        light_cam.setPositionOrientation(main_light.getPosition(),main_light.getPosition().add(main_light.light_dir));
        light_cam.ortho(-10,10,-10,10,1,1000);    
        setMatrix4ToUniform("MVP", (light_cam.Matrix().mult(gameobject.localToWorld())).transposed());
        
    }
}
