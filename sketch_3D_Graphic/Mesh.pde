class Mesh {
  Vector3[] verties;
  Vector3[] TMverties;
  Vector3[] PMverties;
  int[] triangles;
  int[] uv_triangle;
  Vector3[] uv;
  Vector3[] nv;
  Vector3[] normal_vector;
  ShadeParameter shadeParameter;
  Matrix transform_matrix;
  String[] texture_name;
  int[] tc;
  PImage[] texture;

  Mesh(Vector3[] verties, int[] triangles, Vector3[] uv, int[] uv_triangle, ShadeParameter shadeParameter, int[] tc, String[] tn,Matrix transform) {
    this.verties=verties;
    this.TMverties=new Vector3[verties.length];
    this.PMverties=new Vector3[verties.length];
    this.triangles=triangles;
    this.uv=uv;
    this.uv_triangle=uv_triangle;   
    this.nv=new Vector3[triangles.length/3];
    this.normal_vector=new Vector3[triangles.length/3];
    this.shadeParameter=shadeParameter;
    this.tc=tc;
    this.texture_name=tn;
    
    this.transform_matrix=transform.copy();
    
    
    if (tc!=null) {
      texture=new PImage[tc.length];
      for (int i=0; i<texture.length; i+=1) {
        texture[i]=loadImage(texture_name[i]);
      }
    }
    reload();

  }
  Mesh() {
  }
  void reload(){
    set_transform_matrix();    
    set_PM_matrix();
    initNV();
  
  }
  
  void set_transform_matrix(){
    for(int i=0;i<verties.length;i+=1){
      TMverties[i]=Matrix.mult(verties[i],transform_matrix);
    }
  }
  
  void set_PM_matrix(){
    for(int i=0;i<verties.length;i+=1){
      Vector3 v=new Vector3(TMverties[i].x,TMverties[i].y,TMverties[i].z);
      PMverties[i]=Matrix.mult(v,EMPM_matrix);
      PMverties[i].perspective();
    }
  }

  void initNV() {
    int count=0;
    //println(number.length);
    for (int i=0; i<nv.length; i+=1) {      
      Vector3 v1=Vector3.sub(TMverties[triangles[count]], TMverties[triangles[count+1]]);
      Vector3 v2=Vector3.sub(TMverties[triangles[count+2]], TMverties[triangles[count+1]]);
      Vector3 v3=Vector3.cross(v1, v2);
      float d=Vector3.dot3(v3,TMverties[triangles[count]]);
      nv[i]=new Vector3(v3.x, v3.y, v3.z, d);
      count+=3;
    }
    count=0;
    for (int i=0; i<nv.length; i+=1) {      
      Vector3 v1=Vector3.sub(PMverties[triangles[count]], PMverties[triangles[count+1]]);
      Vector3 v2=Vector3.sub(PMverties[triangles[count+2]], PMverties[triangles[count+1]]);
      Vector3 v3=Vector3.cross(v1, v2);
      float d=Vector3.dot3(v3,PMverties[triangles[count]]);
      normal_vector[i]=new Vector3(v3.x, v3.y, v3.z, d);
      count+=3;
    }
  }

  

  void show() {
    if (verties==null||triangles==null) return;
    stroke(200);
    //noStroke();
    //fill(shader.c);
    noFill();
    int r=0;
    for (int i=0; i<triangles.length/3; i+=1) {
      beginShape();
      for (int j=0; j<3; j+=1) {
        vertex(map(verties[triangles[r+j]].x, -1, 1, 0, width), map( verties[triangles[r+j]].y, -1, 1, 0, height));
      }
      endShape(CLOSE);
      r+=3;   
    }
  }


  void zBuffer() {
    int count=0;

    for (int i=0; i<triangles.length/3; i+=1) {
      Vector3[] vs=new Vector3[3];
      for (int j=0; j<vs.length; j+=1) {
        vs[j]=PMverties[triangles[count+j]];
      }

      PVector xminmax=new PVector(1.0/0.0, -1.0, 0.0);
      PVector yminmax=new PVector(1.0/0.0, -1.0, 0.0);
      ;
      for (int j=0; j<vs.length; j+=1) {
        xminmax.x=min(vs[j].x, xminmax.x);
        xminmax.y=max(vs[j].x, xminmax.y);
        yminmax.x=min(vs[j].y, yminmax.x);
        yminmax.y=max(vs[j].y, yminmax.y);
      }
      xminmax.x=max(0, map(xminmax.x, -1, 1, 0, width));
      xminmax.y=min(width, map(xminmax.y, -1, 1, 0, width));
      yminmax.x=max(0, map(yminmax.x, -1, 1, 0, height));
      yminmax.y=min(height, map(yminmax.y, -1, 1, 0, height));


      for (int y=(int)yminmax.x; y<yminmax.y; y+=1) {
        for (int x=(int)xminmax.x; x<xminmax.y; x+=1) {
          int index=y*width+x;
          float mx=map(x, 0, width, -1, 1);
          float my=map(y, 0, height, -1, 1);

          if (!pnpoly(mx, my, vs)) {
            continue;
          }

          float z=(normal_vector[i].h-mx*normal_vector[i].x-my*normal_vector[i].y)/normal_vector[i].z;
          if (z<=dz[index]) {
            dz[index]=z;
            PImage image=null;
            if (tc!=null) {
              for (int s=0; s<tc.length; s+=1) {
                if (i<tc[s]) {
                  image=texture[s];
                  break;
                }
              }
            }
            Vector3 uv_color=caculateUV(new Vector3(mx, my, z), i*3, image);
            //Vector3 real_TMPoint=caculateTMPoint(new Vector3(mx, my, z),i*3);
            Vector3 c=calculateIlambda(TMverties[triangles[i*3]], nv[i], uv_color);

            cz[index]=color(c.x*255, c.y*255, c.z*255);
          }
        }
      }
     
      count+=3;
    }
  }
  Vector3 caculateTMPoint(Vector3 P, int count){
    Vector3 A=PMverties[triangles[count+0]];
    Vector3 B=PMverties[triangles[count+1]];
    Vector3 C=PMverties[triangles[count+2]];
    Vector3 A_uv=TMverties[triangles[count+0]];
    Vector3 B_uv=TMverties[triangles[count+0]];
    Vector3 C_uv=TMverties[triangles[count+0]];

    float t=((B.y-C.y)*(A.x-C.x)+(C.x-B.x)*(A.y-C.y));
    float BaryA=((B.y-C.y)*(P.x-C.x)+(C.x-B.x)*(P.y-C.y))/t;
    float BaryB=((C.y-A.y)*(P.x-C.x)+(A.x-C.x)*(P.y-C.y))/t;
    float BaryC=1-BaryA-BaryB;
    //println(BaryA,BaryB,BaryC);
    Vector3 P_TM=Vector3.add(Vector3.add(Vector3.mult(A_uv, BaryA), Vector3.mult(B_uv, BaryB)), Vector3.mult(C_uv, BaryC));
    //println(P_TM);
    return P_TM;
  }
  Vector3 caculateUV(Vector3 P, int count, PImage image) {
    
    if (uv==null||uv_triangle[count]>=uv.length || image==null) return shadeParameter.Olambda;
    Vector3 A=PMverties[triangles[count+0]];
    Vector3 B=PMverties[triangles[count+1]];
    Vector3 C=PMverties[triangles[count+2]];
    Vector3 A_uv=uv[uv_triangle[count+0]];
    Vector3 B_uv=uv[uv_triangle[count+1]];
    Vector3 C_uv=uv[uv_triangle[count+2]];

    float t=((B.y-C.y)*(A.x-C.x)+(C.x-B.x)*(A.y-C.y));
    float BaryA=((B.y-C.y)*(P.x-C.x)+(C.x-B.x)*(P.y-C.y))/t;
    float BaryB=((C.y-A.y)*(P.x-C.x)+(A.x-C.x)*(P.y-C.y))/t;
    float BaryC=1-BaryA-BaryB;
    //println(BaryA,BaryB,BaryC);
    Vector3 P_uv=Vector3.add(Vector3.add(Vector3.mult(A_uv, BaryA), Vector3.mult(B_uv, BaryB)), Vector3.mult(C_uv, BaryC));
    int x=int(map(P_uv.x, 0, 1, 0, image.width));
    int y=int(map(P_uv.y, 1, 0, 0, image.height));
    //println(A_uv);
    int pixel=image.pixels[y*image.width+x];

    int B_MASK = 255;
    int G_MASK = 255<<8; //65280
    int R_MASK = 255<<16; //16711680

    float r = float((pixel & R_MASK)>>16)/255;
    float g = float((pixel & G_MASK)>>8)/255;
    float b = float(pixel & B_MASK)/255;
    //println(r,g,b);
    return new Vector3(r, g, b);
  }

  Vector3 calculateIlambda(Vector3 position, Vector3 normal, Vector3 uv_color) {
    // println(position,normal);

    Vector3 n=normal;
    Vector3 I=Vector3.product(kala, uv_color);
    for (Light light : lights) {
      Vector3 l=Vector3.sub(light.location,position).norm();

      float cos_theda=Vector3.dot3(n, l);
      //println(n);
      if (cos_theda<0) cos_theda=0;//return new Vector3(0, 0, 0);
      Vector3 R=Vector3.sub(Vector3.mult(n, 2*cos_theda), l).norm();
      Vector3 v=Vector3.sub(position, cam.eye_position).norm();
      
      float cos_beta=Vector3.dot3(R, v);


      I=Vector3.add(I, Vector3.product(Vector3.mult(light.lp, cos_theda*shadeParameter.Kd), uv_color));
      //I=new Vector3();
      if (cos_beta>=0 && cos_beta<PI/2) {
        I=Vector3.add(I, Vector3.mult(light.lp, shadeParameter.Ks*pow(cos_beta, shadeParameter.N)));
      }
    }
    return I;
  }
  void drawUV() {
    int count=0;
    if (uv==null) return;
    for (int i=0; i<uv.length; i+=1) {
      stroke(0);
      beginShape();
      for (int j=0; j<3; j+=1) {
        float x=map(uv[uv_triangle[count+j]].x, 0, 1, 0, width);
        float y=map(uv[uv_triangle[count+j]].y, 1, 0, 0, width);
        vertex(x, y);
      }
      endShape(CLOSE);
      count+=3;
    }
  }
}

void drawdz(int x0, int y0, int x1, int y1, color c, Vector3 normal_vector) {
  //println(x0,y0,x1,y1);
  boolean steep=abs(y1-y0)>abs(x1-x0);
  if (steep) {
    int tmp=x0;
    x0=y0;
    y0=tmp;

    int tmp1=x1;
    x1=y1;
    y1=tmp1;
  }
  if (x0>x1) {
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
  for (int x=(int)x0; x<x1; x+=1) {
    if (x>=width || y>=height || x<0 || y<0) continue;
    if (steep) {
      float mx=map(y, 0, height, -1, 1);
      float my=map(x, 0, width, -1, 1);
      float z=(normal_vector.h-mx*normal_vector.x-my*normal_vector.y)/normal_vector.z;
      int index=x*width+y;

      if (z<=dz[index]) {

        dz[index]=z;
        cz[index]=c;
      }
    } else {
      float mx=map(x, 0, height, -1, 1);
      float my=map(y, 0, width, -1, 1);
      float z=(normal_vector.h-mx*normal_vector.x-my*normal_vector.y)/normal_vector.z;
      //println(z);
      int index=y*width+x;
      if (z<=dz[index]) {

        dz[index]=z;
        cz[index]=c;
      }
    }
    error-=deltaY;
    if (error<0) {
      y+=ystep;
      error+=deltaX;
    }
  }
}
