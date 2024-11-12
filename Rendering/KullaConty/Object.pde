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


abstract class PBRObject extends GObject{
    float roughness = 0.5;
    Vector3 albedo = new Vector3(0.7216, 0.451, 0.2);
    
    public Vector3 schlichApproximate(Vector3 R0,Vector3 V,Vector3 H){
        float c = 1 - max(Vector3.dot(V,H),0);
        float c5 = pow(c,5);
        return R0.add( (R0.mult(-1).add(new Vector3(1))).mult(c5) );
    }
    
    public float GGX(Vector3 N,Vector3 H,float roughness){
        float alpha = roughness*roughness;
        float alpha2 = alpha*alpha;
        float NoH = max(Vector3.dot(N,H),0.0);
        float g = NoH*NoH*(alpha2-1.0)+1.0;
        float s = PI*g*g;
        return alpha2/max(s,0.0001);
    
    }
    
    public float GeometrySchlickGGX(float NoV,float roughness){
        float k = (roughness+1.0) * (roughness+1.0)/8.0;
        return NoV/(NoV*(1-k)+k);
    }
    
    public float GeometrySmith(Vector3 N,Vector3 V,Vector3 L,float roughness){
        float NoV = max(Vector3.dot(N,V),0.0);
        float NoL = max(Vector3.dot(N,L),0.0);
        return GeometrySchlickGGX(NoV,roughness)*GeometrySchlickGGX(NoL,roughness);
    }
    
    
    @Override
    public void Draw(){
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
                    Vector3 R0 = albedo;
                    Vector3 normal = calcInterpolation(coord,worldNormal).xyz().unit_vector();
                    Vector3 L = calcInterpolation(coord,worldLightDir).unit_vector();
                    Vector3 V = calcInterpolation(coord,worldViewDir).unit_vector();
                    float NdotV = max(Vector3.dot(normal,V),0.0);
                    float NdotL = max(Vector3.dot(normal,L),0.0);
                    Vector3 H = L.add(V).unit_vector();
                    Vector3 radiance = light.light_color;
                    float NDF = GGX(normal,H,roughness);
                    float G = GeometrySmith(normal,V,L,roughness);
                    
                    Vector3 F = schlichApproximate(R0,V,H);
                    
                    Vector3 numerator = F.mult(G*NDF);
                    float denominator = max(4.0*NdotV*NdotL,0.001);
                    Vector3 brdf = numerator.mult(1.0/denominator);
                    col = brdf.product(radiance).mult(NdotL);
                    //col = new Vector3(col.x/(col.x+1.0),col.y/(col.y+1.0),col.z/(col.z+1.0));
                    col = pow(col,1.0/2.2);
                    if (z<zBuffer[index]) {
                        zBuffer[index]=z;
                        colorBuffer[index]=color(col.x*255, col.y*255, col.z*255);
                    }
                }
            }
        }
    }
    
    
}
