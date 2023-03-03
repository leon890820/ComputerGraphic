class Planet{
  TerrainFace[] terrainFace=new TerrainFace[6];
  ShapeGenerator shapeGenerator=new ShapeGenerator(editor);
  Planet(){
    initialize();
    generate();
  }
  void initialize(){
    PVector[] directions = {new PVector(1,0,0),new PVector(-1,0,0),new PVector(0,1,0),new PVector(0,-1,0),new PVector(0,0,1),new PVector(0,0,-1)};
    for(int i=0;i<terrainFace.length;i+=1){
      terrainFace[i]=new TerrainFace(new Mesh(),directions[i],shapeGenerator);
    }
    
    
  
  
  
  }
  void generate(){
    for(TerrainFace face:terrainFace){
      face.contructMesh();
    }
    
  }
  

} 
