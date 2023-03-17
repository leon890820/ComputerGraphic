public class Knot extends Object {

    public Knot() {
        mesh = new Mesh("buddha.obj");
    }

    @Override
        public void Draw() {
        Vector3 diffuse=new Vector3(0.66, 0.66, 0.66);
        Vector3 specular_color=new Vector3(1, 1, 1);
        for (int i=0; i<mesh.triangles.size(); i+=1) {
            Triangle triangle = mesh.triangles.get(i);
            Vector4[] worldNormal = new Vector4[3];
            Vector3[] worldViewDir = new Vector3[3];
            Vector3[] worldLightDir = new Vector3[3];
            Vector3[] worldPos = new Vector3[3];
            Vector4[] eye_homogenized_point = new Vector4[3];
            for (int j=0; j<worldNormal.length; j+=1) {
                worldNormal[j] = localToWorld().mult(triangle.normal[j].getVector4(0));
                worldViewDir[j] = main_cam.pos.sub(localToWorld().mult(triangle.verts[j].getVector4(1)).xyz());
                worldLightDir[j] = light.pos.sub(localToWorld().mult(triangle.verts[j].getVector4(1)).xyz());
                worldPos[j] = localToWorld().mult(triangle.verts[j].getVector4(1)).xyz();
                eye_homogenized_point[j] = main_cam.worldView.mult(localToWorld()).mult(triangle.verts[j].getVector4(1));
            }

            Vector4[] clipping_eye_point=eye_homogenized_point;//clippingLineByPlane(eye_homogenized_point,new Vector4(0,0,1,0.1));
            Vector4[] clipping_divided_position = new Vector4[clipping_eye_point.length];
            for (int j=0; j<clipping_divided_position.length; j+=1) {
                clipping_divided_position[j] = main_cam.projection.mult(clipping_eye_point[j]).homogenized().getVector4(clipping_eye_point[j].w);
            }

            Vector4[] projection_position = new Vector4[3];
            Vector3[] divided_position = new Vector3[3];
            for (int j=0; j<projection_position.length; j+=1) {
                projection_position[j] = main_cam.Matrix().mult(localToWorld()).mult(triangle.verts[j].getVector4(1));
                divided_position[j] = projection_position[j].homogenized();
            }



            Vector3[] prt_col = new Vector3[3];


            if (materialType == MaterialType.Diffuse) {
                float[][] prt_cof = new float[3][];
                for (int j=0; j<prt_cof.length; j+=1) {
                    prt_cof[j] = m_TransportSHCoeffs.get(triangle.triangle[j]).v;
                }
                for (int j=0; j<prt_col.length; j+=1) {
                    Vector3 c = new Vector3();
                    for (int k=0; k<prt_cof[j].length; k+=1) {
                        c = c.add(skybox.shCoeffs[k].mult(prt_cof[k][j]));
                    }
                    prt_col[j] = c.mult(rho);
                    //println(c);
                }
            } else {
                Matrix[] matrix_prt_cof = new Matrix[3];
                for (int j=0; j<matrix_prt_cof.length; j+=1) {
                    matrix_prt_cof[j] = matrix_TransportSHCoeffs.get(triangle.triangle[j]);
                }

                Vector3[][] Lo = new Vector3[3][matrix_prt_cof[0].c];
                for (int j=0; j<Lo.length; j+=1) {
                    for (int k=0; k<matrix_prt_cof[j].r; k+=1) {
                        Lo[j][k] = new Vector3();
                        Vector3 sum = new Vector3();
                        for (int l=0; l<matrix_prt_cof[j].c; l+=1) {
                            sum = sum.add(skybox.shCoeffs[l].mult(matrix_prt_cof[j].m[k][l]));
                        }
                        Lo[j][k] = sum;
                    }
                }
                for (int j=0; j<3; j+=1) {
                    prt_col[j] = new Vector3();
                    Vector3 N = worldNormal[j].xyz().unit_vector();
                    Vector3 V = worldViewDir[j].unit_vector();
                    Vector3 R = N.mult(2*Vector3.dot(N, V)).sub(V);
                    for (int l=0; l<skybox.SHOrder; l+=1) {
                        for (int m=-l; m<=l; m+=1) {
                            int index = l*(l+1)+m;                            
                            prt_col[j] = prt_col[j].add( Lo[j][index].mult(SphereHarmonic.EvalSH(l, m, R.mult(-1).unit_vector())));
                        }
                    }
                    
                    prt_col[j] = new Vector3(abs(prt_col[j].x),abs(prt_col[j].y),abs(prt_col[j].z));
                    prt_col[j] = prt_col[j].mult(rho);
                }
            }

            //Vector3 PN = Vector3.cross(divided_position[1].xyz().sub(divided_position[0].xyz()),divided_position[2].xyz().sub(divided_position[0].xyz())).unit_vector();
            //float d = Vector3.dot(divided_position[0].xyz(),PN);
            Vector3[] bounding_box=findBoundBox(clipping_divided_position);
            float minx=max(0, map(bounding_box[0].x, -1, 1, 0, width-1));
            float maxx=min(width-1, map(bounding_box[1].x, -1, 1, 0, width-1));
            float miny=max(0, map(bounding_box[0].y, -1, 1, 0, width-1));
            float maxy=min(width-1, map(bounding_box[1].y, -1, 1, 0, width-1));
            for (int y=int(miny); y<=maxy; y+=1) {
                for (int x=int(minx); x<=maxx; x+=1) {
                    int index=y*width+x;
                    float rx=map(x, 0, width-1, -1, 1);
                    float ry=map(y, 0, height-1, -1, 1);
                    if (!pnpoly(rx, ry, clipping_divided_position)) {
                        continue;
                    }
                    float[] coord=barycentric(new Vector3(rx, ry, 0), projection_position);
                    float z=calcInterpolation(barycentric(new Vector3(rx, ry, 0), divided_position), divided_position).z;  //(d - PN.x * rx - PN.y * ry) / PN.z;
                    Vector3 col = new Vector3();
                    Vector3 cc = calcInterpolation(coord, prt_col);
                    col = cc;
                    //Vector3 normal = calcInterpolation(coord, worldNormal).xyz().unit_vector();
                    //Vector3 view_dir = calcInterpolation(coord, worldViewDir).unit_vector();
                    //Vector3 light_dir = calcInterpolation(coord, worldLightDir).unit_vector();//light.light_dir.mult(-1).unit_vector();//
                    //Vector3 u=calcInterpolation(coord, triangle.uvs);
                    //Vector3 albedo=diffuse;
                    //if (texture!=null) {
                    //    albedo=getTextureColor(texture.texture, new Vector3(u.x, u.y, 0)).product(diffuse);
                    //}
                    //Vector3 ambient=AMBIENT_LIGHT.product(albedo);
                    //Vector3 dif = light.light_color.product(albedo).mult(max(0, Vector3.dot(light_dir.unit_vector(), normal)));
                    //Vector3 h=(light_dir.add(view_dir)).unit_vector();
                    //Vector3 specular = light.light_color.product(specular_color).mult(pow(max(0, Vector3.dot(normal, h)), 128));

                    //Vector3 sd = (dif.add(specular));
                    //col=ambient.add(sd);
                    if (z<zBuffer[index]) {
                        zBuffer[index]=z;
                        colorBuffer[index]=color(col.x*255, col.y*255, col.z*255);
                    }
                }
            }
        }
    }
}
