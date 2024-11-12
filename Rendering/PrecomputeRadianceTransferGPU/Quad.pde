public class Quad extends GameObject{
    
    public Quad(String mesh,Material m){
        setShape(mesh);
        setMaterial(m);
        init();
    }
        
    @Override
    public void draw(){
        
        material.setGameobject(this);
        material.shader.bind();  
        
        material.run();   
        run();
        material.shader.unbind();
        
    }
}

public class PhongObject extends GameObject{
    BVH bvh;
    
    public PhongObject(String mesh,Material m){
        setShape(mesh);
        setMaterial(m);
        init();
        
        bvh = new BVH(shape.triangles,MAX_BVP_DEPTH);
        bvh.setGameObject(this);
    }
    
    
    public boolean intersection(Vector3 o,Vector3 dir){
        return bvh.intersection(o,dir);
    }

        
    @Override
    public void draw(){
        
        material.setGameobject(this);
        material.shader.bind();          
        material.run();   
        run();
        material.shader.unbind();
        
        bvh.setGameObject(this);
        bvh.draw();
        
    }
}

public class PRTObject extends GameObject{
    FloatBuffer lightBuffer;
    float[] lights;
    BVH bvh;
    boolean glossy = true;
    
    public PRTObject(String mesh,Material m){
        setShape(mesh);
        setMaterial(m);
        material.setGameobject(this);
        bvh = new BVH(shape.triangles,MAX_BVP_DEPTH);
        bvh.setGameObject(this);
        
        if(!glossy){
            diffuse();
        }else{
            ((PRTMaterial) material).preCalculateLightTransportGlossy();
        }
        
        init();
        
    }
    
    
    void diffuse(){
                
            String[] light_cof = loadStrings(name + ".prt");
            if(light_cof == null) ((PRTMaterial) material).preCalculateLightTransport(name);
            else ((PRTMaterial) material).preCalculateLightTransport(light_cof);
            if(pt == PRTType.INTERSHADOW) {      
                String[] light_cof_inter = loadStrings(name + ".inter");          
                if(light_cof_inter == null){
                    for(int i = 0; i < shape.verts.size();i++){
                        println("indirect : " + (float)i/(float)shape.verts.size() * 100 + "%");
                        for(int j = 0; j < 3; j++){
                            Vector3 pos = shape.triangles.get(i).verts[j];
                            Vector3 normal = shape.triangles.get(i).normal[j];
                            float[] lds = ((PRTMaterial) material).calcInterreflectionSH(pos,normal,MAX_DEPTH);
                            for(int k = 0; k < lds.length; k++){
                                ((PRTMaterial) material).light_transport_array.get(i*3+j)[k] += lds[k];
                            }
                            
                        }
                    }
                    ((PRTMaterial) material).saveLightTransportInter(name);
                }else{
                    ((PRTMaterial) material).preCalculateLightTransportInter(light_cof_inter);
                }
            }
    
    }
    
    public boolean intersection(Vector3 o,Vector3 dir){      
        return bvh.intersection(o,dir);
    }
    
    public boolean intersection(Vector3 o,Vector3 dir,HitRecord hit){        
        return bvh.intersection(o,dir,hit);
    }
    
    @Override
    public void init(){
        super.init();
        
        lightBuffer = allocateDirectFloatBuffer(shape.triangles.size() * 3 * 3);
        if(!glossy) lights = ((PRTMaterial) material).getColorArray();
        else lights = ((PRTMaterial) material).getColorArrayGlossy();
        lightBuffer.rewind();
        lightBuffer.put(lights);
        lightBuffer.rewind();
        
    }
    
    @Override
    public void draw(){
        
        material.setGameobject(this);
        material.shader.bind();  
        
        material.run();   
        run();
        material.shader.unbind();
        
        //bvh.draw();
    }
    
    @Override
    public void run(){
        int posLoc = gl.glGetAttribLocation(material.shader.glProgram, "aVertexPosition");
        int uvLoc = gl.glGetAttribLocation(material.shader.glProgram, "aTextureCoord");
        int normalLoc = gl.glGetAttribLocation(material.shader.glProgram, "aNormalPosition");
        int lightLoc = gl.glGetAttribLocation(material.shader.glProgram, "aColor");
        gl.glEnableVertexAttribArray(posLoc);
        gl.glEnableVertexAttribArray(uvLoc);
        gl.glEnableVertexAttribArray(normalLoc);
        
        
        //println(positions);
        gl.glGenBuffers(4, intBuffer);
        int posVboId = intBuffer.get(0);
        
        gl.glBindBuffer(GL.GL_ARRAY_BUFFER, posVboId);
        gl.glBufferData(GL.GL_ARRAY_BUFFER, Float.BYTES * positions.length, posBuffer, GL.GL_STATIC_DRAW);
        gl.glVertexAttribPointer(posLoc, 3, GL.GL_FLOAT, false, 3 * Float.BYTES, 0);
        
        if(shape.uvs.size() > 0){          
            int uvVboId = intBuffer.get(1);
            gl.glBindBuffer(GL.GL_ARRAY_BUFFER, uvVboId);
            gl.glBufferData(GL.GL_ARRAY_BUFFER, Float.BYTES * uvs.length, uvBuffer, GL.GL_STATIC_DRAW);
            gl.glVertexAttribPointer(uvLoc, 2, GL.GL_FLOAT, false, 2 * Float.BYTES, 0);
        }
        
        if(shape.normals.size() > 0){
           
            int normalVboId = intBuffer.get(2);
            gl.glBindBuffer(GL.GL_ARRAY_BUFFER, normalVboId);
            gl.glBufferData(GL.GL_ARRAY_BUFFER, Float.BYTES * normals.length, normalBuffer, GL.GL_STATIC_DRAW);
            gl.glVertexAttribPointer(normalLoc, 3, GL.GL_FLOAT, false, 3 * Float.BYTES, 0);
        }
        
        
        int lightVboId = intBuffer.get(3);       
        gl.glBindBuffer(GL.GL_ARRAY_BUFFER, lightVboId);
        gl.glBufferData(GL.GL_ARRAY_BUFFER, Float.BYTES * lights.length, lightBuffer, GL.GL_STATIC_DRAW);
           
        
        gl.glEnableVertexAttribArray(lightLoc);
        gl.glVertexAttribPointer(lightLoc, 3, GL.GL_FLOAT, false, 3 * Float.BYTES,  0);            
        
        

        
        gl.glBindBuffer(GL.GL_ARRAY_BUFFER, 0);        
        gl.glDrawArrays(PGL.TRIANGLES,0,shape.triangles.size() * 3);
        
    }
    

    
}
