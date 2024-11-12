class ShadeParameter{
  Vector3 Olambda;
  float Kd;
  float Ks;
  float N;
  ShadeParameter(Vector3 Olambda,float Kd,float Ks,float N){
    this.Olambda=Olambda;
    this.Kd=Kd;
    this.Ks=Ks;
    this.N=N;
  }
}

class Transform{
  Vector3 position,scale,rotation;
  Transform(Vector3 position,Vector3 scale,Vector3 rotation){
    this.position=position;
    this.scale=scale;
    this.rotation=rotation;
  }

}
