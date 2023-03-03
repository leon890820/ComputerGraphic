void setup(){
  size(600,600);
  background(255);
  //myLine(100,300,300,200);
  
}
void draw(){
  background(255);
  loadPixels();  
  //myLine(100,300,mouseX,mouseY);
  myCircle(mouseX,mouseY,100,color(0));
  //scanLineFill(width/2,height/2,color(255),color(0,255,0));
  
  updatePixels();
}


void myLine(int x0,int y0,int x1,int y1,color c){
  boolean steep=abs(y1-y0)>abs(x1-x0);
  if(steep){
    int tmp=x0;
    x0=y0;
    y0=tmp;
    
    int tmp1=x1;
    x1=y1;
    y1=tmp1;
  }
  if(x0>x1){
    int tmp=x0;
    x0=x1;
    x1=tmp;
    
    int tmpy=y0;
    y0=y1;
    y1=tmpy;
  
  }
  int deltaX=x1-x0;
  int deltaY=abs(y1-y0);
  
  
  int error=deltaX/2;
  
  int ystep;
  int y=(int)y0;
  ystep=(y0<y1)?1:-1;
  for(int x=(int)x0;x<x1;x+=1){
    if(steep)plot(y,x,c);
    else plot(x,y,c);
    error-=deltaY;
    if(error<0){
      y+=ystep;
      error+=deltaX;
    }
  }
  
  
}

void myCircle(int a,int b,float r,color c){
  float x=0;
  float y=r;
  float p=3-2*r;
  while(x<y){
    
    plot((int)x+a,(int)y+b,c);
    plot((int)-x+a,(int)y+b,c);
    plot((int)x+a,(int)-y+b,c);
    plot((int)-x+a,(int)-y+b,c);
    plot((int)y+a,(int)x+b,c);
    plot((int)-y+a,(int)x+b,c);
    plot((int)y+a,(int)-x+b,c);
    plot((int)-y+a,(int)-x+b,c);
    
    if(p<0){
      p=p+4*x-6;
    }else{
      p=p+4*(x-y)+10;
      y-=1;
    }
    x+=1;
  
  }
}



void scanLineFill(int x,int y,color old_color,color new_color){
  int xl,xr;
  boolean span_need_fill;
  PVector seed=new PVector();
  ArrayList<PVector> st=new ArrayList<PVector>();
  seed.x=x;
  seed.y=y;
  
  st.add(seed.copy());
  while(!st.isEmpty()){
    seed=st.get(st.size()-1);
    st.remove(st.size()-1);
    x=(int)seed.x;
    y=(int)seed.y;
    while(true){
      
      if(y*width+x<0||y*width+x>width*height) {
        x++;
        continue;
      }
      if(pixels[y*width+x]!=old_color)break;
      
      plot(x,y,new_color);
      x++;
    }
    
    xr=x-1;
    x=(int)seed.x-1;
    while(true){
      
      if(y*width+x<0||y*width+x>=width*height) {
        x--;
        continue;
      }
      if(pixels[y*width+x]!=old_color)break;
      plot(x,y,new_color);
      x--;
    }
    
    xl=x+1;
    
    x=xl;
    
    y+=1;
    
    while(x<xr){
      span_need_fill=false;
      
      while(true){
        
        if(y*width+x<0||y*width+x>=width*height) {
          x++;
          continue;
        }
        if(pixels[y*width+x]!=old_color)break;
        span_need_fill=true;
        x++;
        
      }
      
      if(span_need_fill){
        seed.x=x-1;
        seed.y=y;
        st.add(seed.copy());
        span_need_fill=false;
        while(true) {
          if(y*width+x<0||y*width+x>=width*height) {
            x++;
            continue;
          }
          if(!(pixels[y*width+x]!=old_color && x<xr))break;
          x++;
          
        }
        
        if(x>=xr) break;
      }
      
      
      
    }
    
    x=xl;
    y=y-2;
    
    while(x<xr){
      span_need_fill=false;
      while(true){
        if(y*width+x<0||y*width+x>=width*height) {
          x++;
          continue;
        }
        if(pixels[y*width+x]!=old_color)break;
        span_need_fill=true;
        x++;
       
      
      }
      if(span_need_fill){
        seed.x=x-1;
        seed.y=y;
        st.add(seed.copy());
        span_need_fill=false;
         
        while(true) {
          if(y*width+x<0||y*width+x>=width*height) {
           x++;
           continue;
          }
            
          if(!(pixels[y*width+x]!=old_color && x<xr))break;
          x++;
          
        }
        
        if(x>=xr)break;
        
      }
      
    }
   
    
  }
  
  
  

}


void plot(int x,int y,color c){
  
  
  int index=y*width+x;
  if(index>=width*height || index<0) return;
  pixels[index]=c;  
  
}
