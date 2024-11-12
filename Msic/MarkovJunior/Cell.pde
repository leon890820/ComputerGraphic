public class Cell{
    Vector3 position = new Vector3();
    ColorState colorState = ColorState.B; 
    public Cell(){
    
    }
    public Cell(float x, float y){
        position = new Vector3(x,y,0);
    }
    public Cell(float x, float y, ColorState cs){
        position = new Vector3(x,y,0);
        colorState = cs;
    }   
    
    public void show(){
        noStroke();
        fill(getColor(colorState));
        rect(position.x * size, position.y * size ,size, size);        
    }
    




}
