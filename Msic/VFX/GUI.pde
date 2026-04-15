class GUIManager extends PApplet{
    ControlP5 cp5;
    ArrayList<SliderRequest> pendingSliders = new ArrayList<>();
    GUIManager(){
        super();
        PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);

    }
    
    void settings() {
       
        size(200, 200);
    }
    
    void setup() {
        cp5 = new ControlP5(this);
        background(0);

        for (SliderRequest req : pendingSliders) {
            addSliderNow(req.object, req.value, req.name, req.pos, req.range);
        }
        pendingSliders.clear(); // 清除 queue
    }
    
    void draw() {

    }
     void addSlider(Object object, float value, String name, Vector3 pos, Vector3 range) {
        if (cp5 == null) {
            pendingSliders.add(new SliderRequest(object, value, name, pos, range));
        } else {
            addSliderNow(object, value, name, pos, range);
        }
    }
    
     void addSliderNow(Object object, float value, String name, Vector3 pos, Vector3 range) {
        cp5.addSlider(name)
           .setPosition(pos.x, pos.y)
           .setRange(range.x, range.y)
           .setValue(value)
           .plugTo(object, name);
    }
    
   void exit() {
      dispose();      
   }
   
   
   class SliderRequest {
        Object object;
        float value;
        String name;
        Vector3 pos;
        Vector3 range;

        SliderRequest(Object o, float v, String n, Vector3 p, Vector3 r) {
            object = o;
            value = v;
            name = n;
            pos = p;
            range = r;
        }
    }

}
