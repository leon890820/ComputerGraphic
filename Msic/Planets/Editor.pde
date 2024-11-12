class Editor {
  ColorType meshColor=new ColorType(new PVector(255,255,255)); 
  BooleanType showgrid=new BooleanType(false);
  FloatType radius=new FloatType(100);
  FloatType resolution=new FloatType(40);
  FloatType roughness=new FloatType(1.1);
  FloatType baseRoughness=new FloatType(3.1);
  FloatType persistance=new FloatType(1.28);
  FloatType numLayers=new FloatType(3.4);
  FloatType strength=new FloatType(0.26);
  FloatType minValue=new FloatType(3.3);
}
class ColorType extends ChangableObject<Integer> {
    ColorType(PVector value) {
      colorMode(HSB);
      type=color(value.x,value.y,value.z);
    }
  }

class BooleanType extends ChangableObject<Boolean> {
    BooleanType(boolean value) {
      type=value;
    }
  }
  
class FloatType extends ChangableObject<Float> {
    FloatType(float value) {
      type=value;
    }
  }
class IntType extends ChangableObject<Integer> {
    IntType(int value) {
      type=value;
    }
  }
class ChangableObject<T> {
  T type;
}

class ShapeGenerator {
  Editor editor;
  ShapeGenerator(Editor editor) {
    this.editor=editor;
  }

  float evaluate(PVector point) {

    float value=0;
    float amplitude=1;
    float frequence=editor.baseRoughness.type;
    for(int i=0;i<editor.numLayers.type;i+=1){
      float v=(noise((point.x+1)*frequence, (point.y+1)*frequence, (point.z+1)*frequence));
      value+=v*amplitude;
      amplitude*=editor.persistance.type;
      frequence*=editor.roughness.type;
    }
    
    value=max(0,value-editor.minValue.type);
    return (value*editor.strength.type+1)*editor.radius.type;
  }
}
