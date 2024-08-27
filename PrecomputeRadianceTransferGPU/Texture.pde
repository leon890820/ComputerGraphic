public class Texture{
    PImage img;
    
    public Texture(int w,int h){
        img = createImage(w,h,ARGB);
    }
    
    public Texture(String s){
        img = loadImage(s);
    }
    
    public Texture setTexture(String s){
        img = loadImage(s);
        return this;
    }
    
    public Texture setTexture(PImage img){
        this.img = img;
        return this;
    }
    
    public Texture setWrapMode(int m){
        textureWrap(m); 
        return this;
    }
    
    public Texture setSamplingMode(int m){
        ((PGraphicsOpenGL)img).textureSampling(m);
        return this;
    }

}
