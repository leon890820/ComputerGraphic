public class Light{
  public Vector3 pos;
  public Vector3 light_dir;
  public Vector3 light_color;
  
  Light(Vector3 pos,Vector3 ld,Vector3 lc){
    this.pos=pos;
    this.light_dir=ld;
    this.light_color=lc;
  }
  
}
