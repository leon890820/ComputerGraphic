Vector3[] findBoundBox(Vector4[] v){
  Vector3 recordminV=new Vector3(1.0/0.0);
  Vector3 recordmaxV=new Vector3(-1.0/0.0);
  for(int i=0;i<v.length;i+=1){
    recordmaxV.x=max(recordmaxV.x,v[i].x);
    recordminV.x=min(recordminV.x,v[i].x);
    
    recordmaxV.y=max(recordmaxV.y,v[i].y);
    recordminV.y=min(recordminV.y,v[i].y);
    
    recordmaxV.z=max(recordmaxV.z,v[i].z);
    recordminV.z=min(recordminV.z,v[i].z);
  }
  Vector3[] result={recordminV,recordmaxV};
  return result;
  
}
Vector3[] findBoundBox(Vector3[] v){
  Vector3 recordminV=new Vector3(1.0/0.0);
  Vector3 recordmaxV=new Vector3(-1.0/0.0);
  for(int i=0;i<v.length;i+=1){
    recordmaxV.x=max(recordmaxV.x,v[i].x);
    recordminV.x=min(recordminV.x,v[i].x);
    
    recordmaxV.y=max(recordmaxV.y,v[i].y);
    recordminV.y=min(recordminV.y,v[i].y);
    
    recordmaxV.z=max(recordmaxV.z,v[i].z);
    recordminV.z=min(recordminV.z,v[i].z);
  }
  Vector3[] result={recordminV,recordmaxV};
  return result;
  
}

Vector4[] clippingLineByPlane(Vector4[] points,Vector4 plane){
  Vector3 N=plane.xyz();
  ArrayList<Vector3> output=new ArrayList<Vector3>();
  ArrayList<Vector3> input=new ArrayList<Vector3>();  
  for(int i=0;i<points.length;i+=1){
    input.add(points[i].xyz());
  }
  
  for(int i=0;i<input.size();i++){
    
    Vector3 s0=input.get(i);
    Vector3 s1=input.get((i+1)%input.size());
    
    float t=(plane.w-Vector3.dot(s0,N))/Vector3.dot(s1.sub(s0),N);
    Vector3 l=s0.add((s1.sub(s0)).mult(t));
    
    if(isInFrontOfThePlane(s0,l,N)){
      output.add(s0);
      if(!isInFrontOfThePlane(s1,l,N)){
        output.add(l);
      }
      
    }else if(isInFrontOfThePlane(s1,l,N)){
      output.add(l);
    }    
  }
  
  
  Vector4[] result=new Vector4[output.size()];
  for(int i=0;i<result.length;i+=1){
    result[i]=new Vector4(output.get(i),1);
  }
  return result;
}

boolean isInFrontOfThePlane(Vector3 s,Vector3 l,Vector3 N){
  if(Vector3.dot(s.sub(l),N)>0) return true;
  else return false;
}


boolean pnpoly(float x, float y, Vector3[] vertexes) {
  boolean c=false;

  for (int i=0, j=vertexes.length-1; i<vertexes.length; j=i++) {
    if (((vertexes[i].y>y)!=(vertexes[j].y>y))&&(x<(vertexes[j].x-vertexes[i].x)*(y-vertexes[i].y)/(vertexes[j].y-vertexes[i].y)+vertexes[i].x)) {
      c=!c;
    }
  }
  return c;
}
boolean pnpoly(float x, float y, Vector4[] vertexes) {
  boolean c=false;

  for (int i=0, j=vertexes.length-1; i<vertexes.length; j=i++) {
    if (((vertexes[i].y>y)!=(vertexes[j].y>y))&&(x<(vertexes[j].x-vertexes[i].x)*(y-vertexes[i].y)/(vertexes[j].y-vertexes[i].y)+vertexes[i].x)) {
      c=!c;
    }
  }
  return c;
}

float dist(Vector3 a,Vector3 b){
  return a.sub(b).length_squared();
}

float clamp(float x,float a,float b){
  if(x<a) return a;
  if(x>b) return b;
  return x;

}
