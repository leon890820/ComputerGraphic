class Mesh{
  int NUM_VBOS=3;
  ArrayList<Vector3> verts=new ArrayList<Vector3>();
  ArrayList<Vector3> uvs=new ArrayList<Vector3>();
  ArrayList<Vector3> normals=new ArrayList<Vector3>();  
  ArrayList<Collider> colliders=new ArrayList<Collider>();
  ArrayList<Triangle> triangles=new ArrayList<Triangle>();
  ArrayList<Vector4> tangents=new ArrayList<Vector4>();
  
  
  Mesh(String fname){    
    String[] fin=loadStrings("Meshes/"+fname);
    for(int i=0;i<fin.length;i+=1){
      String line=fin[i];
      if(line.indexOf("# ")!=-1){
        continue;
      }
      else if(line.indexOf("v ")!=-1){
        String[] s=line.split(" ");
        verts.add(new Vector3(float(s[1]),float(s[2]),float(s[3])));
      }else if(line.indexOf("vt ")!=-1){
        String[] s=line.split(" ");
        uvs.add(new Vector3(float(s[1]),float(s[2]),0));
      }else if(line.indexOf("vn ")!=-1){
        String[] s=line.split(" ");
        normals.add(new Vector3(float(s[1]),float(s[2]),float(s[3])));
      }else if(line.indexOf("c ")!=-1){
        int a,b,c=0;
        if(line.charAt(2)=='*'){
          int v_ix=verts.size();
          a=v_ix-2;b=v_ix-1;c=v_ix;
        }else{
          String[] s=line.split(" ");
          a=int(s[1]);b=int(s[2]);c=int(s[3]);
        }
        Vector3 v1=verts.get(a-1);
        Vector3 v2=verts.get(b-1);
        Vector3 v3=verts.get(c-1);
        colliders.add(new Collider(v1,v2,v3));
        
      }else if(line.indexOf("f ")!=-1){
        int num_slashes=0;
        int last_slash_ix=0;
        boolean double_slashes=false;
        StringBuilder sb=new StringBuilder(line);       
        for(int j=0;j<line.length();j+=1){   
                    
          
          if(sb.charAt(j)=='/'){
            sb.setCharAt(j,' ');
            if(last_slash_ix==i-1) double_slashes=true;
            last_slash_ix=i;
            num_slashes++;         
          }
        }
        line=new String(sb);
        
        int a=0,b=0,c=0,d=0;
        int at=0,bt=0,ct=0,dt=0;
        boolean wild=line.charAt(2)=='*'; 
        boolean wild2=line.charAt(3)=='*'; 
        boolean isQuad=false;
        String[] s=line.split(" ");
        if(wild){
        
        }else if(num_slashes==0){
          isQuad= s.length==5;
          if(isQuad){
            a=int(s[1]);b=int(s[2]);c=int(s[3]);d=int(s[4]);
          }else{
            a=int(s[1]);b=int(s[2]);c=int(s[3]);
          }
          at = a; bt = b; ct = c; dt = d;        
        }else if(num_slashes==3){
          a=int(s[1]);at=int(s[2]);b=int(s[3]);bt=int(s[4]);c=int(s[5]);ct=int(s[6]);
        }else if(num_slashes==4){
          a=int(s[1]);at=int(s[2]);b=int(s[3]);bt=int(s[4]);c=int(s[5]);ct=int(s[6]);d=int(s[7]);dt=int(s[8]);         
          isQuad=true;  
        }else if(num_slashes==6){
          if(double_slashes){
            a=int(s[1]);at=int(s[1]);b=int(s[3]);bt=int(s[3]);c=int(s[5]);ct=int(s[5]);
          }else{
            a=int(s[1]);at=int(s[2]);b=int(s[4]);bt=int(s[5]);c=int(s[7]);ct=int(s[8]);
          }
        }else if(num_slashes==8){
          isQuad=true;
          if(double_slashes){
            a=int(s[1]);at=int(s[1]);b=int(s[3]);bt=int(s[3]);c=int(s[5]);ct=int(s[5]);d=int(s[7]);dt=int(s[7]);
          }else{
            a=int(s[1]);at=int(s[2]);b=int(s[4]);bt=int(s[5]);c=int(s[7]);ct=int(s[8]);d=int(s[10]);dt=int(s[11]);
          }
        }else{
          continue;
        }
        
        
        addFace(a,at,b,bt,c,ct);
        if(isQuad){
          addFace(a,at,c,ct,d,dt);
        }
      }
      
      
      
    }
    
    calcTangent();
    
    println(tangents.get(0));
    
  
  }
  
  void calcTangent(){
    Vector3[] tangent=new Vector3[verts.size()];
    Vector3[] bitangent=new Vector3[verts.size()];
    for(int i=0;i<tangent.length;i+=1){
        tangent[i]=new Vector3();
        bitangent[i]=new Vector3();
    }
    for(int i=0;i<triangles.size();i+=1){
      int i0 = triangles.get(i).triangle[0];
      int i1 = triangles.get(i).triangle[1];
      int i2 = triangles.get(i).triangle[2]; 
      Vector3 p0 = verts.get(i0);
      Vector3 p1 = verts.get(i1);
      Vector3 p2 = verts.get(i2);
      Vector3 w0 = uvs.get(i0);
      Vector3 w1 = uvs.get(i1);
      Vector3 w2 = uvs.get(i2);
      
      Vector3 e1=p1.sub(p0);
      Vector3 e2=p2.sub(p0);
      float x1=w1.x-w0.x;
      float x2=w2.x-w0.x;
      float y1=w1.y-w0.y;
      float y2=w2.y-w0.y;
      
      float r=1.0/(x1*y2-x2*y1);
      Vector3 t=((e1.mult(y2)).sub(e2.mult(y1))).mult(r);
      Vector3 b=((e2.mult(x1)).sub(e1.mult(x2))).mult(r);
      
      tangent[i0]=tangent[i0].add(t);
      tangent[i1]=tangent[i1].add(t);
      tangent[i2]=tangent[i2].add(t);
      
      bitangent[i0]=bitangent[i0].add(b);
      bitangent[i1]=bitangent[i1].add(b);
      bitangent[i2]=bitangent[i2].add(b);
      
      
    }
    
    for(int i=0;i<verts.size();i+=1){
      Vector3 t=tangent[i];
      Vector3 b=bitangent[i];
      Vector3 n=normals.get(i);
      
      Vector4 tan=new Vector4((t.sub(n.mult(Vector3.dot(n,t)))).unit_vector(),0);
      tan.w=(Vector3.dot(Vector3.cross(n,t),b)<0.0)?-1.0:1.0;
      tangents.add(tan);
     
    
    }
  
  
  
  }
  
  void Draw(){
  
  }
  void debudDraw(){
  
  }
  
  
  void addFace(int a,int at,int b,int bt,int c,int ct){
    a-=1;b-=1;c-=1;at-=1;bt-=1;ct-=1;
    int[] v_ix={a,b,c};
    int[] uv_ix={at,bt,ct};
    Vector3 v1=verts.get(a);
    Vector3 v2=verts.get(b);
    Vector3 v3=verts.get(c);
    Vector3[] vs={v1,v2,v3};
    Vector3[] normal=new Vector3[3];
    for(int i=0;i<3;i+=1){
      Vector3 n=Vector3.cross(Vector3.sub(vs[(i+1)%3],vs[i]),Vector3.sub(vs[(i+2)%3],vs[i])).unit_vector();
      normal[i]=n;
    }
    
    
    Vector3[] us={uvs.get(at),uvs.get(bt),uvs.get(ct)};
    int[] triangle={a,b,c};
    triangles.add(new Triangle(vs,us,normal,triangle));
  }
  
  
  @Override
 public String toString(){
    int c=1;
    String s=new String();    
    for(Triangle t:triangles){
      s+="Trangle"+ c+++":\n";
      s+=t.toString();
      
    }
    return s;
  }
}

class Triangle{
  Vector3[] verts;
  Vector3[] uvs;
  Vector3[] normal;
  int[] triangle;
  Triangle(Vector3[] verts,Vector3[] uvs,Vector3[] normal,int[] triangle){
    this.verts=verts;
    this.uvs=uvs;
    this.normal=normal;     
    this.triangle=triangle;
  }
  
  @Override
 public String toString(){
    String s="Verties: \n";
    for(Vector3 v:verts){
      s+=v.toString()+"\n";
    }
    s+="Uvs: \n";
    for(Vector3 v:uvs){
      s+=v.toString()+"\n";
    }
    return s;
  }

}
