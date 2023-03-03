class Mesh{
  PVector[] verties;
  int[] triangles;
  int[] number;
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
    //noStroke();
    fill(shader.c);
    noFill();
    int n=0;
    int r=0;
    for(int i=0;i<number.length;i+=1){
      //println(i,number[n]);
      beginShape();
      for(int j=0;j<number[n];j+=1){
        
        vertex(verties[triangles[r+j]].x*editor.radius,verties[triangles[r+j]].y*editor.radius,verties[triangles[r+j]].z*editor.radius);
      }            
      //vertex(verties[triangles[i]].x*editor.radius,verties[triangles[i]].y*editor.radius,verties[triangles[i]].z*editor.radius);
      //vertex(verties[triangles[i+1]].x*editor.radius,verties[triangles[i+1]].y*editor.radius,verties[triangles[i+1]].z*editor.radius);
     // vertex(verties[triangles[i+2]].x*editor.radius,verties[triangles[i+2]].y*editor.radius,verties[triangles[i+2]].z*editor.radius);
      endShape(CLOSE); 
      r+=number[n];
      n+=1;

      //println(verties[triangles[i]],verties[triangles[i+1]],verties[triangles[i+2]]);
    }
    
  }

}
class Editor{
  float radius=100;
  color c=color(255);

}

class Shader{
  color c;
  Shader(){
    c=editor.c;
  
  }
  void setColor(color c){
    this.c=c;
  }
  

}
