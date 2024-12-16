public class Fluid extends GameObject{
    Vector3 velosity = new Vector3();
    Vector3 acceleration = new Vector3();
    float radius = 0.0;
    float mass = 1.0;
    float kernelRadius = 1.0;
    
    public Fluid(){
        acceleration.set(0,GH_GRAVITY,0);
    }
    
    @Override
    public void update(){
        velosity = velosity.add(acceleration.mult(dt));
        transform.position = getPosition().add(velosity.mult(dt));    
        
        Vector3 halfBoundSize = boundSize.mult(0.5).sub(new Vector3(radius,radius,0));
        if(abs(transform.position.x) > halfBoundSize.x){
            transform.position.x = halfBoundSize.x * sign(transform.position.x);
            velosity.x *= -1 * damp;
        }
        if(abs(transform.position.y) > halfBoundSize.y){
            transform.position.y = halfBoundSize.y * sign(transform.position.y);
            velosity.y *= -1 * damp;
        }
        
        
        
        
    }
    
    //public float calculateDensity(){
    //    float density = 0.0;
    //    for(Fluid f : fluids){
    //        if(f == this) continue;
    //        float dst = this.transform.position.sub(f.transform.position).length();
    //        float influence = smoothingKernel(kernelRadius,dst);
    //        density += influence * f.mass;
    //    }
        
    //    return density;
    //}
    
    
    //public float smoothingKernel(float kernelRadius, float dst){
    //    float volume = PI * pow(kernelRadius , 8) / 4;
    //    float value = max(0.0 , kernelRadius * kernelRadius - dst*dst);
        
    //    return value * value * value / volume;
        
    //}


}
