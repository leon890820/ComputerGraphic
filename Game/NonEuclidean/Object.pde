abstract class Object{
  Vector3 pos;
  Vector3 eular;
  Vector3 scale;
  float p_scale;
  Mesh mesh;
  Texture texture;
  Shader shader;
  
  Object(){
    pos=new Vector3(0);
    eular=new Vector3(0);
    scale=new Vector3(1);
    p_scale=1;
  }
  void reset(){
    pos.setZero();
    eular.setZero();
    scale.setOnes();
    p_scale=1;
  }
  
  
  
  
  
 
 
  abstract void Draw();
    
  
  
  Vector3[] eyeClip(Triangle t){
     Vector4[] eye_homogenized_point=new Vector4[3];     
      
      for(int j=0;j<3;j+=1){
        Vector4 p=t.verts[j].getVector4();        
        eye_homogenized_point[j]=main_cam.worldView.mult(localToWorld().mult(p));        

      }  
      
      
      Vector4[] clipping_eye_point=clippingLineByPlane(eye_homogenized_point,new Vector4(0,0,1,0.1));
      Vector3[] clipping_projection_point=new Vector3[clipping_eye_point.length];
      for(int j=0;j<clipping_projection_point.length;j++){
        clipping_projection_point[j]=(main_cam.projection.mult(clipping_eye_point[j])).homogenized();
      }
     return null;
  
  }
  
  float[] barycentric(Vector3 P,Vector4[] verts){
    
    
    
    Vector3 A=verts[0].homogenized();
    Vector3 B=verts[1].homogenized();
    Vector3 C=verts[2].homogenized();
    float AW=verts[0].w;
    float BW=verts[1].w;
    float CW=verts[2].w;

    
    
    
    float alpha=(P.x*(B.y-C.y)+P.y*(C.x-B.x)+(B.x*C.y-C.x*B.y))/(A.x*(B.y-C.y)+A.y*(C.x-B.x)+(B.x*C.y-C.x*B.y));
    float beta=(P.x*(C.y-A.y)+P.y*(A.x-C.x)+(C.x*A.y-A.x*C.y))/(B.x*(C.y-A.y)+B.y*(A.x-C.x)+(C.x*A.y-A.x*C.y));
    float gamma=1-alpha-beta;

    float s=alpha/AW+beta/BW+gamma/CW;
    float Walpha=alpha/(AW*s);
    float Wbeta=beta/(BW*s);
    float Wgamma=gamma/(CW*s);
    
    float[] result={Walpha,Wbeta,Wgamma};
    
    return result;
  }
  Vector3 getTextureColor(PImage img,Vector3 uv){
    
    float x=map(uv.x,0,1,0,img.width-1);
    float y=map(uv.y,0,1,0,img.height-1);
    
    
    int index=int(x%img.width)+int(y%img.height)*img.width;
    
    color pixel=img.pixels[index];
    int B_MASK = 255;
    int G_MASK = 255<<8; //65280 
    int R_MASK = 255<<16; //16711680
    float r = (pixel & R_MASK)>>16;
    float g = (pixel & G_MASK)>>8;
    float b = pixel & B_MASK;
    
    return new Vector3(r/255.0,g/255.0,b/255.0);
    
  }
  
  
  Vector4 calcInterpolation(float[] b,Vector4[] v){
      return v[0].mult(b[0]).add(v[1].mult(b[1])).add(v[2].mult(b[2]));
  }
  Vector3 calcInterpolation(float[] b,Vector3[] v){
      return v[0].mult(b[0]).add(v[1].mult(b[1])).add(v[2].mult(b[2]));
  }
  float calcInterpolation(float[] b,float[] v){
      return v[0]*b[0]+v[1]*b[1]+v[2]*b[2];
  }
  
  
  void update(){};
  void onHit(Object other,Vector3 push){};
  
  void debugDraw(){}
 
  Physical asPhysical(){
    return null;
  }
  
 
  
  
  
  
  Matrix4 localToWorld(){
    return Matrix4.Trans(pos).mult(Matrix4.RotY(eular.y)).mult(Matrix4.RotX(eular.x)).mult(Matrix4.RotZ(eular.z)).mult(Matrix4.Scale(scale.mult(p_scale)));     
  }
  Matrix4 worldToLocal(){
    return Matrix4.Scale(scale.mult(p_scale).inv()).mult(Matrix4.RotZ(-eular.z)).mult(Matrix4.RotX(-eular.x)).mult(Matrix4.RotY(-eular.y)).mult(Matrix4.Trans(pos.mult(-1)));
  }
  Vector3 forward(){
    return (Matrix4.RotZ(eular.z).mult(Matrix4.RotX(eular.y)).mult(Matrix4.RotY(eular.x)).zAxis()).mult(-1);
  }
  


}
