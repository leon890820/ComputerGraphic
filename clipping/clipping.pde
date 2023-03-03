PVector[] view_points;
PVector[] polygon_points;

void setup(){
  size(600,600);
  background(0);

  
  initViewPoint();
  initPolygonPoint(); 
  run();

  
  
  //print(pnpoly(93,132-50,view_points));
  
}
void draw(){
  background(0);
  initViewPoint();
  run();

}


void run(){
  ArrayList<PVector> points=Sutherland_Hodgman_algorithm();
  //print(points.size());
  
  //fill(255);
  stroke(255);
  fill(255);
  beginShape();
  for(int i=0;i<view_points.length;i+=1){       
    vertex(view_points[i].x,view_points[i].y);    
  }
  endShape(CLOSE);
  
  stroke(255,0,0);
  fill(255,0,0);
  beginShape();
  for(PVector p:points){      
    vertex(p.x,p.y);    
  }
  endShape(CLOSE);

}

ArrayList Sutherland_Hodgman_algorithm(){
  ArrayList<PVector> output_list=new ArrayList<PVector>();
  for(PVector p:polygon_points) output_list.add(p);
  
  for(int i=0;i<view_points.length;i+=1){
    ArrayList<PVector> input_list=new ArrayList<PVector>();
    clone(input_list,output_list);
    output_list.clear();
    
    for(int j=0;j<input_list.size();j+=1){
      PVector current_point=input_list.get(j);
      PVector prev_point=input_list.get((j-1+input_list.size())%input_list.size());
      
      PVector intersecting_point=computeIntersection(prev_point,current_point,view_points[(i-1+view_points.length)%view_points.length],view_points[i]);
      
      if(inside_line(current_point.x,current_point.y,view_points[(i-1+view_points.length)%view_points.length],view_points[i])){
        if(!inside_line(prev_point.x,prev_point.y,view_points[(i-1+view_points.length)%view_points.length],view_points[i])){
          output_list.add(intersecting_point);
        }
        output_list.add(current_point);
      }else if(inside_line(prev_point.x,prev_point.y,view_points[(i-1+view_points.length)%view_points.length],view_points[i])){
        output_list.add(intersecting_point);
      }
    
    }
  
  
  
  
  
  }
  return output_list;
}

boolean inside_line(float x,float y,PVector p1,PVector p2){
  if((p2.x-p1.x)*(y-p1.y)-(p2.y-p1.y)*(x-p1.x)<0) return true;
  else return false;
}

PVector computeIntersection(PVector p1,PVector p2,PVector p3,PVector p4){
  float D=(p1.x-p2.x)*(p3.y-p4.y)-(p1.y-p2.y)*(p3.x-p4.x);
  float t=((p1.x-p3.x)*(p3.y-p4.y)-(p1.y-p3.y)*(p3.x-p4.x))/D;
  float u=((p1.x-p3.x)*(p1.y-p2.y)-(p1.y-p3.y)*(p1.x-p2.x))/D;
  
  return new PVector(p1.x+t*(p2.x-p1.x),p1.y+t*(p2.y-p1.y));
  

}

boolean pnpoly(float x, float y, PVector[] v) {
  boolean c=false;

  for (int i=0, j=v.length-1; i<v.length; j=i++) {
    if (((v[i].y>y)!=(v[j].y>y))&&(x<(v[j].x-v[i].x)*(y-v[i].y)/(v[j].y-v[i].y)+v[i].x)) {
      c=!c;
    }
    float m=(v[j].y-v[i].y)/(v[j].x-v[i].x);
    //if((x-v[i].x)*m==y-v[i].y) return false;
    //if(y==v[i].y && y==v[j].y) return false;
    
  }
  
  
  
  return c;
}


void clone(ArrayList a,ArrayList b){
  for(Object o:b){
    a.add(o);
  }
}

void initViewPoint(){
  view_points=new PVector[4];
  view_points[0]=new PVector(mouseX-50,mouseY-50);
  view_points[1]=new PVector(mouseX-50,mouseY+50);
  view_points[2]=new PVector(mouseX+50,mouseY+50);
  view_points[3]=new PVector(mouseX+50,mouseY-50);
}

void initPolygonPoint(){
  polygon_points=new PVector[4];
  polygon_points[0]=new PVector(50,120);
  polygon_points[1]=new PVector(120,180);
  polygon_points[2]=new PVector(180,120);
  polygon_points[3]=new PVector(120,50);

}
