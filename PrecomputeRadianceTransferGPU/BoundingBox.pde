
public class BVH{
    BVH childA;
    BVH childB;
    BoundingBox boundingBox;
    ArrayList<Triangle> tris;
    public BVH(ArrayList<Triangle> tri,int depth){
        this.tris = tri;
        setBoundingBox();
        splitBVH(depth);
    }
    
     public boolean intersection(Vector3 o,Vector3 dir){
         if(!boundingBox.intersection(o,dir)) return false;
                  
         if(childA == null ? triangle_intersection(o,dir) : childA.intersection(o,dir)) return true;
         if(childB == null ? triangle_intersection(o,dir) : childB.intersection(o,dir)) return true;
         
         return false;
     }
     
     boolean triangle_intersection(Vector3 o,Vector3 dir){
         for(Triangle t : tris){
             if(t.intersection(o,dir,boundingBox.go.localToWorld())) return true;
         }
         return false;
     }
     
     public boolean intersection(Vector3 o,Vector3 dir,HitRecord hit){
         if(!boundingBox.intersection(o,dir)) return false;
                  
         if(childA == null ? triangle_intersection(o,dir,hit) : childA.intersection(o,dir,hit)) return true;
         if(childB == null ? triangle_intersection(o,dir,hit) : childB.intersection(o,dir,hit)) return true;
         
         return false;
     }
     
     boolean triangle_intersection(Vector3 o,Vector3 dir,HitRecord hit){
         boolean flag = false;
         for(Triangle t : tris){
             flag = flag || t.intersection(o,dir,boundingBox.go.localToWorld(),hit);
         }
         return flag;
     }
     
    
    void setBoundingBox(){
                
        Vector3 maxRecord = new Vector3(-1.0/0.0);
        Vector3 minRecord = new Vector3(1.0/0.0);
        for(int i = 0; i < tris.size(); i++){
            Triangle triangle = tris.get(i);
            for(int j = 0; j < 3; j++){
                Vector3 vert = triangle.verts[j];
                minRecord.set(min(vert.x, minRecord.x), min(vert.y, minRecord.y), min(vert.z, minRecord.z));
                maxRecord.set(max(vert.x, maxRecord.x), max(vert.y, maxRecord.y), max(vert.z, maxRecord.z));
            }                                              
        }

        boundingBox = new BoundingBox(minRecord,maxRecord);
        //boundingBox.setMaterial(new BoundingBoxMaterial("Shaders/BoundingBox.frag","Shaders/BoundingBox.vert").setAlbedo(random(1),random(1),random(1)));
    }
    
    void splitBVH(int depth){
        if(depth == 0) return;
        if(tris.size() <= 10) return;
        Vector3 size = boundingBox.maxB.sub(boundingBox.minB);
        int a = size.x > size.y && size.x > size.z ? 0 : size.y > size.z? 1 :2 ; 
        
        ArrayList<Triangle> triA = new ArrayList<Triangle>();
        ArrayList<Triangle> triB = new ArrayList<Triangle>();
        for(int i = 0;i < tris.size(); i++){
            Triangle t = tris.get(i);
            if(t.center.xyz(a) < boundingBox.center.xyz(a)) triA.add(t);
            else triB.add(t);
        }
        childA = new BVH(triA,depth - 1);
        childB = new BVH(triB,depth - 1);
    }
    
    public void setGameObject(GameObject go){
        this.boundingBox.setGameObject(go);
        if(childA != null)childA.setGameObject(go);
        if(childB != null)childB.setGameObject(go);
    }
    
    public void draw(){
        if(childA == null)boundingBox.draw();
        if(childA != null)childA.draw();
        if(childB != null)childB.draw();
        
    }
    

}

public class BoundingBox extends GameObject{
    Vector3 maxB,minB;
    Vector3 center;
    
    GameObject go;
    public BoundingBox(Vector3 min,Vector3 max){
        minB = min; maxB = max;
        center = Vector3.add(min,max).mult(0.5);
        init();
    }
    
    public BoundingBox setGameObject(GameObject go){
        this.go = go;
        return this;
    }
    
    public void setHit(boolean hit){
        //((BoundingBoxMaterial)material).hit = hit;
    }
    
    public boolean intersection(Vector3 o,Vector3 dir){
        Vector3 inv_dir = dir.inv();

        Vector3 world_minB = go.localToWorld().mult(minB);
        Vector3 world_maxB = go.localToWorld().mult(maxB);
        
        Vector3 mint = Vector3.mult(Vector3.sub(world_minB,o) , inv_dir);
        Vector3 maxt = Vector3.mult(Vector3.sub(world_maxB,o) , inv_dir);
       
        Vector3 mmit = new Vector3(mint.x < maxt.x? mint.x : maxt.x , mint.y < maxt.y? mint.y : maxt.y , mint.z < maxt.z? mint.z : maxt.z);
        Vector3 mmat = new Vector3(mint.x >= maxt.x? mint.x : maxt.x , mint.y >= maxt.y? mint.y : maxt.y , mint.z >= maxt.z? mint.z : maxt.z);
        
        float enter = max(mmit.x,max(mmit.y,mmit.z));
        float exit = min(mmat.x,min(mmat.y,mmat.z));

        
        if(enter < exit && exit >= 0) {
            setHit(true);
            return true;
        }
        setHit(false);
        return false;
        
    }
    
    public void init(){
        intBuffer = allocateDirectIntBuffer(1);
        
        posBuffer = allocateDirectFloatBuffer(12 * 2 * 3);
        positions = getPointLine();
        posBuffer.rewind();
        posBuffer.put(positions);
        posBuffer.rewind();


    }
    
    public float[] getPointLine(){
        float[] result = new float[12*2*3];
        //1
        result[0] = minB.x;  result[3] = maxB.x;
        result[1] = minB.y;  result[4] = minB.y;
        result[2] = minB.z;  result[5] = minB.z;
        //2
        result[6] = maxB.x;  result[9]  = maxB.x;
        result[7] = minB.y;  result[10] = maxB.y;
        result[8] = minB.z;  result[11] = minB.z;
        //3
        result[12] = maxB.x;  result[15] = minB.x;
        result[13] = maxB.y;  result[16] = maxB.y;
        result[14] = minB.z;  result[17] = minB.z;
        //4
        result[18] = minB.x;  result[21] = minB.x;
        result[19] = maxB.y;  result[22] = minB.y;
        result[20] = minB.z;  result[23] = minB.z;
        
        //5
        result[24] = minB.x;  result[27] = minB.x;
        result[25] = minB.y;  result[28] = minB.y;
        result[26] = minB.z;  result[29] = maxB.z;
        //6
        result[30] = maxB.x;  result[33] = maxB.x;
        result[31] = minB.y;  result[34] = minB.y;
        result[32] = minB.z;  result[35] = maxB.z;
        //7
        result[36] = maxB.x;  result[39] = maxB.x;
        result[37] = maxB.y;  result[40] = maxB.y;
        result[38] = minB.z;  result[41] = maxB.z;
        //8
        result[42] = minB.x;  result[45] = minB.x;
        result[43] = maxB.y;  result[46] = maxB.y;
        result[44] = minB.z;  result[47] = maxB.z;
        
        //9
        result[48] = minB.x;  result[51] = maxB.x;
        result[49] = minB.y;  result[52] = minB.y;
        result[50] = maxB.z;  result[53] = maxB.z;
        //10
        result[54] = maxB.x;  result[57] = maxB.x;
        result[55] = minB.y;  result[58] = maxB.y;
        result[56] = maxB.z;  result[59] = maxB.z;
        //11
        result[60] = maxB.x;  result[63] = minB.x;
        result[61] = maxB.y;  result[64] = maxB.y;
        result[62] = maxB.z;  result[65] = maxB.z;
        //12
        result[66] = minB.x;  result[69] = minB.x;
        result[67] = maxB.y;  result[70] = minB.y;
        result[68] = maxB.z;  result[71] = maxB.z;
        
        return result;
    }
    
    void run() {
       

        int posLoc = gl.glGetAttribLocation(material.shader.glProgram, "aVertexPosition");

        gl.glEnableVertexAttribArray(posLoc);
        gl.glGenBuffers(1, intBuffer);
        int posVboId = intBuffer.get(0);
        
        gl.glBindBuffer(GL.GL_ARRAY_BUFFER, posVboId);
        gl.glBufferData(GL.GL_ARRAY_BUFFER, Float.BYTES * positions.length, posBuffer, GL.GL_STATIC_DRAW);
        gl.glVertexAttribPointer(posLoc, 3, GL.GL_FLOAT, false, 3 * Float.BYTES, 0);

        
        gl.glBindBuffer(GL.GL_ARRAY_BUFFER, 0);
        
        gl.glDrawArrays(PGL.LINES, 0, 12 * 2);
        //gl.glDisableVertexAttribArray(posLoc);
        //gl.glDisableVertexAttribArray(uvLoc);
        //gl.glDisableVertexAttribArray(normalLoc);
    }
    
    @Override
    public void draw(){
        material.setGameobject(go);
        material.shader.bind();          
        material.run();   
        run();
        material.shader.unbind();
        
    }

}
