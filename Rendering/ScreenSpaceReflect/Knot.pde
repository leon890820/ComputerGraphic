public class Cube1 extends SSRObject {

    public Cube1() {
        mesh = new Mesh("cave/cave.obj");
        texture = new Texture("cave/cave.jpg");
    }
   
}

public class Cube extends SSRObject {

    public Cube() {
        mesh = new Mesh("cube.obj");
        //texture = new Texture("cube/checker.png");
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
                    Vector3 normal = calcInterpolation(coord, worldNormal).xyz().unit_vector();
                    Vector3 view_dir = calcInterpolation(coord, worldViewDir).unit_vector();
                    Vector3 light_dir = calcInterpolation(coord, worldLightDir).unit_vector();//light.light_dir.mult(-1).unit_vector();//
                    Vector3 u=calcInterpolation(coord, triangle.uvs);
                    Vector3 albedo=diffuse;
                    if (texture!=null) {
                        //println(u);
                        albedo=getTextureColor(texture.texture, new Vector3(u.x, u.y, 0));//.product(diffuse);
                    }
                    Vector3 ambient=AMBIENT_LIGHT.product(albedo);
                    Vector3 dif = light.light_color.product(albedo).mult(max(0, Vector3.dot(light_dir.unit_vector(), normal)));
                    Vector3 h=(light_dir.add(view_dir)).unit_vector();
                    Vector3 specular = new Vector3();//light.light_color.product(specular_color).mult(pow(max(0, Vector3.dot(normal, h)), 128));

                    Vector3 sd = (dif.add(specular));
                    col=ambient;//.add(sd);
                    col =pow( clamp(col,0,1),1);
                    if (z<zBuffer[index]) {
                        zBuffer[index]=z;
                        colorBuffer[index]=color(col.x*255, col.y*255, col.z*255);
                    }
                }
            }
        }
   }
}
