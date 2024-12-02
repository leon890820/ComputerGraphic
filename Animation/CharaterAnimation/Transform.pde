public class Transform{
    Vector3 position;
    Vector3 eular;
    Vector3 scale;
    Transform(){
        position = Vector3.Zero();
        eular = Vector3.Zero();
        scale = Vector3.Ones();
    }
     
    public Transform setPosition(Vector3 position){
        this.position = position;
        return this;
    }
    
    public Transform setEular(Vector3 eular){
        this.eular = eular;
        return this;
    }
    
    public Transform setScale(Vector3 scale){
        this.scale = scale;
        return this;
    }
    
    public Transform setPosition(float x,float y,float z){
        this.position.set(x,y,z);
        return this;
    }
    
    public Transform setEular(float x,float y,float z){
        this.eular.set(x,y,z);
        return this;
    }
    
    public Transform setScale(float x,float y,float z){
        this.scale.set(x,y,z);
        return this;
    }
    
    @Override
    public String toString(){
        return "Position : " + position.toString() + "\n" +
               "Eular : "    + eular.toString()    + "\n" +
               "Scale : "    + scale.toString()    + "\n";
    }
    
    
}
