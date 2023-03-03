class Shader{
  color c;
  Shader(){
    c=editor.meshColor.type;
  
  }
  void setColor(color c){
    this.c=c;
  }
  

}

class ShaderGUI extends Box implements GUI{
  ColorType colorType;
  PImage img;
  float hc=255;
  float biasX=255;   
  float biasY=255;
  Circle cir;
  ShaderGUI(float x,float y,float w,float h,ColorType colorType){
    super(x,y,w,h);
    cir=new Circle(x+w/2,y+h/2,w*1.2,sqrt(h*h+w*w)/2);
    this.colorType=colorType;
    img=createImage((int)w,(int)h,1);    
    createColorImage(hc);
  }
  void run(){
    show();
    select();
    selectCircle();
  }
  
  void select(){
    if(pnpoly(mouseX,mouseY,this)) touch=true;
    if (touch==true && mousePressed == true) {  
       float px=min(max(mouseX,x),x+w);
       float py=min(max(mouseY,y),y+w);
       biasX=px-x;   
       biasY=py-y;
       biasX=map(biasX,0,w,0,255);
       biasY=map(biasY,0,h,0,255);
       colorType.type=color(hc,biasX,biasY);
      
    } else touch=false;
  
  }
  
  void selectCircle(){
    if(inCircle(mouseX,mouseY,cir) && mousePressed==true){
      float a=atan2(mouseY-cir.y,mouseX-cir.x);
      hc=map(a,-PI,PI,128,128+255)%255;
      createColorImage(hc);
      colorType.type=color(hc,biasX,biasY);
    }
  
  
  }
  
  void show(){
    image(img,x,y);
    createCircleColorImage();
    //rect(x,y,w,h);
    //println(x,y);
    
  }
  void createColorImage(float x){
    img=createImage((int)w,(int)h,1);
    for(int i=0;i<h;i+=1){
      for(int j=0;j<w;j+=1){
        int index=i*(int)w+j;
        float s=map(i,0,h,0,255);
        float b=map(j,0,h,0,255);
        img.pixels[index]=color(x,b,s);
      }
    }
  }
  void createCircleColorImage(){
    for(int i=0;i<720;i+=1){
      float a=map(i,0,720,0,2*PI);
      float c=map(i,0,720,0,255);
      stroke(color(c,255,255));
      line(cir.x+cos(a)*cir.r1,cir.y+sin(a)*cir.r1,cir.x+cos(a)*cir.r2,cir.y+sin(a)*cir.r2);
      noStroke();
    }
  }

}
