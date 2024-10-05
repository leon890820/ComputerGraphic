public abstract class GameObject{
    Vector3 pos;
    Vector3 velosity;

    GameObject(){   
        pos = new Vector3();
        velosity = new Vector3();
    }
        
    public GameObject setPos(float x,float y,float z){
        pos.set(x,y,z);
        return this;
    }
    
    
    
}

public class Liquid extends GameObject{
    float density;
    public Liquid(){}
    
    public void update(int i,float densityRadius){
        Vector3 accelerate = calcPressure(i,densityRadius);  
        velosity = velosity.add(accelerate.mult(dt));
        velosity = velosity.mult(0.99);
        pos = pos.add(velosity.mult(dt));
        if(pos.x < -10){
            pos.x = -10;
            velosity.x *= -1;
        }
        if(pos.y < -10){
            pos.y = -10;
            velosity.y *= -1;
        }
        if(pos.x > 10){
            pos.x = 10;
            velosity.x *= -1;
        }
        if(pos.y > 10){
            pos.y = 10;
            velosity.y *= -1;
        }
    }
    
    public void show(){
        fill(255);
        noStroke();
        float x = map(pos.x,-10,10,0,width);
        float y = map(pos.y,-10,10,0,height);
        circle(x,y,5);
    }
    
    public void density(int i,float densityRadius){
        density = calcDensity(i,densityRadius);
    }


}
