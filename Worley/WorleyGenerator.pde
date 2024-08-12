class WorleyGenerator{  
    boolean invert = true;
    int img_size;
    
    WorleyGenerator(int is){
        img_size = is;
        
    }
    
    public PImage[] run(){
        ShapeSetting shapeSetting1 = new ShapeSetting(3  ,7 ,11,0.65); 
        ShapeSetting shapeSetting2 = new ShapeSetting(9  ,15,23,0.33);
        ShapeSetting shapeSetting3 = new ShapeSetting(13 ,28,42,0.58);
        PImage[] shapeImageChannelR = generate(shapeSetting1,Channel.R);  
        PImage[] shapeImageChannelG = generate(shapeSetting2,Channel.G);  
        PImage[] shapeImageChannelB = generate(shapeSetting3,Channel.B);  
        
        PImage[] shapeImage = merge( shapeImageChannelR , shapeImageChannelG , shapeImageChannelB);
        //gray(shapeImageChannelB,Channel.B);
        //show(shapeImage);
        return shapeImage;
    }
    
    public void gray(PImage img,Channel channel){
        for(int i=0;i<img.pixels.length;i++){
            float[] rgb = intToColor(img.pixels[i]);
            switch(channel){
                    case R:
                        img.pixels[i] = color(rgb[0]*255 , rgb[0]*255 , rgb[0]*255 );
                        break;
                    case G:
                        img.pixels[i] = color(rgb[1]*255 , rgb[1]*255 , rgb[1]*255);
                        break;
                    case B:
                        img.pixels[i] = color(rgb[2]*255 , rgb[2]*255 , rgb[2]*255);
                        break;
                    case A:
                        img.pixels[i] = color(rgb[0]*255 ,rgb[0]*255 , rgb[0]*255 ,0);
                        break;
                }
            
        }
    }
    
    public PImage[] merge(PImage[] R,PImage[] G,PImage[] B){
        PImage[] imgs = new PImage[img_size];
        for(int k=0;k<R.length;k++){
            PImage img = new PImage(img_size,img_size);
            for(int i=0;i<img.pixels.length;i++){
                int pr = R[k].pixels[i];  
                int pg = G[k].pixels[i];    
                int pb = B[k].pixels[i];
                int result = pr|pg|pb;
                img.pixels[i] = result;
            }
            imgs[k] = img;
        }
        return imgs;
    }
    
    
    
    
    public PImage[] generate(ShapeSetting shapeSetting , Channel channel){
        Vector3[] pointsA = setPoints(shapeSetting.numberDivisionA);
        Vector3[] pointsB = setPoints(shapeSetting.numberDivisionB);
        Vector3[] pointsC = setPoints(shapeSetting.numberDivisionC);
        
        PImage[] worleyA = generateImg(shapeSetting.numberDivisionA ,pointsA ,channel);
        PImage[] worleyB = generateImg(shapeSetting.numberDivisionB ,pointsB ,channel);
        PImage[] worleyC = generateImg(shapeSetting.numberDivisionC ,pointsC ,channel);
        PImage[] worleyImg = fractalWorley(new PImage[][]{worleyA,worleyB,worleyC} ,shapeSetting.persistence);
        normalize(worleyImg);
        if(invert) invert(worleyImg,channel);        
        return worleyImg;
        //show(worleyImg);
    
    }
    
    public PImage[] fractalWorley(PImage[][] imgs,float persistence){
        PImage[] result_imgs = new PImage[img_size];
        for(int k=0;k<result_imgs.length;k++){
        
            PImage img = new PImage(img_size,img_size);        
            for(int y=0;y<img.height;y++){
                for(int x=0;x<img.width;x++){
                    int index = y*img.width + x;
                    float r = 0; float g = 0; float b = 0;
                    for(int i=0;i<imgs.length;i++){
                        float p = pow(persistence,i);                        
                        float[] rgb = intToColor(imgs[i][k].pixels[index]);
                        r+=rgb[0]*p; g+=rgb[1]*p; b+=rgb[2]*p;
                    }      //<>//
                    
                    img.pixels[index] = color(r * 255,g * 255,b * 255);
                }
            }
            result_imgs[k] = img;
            
        }
        return result_imgs;
    }
    
    
    public float[] intToColor(int pixel){
        int B_MASK = 255;
        int G_MASK = 255<<8; //65280 
        int R_MASK = 255<<16; //16711680

        float r = (pixel & R_MASK)>>16;
        float g = (pixel & G_MASK)>>8;
        float b = pixel & B_MASK;
        

        return new float[]{r/255.0 ,g/255.0 ,b/255.0};
    }
    
    public Vector3[] setPoints(int resolution){    
        float slice_size = 1.0/ (float)resolution;
        Vector3[] points = new Vector3[resolution * resolution * resolution]; 
        for(int i=0;i<resolution;i++){
            for(int j=0;j<resolution;j++){
                for(int k=0;k<resolution;k++){
                    Vector3 p = new Vector3(k*slice_size,j*slice_size,i*slice_size);
                    Vector3 r = new Vector3(random(1)*slice_size,random(1)*slice_size,random(1)*slice_size);
                    int index = i*resolution*resolution + j*resolution + k;
                    points[index] = p.add(r);     
                }
            }
        }
        return points;
    
    }
    
    
    public PImage[] generateImg(int resolution,Vector3[] points,Channel channel){
        PImage[] imgs = new PImage[img_size];
        
        for(int k=0;k<img_size;k++){
            PImage img = new PImage(img_size,img_size);
            for(int i=0;i<img_size;i++){
                for(int j=0;j<img_size;j++){
                    int index = i*img_size + j;
                    float worleyDist = findMinDist(new Vector3((float)j/(float)img_size,(float)i/(float)img_size,(float)k/(float)img_size),resolution,points);    
                    switch(channel){
                        case R:
                            img.pixels[index] = color(worleyDist*255 , 0 , 0 , 0);
                            break;
                        case G:
                            img.pixels[index] = color(0 , worleyDist*255 , 0 , 0);
                            break;
                        case B:
                            img.pixels[index] = color(0 , 0 , worleyDist*255 , 0);
                            break;
                        case A:
                            img.pixels[index] = color(0 , 0 , 0 ,worleyDist*255);
                            break;
                    }
                }
            }        

            imgs[k] = img;
        }
        return imgs;
    
    }
    
    private void normalize(float[] f){
        float record = 0;
        for(int i=0;i<f.length;i++){
            record = max(record,f[i]);
        }
        for(int i=0;i<f.length;i++){
            f[i]/=record;
        }
        
    }
    
    private void normalize(PImage[] p){
        float recordR = -10000;
        float recordG = -10000;
        float recordB = -10000;
        
        for(int j=0;j<p.length;j++){
            for(int i=0;i<p[j].pixels.length;i++){
                float[] rgb = intToColor(p[j].pixels[i]);
                
                recordR = max(recordR,rgb[0]);
                recordG = max(recordG,rgb[1]);
                recordB = max(recordB,rgb[2]);
            }
        }
        
        for(int j=0;j<p.length;j++){
            for(int i=0;i<p[j].pixels.length;i++){
                float[] rgb = intToColor(p[j].pixels[i]);             
                p[j].pixels[i] = color(rgb[0]/recordR * 255,rgb[1]/recordG * 255,rgb[2]/recordB * 255);
                
            }
        }
        
        
    }
    
    private void invert(PImage[] p,Channel channel){       
        for(int j=0;j<p.length;j++){
            for(int i=0;i<p[j].pixels.length;i++){
                float[] rgb = intToColor(p[j].pixels[i]);
                switch(channel){
                    case R:
                        p[j].pixels[i] = color( (1 - rgb[0]) * 255 ,rgb[1] * 255 , rgb[2] * 255);
                        break;
                    case G:
                        p[j].pixels[i] = color( rgb[0] * 255 ,(1 - rgb[1]) * 255 ,rgb[2] * 255);
                        break;
                    case B:
                        p[j].pixels[i] = color( rgb[0] * 255 ,rgb[1] * 255 ,(1 - rgb[2]) * 255);
                        break;
                    case A:
                        break;
                }
                
            }   
        }
    }
    
    private void invert(float[] f){
        for(int i=0;i<f.length;i++){
            f[i] = 1-f[i];
        }
    }
    
    private float findMinDist(Vector3 v,int resolution,Vector3[] points){
        int cx = int(v.x*resolution);
        int cy = int(v.y*resolution);
        int cz = int(v.z*resolution);
        float record = 1000000;
        for(int k=-1;k<=1;k++){
            for(int i=-1;i<=1;i++){
                for(int j=-1;j<=1;j++){
                    
                    Vector3 offest_point = new Vector3(cx+j,cy+i,cz+k);
                    if(offest_point.minComponent()==-1 || offest_point.maxComponent()==resolution){
                        offest_point = new Vector3((offest_point.x + resolution)%resolution,(offest_point.y + resolution)%resolution,(offest_point.z + resolution)%resolution);
                        int index = (int)offest_point.z*resolution*resolution + (int)offest_point.y * resolution + (int)offest_point.x;
                        for(int rk=-1;rk<=1;rk++){
                            for(int ri=-1;ri<=1;ri++){
                                for(int rj=-1;rj<=1;rj++){
                                    Vector3 point = points[index].add(new Vector3(rj,ri,rk));
                                    float d = distSquare(point,v);
                                    record = min(d,record);
                                }
                            }
                        }
                        
                    }else{
                        int index = (int)offest_point.z*resolution*resolution + (int)offest_point.y * resolution + (int)offest_point.x;
                        Vector3 point = points[index];                     
                        float d = distSquare(point,v);
                        record = min(d,record);
                    }
                    
                    
                    
                }
            }
        }
        //println(record);
        return sqrt(record);
    }
    
    private float distSquare(Vector3 a,Vector3 b){
        return (a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y) + (a.z-b.z)*(a.z-b.z);
    }
    
    public void saveImage(PImage[] imgs){
        String path = "/data/worley_noise/";        
        for(int i=0;i<imgs.length;i++){
           image(imgs[i],0,0);
           save(path+"worley_"+i+".png");
        }
    }
    
    public PImage[] loadWorleyImage(){
        String path = "/data/worley_noise/";
        String path_name = sketchPath("");
        File f = new File(path_name+path);
        int num = f.listFiles().length;
        PImage[] imgs = new PImage[num];
        for(int i=0;i<num;i++){
            imgs[i] =  loadImage(path + "worley_" + i + ".png");
        }
        return imgs;
        
    }
    
    
    public void show(PImage[] imgs){
        int d = floor(map(sliceDepth,0,1,0,img_size-1));
        image(imgs[d],0,0);        
    }

}
