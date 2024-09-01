public abstract class Material {
    PShader shader;
    GameObject gameobject;
    public Material(String frag) {
        shader = loadShader(frag);
    }

    public Material(String frag, String vert) {
        shader = loadShader(frag, vert);
    }

    public void setGameobject(GameObject g) {
        gameobject = g;
    }



    abstract void run();
}

public class BoundingBoxMaterial extends Material{
    
    Vector3 albedo = new Vector3();
    boolean hit;
    
    public BoundingBoxMaterial(String frag) {
        super(frag);
    }
    public BoundingBoxMaterial(String frag, String vert) {
        super(frag, vert);
    }
    
    public BoundingBoxMaterial setAlbedo(float x,float y,float z){
        albedo.set(x,y,z);
        return this;
    }
    
    @Override 
    public void run(){
        shader(shader);
        shader.set("MVP", gameobject.MVP().transposed().toPMatrix());
        shader.set("albedo",albedo.x,albedo.y,albedo.z);
        shader.set("hit", hit ? 1 : 0);
    }
}

public class Skybox extends Material {

    Texture[] skycube = new Texture[6];
    Vector3[] shParameter ; 
    
    public Skybox(String frag) {
        super(frag);
    }
    public Skybox(String frag, String vert) {
        super(frag, vert);
    }

    public Skybox setSkycube(String s) {
        String[] name = {"posx", "negx", "posy", "negy", "posz", "negz"};
        for (int i = 0; i < name.length; i++) {
            skycube[i] = new Texture(s + "/" + name[i] + ".jpg");
        }
        return this;
    }

    public void run() {
        shader(shader);

        
        shader.set("MV", main_camera.worldView.toPMatrix());
        shader.set("z", 1.0 / (2 * tan(GH_FOV*PI/180)));
        shader.set("skycube1", skycube[0].img);
        shader.set("skycube2", skycube[1].img);
        shader.set("skycube3", skycube[2].img);
        shader.set("skycube4", skycube[3].img);
        shader.set("skycube5", skycube[4].img);
        shader.set("skycube6", skycube[5].img);
    }

    public void precomputeSphereHarmonicParameter(int shOrder) {
        shParameter = new Vector3[shOrder*shOrder];
        float w = skycube[0].img.width;
        float h = skycube[0].img.height;
        for (int i=0; i<shParameter.length; i+=1) {
            shParameter[i] = new Vector3();
        }

        Vector3[][] cubemapFaceDirections= {
            {new Vector3(0, 0, 1), new Vector3(0, -1, 0), new Vector3(1, 0, 0) }, // posx
            {new Vector3(0, 0, 1), new Vector3(0, -1, 0), new Vector3(-1, 0, 0) }, // negx
            {new Vector3(1, 0, 0), new Vector3(0, 0, 1), new Vector3(0, 1, 0) }, // posy
            {new Vector3(1, 0, 0), new Vector3(0, 0, -1), new Vector3(0, -1, 0) }, // negy
            {new Vector3(1, 0, 0), new Vector3(0, -1, 0), new Vector3(0, 0, 1) }, // posz
            {new Vector3(-1, 0, 0), new Vector3(0, -1, 0), new Vector3(0, 0, -1) }   // negz

        };

        for (int i = 0; i < skycube.length; i++) {
            Vector3 faceDirX = cubemapFaceDirections[i][0];
            Vector3 faceDirY = cubemapFaceDirections[i][1];
            Vector3 faceDirZ = cubemapFaceDirections[i][2];
            for (int y = 0; y < h; y+=1) {
                println((float)(i*h+y)/(float)(6*h)*100+"%");
                for (int x = 0; x < w; x+=1) {
                    float u = map(x, 0, w-1, -1, 1);
                    float v = map(y, 0, h-1, 1, -1);
                    Vector3 dir = (faceDirX.mult(u).add(faceDirY.mult(v)).add(faceDirZ));//.unit_vector();
                    dir = uniformCube(dir);
                    int index = ((int)h-y-1) *(int)w + x;
                    Vector3 Le = colorToVector3(skycube[i].img.pixels[index]);
                    float delta_w = 2 * PI / (w * h * 6);//calcArea(x, h-y-1);

                    for (int l=0; l<shOrder; l+=1) {
                        for (int m=-l; m<=l; m+=1) {
                            float cof = SphereHarmonic.EvalSH(l, m, dir.unit_vector());
                            int sh_index = l*(l+1)+m;
                            shParameter[sh_index] = shParameter[sh_index].add(Le.mult(cof*delta_w));
                        }
                    }
                }
            }
        }

    }
}

public class PRTMaterial extends Material {
      
    
    ArrayList<float[]> light_transport_array = new ArrayList<float[]>();
    
    
    public PRTMaterial(String frag) {
        super(frag);
        
    }
    public PRTMaterial(String frag, String vert) {
        super(frag, vert);
        
    }

    public void run() {
        //shader(shader);
        Vector3[] skym = skyboxMaterial.shParameter;
        Matrix4 scr = new Matrix4(skym[0].x,  skym[1].x,  skym[2].x,  skym[3].x,
                                  skym[4].x,  skym[5].x,  skym[6].x,  skym[7].x,
                                  skym[8].x,  skym[9].x,  skym[10].x, skym[11].x,
                                  skym[12].x, skym[13].x, skym[14].x, skym[15].x);
                                  
        Matrix4 scg = new Matrix4(skym[0].y,  skym[1].y,  skym[2].y,  skym[3].y,
                                  skym[4].y,  skym[5].y,  skym[6].y,  skym[7].y,
                                  skym[8].y,  skym[9].y,  skym[10].y, skym[11].y,
                                  skym[12].y, skym[13].y, skym[14].y, skym[15].y);
                                  
        Matrix4 scb = new Matrix4(skym[0].z,  skym[1].z,  skym[2].z,  skym[3].z,
                                  skym[4].z,  skym[5].z,  skym[6].z,  skym[7].z,
                                  skym[8].z,  skym[9].z,  skym[10].z, skym[11].z,
                                  skym[12].z, skym[13].z, skym[14].z, skym[15].z);
                                
        shader.set("MVP", gameobject.MVP().transposed().toPMatrix());
        shader.set("shCofr", scr.toPMatrix());
        shader.set("shCofg", scg.toPMatrix());
        shader.set("shCofb", scb.toPMatrix());
    }
    
    public float[] getLightTransportArray(){
        float[] result = new float[light_transport_array.size() * 16];
        for(int i=0; i < light_transport_array.size(); i++){
            float[] f = light_transport_array.get(i);
            for(int j = 0; j < 16; j++){
                int index = i * 16 + j;
                result[index] = f[j];
            }
        }
                
        return result;
    }
    
    public void preCalculateLightTransport(){
        
        for(int i = 0; i < gameobject.shape.triangles.size();i++){
             println("sample : " + (float)i/gameobject.shape.triangles.size());
            for(int j = 0; j < 3; j++){      
               
                float[] light_transport = new float[shCof * shCof];
                Vector3 normal = gameobject.shape.triangles.get(i).normal[j];
                Vector3 pos = gameobject.shape.triangles.get(i).verts[j];
                float di = 4 * PI / sample_number;
                for(int s = 0; s < sample_number; s++){
                    Vector3 sample_ray = sampler.sample_rays[s];                    
                    float ndoti = 0.0;
                    if(pt == PRTType.NONSHADOW) ndoti = max(0.0, Vector3.dot(sample_ray,normal));
                    else if(pt == PRTType.SHADOW){
                        if(!((PRTObject)gameobject).intersection(pos,sample_ray)){
                            ndoti = max(0.0, Vector3.dot(sample_ray,normal));
                        }else ndoti = 0.0;
                    }
                    
                    
                    for(int l = 0; l < shCof;l++){
                        for(int m = -l ; m <= l; m++){
                            int sh_index = l * (l + 1) + m;
                            float sh = ndoti * sampler.sample[s][sh_index] * di * INV_PI;
                            light_transport[sh_index] += sh;
                        }
                    }
                }
                light_transport_array.add(light_transport);                
            }                                   
        }
          
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


    public void run() {
        //shader(shader);
        shader.set("MVP", gameobject.MVP().transposed().toPMatrix());

        shader.set("modelMatrix", gameobject.localToWorld().transposed().toPMatrix());
        shader.set("light_dir", main_light.light_dir.x, main_light.light_dir.y, main_light.light_dir.z);

        shader.set("ambient_light", AMBIENT_LIGHT.x, AMBIENT_LIGHT.y, AMBIENT_LIGHT.z);
        shader.set("albedo", albedo.x, albedo.y, albedo.z);
        shader.set("light_color", main_light.light_color.x, main_light.light_color.y, main_light.light_color.z);
        shader.set("view_pos", main_camera.pos.x, main_camera.pos.y, main_camera.pos.z);

        if (texture!=null) shader.set("tex", texture.img);
    }
}
