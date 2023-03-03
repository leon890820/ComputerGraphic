class ShadowMapObject extends Object{
  int PCFn = 7;
  ShadowMapObject(String s){
    super();
    mesh = new Mesh(s);
  }
  
  @Override
  public void Draw(){
    Pass1();
    Pass2();
  }
  
  @Override
  public void Pass1(){
    Camera light_cam = engine.light_cam;
    for(int i=0;i<mesh.triangles.size();i+=1){
       Triangle triangle = mesh.triangles.get(i);
                     
       Vector4[] projection_position = new Vector4[3];
       for(int j=0;j<projection_position.length;j+=1){
         projection_position[j] = light_cam.Matrix().mult(localToWorld()).mult(triangle.verts[j].getVector4(1));
       }
       
       Vector4[] divided_position = new Vector4[3];
       for(int j=0;j<projection_position.length;j+=1){
         divided_position[j] = projection_position[j].homogenized().getVector4(projection_position[j].w);
       }
       Vector3[] bounding_box=findBoundBox(divided_position);
       float minx=max(0, map(bounding_box[0].x,-1,1,0,width-1));
       float maxx=min(width-1, map(bounding_box[1].x,-1,1,0,width-1));
       float miny=max(0, map(bounding_box[0].y,-1,1,0,width-1));
       float maxy=min(width-1, map(bounding_box[1].y,-1,1,0,width-1));
       
       for(int y=int(miny);y<=maxy;y+=1){
          for(int x=int(minx);x<=maxx;x+=1){          
            int index=y*width+x;
            float rx=map(x,0,width-1,-1,1);
            float ry=map(y,0,height-1,-1,1);
            if (!pnpoly(rx, ry,divided_position)) {
              continue;
            }
            float[] coord=barycentric(new Vector3(rx,ry,0),projection_position);
            float z=calcInterpolation(coord,divided_position).z;
            if(z<shadowDepthBuffer[index]){
              shadowDepthBuffer[index]=z;                         
            }
          }
       }
       
    }
  
  }
  
  @Override
  public void Pass2(){
    Vector3 diffuse=new Vector3(0.66,0.66,0.66);
    Vector3 specular_color=new Vector3(1,1,1);
    Camera light_cam = engine.light_cam;
    for(int i=0;i<mesh.triangles.size();i+=1){
       Triangle triangle = mesh.triangles.get(i);
       Vector4[] worldNormal = new Vector4[3];
       for(int j=0;j<worldNormal.length;j+=1){
         worldNormal[j] = localToWorld().mult(triangle.normal[j].getVector4(0));
       }
       Vector3[] worldViewDir = new Vector3[3];
       for(int j=0;j<worldViewDir.length;j+=1){
         worldViewDir[j] = main_cam.pos.sub(localToWorld().mult(triangle.verts[j].getVector4(1)).xyz());
       }
       Vector3[] worldLightDir = new Vector3[3];
       for(int j=0;j<worldLightDir.length;j+=1){
         worldLightDir[j] = light.pos.sub(localToWorld().mult(triangle.verts[j].getVector4(1)).xyz());
       }
       Vector3[] worldPos = new Vector3[3];
       for(int j=0;j<worldPos.length;j+=1){
         worldPos[j] = localToWorld().mult(triangle.verts[j].getVector4(1)).xyz();
       }
       Vector4[] eye_homogenized_point = new Vector4[3];
       for(int j=0;j<eye_homogenized_point.length;j+=1){
         eye_homogenized_point[j] = main_cam.worldView.mult(localToWorld()).mult(triangle.verts[j].getVector4(1));    
         
       }
       Vector4[] clipping_eye_point=eye_homogenized_point;//clippingLineByPlane(eye_homogenized_point,new Vector4(0,0,1,0.1));
       Vector4[] clipping_divided_position = new Vector4[clipping_eye_point.length];
       for(int j=0;j<clipping_divided_position.length;j+=1){
         clipping_divided_position[j] = main_cam.projection.mult(clipping_eye_point[j]).homogenized().getVector4(clipping_eye_point[j].w);
         
       }
       
       Vector4[] projection_position = new Vector4[3];
       for(int j=0;j<projection_position.length;j+=1){
         projection_position[j] = main_cam.Matrix().mult(localToWorld()).mult(triangle.verts[j].getVector4(1));         
       }
       //println(main_cam.projection);
       //println(main_cam.Matrix().mult(new Vector3(0,0,-100).getVector4(1)).homogenized());
       Vector3[] divided_position = new Vector3[3];
       for(int j=0;j<projection_position.length;j+=1){
         divided_position[j] = projection_position[j].homogenized();
         
       }
       //Vector3 PN = Vector3.cross(divided_position[1].xyz().sub(divided_position[0].xyz()),divided_position[2].xyz().sub(divided_position[0].xyz())).unit_vector();
       //float d = Vector3.dot(divided_position[0].xyz(),PN);
       Vector3[] bounding_box=findBoundBox(clipping_divided_position);
       float minx=max(0, map(bounding_box[0].x,-1,1,0,width-1));
       float maxx=min(width-1, map(bounding_box[1].x,-1,1,0,width-1));
       float miny=max(0, map(bounding_box[0].y,-1,1,0,width-1));
       float maxy=min(width-1, map(bounding_box[1].y,-1,1,0,width-1));
       
        for(int y=int(miny);y<=maxy;y+=1){
          for(int x=int(minx);x<=maxx;x+=1){          
            int index=y*width+x;
            float rx=map(x,0,width-1,-1,1);
            float ry=map(y,0,height-1,-1,1);
            if (!pnpoly(rx, ry,clipping_divided_position)) {
              continue;
            }
            float[] coord=barycentric(new Vector3(rx,ry,0),projection_position);
            float z=calcInterpolation(barycentric(new Vector3(rx,ry,0),divided_position),divided_position).z;  //(d - PN.x * rx - PN.y * ry) / PN.z;            
            Vector3 pos = calcInterpolation(coord,worldPos);
            Vector3 light_divided_pos = (light_cam.Matrix().mult(pos.getVector4(1))).homogenized();
            int smx = int(map(light_divided_pos.x,-1,1,0,width-1));
            int smy = int(map(light_divided_pos.y,-1,1,0,height-1));    
            int sum = 0;
            int count = 0;
            if(!outOfMap(smx,smy)){ 
              for(int s=-3;s<=3;s+=1){
                for(int t=-3;t<=3;t+=1){
                  if(outOfMap(smx+s,smy+t)) continue;
                   count+=1;
                   if(abs(shadowDepthBuffer[(smy+t)*width+(smx+s)]-light_divided_pos.z)<4E-4 ){
                     sum+=1;
                   }                
                }
              }            
            }
            count = count==0?1:count;            
            float average = (float)sum/(float)count;
            Vector3 col;
            //if(!depth_test){
            Vector3 normal = calcInterpolation(coord,worldNormal).xyz().unit_vector();
            Vector3 view_dir = calcInterpolation(coord,worldViewDir).unit_vector();
            Vector3 light_dir = light.light_dir.mult(-1).unit_vector();//= calcInterpolation(coord,worldLightDir).unit_vector();
            Vector3 u=calcInterpolation(coord,triangle.uvs);
            Vector3 albedo=diffuse;
            if(texture!=null){
              albedo=getTextureColor(texture.texture,new Vector3(u.x,u.y,0)).product(diffuse);
            }
            Vector3 ambient=AMBIENT_LIGHT.product(albedo);
            Vector3 dif = light.light_color.product(albedo).mult(max(0,Vector3.dot(light_dir.unit_vector(),normal)));
            Vector3 h=(light_dir.add(view_dir)).unit_vector();
            Vector3 specular = light.light_color.product(specular_color).mult(pow(max(0,Vector3.dot(normal,h)),128));
           
            Vector3 sd = (dif.add(specular)).mult(average);
            col=ambient.add(sd);
            //}else{
            //  Vector3 albedo=diffuse;
            //  Vector3 u=calcInterpolation(coord,triangle.uvs);
            //  if(texture!=null){
            //    albedo=getTextureColor(texture.texture,new Vector3(u.x,u.y,0)).product(diffuse);
            //  }
            //  Vector3 ambient=AMBIENT_LIGHT.product(albedo);
            //  col = ambient;
              
            //}
            if(z<zBuffer[index]){
              zBuffer[index]=z;           
              colorBuffer[index]=color(col.x*255,col.y*255,col.z*255);
            }
                        
          }
        }      
    }
  
  }
} 
