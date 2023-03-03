class Collider{
  Matrix4 mat=new Matrix4();
  
  Collider(Vector3 a,Vector3 b,Vector3 c){
    
    Vector3 ab=b.sub(a);
    Vector3 bc=c.sub(b);
    Vector3 ca=a.sub(c);
    float magAB=ab.magSq();
    float magBC=bc.magSq();
    float magCA=ca.magSq();
    
    
    if(magAB>=magBC && magAB>=magCA){
      createSorted(bc.mult(0.5),(a.add(b)).mult(0.5),ca.mult(0.5));
    }else if (magBC >= magAB && magBC >= magCA) {
      createSorted(ca.mult(0.5),(b.add(c)).mult(0.5),ab.mult(0.5));
    }else {
      createSorted(ab.mult(0.5),(c.add(a)).mult(0.5),bc.mult(0.5));
    }  
  }
  
  boolean collide(Matrix4 localToUnit,Vector3 delta){
    Matrix4 local=localToUnit.mult(mat);
    Vector3 v=local.translation().mult(-1);
    
    Vector3 x=local.xAxis();
    Vector3 y=local.yAxis();
    
    float px=clamp(Vector3.dot(v,x)/x.magSq(),-1,1);
    float py=clamp(Vector3.dot(v,y)/y.magSq(),-1,1);
    
    Vector3 closest=x.mult(px).add(y.mult(py));
    
    delta.copy(v.sub(closest));
    
    if(delta.magSq()>=1.0){
      return false;
    }else{
      Vector3 d=delta.copy();
      delta.normalize();
      delta.minus(d);
      return true;
    }
    
  }
  
  void createSorted(Vector3 da,Vector3 c,Vector3 db){
    mat.makeIdentity();
    mat.setTranslation(c);
    mat.setXAxis(da);
    mat.setYAxis(db);
  
  }
  
  

}
