class Mesh{
  PVector[] verties;
  int[] triangles;
  Shader shader=new Shader();
  Mesh(PVector[] verties ,int[] triangles,Shader shader){
    this.verties=verties;
    this.triangles=triangles;
    this.shader=shader;
  }
  Mesh(){}
  void show(){
    if(verties==null||triangles==null) return;
    stroke(200);
    if(editor.showgrid.type)noStroke();
    fill(shader.c);
    for(int i=0;i<triangles.length;i+=3){
      beginShape();
      vertex(verties[triangles[i]].x,verties[triangles[i]].y,verties[triangles[i]].z);
      vertex(verties[triangles[i+1]].x,verties[triangles[i+1]].y,verties[triangles[i+1]].z);
      vertex(verties[triangles[i+2]].x,verties[triangles[i+2]].y,verties[triangles[i+2]].z);
      endShape(CLOSE); 
      //println(verties[triangles[i]],verties[triangles[i+1]],verties[triangles[i+2]]);
    }
    
  }

}
