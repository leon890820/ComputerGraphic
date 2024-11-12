public class MeshRenderer {
    Mesh mesh;
    Material material;
    GameObject gameObject;

    FloatBuffer posBuffer;
    float[] positions;
    FloatBuffer uvBuffer;
    float[] uvs;
    FloatBuffer normalBuffer;
    float[] normals;
    FloatBuffer tangentBuffer;
    float[] tangents;

    IntBuffer vao;
    IntBuffer vbo;
    int count;


    public MeshRenderer() {
    }
    public MeshRenderer(Mesh m, Material mat,GameObject go) {
        setMeshAndMaterial(m, mat,go);
    }

    public MeshRenderer setMeshAndMaterial(Mesh m, Material mat,GameObject go) {
        mesh = m;
        material = mat;
        gameObject = go;
        initialize();
        return this;
    }

    public void initialize() {
        material.shader.bind();
        int triangle_num = mesh.triangles.size();
        vbo = IntBuffer.allocate(4);
        vao = IntBuffer.allocate(1);
        gl3.glGenVertexArrays(1, vao);
        gl3.glBindVertexArray(vao.get(0));
        
        posBuffer = allocateDirectFloatBuffer(triangle_num * 3 * 3);
        positions = mesh.getTrianglePosition();
        setBuffer(posBuffer, positions);
        if (mesh.uvs.size() > 0) {
            uvBuffer = allocateDirectFloatBuffer(triangle_num * 2 * 3);
            uvs = mesh.getTriangleUV();
            setBuffer(uvBuffer, uvs);
        }
        if (mesh.normals.size() > 0) {
            normalBuffer = allocateDirectFloatBuffer(triangle_num * 3 * 3);
            normals = mesh.getTriangleNormal();
            setBuffer(normalBuffer, normals);
        }
        if (mesh.tangents.size() > 0) {
            tangentBuffer = allocateDirectFloatBuffer(triangle_num * 3 * 3);
            tangents = mesh.getTriangleTangent();
            setBuffer(tangentBuffer, tangents);
        }

        gl3.glGenBuffers(4, vbo);
        pushVertexAttribData("aVertexPosition" , 0  ,posBuffer , positions.length ,3 ,0);
        if(mesh.normals.size() > 0){
            pushVertexAttribData("aNormalPosition" , 1 ,normalBuffer , normals.length ,3 ,0);
        }
        if(mesh.tangents.size() > 0){
            pushVertexAttribData("aTangentPosition" , 2 ,tangentBuffer , tangents.length ,3 ,0);
        }
        if(mesh.uvs.size() > 0){
            pushVertexAttribData("aTexCoordPosition" , 3 ,uvBuffer , uvs.length ,2 ,0);
        }
     
        gl3.glBindBuffer(GL.GL_ARRAY_BUFFER, 0);       
        material.shader.unbind();
    }
    
    void pushVertexAttribData(String name,int ind, FloatBuffer buffer ,int size , int num, int bias){
        int posVboId = vbo.get(ind);       
        int posLoc = gl3.glGetAttribLocation(material.shader.glProgram, name);
                       
        gl3.glBindBuffer(GL.GL_ARRAY_BUFFER, posVboId);
        gl3.glBufferData(GL.GL_ARRAY_BUFFER, Float.BYTES *size, buffer, GL.GL_STATIC_DRAW);
        gl3.glVertexAttribPointer(posLoc, num, GL.GL_FLOAT, false, num * Float.BYTES, bias);
        
        gl3.glEnableVertexAttribArray(posLoc);
        
        
    }

    public void setBuffer(FloatBuffer buffer, float[] data) {
        buffer.rewind();
        buffer.put(data);
        buffer.rewind();                
    }


    public void render() {
        material.shader.bind();
       
        material.run(gameObject);
        gl3.glBindVertexArray(vao.get(0));
        gl3.glDrawArrays(PGL.TRIANGLES, 0, mesh.triangles.size() * 3);

        material.shader.unbind();
    }



    public void debugRender() {
    }
}
