public static class Vector4{
    float x,y,z,w;
    public Vector4(){
        x = 0; y = 0; z = 0; w = 0;
    }
    public Vector4(float _x,float _y,float _z,float _w){
        x = _x; y = _y; z = _z; w = _w;
    }
    
    public Vector4(float a){
        x = a; y = a; z = a; w = a;
    }
    
    static public Vector4 Add(Vector4 a, Vector4 b){
        return new Vector4(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);
    }
    static public Vector4 Sub(Vector4 a, Vector4 b){
        return new Vector4(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w);
    }
    static public Vector4 Mult(Vector4 a, float b){
        return new Vector4(a.x*b, a.y * b, a.z * b, a.w * b);
    }
    static public Vector4 Div(Vector4 a, float b){
        return new Vector4(a.x / b, a.y / b, a.z / b, a.w / b);
    }    
    static public Vector4 Product(Vector4 a, Vector4 b){
        return new Vector4(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w);
    }
    static public float Dot(Vector4 a, Vector4 b){
        return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
    }
    static public float Mag2(Vector4 a){
        return Vector4.Dot(a,a);
    }
    
    public Vector4 add(Vector4 b){
        return new Vector4(x + b.x, y + b.y, z + b.z, w + b.w);
    }
    
    public Vector4 sub(Vector4 b){
        return new Vector4(x - b.x, y - b.y, z - b.z, w - b.w);
    }
    
    public Vector4 mult(float b){
        return new Vector4(x * b, y * b, z * b, w * b);
    }
    
    public Vector4 div(float b){
        return new Vector4(x / b, y / b, z / b, w / b);
    }
    
    public float dot(Vector4 b){
        return x * b.x + y * b.y + z * b.z + w * b.w;
    }
    
    public float magnitude2(){
        return Vector4.Dot(this,this);
    }
    
    public float magnitude(){
        return sqrt(magnitude2());
    }  
    
    public Vector4 normalize(){
        return this.div(magnitude());
    }
    
    public Vector5 getHomo(){
        return new Vector5(this);
    }
    
    String toString(){
        return "x : " + x + " y : " + y +" z : " + z + " w : " + w +"\n";
    }
    
}

Vector4 vector() {
    return new Vector4();
}

public static class Vector5{
    Vector4 v;
    float h = 1;
    public Vector5(){
        v = new Vector4();
    }
    
    public Vector5(Vector4 _v){
        v = _v;
    }
    
    public Vector5(Vector4 _v,float _h){
        v = _v;
        h = _h;
    }
    
    public Vector5(float _x,float _y,float _z,float _w,float _h){
        v = new Vector4(_x,_y,_z,_w);
        h = _h;
    }
    
    public Vector4 homogenized(){
        return v.div(h);
    }
    

}
