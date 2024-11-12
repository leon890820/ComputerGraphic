class Quad extends Object{
  PImage bump=loadImage("Textures/Wall03_Normal.jpg");
  boolean debug=false;
  Quad(){
    mesh=new Mesh("quad.obj");
    texture=new Texture("Wall03_Diffuse.jpg");
  }
  
  class Vert{
    Vector4[] position;
    Vector4[] tangent;
    Vector3[] normal;
    Vector3[] texcoord;
    Vert(Mesh m){
      init(m);
    }
    
    void init(Mesh m){
      position=new Vector4[m.verts.size()];
      normal=new Vector3[m.normals.size()];
      tangent = new Vector4[m.tangents.size()];
      texcoord=new Vector3[m.uvs.size()];
      
      for(int i=0;i<position.length;i+=1){
        position[i] = m.verts.get(i).getVector4();
        normal[i]=m.normals.get(i);
        texcoord[i] = m.uvs.get(i);
        tangent[i]=m.tangents.get(i);
      }
      
      
    }
  }
  class Frag{
    //Vector4[] world_position;
    Vector4[] eye_position;
    //Vector3[] world_normal;
    Vector4[] pos;
    Vector4[] uv; 
    Vector3[] light_dir;
    Vector3[] view_dir;
    
    Frag getSpecialPosition(int[] t){
      Frag f=new Frag();
      //Vector4[] world_position={this.world_position[t[0]],this.world_position[t[1]],this.world_position[t[2]]};
      Vector4[] eye_position={this.eye_position[t[0]],this.eye_position[t[1]],this.eye_position[t[2]]};
      //Vector3[] world_normal={this.world_normal[t[0]],this.world_normal[t[1]],this.world_normal[t[2]]};
      Vector4[] pos={this.pos[t[0]],this.pos[t[1]],this.pos[t[2]]};
      Vector4[] uv={this.uv[t[0]],this.uv[t[1]],this.uv[t[2]]};
      Vector3[] light_dir={this.light_dir[t[0]],this.light_dir[t[1]],this.light_dir[t[2]]};
      Vector3[] view_dir={this.view_dir[t[0]],this.view_dir[t[1]],this.view_dir[t[2]]};

      //f.world_normal=world_normal;
      //f.world_position=world_position;
      f.eye_position=eye_position;
      f.pos=pos;
      f.uv=uv;
      f.light_dir=light_dir;
      f.view_dir=view_dir;
      return f;
    }
  }
  
  void vert(Vert vert,Frag frag){
    //frag.world_normal=new Vector3[vert.normal.length];
    //frag.world_position=new Vector4[vert.position.length];
    frag.pos=new Vector4[vert.position.length];
    frag.uv=new Vector4[vert.texcoord.length];
    frag.eye_position=new Vector4[vert.position.length];
    frag.light_dir=new Vector3[vert.position.length];
    frag.view_dir=new Vector3[vert.position.length];
    
    for(int j=0;j<frag.pos.length;j+=1){
      Vector4 world_position=localToWorld().mult(vert.position[j]);
      frag.eye_position[j]=main_cam.worldView.mult(world_position);
      //frag.world_normal[j]=localToWorld().mult(vert.normal[j].getVector4(0)).xyz();
      frag.pos[j] = main_cam.projection.mult(frag.eye_position[j]);
      frag.uv[j]=new Vector4();
      frag.uv[j].x = vert.texcoord[j].x;frag.uv[j].y = vert.texcoord[j].y;
      frag.uv[j].z = vert.texcoord[j].x;frag.uv[j].w = vert.texcoord[j].y;
      
      Vector3 world_normal = localToWorld().mult(vert.normal[j].getVector4(0)).xyz();
      Vector3 world_tangent = localToWorld().mult(vert.tangent[j].xyz().getVector4(0)).xyz();
      Vector3 world_binormal = Vector3.cross(world_normal,world_tangent).mult(vert.tangent[j].w);
      
      Matrix4 worldToTangent = new Matrix4(world_tangent,world_binormal,world_normal);
      
      
      frag.light_dir[j]=worldToTangent.mult(light.light_dir.getVector4(0)).xyz();
      frag.view_dir[j]=worldToTangent.mult( (engine.player.pos.sub(world_position.xyz())).getVector4(0)).xyz();
      
    }
  
  
  }
  
  @Override
  public void Draw(){
    fill(255);
    noStroke();
   
    if(mesh==null) return;
    Vert vert = new Vert(mesh);
    Frag frag = new Frag();
    vert(vert,frag);  
    
    
    for(int i=0;i<mesh.triangles.size();i+=1){
      Triangle t=mesh.triangles.get(i);
      Frag f=frag.getSpecialPosition(t.triangle);
      //println(getTextureColor(bump,new Vector3(0,0,0)));
     
      
     
     //if(Vector3.dot(main_cam.worldView.mult(localToWorld().mult(vert.normal[0].getVector4(0))).xyz().unit_vector(),new Vector3(0,0,1))>0){
     //   return;
     // }
      
      
      Vector3[] clipping_projection_point=eyeClip(f.eye_position);
      Vector3[] bounding_box=findBoundBox(clipping_projection_point);
      
      float minx=max(0, map(bounding_box[0].x,-1,1,0,width));
      float maxx=min(width-1, map(bounding_box[1].x,-1,1,0,width));
      float miny=max(0, map(bounding_box[0].y,-1,1,0,width));
      float maxy=min(width-1, map(bounding_box[1].y,-1,1,0,width));
      
      
      //frag
      for(int y=int(miny);y<=maxy;y+=1){
        for(int x=int(minx);x<=maxx;x+=1){          
          int index=y*width+x;
          float rx=map(x,0,width,-1,1);
          float ry=map(y,0,height,-1,1);  
          
          
          
          if (!pnpoly(rx, ry,clipping_projection_point)) {
            continue;
          }
          Vector3[] pos={f.pos[0].homogenized(),f.pos[1].homogenized(),f.pos[2].homogenized()};
          float[] coord=barycentric(new Vector3(rx,ry,0),f.pos);
          
          float z=calcInterpolation(coord,pos).z;
          int c=frag(coord,f);
          if(z<zBuffer[index]){
            zBuffer[index]=z;           
            colorBuffer[index]=c;
          }
          
          
          
          
        }
      }             
    }  
  }
  
  Vector3 diffuse=new Vector3(0.6,0.6,0.6);
  Vector3 specular_color=new Vector3(1,1,1);
  color frag(float[] coord,Frag f){
    
    
    
    Vector3 tangent_light_dir=calcInterpolation(coord,f.light_dir).unit_vector();
    Vector3 tangent_view_dir=calcInterpolation(coord,f.view_dir).unit_vector();
    
    Vector4 u=calcInterpolation(coord,f.uv);
    
    Vector3 tangent_normal=getTextureColor(bump,new Vector3(u.z,u.w,0)).unit_vector();
    //println(Vector3.dot(tangent_light_dir,tangent_normal));
    tangent_normal.x*=1;tangent_normal.y*=1;
    tangent_normal.z=sqrt(1-min(1,max(0,tangent_normal.x*tangent_normal.x+tangent_normal.y*tangent_normal.y)));
    //tangent_normal=new Vector3(0,0,1);
    
    Vector3 albedo=diffuse;
    if(texture!=null){
      albedo=getTextureColor(texture.texture,new Vector3(u.x,u.y,0)).product(diffuse);
    }
    
    //Vector3 albedo=diffuse;
    Vector3 ambient=AMBIENT_LIGHT.product(albedo);
    
    Vector3 dif = light.light_color.product(albedo).mult(min(1,max(0,Vector3.dot(tangent_light_dir,tangent_normal))));
     
    Vector3 h=(tangent_light_dir.add(tangent_view_dir)).unit_vector();
    
    Vector3 specular = light.light_color.product(specular_color).mult(pow(max(0,Vector3.dot(tangent_normal,h)),128));
   
    Vector3 col=ambient.add(dif).add(specular);
    
    
    
   
    //color c=color((n.x+1)/2*255,(n.y+1)/2*255,(n.z+1)/2*255);
    
    
    return color(col.x*255,col.y*255,col.z*255);
  }
  
  Vector3[] eyeClip(Vector4[] eye_position){
      
      
      
      Vector4[] clipping_eye_point=clippingLineByPlane(eye_position,new Vector4(0,0,1,0.1));
      Vector3[] clipping_projection_point=new Vector3[clipping_eye_point.length];
      for(int j=0;j<clipping_projection_point.length;j++){
        clipping_projection_point[j]=(main_cam.projection.mult(clipping_eye_point[j])).homogenized();
      }
     return clipping_projection_point;
  
  }
  
 
  
}

class SphereObj extends Object{
  
  
  
  SphereObj(){
    mesh=new Mesh("globe-sphere.obj");
    texture=new Texture("Brick_Diffuse.JPG");
  }
  
  
  class Vert{
    Vector4[] position;
    Vector3[] normal;
    Vector3[] texcoord;
    Vert(Mesh m){
      init(m);
    }
    
    void init(Mesh m){
      position=new Vector4[m.verts.size()];
      normal=new Vector3[m.normals.size()];
      texcoord=new Vector3[m.uvs.size()];
      
      for(int i=0;i<position.length;i+=1){
        position[i] = m.verts.get(i).getVector4();
        normal[i]=m.verts.get(i);
        texcoord[i] = m.uvs.get(i);
      }
      
    }
  }
  class Frag{
    Vector4[] world_position;
    Vector4[] eye_position;
    Vector3[] world_normal;
    Vector4[] pos;
    Vector3[] uv; 
    
    Frag getSpecialPosition(int[] t){
      Frag f=new Frag();
      Vector4[] world_position={this.world_position[t[0]],this.world_position[t[1]],this.world_position[t[2]]};
      Vector4[] eye_position={this.eye_position[t[0]],this.eye_position[t[1]],this.eye_position[t[2]]};
      Vector3[] world_normal={this.world_normal[t[0]],this.world_normal[t[1]],this.world_normal[t[2]]};
      Vector4[] pos={this.pos[t[0]],this.pos[t[1]],this.pos[t[2]]};
      Vector3[] uv={this.uv[t[0]],this.uv[t[1]],this.uv[t[2]]};
      f.world_normal=world_normal;
      f.world_position=world_position;
      f.eye_position=eye_position;
      f.pos=pos;
      f.uv=uv;
      return f;
    }
  }
  
  void vert(Vert vert,Frag frag){
    frag.world_normal=new Vector3[vert.normal.length];
    frag.world_position=new Vector4[vert.position.length];
    frag.pos=new Vector4[vert.position.length];
    frag.uv=new Vector3[vert.texcoord.length];
    frag.eye_position=new Vector4[vert.position.length];
    
    for(int j=0;j<frag.world_normal.length;j+=1){
      frag.world_position[j]=localToWorld().mult(vert.position[j]);
      frag.eye_position[j]=main_cam.worldView.mult(frag.world_position[j]);
      frag.world_normal[j]=localToWorld().mult(vert.normal[j].getVector4()).xyz();
      frag.pos[j] = main_cam.projection.mult(frag.eye_position[j]);
      frag.uv[j] = vert.texcoord[j];
    }
  
  
  }
  
  @Override
  public void Draw(){
    fill(255);
    noStroke();
   
    if(mesh==null) return;
    Vert vert = new Vert(mesh);
    Frag frag = new Frag();
    vert(vert,frag);  
    
    
    for(int i=0;i<mesh.triangles.size();i+=1){
      Triangle t=mesh.triangles.get(i);
      Frag f=frag.getSpecialPosition(t.triangle);
      
      
     
     //if(Vector3.dot(main_cam.worldView.mult(localToWorld().mult(vert.normal[0].getVector4(0))).xyz().unit_vector(),new Vector3(0,0,1))>0){
     //   return;
     // }
      
      
      Vector3[] clipping_projection_point=eyeClip(f.eye_position);
      Vector3[] bounding_box=findBoundBox(clipping_projection_point);
      
      float minx=max(0, map(bounding_box[0].x,-1,1,0,width));
      float maxx=min(width-1, map(bounding_box[1].x,-1,1,0,width));
      float miny=max(0, map(bounding_box[0].y,-1,1,0,width));
      float maxy=min(width-1, map(bounding_box[1].y,-1,1,0,width));
      
      
      //frag
      for(int y=int(miny);y<=maxy;y+=1){
        for(int x=int(minx);x<=maxx;x+=1){          
          int index=y*width+x;
          float rx=map(x,0,width,-1,1);
          float ry=map(y,0,height,-1,1);  
          
          
          if (!pnpoly(rx, ry,clipping_projection_point)) {
            continue;
          }
          Vector3[] pos={f.pos[0].homogenized(),f.pos[1].homogenized(),f.pos[2].homogenized()};
          float[] coord=barycentric(new Vector3(rx,ry,0),f.pos);
          
          float z=calcInterpolation(coord,pos).z;
          int c=frag(coord,f);
          if(z<zBuffer[index]){
            zBuffer[index]=z;           
            colorBuffer[index]=c;
          }
          
          
          
          
        }
      }             
    }  
  }
  
  
  color frag(float[] coord,Frag f){
    
    Vector3 n=calcInterpolation(coord,f.world_normal).unit_vector();
    Vector3 u=calcInterpolation(coord,f.uv);
   
    color c=color((n.x+1)/2*255,(n.y+1)/2*255,(n.z+1)/2*255);
    if(texture!=null){
      //c=getTextureColor(texture.texture,u);
    }
    
    return c;
  }
  
  Vector3[] eyeClip(Vector4[] eye_position){
      
      
      
      Vector4[] clipping_eye_point=clippingLineByPlane(eye_position,new Vector4(0,0,1,0.1));
      Vector3[] clipping_projection_point=new Vector3[clipping_eye_point.length];
      for(int j=0;j<clipping_projection_point.length;j++){
        clipping_projection_point[j]=(main_cam.projection.mult(clipping_eye_point[j])).homogenized();
      }
     return clipping_projection_point;
  
  }
  

}


public enum Type {
  NORMAL,SCALE,SLOPE
}
