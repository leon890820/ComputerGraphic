public class PhongObject extends GameObject{
       
    public PhongObject(String mesh){
        shape = loadShape(mesh);
    }
    
    public PhongObject(String mesh,String frag){
        shape = loadShape(mesh);
        shader = loadShader(frag);
    }
    
    public PhongObject(String mesh,String frag,String vert){
        shape = loadShape(mesh);
        shader = loadShader(frag, vert);
    }
    
    @Override
    public void draw(){
        shader(shader);
        shader.set("MVP",MVP().transposed().toPMatrix());
        shader.set("modelMatrix",localToWorld().transposed().toPMatrix());
        shader.set("light_dir",main_light.light_dir.x,main_light.light_dir.y,main_light.light_dir.z);
        
        shader.set("ambient_light",AMBIENT_LIGHT.x,AMBIENT_LIGHT.y,AMBIENT_LIGHT.z);
        shader.set("albedo", albedo.x, albedo.y, albedo.z);
        shader.set("light_color", main_light.light_color.x, main_light.light_color.y, main_light.light_color.z);
        shader.set("view_pos", main_camera.pos.x,main_camera.pos.y,main_camera.pos.z);
        
        shape(shape);
    }
    

}
