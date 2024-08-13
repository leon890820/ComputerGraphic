public class FBO{
    Texture tex;
    public FBO(){
        tex = new Texture(width,height);
    }
    
    public void bindFrameBuffer(){

        loadPixels();        
        tex.img.pixels = pixels;         
        tex.img.updatePixels();
        background(0);
    }
    
}
