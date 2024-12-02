PImage room;
int[] roomLight;

void setup(){
    size(600,600);
    room = loadImage("Textures/room.png");
    init();
    roomLight = new int[width * height];
    
    for(int i = 0; i < height; i++){       
        for(int j = 0; j < width; j++){
            int x = (int)map(j , 0 , width - 1 ,0 , room.width - 1);
            int y = (int)map(i , 0 , height - 1 ,0 , room.height - 1);
            int indexR = y * room.width + x;
            int index = i * width + j;
            roomLight[index] = room.pixels[indexR];
        }
    }

    
    //image(room , 0 ,0);
}

void copyLight(int[] a, int b[]){
    for(int i = 0; i < a.length; i ++){
        a[i] = b[i];
    }
}


void draw(){
    sample();
    
    loadPixels();
    copyLight(roomLight , pixels);
    updatePixels();
}

public boolean isWall(Vector3 v){
    return v.x == 255.0 && v.y == 255.0 && v.z == 255.0 ? false : true;
}


public void sample(){        
    loadPixels();
    for(int y = 0; y < height; y++){    
        println(y / (float)height * 100 + "%");
        for(int x = 0; x < width; x++){
            int index = y * width + x;
            Vector3 light = intergerToRGB(roomLight[index]);
            float brightness = max(light.x , max(light.y, light.z));
            for(float n = 0; n < 360; n++){
                float a = n * PI / 180;
                Vector3 hit_color = rayRrace(new Vector3(x,y,0) , new Vector3(cos(a),sin(a),0));
                light = light.add(hit_color);
                brightness += max(hit_color.x , max(hit_color.y , hit_color.z));
            }
            
            light = light.dive(brightness).mult(brightness / 360.0);
            
            pixels[index] = color(light.x, light.y, light.z);
        }
    }
    updatePixels();

}


public Vector3 rayRrace(Vector3 v , Vector3 dir){
       
    for(int i = 0 ;i < 1000; i++){
        Vector3 position = v.add(dir.mult(i));        
        if(outOfBoundary(position)) break;
        int index = (int)position.y * width + (int)position.x;
        Vector3 c = intergerToRGB(roomLight[index]);
        if(isWall(c)) return c;
    }
    
    return new Vector3(0.0);
}

public void init(){
    loadPixels();
    for(int i = 0; i < height; i++){
        for(int j = 0; j < width; j++){
            int index = i * width + j;
            pixels[index] = color(0,0,0);
        }
    
    }        
    updatePixels();
}
