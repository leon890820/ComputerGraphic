Liquid[] molecular;
float densityRadius = 3;
float rho0 = 1.5;
float K = 0.5;
float dt = 0.05;

void setup(){
    size(800,800);
    background(50);
    molecular = new Liquid[1000];
    for(int i = 0; i < molecular.length; i++){
        molecular[i] = new Liquid();
        molecular[i].setPos(random(-10,10),random(-10,10),0.0);
    }

    
}

void draw(){
    background(50);
    for(int i = 0; i< molecular.length; i++){
        molecular[i].density(i,densityRadius); 
    }
    
    //visualizeDensity();
    
    
    for(int i = 0; i< molecular.length; i++){
        molecular[i].update(i,densityRadius); 
        molecular[i].show(); 
    }

}

void visualizeDensity(){
    loadPixels();
    for(int i=0;i<height;i++){
        for(int j=0;j<width;j++){
            int index = i * width + j;
            float d = idealGas(calcDensity(new Vector3(map(j,0,width,-10,10),map(i,0,height,-10,10),0.0),densityRadius));
            if(d > 0) pixels[index] = color(d * 255 ,0.0,0.0);
            else pixels[index] = color(0.0,-d * 255,0.0);
            
        }
    }
    updatePixels();
}
