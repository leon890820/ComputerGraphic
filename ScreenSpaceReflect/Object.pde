abstract class GObject {
    public Vector3 pos;
    public Vector3 eular;
    public Vector3 scale;
    public float p_scale;
    public Mesh mesh;
    public Texture texture;
    

    GObject() {
        pos=new Vector3(0);
        eular=new Vector3(0);
        scale=new Vector3(1);
        p_scale=1;
    }
    void reset() {
        pos.setZero();
        eular.setZero();
        scale.setOnes();
        p_scale=1;
    }

    void setPos(Vector3 v) {
        pos = v;
    }

    void setEular(Vector3 v) {
        eular = v;
    }
    void setScale(Vector3 v) {
        scale = v;
    }


    abstract public void Draw();
    public void update() {
    };
    void debugDraw() {
    }



    Matrix4 localToWorld() {
        return Matrix4.Trans(pos).mult(Matrix4.RotY(eular.y)).mult(Matrix4.RotX(eular.x)).mult(Matrix4.RotZ(eular.z)).mult(Matrix4.Scale(scale));
    }
    Matrix4 worldToLocal() {
        return Matrix4.Scale(scale.mult(p_scale).inv()).mult(Matrix4.RotZ(-eular.z)).mult(Matrix4.RotX(-eular.x)).mult(Matrix4.RotY(-eular.y)).mult(Matrix4.Trans(pos.mult(-1)));
    }
    Vector3 forward() {
        return (Matrix4.RotZ(eular.z).mult(Matrix4.RotX(eular.y)).mult(Matrix4.RotY(eular.x)).zAxis()).mult(-1);
    }
}


abstract class SSRObject extends GObject{
    float[] shadowDepthBuffer;
     Matrix4 worldToLight;
    SSRObject(){
      shadowDepthBuffer = new float[width*height];
    }
    
    public float SimpleShadowMap(Vector3 posWorld,float bias){
        Vector3 posLight = worldToLight.mult(posWorld.getVector4(1)).homogenized();
        Vector3 shadowCoord = clamp(posLight.add(new Vector3(1)).mult(0.5),0.0,1.0);
        int x= int(map(shadowCoord.x,0,1,0,width-1));
        int y= int(map(shadowCoord.y,0,1,0,height-1));
        int index = (height - y - 1)*width+x; 
        float depthSM = shadowDepthBuffer[index];
        float depth = (posLight.z)*100;
        if(depthSM-depth+bias>0) return 1;
        else return 0;
    }
    
    public void pass1(){
        float[] passZBuffer = new float[width*height];
        for (int i=0; i<passZBuffer.length; i+=1) {
           passZBuffer[i]=1.0/0.0;        
        }
        for (int i=0; i<mesh.triangles.size(); i+=1) {
            Triangle triangle = mesh.triangles.get(i);
            Vector4[] projection_position = new Vector4[3];
            Vector3[] division_position = new Vector3[3];
            for(int j=0;j<division_position.length;j+=1){      
                projection_position[j] = engine.light_cam.Ortho().mult(localToWorld()).mult(triangle.verts[j].getVector4(1));
                division_position[j] = projection_position[j].homogenized();
            }
            
            Vector3[] bounding_box=findBoundBox(division_position);
            float minx=max(0, map(bounding_box[0].x, -1, 1, 0, width-1));
            float maxx=min(width-1, map(bounding_box[1].x, -1, 1, 0, width-1));
            float miny=max(0, map(bounding_box[0].y, -1, 1, 0, width-1));
            float maxy=min(width-1, map(bounding_box[1].y, -1, 1, 0, width-1));
            for (int y=int(miny); y<=maxy; y+=1) {
                for (int x=int(minx); x<=maxx; x+=1) {
                    int index=(height-y-1)*width+x;
                    float rx=map(x, 0, width-1, -1, 1);
                    float ry=map(y, 0, height-1, -1, 1);
                    if (!pnpoly(rx, ry, division_position)) {
                        continue;
                    }
                    float[] coord=barycentric(new Vector3(rx, ry, 0), projection_position);
                    float z=calcInterpolation(barycentric(new Vector3(rx, ry, 0), division_position), division_position).z;
                    float w = calcInterpolation(coord,projection_position).w;
                    if (z<passZBuffer[index]) {        
                        passZBuffer[index] = z;
                        shadowDepthBuffer[index]=z*100;
                    }
                }
            }
            
        }
    
    
    }
    
    Vector3[] kdBuffer = new Vector3[width*height];
    float[] depthBuffer = new float[width*height];
    Vector3[] normalBuffer = new Vector3[width*height];
    float[] simpleShadowBuffer = new float[width*height];
    Vector3[] worldPosBuffer = new Vector3[width*height];
    public void pass2(){
        float[] passZBuffer = new float[width*height];
        for (int i=0; i<passZBuffer.length; i+=1) {
           passZBuffer[i]=1.0/0.0;   
           kdBuffer[i] = new Vector3();
           depthBuffer[i] = 1.0/0.0;
        }
        
        for (int i=0; i<mesh.triangles.size(); i+=1) {
            Triangle triangle = mesh.triangles.get(i);            
            Vector3[] division_position = new Vector3[3];
            Vector3[] worldNormal = new Vector3[3];
            Vector3[] worldPos = new Vector3[3];
            Vector4[] eye_homogenized_point = new Vector4[3];
            Vector4[] projection_position = new Vector4[3];
            float[] depth = new float[3]; 
            worldToLight = engine.light_cam.Ortho();
            for(int j=0;j<division_position.length;j+=1){     
                worldPos[j] = localToWorld().mult(triangle.verts[j].getVector4(1)).xyz();
                worldNormal[j] = localToWorld().mult(triangle.normal[j].getVector4(0)).xyz().unit_vector();
                eye_homogenized_point[j] = main_cam.worldView.mult(localToWorld()).mult(triangle.verts[j].getVector4(1));
                projection_position[j] = main_cam.Matrix().mult(localToWorld()).mult(triangle.verts[j].getVector4(1));
                depth[j] = projection_position[j].w;
                division_position[j] = projection_position[j].homogenized();
            }
            Vector4[] clipping_eye_point=clippingLineByPlane(eye_homogenized_point,new Vector4(0,0,-1,0.1));
            Vector3[] clipping_projection_point=new Vector3[clipping_eye_point.length];
            for(int j=0;j<clipping_projection_point.length;j++){
                clipping_projection_point[j]=(main_cam.projection.mult(clipping_eye_point[j])).homogenized();
            }
            
            
            Vector3[] bounding_box=findBoundBox(clipping_projection_point);
            float minx=max(0, map(bounding_box[0].x, -1, 1, 0, width-1));
            float maxx=min(width-1, map(bounding_box[1].x, -1, 1, 0, width-1));
            float miny=max(0, map(bounding_box[0].y, -1, 1, 0, width-1));
            float maxy=min(width-1, map(bounding_box[1].y, -1, 1, 0, width-1));
            for (int y=int(miny); y<=maxy; y+=1) {
                for (int x=int(minx); x<=maxx; x+=1) {
                    int index=(height-y-1)*width+x;
                    float rx=map(x, 0, width-1, -1, 1);
                    float ry=map(y, 0, height-1, -1, 1);
                    if (!pnpoly(rx, ry, clipping_projection_point)) {
                        continue;
                    }
                    float[] coord=barycentric(new Vector3(rx, ry, 0), projection_position);
                    float z=calcInterpolation(barycentric(new Vector3(rx, ry, 0), division_position), division_position).z;
                    Vector3 albedo = new Vector3(0.6,0.6,0.6);
                    Vector3 u=calcInterpolation(coord, triangle.uvs);
                    Vector3 world_pos = calcInterpolation(coord,worldPos);
                    Vector3 world_normal = calcInterpolation(coord,worldNormal);
                    if (texture!=null) {                        
                        albedo=getTextureColor(texture.texture, new Vector3(u.x, u.y, 0));
                    }
                    if (z<passZBuffer[index]) {        
                        passZBuffer[index] = z;   
                        depthBuffer[index] =  calcInterpolation(coord,depth);
                        kdBuffer[index] = albedo;
                        simpleShadowBuffer[index] = SimpleShadowMap(world_pos,0.001);
                        worldPosBuffer[index] = world_pos;
                        normalBuffer[index] = world_normal;
                    }
                }
            }
    
        }
    
    }
    int SAMPLE_NUM = 2;
    
    public void pass3(){
        Vector3 diffuse=new Vector3(0.66, 0.66, 0.66);
        Vector3 specular_color=new Vector3(1, 1, 1);
        for (int i=0; i<mesh.triangles.size(); i+=1) {
            Triangle triangle = mesh.triangles.get(i);
            Vector4[] worldNormal = new Vector4[3];
            Vector3[] worldViewDir = new Vector3[3];
            Vector3[] worldLightDir = new Vector3[3];
            Vector3[] worldPos = new Vector3[3];
            Vector4[] eye_homogenized_point = new Vector4[3];
            Vector4[] projection_position = new Vector4[3];
            Vector3[] divided_position = new Vector3[3];
            for (int j=0; j<worldNormal.length; j+=1) {
                worldNormal[j] = localToWorld().mult(triangle.normal[j].getVector4(0));
                worldViewDir[j] = main_cam.pos.sub(localToWorld().mult(triangle.verts[j].getVector4(1)).xyz());
                worldLightDir[j] = light.pos.sub(localToWorld().mult(triangle.verts[j].getVector4(1)).xyz());
                worldPos[j] = localToWorld().mult(triangle.verts[j].getVector4(1)).xyz();
                eye_homogenized_point[j] = main_cam.worldView.mult(localToWorld()).mult(triangle.verts[j].getVector4(1));
                projection_position[j] = main_cam.Matrix().mult(localToWorld()).mult(triangle.verts[j].getVector4(1));
                divided_position[j] = projection_position[j].homogenized();
            }

            Vector4[] clipping_eye_point=clippingLineByPlane(eye_homogenized_point,new Vector4(0,0,-1,0.1));
            Vector3[] clipping_projection_point=new Vector3[clipping_eye_point.length];
            for(int j=0;j<clipping_projection_point.length;j++){
                clipping_projection_point[j]=(main_cam.projection.mult(clipping_eye_point[j])).homogenized();
            }

            Vector3[] bounding_box=findBoundBox(clipping_projection_point);
            float minx=max(0, map(bounding_box[0].x, -1, 1, 0, width-1));
            float maxx=min(width-1, map(bounding_box[1].x, -1, 1, 0, width-1));
            float miny=max(0, map(bounding_box[0].y, -1, 1, 0, width-1));
            float maxy=min(width-1, map(bounding_box[1].y, -1, 1, 0, width-1));
            for (int y=int(miny); y<=maxy; y+=1) {
                for (int x=int(minx); x<=maxx; x+=1) {
                    int index=(height-y-1)*width+x;
                    float rx=map(x, 0, width-1, -1, 1);
                    float ry=map(y, 0, height-1, -1, 1);
                    if (!pnpoly(rx, ry, clipping_projection_point)) {
                        continue;
                    }
                    float[] coord=barycentric(new Vector3(rx, ry, 0), projection_position);
                    float z=calcInterpolation(barycentric(new Vector3(rx, ry, 0), divided_position), divided_position).z;  //(d - PN.x * rx - PN.y * ry) / PN.z;
                    Vector3 col = new Vector3();
                    Vector3 world_pos = calcInterpolation(coord, worldPos);
                    Vector3 view_dir = calcInterpolation(coord, worldViewDir).unit_vector();
                    Vector3 light_dir = calcInterpolation(coord, worldLightDir).unit_vector();//light.light_dir.mult(-1).unit_vector();//
                    
                   
                    
                    col= evalDiffuse(light_dir,view_dir,index).product(evalDirectionLight(index));//(kdBuffer[index].add(evalReflect(light_dir,view_dir,world_pos,index))).mult(0.5);
                    //col = (col.add(new Vector3(1))).mult(0.5);
                    
                    Vector3 L_ind = new Vector3();
                    //for(int sam = 0;sam<SAMPLE_NUM;sam+=1){
                    //    Object[] localDir = SampleHemisphereCos();
                    //    Vector3 ld = (Vector3)localDir[0];
                    //    float pdf = (float)localDir[1];
                    //    Vector3 n = normalBuffer[index];
                    //    Vector3[] b = LocalBasis(n);
                        
                    //    Vector3 dir = new Matrix4(b[0],b[1],n).mult(ld.getVector4(0)).xyz();//reflect(view_dir.mult(-1),n);//new Matrix4(b[0],b[1],n).mult(ld.getVector4(0)).xyz();

                    //    RayRecord rr = rayMarch(world_pos,dir);
                    //    if(rr.hit){
                    //        Vector3 hp = main_cam.Matrix().mult(rr.hit_point.getVector4(1)).homogenized();
                    //        int hpindex = getIndex(hp);
                    //        Vector3 dd = evalDiffuse(dir,view_dir,index).mult(1/pdf).product(evalDiffuse(light_dir,dir.mult(-1),hpindex)).product(evalDirectionLight(hpindex));
                            
                    //        L_ind = L_ind.add(dd);
                    //    }
                    //}

                    //L_ind = L_ind.mult(1/(float)SAMPLE_NUM);
                    
                    //col = col.add(L_ind);
                    col =pow( clamp(col,0,1),1);
                    if (z<zBuffer[index]) {
                        zBuffer[index]=z;
                        colorBuffer[index]=color(col.x*255, col.y*255, col.z*255);
                    }
                }
            }
        }
    }
    
    Object[] SampleHemisphereCos(){
        float s = random(1);
        Vector3 uv = new Vector3(random(1),random(1),0);
        
        float z = uv.x;
        float phi = uv.y * TWO_PI;
        float sinTheta = sqrt(1.0 - z*z);
        Vector3 dir = new Vector3(sinTheta * cos(phi), sinTheta * sin(phi), z);
        float pdf = INV_TWO_PI;       
        return new Object[]{dir,pdf};
    }
    
    public Vector3 evalDiffuse(Vector3 wi,Vector3 wo,int index){        
        Vector3 n = normalBuffer[index].unit_vector();
        float cos = clamp (Vector3.dot(wo,n),0.0,1.0);
        Vector3 fr = kdBuffer[index];
        return fr.mult(cos);
    }
    
    public Vector3 evalDirectionLight(int index){
        Vector3 Le = new Vector3(1,1,1).mult(simpleShadowBuffer[index]);
        return Le;
    }
    
    public Vector3 evalReflect(Vector3 wi,Vector3 wo,Vector3 pos,int index){
        Vector3 n = normalBuffer[index];
        Vector3 r = reflect(wo.mult(-1),n).unit_vector();
        RayRecord rr = rayMarch(pos,r);
        if(rr.hit){
            Vector3 hp = main_cam.Matrix().mult(rr.hit_point.getVector4(1)).homogenized();            
            return kdBuffer[getIndex(hp)];
        }
        return new Vector3(0);
    }
    
    public RayRecord rayMarch(Vector3 o,Vector3 d){
        RayRecord result = new RayRecord();
        float step = 0.05;
        int total_step = 150;
        Vector3 curpos = o.copy();
        Vector3 step_dir = d.unit_vector().mult(step);
        for(int i=0;i<total_step;i+=1){
            Vector3 screen_pos = main_cam.Matrix().mult(curpos.getVector4(1)).homogenized();
            int index = getIndex(screen_pos);
            float rayDepth = main_cam.Matrix().mult(curpos.getVector4(1)).w;
            float gBufferDepth  = depthBuffer[index];
            if(rayDepth - gBufferDepth > 0.01){
                result.hit_point = curpos;
                result.hit = true;
                return result;
            }
            curpos = curpos.add(step_dir);
        }
        return result;
    }
    
    
    
    class RayRecord{
        boolean hit = false;
        Vector3 hit_point;
    }
    
    @Override
    public void Draw(){
        pass1();
        pass2();
        pass3();
    }
    
    
}
