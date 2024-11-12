public class FBO extends Texture{
    public FBO(int w,int h){
        super(w,h);
    }
    
    public void bindFrameBuffer(){
        loadPixels();        
        img.pixels = pixels;         
        img.updatePixels();
        background(0);
    }
    
}
