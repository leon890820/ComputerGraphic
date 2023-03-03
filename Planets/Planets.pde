import peasy.*;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
PeasyCam cam;

Planet planet;
Editor editor;
ArrayList<GUI> guis;

void setup() {
  size(800, 600, P3D);
  cam=new PeasyCam(this, 100);
  editor=new Editor();
  noiseSeed(561564894);
  guis=new ArrayList<GUI>();
  createGUI();
  
 
  
  
  background(0);
}

void draw() {
  background(0);


  lights();
  pushMatrix();
  translate(-100,0);
  planet=new Planet();
  popMatrix();

  cam.beginHUD();
  GUI();
  cam.endHUD();
  
  //noLights();
  
}



void GUI(){
  fill(200);
  noStroke();
  rect(600, 0, 200, 600);
  for(GUI g:guis){
    g.run();
  }

}

void createGUI(){
  CheckBox gridCheckBox=new CheckBox(610,20,15,15,"Grid",editor.showgrid);
  SliderBox radiusSliderBox=new SliderBox(610,50,10,10,"Radius",50,150,editor.radius);
  SliderBox resolutionSliderBox=new SliderBox(610,80,10,10,"Resolution",2,100,editor.resolution);
  ShaderGUI shaderColor=new ShaderGUI(660,200,80,80,editor.meshColor);
  SliderBox roughnessSliderBox=new SliderBox(610,350,10,10,"Roughness",0,5,editor.roughness); 
  SliderBox baseRoughnessSliderBox=new SliderBox(610,380,10,10,"BaseRoughness",0,5,editor.baseRoughness); 
  SliderBox persistenceSliderBox=new SliderBox(610,410,10,10,"Persistance",0,2,editor.persistance); 
  SliderBox numberLayerSliderBox=new SliderBox(610,440,10,10,"NumLayers",1,5,editor.numLayers); 
  SliderBox strengthSliderBox=new SliderBox(610,470,10,10,"Strength",0,1,editor.strength); 
  SliderBox minValueSliderBox=new SliderBox(610,500,10,10,"MinValue",0,5,editor.minValue);
  guis.add(gridCheckBox);
  guis.add(radiusSliderBox);
  guis.add(resolutionSliderBox);
  guis.add(shaderColor);
  guis.add(roughnessSliderBox);
  guis.add(baseRoughnessSliderBox);
  guis.add(persistenceSliderBox);
  guis.add(numberLayerSliderBox);
  guis.add(strengthSliderBox);
  guis.add(minValueSliderBox);
}

void keyPressed() {

}
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
}
