public class UI extends PApplet {
    ControlP5 cp5;
    int slider = 10;
    UI() {
        super();
        PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
    }

    void settings() {
        size(600, 600);
        
    }
    
    void setup(){
         cp5 = new ControlP5(this);
          cp5.addSlider("slider");
          cp5.addSlider("slider1");
          cp5.addSlider("slider2");
    }
    
    void draw(){
        background(0);
        println(slider);
    }
}
