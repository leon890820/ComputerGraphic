interface GUI{
  public abstract void run();
}
class Circle{
  float x,y,r1,r2;
  Circle(float x,float y,float r1,float r2){
    this.x=x;
    this.y=y;
    this.r1=r1;
    this.r2=r2;
  }
  

}
abstract class Box {
  PVector[] vertexes;
  int[][] vertexDirection={{0,0},{1,0},{1,1},{0,1}};
  float x,y,w,h;  
  boolean touch; 
  boolean pressed;
  String name;
  Box(float x,float y,float w,float h){
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    createVertexes(x,y,w,h);
    
  }
  void test(){
  
  }
  
  void createVertexes(float x,float y,float w,float h){
    vertexes=new PVector[4];
    for(int i=0;i<vertexes.length;i+=1){
      vertexes[i]=new PVector(x+w*vertexDirection[i][0],y+h*vertexDirection[i][1]);
    }
  }

  
}

class SelectableBox extends Box{
  color backgroundColor=color(0);
  color selectBackgroundColor=color(150);
  color checkBackgroundColor=color(255);
  SelectableBox(float x,float y,float w,float h,String name){
    super(x,y,w,h);
  }
  void setColor(color bc){
    backgroundColor=bc;
  }
  void setColor(color bc,color sbc){
    backgroundColor=bc;
    selectBackgroundColor=sbc;
  }
  void setColor(color bc,color sbc,color cbc){
    backgroundColor=bc;
    selectBackgroundColor=sbc;
    checkBackgroundColor=cbc;
  }
}

class CheckBox extends SelectableBox implements GUI,Function{
  
  boolean check; 
  BooleanType booleanType;
  
  CheckBox(float x,float y,float w,float h,String name,BooleanType booleanType){
    super(x,y,w,h,name);
    this.name=name;
    this.booleanType=booleanType;
   
  }
  void run(){
    show();
    select();
  }
  @Override
   public void getRun(ChangableObject o){      
       o.type=!(boolean)o.type;
    }
  
  void show(){
    noStroke();
    fill(0);
    textAlign(LEFT,TOP);
    text(name,x+w*1.1,y);
    if(touch) fill(selectBackgroundColor);
    else if(check) fill(checkBackgroundColor);
    else fill(backgroundColor);
    rect(x,y,w,h);
    
  }
  
  void select(){
    touch=pnpoly(mouseX,mouseY,this);
    if (touch==true && mousePressed == true) {
      if (pressed==false) {
        
        check=!check;
        getRun(booleanType);
        pressed=true;
      }
    } else pressed=false;
  }
  
  
  

}

class SliderBox extends SelectableBox implements GUI,Function{
  float minValue;
  float maxValue;
  float value;
  float bias;
  float maxbias=50;
  color silderBackground=color(100);
  ChangableObject co;
  
  SliderBox(float x,float y,float w,float h,String name,float minValue,float maxValue,ChangableObject intType){
    super(x,y,w,h,name);
    this.name=name;
    this.minValue=minValue;
    this.maxValue=maxValue;
    this.co=intType;
  }
  
  @Override
  public void getRun(ChangableObject o){    
    
    o.type=value;
  }
  
  @Override
  public void run(){
    show();
    select();
  }
  
  void show(){
    noStroke();
    fill(0);
    textAlign(LEFT,TOP);
    text(name+" : "+co.type,x+50+w*1.1,y);
    fill(silderBackground);
    rect(x,y,w+maxbias,h);
    if(touch) fill(selectBackgroundColor);    
    else fill(backgroundColor);    
    rect(x+bias,y,w,h);
  }
  
  void select(){
    if(pnpoly(mouseX,mouseY,this)) touch=true;
    if (touch==true && mousePressed == true) {  
        float px=min(max(mouseX,x),x+maxbias);
        bias=px-x;       
        createVertexes(px,y,w,h);
        value=map(bias,0,maxbias,minValue,maxValue);
        getRun(co);
      
    } else touch=false;
  }

}

interface Function{
  public abstract void getRun(ChangableObject<?> o);
}


boolean pnpoly(float x, float y, Box b) {
  boolean c=false;

  for (int i=0, j=b.vertexes.length-1; i<b.vertexes.length; j=i++) {
    if (((b.vertexes[i].y>y)!=(b.vertexes[j].y>y))&&(x<(b.vertexes[j].x-b.vertexes[i].x)*(y-b.vertexes[i].y)/(b.vertexes[j].y-b.vertexes[i].y)+b.vertexes[i].x)) {
      c=!c;
    }
  }
  return c;
}

boolean inCircle(int x,int y,Circle c){
  float r=dist(x,y,c.x,c.y);
  if(r<c.r1 && r>c.r2) return true;  

  return false;
}
