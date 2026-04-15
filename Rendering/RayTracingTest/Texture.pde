public class Texture{
    PImage img;    
    IntBuffer tex;
    
    public Texture(int w,int h){
        tex = IntBuffer.allocate(1);
        gl3.glGenTextures(1 , tex);
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
        ((PGraphicsOpenGL)g).textureSampling(m);
        return this;
    }

}
