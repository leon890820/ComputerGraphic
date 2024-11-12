class TerrainFace{
  Mesh mesh;
  PVector localUp;
  PVector axisA;
  PVector axisB;
  int radius=100;
  ShapeGenerator shapeGenerator;
  TerrainFace(Mesh mesh,PVector localUp,ShapeGenerator shapeGenerator){
    this.mesh=mesh;
    this.localUp=localUp;
    this.shapeGenerator=shapeGenerator;
    axisA=new PVector(localUp.y,localUp.z,localUp.x);
    axisB=localUp.cross(axisA);
    //println(localUp.x,axisA,axisB);
    
  }

  
  void contructMesh(){
    int resolution=int(Float.valueOf(editor.resolution.type));
    PVector[] verties=new PVector[resolution*resolution];
    int[] triangles=new int[(resolution-1)*(resolution-1)*6];
    int triangleIndex=0;
     for(int y=0;y<resolution;y+=1){
       for(int x=0;x<resolution;x+=1){
         int index=y*resolution+x;
         PVector percent = new PVector(map(x,0,resolution-1,-radius,radius),map(y,0,resolution-1,-radius,radius));         
         PVector pointOnUnitCube =PVector.add( PVector.add(PVector.mult(localUp,radius),PVector.mult(axisB,percent.y)),PVector.mult(axisA,percent.x));
         PVector pointOnUnitSphere=new PVector();
         pointOnUnitCube.normalize(pointOnUnitSphere);
         pointOnUnitSphere.mult(shapeGenerator.evaluate(pointOnUnitSphere));
         verties[index]=pointOnUnitSphere;
         //println(pointOnUnitCube);
         if(x<resolution-1&&y<resolution-1){
           triangles[triangleIndex]=index;
           triangles[triangleIndex+1]=index+resolution;
           triangles[triangleIndex+2]=index+resolution+1;
           triangles[triangleIndex+3]=index;
           triangles[triangleIndex+4]=index+1;
           triangles[triangleIndex+5]=index+resolution+1;
           triangleIndex+=6;
         }
         
         
       }
     }
     mesh.verties=verties;
     mesh.triangles=triangles;
     //println(mesh.triangles.length);
     mesh.show();
  
  }
  
  

}
