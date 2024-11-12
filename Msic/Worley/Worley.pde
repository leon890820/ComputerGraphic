WorleyGenerator worleyGenerator;
PImage[] worley_3D_texture;
float sliceDepth = 0.0;
boolean save_worley = false;

void setup(){
    size(500,500);
    randomSeed(0);
    background(0);
    worleyGenerator = new WorleyGenerator(500);
    if(save_worley){
        worley_3D_texture = worleyGenerator.run();    
        worleyGenerator.saveImage(worley_3D_texture);
    }else{
        worley_3D_texture = worleyGenerator.loadWorleyImage();
    }
    //worleyGenerator.saveImage(worley_3D_texture);
    println("Start");
    
    

     

}

void draw(){
    //background(0);
    worleyGenerator.show(worley_3D_texture);
}


void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e > 0){
      sliceDepth +=0.01;
  }else if(e < 0){
      sliceDepth -=0.01;
  }
  if(sliceDepth>=1) sliceDepth-=1;
  if(sliceDepth<0) sliceDepth+=1;
  
  //sliceDepth = min(1,max(0,sliceDepth));
}
