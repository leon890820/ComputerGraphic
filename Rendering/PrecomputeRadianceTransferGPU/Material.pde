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
    public void precomputeSphereHarmonicParameter(int shOrder,String[] par) {
        shParameter = new Vector3[shOrder*shOrder];
        String[] sx = par[0].split(" ");
        String[] sy = par[1].split(" ");
        String[] sz = par[2].split(" ");
        for(int i = 0; i < shParameter.length; i++){
            shParameter[i] = new Vector3(float(sx[i]),float(sy[i]),float(sz[i]));
        }
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
                    float delta_w = 4 * PI / (w * h * 6);//calcArea(x, h-y-1);

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
        String[] s = new String[]{"","",""};
        for(int i = 0; i < shParameter.length; i++){
            s[0] += shParameter[i].x + " ";
            s[1] += shParameter[i].y + " ";
            s[2] += shParameter[i].z + " ";
        }
        saveStrings("data/Textures/church/parameter.txt",s);
    }
}

public class PRTMaterial extends Material {
      
    
    ArrayList<float[]> light_transport_array = new ArrayList<float[]>();
    ArrayList<float[][]> light_transport_glossy_array = new ArrayList<float[][]>();
    
    public PRTMaterial(String frag) {
        super(frag);
        
    }
    public PRTMaterial(String frag, String vert) {
        super(frag, vert);
        
    }

    public void run() {
        //shader(shader);                                
        shader.set("MVP", gameobject.MVP().transposed().toPMatrix());

    }
    
    public float[] getColorArrayGlossy(){
        float[] result = new float[light_transport_glossy_array.size() * 3];
        Vector3[] skybox_cof = skyboxMaterial.shParameter;
        for(int i=0; i < light_transport_glossy_array.size(); i++){
            Vector3[] s = new Vector3[skybox_cof.length];
            for(int j = 0; j < s.length; j++){
                s[j] = dot(skybox_cof,light_transport_glossy_array.get(i)[j]);
                
            }
            
            Vector3 wo = (main_camera.pos.sub(gameobject.shape.triangles.get(int(i / 3)).verts[i % 3])).unit_vector();
            Vector3 N = gameobject.shape.triangles.get(int(i / 3)).verts[i % 3].unit_vector();
            Vector3 R = (N.mult(2*Vector3.dot(N, wo)).sub(wo)).unit_vector();
            
            Vector3 c = new Vector3(0.0);
            for(int l = 0; l < shCof;l++){
                for(int m = -l ; m <= l; m++){
                    int index = l * (l + 1) + m;
                    c = c.add(s[index].mult(SphereHarmonic.EvalSH(l,m,wo.mult(1))*1.2));
                }
            }
            result[3 * i + 0] = c.x;
            result[3 * i + 1] = c.y;
            result[3 * i + 2] = c.z;
            
        }
        
        return result;
    }
    
    public float[] getColorArray(){
        float[] result = new float[light_transport_array.size() * 3];
        Vector3[] skybox_cof = skyboxMaterial.shParameter;
        for(int i=0; i < light_transport_array.size(); i++){
            Vector3 s = dot(skybox_cof,light_transport_array.get(i));
            result[i * 3 + 0] = s.x;
            result[i * 3 + 1] = s.y;
            result[i * 3 + 2] = s.z;
        }
        return result;
    }
    
    public void preCalculateLightTransport(String[] light_trans){
        light_transport_array.clear();
        for(int i = 0; i < light_trans.length; i++){
            String[] ss = light_trans[i].split(" ");
            float[] ff = new float[ss.length];
            for(int j = 0; j < ss.length; j++){
                ff[j] = float(ss[j]);
            }
            light_transport_array.add(ff);            
        }
    }
    
    public void preCalculateLightTransportInter(String[] light_trans){
        light_transport_array.clear();
        for(int i = 0; i < light_trans.length; i++){
            String[] ss = light_trans[i].split(" ");
            float[] ff = new float[ss.length];
            for(int j = 0; j < ss.length; j++){
                ff[j] = float(ss[j]);
            }
            light_transport_array.add(ff);            
        }
    }
    public void preCalculateLightTransportGlossy(){
         for(int i = 0; i < gameobject.shape.triangles.size();i++){
            println("sample : " + (float)i/gameobject.shape.triangles.size());
            for(int j = 0; j < 3; j++){                     
                float[][] light_transport = new float[shCof * shCof][shCof * shCof];
                Vector3 normal = gameobject.shape.triangles.get(i).normal[j].unit_vector();
                Vector3 pos = gameobject.shape.triangles.get(i).verts[j];
                float di = 4 * PI / (float)sample_number;
               
                for(int s = 0; s < sample_number; s++){
                    Vector3 sample_ray = sampler.sample_rays[s];   
                    float ndoti = 0.0;
                    if(pt == PRTType.NONSHADOW) ndoti = max(0.0, Vector3.dot(sample_ray,normal));
                    else{
                        if(!((PRTObject)gameobject).intersection(pos,sample_ray)){
                            ndoti = max(0.0, Vector3.dot(sample_ray,normal));
                        }else ndoti = 0.0;
                    }
                    
                    
                    for(int l = 0; l < shCof;l++){
                        for(int m = -l ; m <= l; m++){
                            for(int ll = 0; ll < shCof;ll++){
                                for(int mm = -ll ; mm <= ll; mm++){
                                    int sh_lmindex = l * (l + 1) + m;
                                    int sh_llmmindex = ll * (ll + 1) + mm;
                                    float sh = ndoti * sampler.sample[s][sh_lmindex] * sampler.sample[s][sh_llmmindex] * di;
                                    light_transport[sh_lmindex][sh_llmmindex] += sh;
                                    
                                }
                            }                                                                               
                        }
                    }
                }
                
                light_transport_glossy_array.add(light_transport);   
                
            }                                   
        }
        println(light_transport_glossy_array.size());
    }
    public void preCalculateLightTransport(String name){
        
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
                    else{
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
        //saveLightTransport(name);
    }
    
    public float[] calcInterreflectionSH(Vector3 pos,Vector3 normal,int depth){        
        float[] cof = new float[shCof*shCof];
        if(depth < 0) return cof;
        for(int i = 0; i < sample_number; i++){
            Vector3 dir = sampler.sample_rays[i];
            HitRecord hit = new HitRecord();
            float H = Vector3.dot(dir.unit_vector(),normal.unit_vector());
            boolean inter = ((PRTObject)gameobject).intersection(pos,dir,hit);
            if(H > 0 && inter){
                Vector3 hit_pos = hit.pos;
                Vector3 hit_normal = hit.tri.normal[0].mult(hit.bary.x).add(hit.tri.normal[1].mult(hit.bary.y)).add(hit.tri.normal[2].mult(hit.bary.z));
                float[] in_cof = calcInterreflectionSH(hit_pos,hit_normal,depth - 1);
                for(int j=0;j<in_cof.length;j++){
                    float interSH = light_transport_array.get(hit.tri.idx * 3 + 0)[j] * hit.bary.x + 
                                    light_transport_array.get(hit.tri.idx * 3 + 1)[j] * hit.bary.y +
                                    light_transport_array.get(hit.tri.idx * 3 + 2)[j] * hit.bary.z   ;
                    cof[j] += (in_cof[i] + interSH) * H / sample_number;
                                    
                }
                
            }
        }
        
        return cof;
    }
    
    public void saveLightTransport(String name){
        String[] result = new String[light_transport_array.size()];
        for(int i = 0; i < result.length; i++){
            float[] fs = light_transport_array.get(i);
            String s = "";
            for(float f : fs){
                s += str(f) + " ";
            }
            result[i] = s;
        }
        saveStrings("data/" + name + ".prt",result);
    }
    
    public void saveLightTransportInter(String name){
        String[] result = new String[light_transport_array.size()];
        for(int i = 0; i < result.length; i++){
            float[] fs = light_transport_array.get(i);
            String s = "";
            for(float f : fs){
                s += str(f) + " ";
            }
            result[i] = s;
        }
        saveStrings("data/" + name + ".inter",result);
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
