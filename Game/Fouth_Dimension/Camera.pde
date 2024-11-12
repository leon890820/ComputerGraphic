class Camera{
    Vector4 position;
    Vector4[] oriented;
    public Camera(Vector4 pos){
        oriented = new Vector4[]{new Vector4(1,0,0,0),new Vector4(0,1,0,0),new Vector4(0,0,1,0),new Vector4(0,0,0,1)};
        position = pos;
    }
    
    public void lookAt(Vector4 point){
        Vector4 f = point.sub(position);
        oriented[0] = f;
        oriented = Gram_Schmidt(oriented);
    }
    
    
    
    
}
