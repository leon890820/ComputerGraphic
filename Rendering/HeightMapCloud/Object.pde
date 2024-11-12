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


abstract class CloudObject extends GObject{
    float roughness = 0.5;
    float _Height = 0.5;
    float _HeightAmount = 0.5;
    Vector3 albedo = new Vector3(0.8, 0.8, 0.8);
       
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
            Vector3[] uvs = triangle.uvs;
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
                    Vector3 uv = calcInterpolation(coord,uvs);
                    uv = (uv.mult(5)).add(new Vector3(a,a,0));
                    Vector3 uv2 = calcInterpolation(coord,uvs);
                    Vector3 T = getTextureColor(texture.texture,uv2);
                    float h2 = T.x * _HeightAmount;
                    Vector3 col = new Vector3();
                    Vector3 normal = calcInterpolation(coord,worldNormal).xyz().unit_vector();
                    Vector3 L = calcInterpolation(coord,worldLightDir).unit_vector();
                    Vector3 V = calcInterpolation(coord,worldViewDir).unit_vector();
                    float NdotV = max(Vector3.dot(normal,V),0.0);
                    float NdotL = max(Vector3.dot(normal,L),0.0);
                    Vector3 H = L.add(V).unit_vector();
                    Vector3 radiance = light.light_color;
                    
                    Vector3 viewRay = V.mult(-1);
                    float tempy = viewRay.y;
                    viewRay.y = viewRay.z;
                    viewRay.z = tempy;
                    //viewRay.z = abs(viewRay.z)+0.2;
                    viewRay.x*=_Height;
                    viewRay.y*=_Height;
                    float linearStep = 16;
                    
                    Vector3 lioffset = viewRay.mult(1/(viewRay.z*linearStep));
                    float d = 1.0 - getTextureColor(texture.texture,uv).x*h2;
                    float prev_d = d;
                    Vector3 prev_shadeP = uv.copy();
                    while(d>uv.z){
                        prev_shadeP = uv.copy();
                        uv = uv.add(lioffset);
                        prev_d = d;
                        d = 1.0 - getTextureColor(texture.texture,uv).x*h2;
                    }
                    float d1 = d-uv.z;
                    float d2 = prev_d - prev_shadeP.z;
                    float w = d1/(d1-d2);
                    uv = lerp(uv,prev_shadeP,w);
                    Vector3 c = getTextureColor(texture.texture,uv).product(T);
                    
                    col = (c.add(light.light_color.mult(NdotL))).product(albedo);//pow(col,1.0/2.2);
                    col = pow(col,2.2);
                    
                    if (z<zBuffer[index]) {
                        zBuffer[index]=z;
                        colorBuffer[index]=color(col.x*255, col.y*255, col.z*255);
                    }
                }
            }
        }
    }
    
    
}
