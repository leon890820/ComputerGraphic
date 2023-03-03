static class Matrix{
  Vector3[] vectors=new Vector3[4];
  Matrix(){
    for(int i=0;i<vectors.length;i+=1){
      vectors[i]=new Vector3();
    }
  }
  Matrix(Vector3[] v){
    vectors=v;
  }
  Matrix(float[][] f){
    for(int i=0;i<f.length;i+=1){
      vectors[i]=new Vector3(f[i]);
    }
  
  }
  
  static Matrix add(Matrix m1,Matrix m2){
    Vector3[] v=new Vector3[4];
    for(int i=0;i<v.length;i+=1){
      v[i]=Vector3.add(m1.vectors[i],m2.vectors[i]);
    }
    return new Matrix(v);
    
  }
  
  static Vector3 mult(Vector3 v,Matrix m){
    float f[]=new float[4];
    for(int i=0;i<f.length;i+=1){
      float[] ff={m.vectors[0].f[i],m.vectors[1].f[i],m.vectors[2].f[i],m.vectors[3].f[i]};
      Vector3 vv=new Vector3(ff);
      f[i]=Vector3.dot(v,vv);
    
    }
    return new Vector3(f);
  }
  
  
  static Matrix mult(Matrix m1,Matrix m2){
    Vector3[] vs=new Vector3[4];
    for(int i=0;i<vs.length;i+=1){
      float[] fs=new float[4];
      for(int j=0;j<fs.length;j+=1){
        float[] ff={m2.vectors[0].f[j],m2.vectors[1].f[j],m2.vectors[2].f[j],m2.vectors[3].f[j]};
        Vector3 vv=new Vector3(ff);
       
        fs[j]=Vector3.dot(m1.vectors[i],vv);
      }
      vs[i]=new Vector3(fs);
    }
    return new Matrix(vs);
  }
  Matrix copy(){
    Vector3[] v=new Vector3[4];
    for(int i=0;i<v.length;i+=1){
      v[i]=vectors[i].copy();
    }
    return new Matrix(v);  
  }
  
  @Override
  String toString(){
    
    for(int i=0;i<vectors.length;i+=1){
      println(i+" : [ "+vectors[i]+" ]");
    }
    return "";
  }
  
}
