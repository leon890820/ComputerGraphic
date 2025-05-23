public class Fluid extends GameObject {
    Vector3 velosity = new Vector3();
    Vector3 acceleration = new Vector3();
    Vector3 force = new Vector3();
    float radius = 0.0;
    float mass = 1.0;
    //float kernelRadius = 1.0;
    float density = 0.0;
    
    
    
    public Fluid(){
        acceleration.set(0,GH_GRAVITY,0);
    }
    
    @Override
    public void update(){
        
        acceleration = force.mult(1 / density);
        
        
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
    

    
    public float calculateDensity(){
         Vector3 predictPosition = transform.position.add(velosity.mult(dt));
        float density = 0.0;
        int s = int(kernelRadius) + 1;
        int[] pos = positionToCellCoord(predictPosition);
        for(int y = -s; y <= s; y++) for(int x = -s; x <= s; x++){
            if(pos[1] + y < 0 || pos[1] + y >= boundSize.y || pos[0] + x < 0 || pos[0] + x >= boundSize.x) continue;
            for(Icosahedron f : fluidsCell[pos[1] + y][pos[0] + x]){
                Vector3 fPredictPosition = f.transform.position.add(f.velosity.mult(dt));
                float dst = predictPosition.sub(fPredictPosition).length();
                float influence = smoothingKernel(kernelRadius,dst);
                density += influence * f.mass;
            }
        }

        
       
        
        return density;
    }
    
    float convertDensityToPressure(float density){
        float densityError = density - targetDensity;
        float pressure = densityError * pressureMutiplyer;
        
        return pressure;
    }
    
    public float calculateSharedPressure(float densityA, float densityB){
        float pA = convertDensityToPressure(densityA);
        float pB = convertDensityToPressure(densityB);
        return (pA + pB) / 2.0;
    }
    
    public Vector3 calculateViscosityForce(){
        Vector3 viscosityForce = new Vector3();
        Vector3 predictPosition = transform.position.add(velosity.mult(dt));
        int s = int(kernelRadius) + 1;
        int[] pos = positionToCellCoord(predictPosition);
        for(int y = -s; y <= s; y++) for(int x = -s; x <= s; x++){
           if(pos[1] + y < 0 || pos[1] + y >= boundSize.y || pos[0] + x < 0 || pos[0] + x >= boundSize.x) continue;
           for(Icosahedron f : fluidsCell[pos[1] + y][pos[0] + x]){
               Vector3 fPredictPosition = f.transform.position.add(f.velosity.mult(dt));
               float dst = predictPosition.sub(fPredictPosition).length();
               float influence = viscositySmoothingKernel(kernelRadius , dst);
               viscosityForce = viscosityForce.add(f.velosity.sub(velosity).mult(influence));
           }
        }

        return viscosityForce.mult(viscosityStrength);
    }
    
    public Vector3 calculatePressureForce(){
        Vector3 predictPosition = transform.position.add(velosity.mult(dt));
        Vector3 property = new Vector3(0.0);
        int s = int(kernelRadius) + 1;
        int[] pos = positionToCellCoord(predictPosition);
        for(int y = -s; y <= s; y++) for(int x = -s; x <= s; x++){
           if(pos[1] + y < 0 || pos[1] + y >= boundSize.y || pos[0] + x < 0 || pos[0] + x >= boundSize.x) continue;
           for(Icosahedron f : fluidsCell[pos[1] + y][pos[0] + x]){
               if(f == this) continue;
               Vector3 fPredictPosition = f.transform.position.add(f.velosity.mult(dt));
               float dst = predictPosition.sub(fPredictPosition).length();
               if(dst < 1E-6) continue;
               Vector3 dir = predictPosition.sub(fPredictPosition).unit_vector();
               float slope = smoothingKernelDerivative(kernelRadius,dst);
               float sharedPressure = calculateSharedPressure(density, f.density);
               property = property.sub(dir.mult(sharedPressure * slope * f.mass / f.density));
           }
        }

        
        
        return property;
    }
    


    float smoothingKernelDerivative(float kernelRadius, float dst){
        if(dst > kernelRadius) return 0;
        
        float scale = 12.0 / (PI * pow(kernelRadius , 4));
        return scale * (dst - kernelRadius);    
    }
    
    public float smoothingKernel(float kernelRadius, float dst){
        if(dst > kernelRadius) return 0;
        float volume = PI * pow(kernelRadius , 4) / 6;        
        return (kernelRadius - dst)*(kernelRadius - dst) / volume;      
    }
    
    public float viscositySmoothingKernel(float kernelRadius, float dst){
        if(dst > kernelRadius) return 0;
        float volume = PI * pow(kernelRadius , 8) / 4;     
        float value = max(0, kernelRadius * kernelRadius - dst * dst);
        return value * value * value / volume;      
    }



}

public class Entry{
    long cellKey;
    int particleIndex;
    
    public Entry(long ck, int i){
        cellKey = ck;
        particleIndex = i;
    }
}
