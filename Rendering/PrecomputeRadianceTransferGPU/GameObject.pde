public abstract class GameObject {
    Vector3 pos;
    Vector3 eular;
    Vector3 scale;
    float p_scale;

    Mesh shape;
    Material material;
    
    String name;
    
    FloatBuffer posBuffer;
    float[] positions;
    
    FloatBuffer uvBuffer;
    float[] uvs;
    
    FloatBuffer normalBuffer;
    float[] normals;
    
    IntBuffer intBuffer;


    public GameObject() {
        pos   = new Vector3(0);
        eular = new Vector3(0);
        scale = new Vector3(1);
        p_scale = 1;
    }
    public void reset() {
        pos.setZero();
        eular.setZero();
        scale.setOnes();
        p_scale = 1;
    }
    
    public GameObject setName(String s) {
        name = s;
        return this;
    }

    public GameObject setPos(Vector3 v) {
        pos = v;
        return this;
    }

    public GameObject setPos(float x, float y, float z) {
        pos.set(x, y, z);
        return this;
    }

    public GameObject setEular(Vector3 v) {
        eular = v;
        return this;
    }
    public GameObject setEular(float x, float y, float z) {
        eular.set(x, y, z);
        return this;
    }

    public GameObject setScale(Vector3 v) {
        scale = v;
        return this;
    }

    public GameObject setScale(float x, float y, float z) {
        scale.set(x, y, z);
        return this;
    }

    public GameObject setMaterial(Material m) {
        material = m;
        return this;
    }

    public GameObject setShape(Mesh m) {
        shape = m;
        return this;
    }

    public GameObject setShape(String mesh) {
        setName(mesh);
        shape = new Mesh(mesh);
        return this;
    }
    
    public void init(){
        intBuffer = allocateDirectIntBuffer(4);
        
        posBuffer = allocateDirectFloatBuffer(shape.triangles.size() * 3 * 3);
        positions = shape.getTrianglePosition();
        posBuffer.rewind();
        posBuffer.put(positions);
        posBuffer.rewind();
        
        if(shape.uvs.size() > 0){
            uvBuffer = allocateDirectFloatBuffer(shape.triangles.size() * 2 * 3);
            uvs = shape.getTriangleUV();
            uvBuffer.rewind();
            uvBuffer.put(uvs);
            uvBuffer.rewind();
        }
        
        if(shape.normals.size() > 0){
            normalBuffer = allocateDirectFloatBuffer(shape.triangles.size() * 3 * 3);
            normals = shape.getTriangleNormal();
            normalBuffer.rewind();
            normalBuffer.put(normals);
            normalBuffer.rewind();
        }
    
    }


    abstract public void draw();
    public void update() {
    }
    public void debugDraw() {
    }

    void run() {
       

        int posLoc = gl.glGetAttribLocation(material.shader.glProgram, "aVertexPosition");
        int uvLoc = gl.glGetAttribLocation(material.shader.glProgram, "aTextureCoord");
        int normalLoc = gl.glGetAttribLocation(material.shader.glProgram, "aNormalPosition");
        gl.glEnableVertexAttribArray(posLoc);
        gl.glEnableVertexAttribArray(uvLoc);
        gl.glEnableVertexAttribArray(normalLoc);
        
        //println(positions);
        gl.glGenBuffers(3, intBuffer);
        int posVboId = intBuffer.get(0);
        
        gl.glBindBuffer(GL.GL_ARRAY_BUFFER, posVboId);
        gl.glBufferData(GL.GL_ARRAY_BUFFER, Float.BYTES * positions.length, posBuffer, GL.GL_STATIC_DRAW);
        gl.glVertexAttribPointer(posLoc, 3, GL.GL_FLOAT, false, 3 * Float.BYTES, 0);
        
        if(shape.normals.size() > 0){
           
            int normalVboId = intBuffer.get(1);
            gl.glBindBuffer(GL.GL_ARRAY_BUFFER, normalVboId);
            gl.glBufferData(GL.GL_ARRAY_BUFFER, Float.BYTES * normals.length, normalBuffer, GL.GL_STATIC_DRAW);
            gl.glVertexAttribPointer(normalLoc, 3, GL.GL_FLOAT, false, 3 * Float.BYTES, 0);
        }
        
        if(shape.uvs.size() > 0){          
            int uvVboId = intBuffer.get(2);
            gl.glBindBuffer(GL.GL_ARRAY_BUFFER, uvVboId);
            gl.glBufferData(GL.GL_ARRAY_BUFFER, Float.BYTES * uvs.length, uvBuffer, GL.GL_STATIC_DRAW);
            gl.glVertexAttribPointer(uvLoc, 2, GL.GL_FLOAT, false, 2 * Float.BYTES, 0);
        }
        
        
        
        gl.glBindBuffer(GL.GL_ARRAY_BUFFER, 0);
        
        gl.glDrawArrays(PGL.TRIANGLES,0,shape.triangles.size() * 3);
        //gl.glDisableVertexAttribArray(posLoc);
        //gl.glDisableVertexAttribArray(uvLoc);
        //gl.glDisableVertexAttribArray(normalLoc);
    }



    public Matrix4 localToWorld() {
        return Matrix4.Trans(pos).mult(Matrix4.RotY(eular.y)).mult(Matrix4.RotX(eular.x)).mult(Matrix4.RotZ(eular.z)).mult(Matrix4.Scale(scale));
    }
    public Matrix4 worldToLocal() {
        return Matrix4.Scale(scale.mult(p_scale).inv()).mult(Matrix4.RotZ(-eular.z)).mult(Matrix4.RotX(-eular.x)).mult(Matrix4.RotY(-eular.y)).mult(Matrix4.Trans(pos.mult(-1)));
    }
    public Vector3 forward() {
        return (Matrix4.RotZ(eular.z).mult(Matrix4.RotX(eular.y)).mult(Matrix4.RotY(eular.x)).zAxis()).mult(-1);
    }
    public Matrix4 MVP() {
        return main_camera.Matrix().mult(localToWorld());
    }
}
