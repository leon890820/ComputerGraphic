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

    int count = 0;
    boolean initialized = false;

    private static final int VBO_POS     = 0;
    private static final int VBO_NORMAL  = 1;
    private static final int VBO_TANGENT = 2;
    private static final int VBO_UV      = 3;

    public MeshRenderer() {
    }

    public MeshRenderer(Mesh m, Material mat, GameObject go) {
        setMeshAndMaterial(m, mat, go);
    }

    public MeshRenderer setMeshAndMaterial(Mesh m, Material mat, GameObject go) {
        // 如果之前已經 init 過，先釋放舊資源，避免漏掉 GPU 資源
        if (initialized) {
            dispose();
        }

        mesh = m;
        material = mat;
        gameObject = go;

        initialize();
        return this;
    }

    public void initialize() {
        if (mesh == null || material == null || gameObject == null) {
            println("[MeshRenderer] initialize failed: mesh/material/gameObject is null");
            return;
        }

        positions = gameObject.getTrianglePosition();
        if (positions == null || positions.length == 0) {
            println("[MeshRenderer] initialize failed: positions is empty");
            return;
        }

        count = positions.length / 3;

        // 用 direct buffer，比 IntBuffer.allocate 更適合給 OpenGL API
        vao = allocateDirectIntBuffer(1);
        vbo = allocateDirectIntBuffer(4);

        material.shader.bind();

        gl3.glGenVertexArrays(1, vao);
        gl3.glBindVertexArray(vao.get(0));

        gl3.glGenBuffers(4, vbo);

        // Position
        posBuffer = allocateDirectFloatBuffer(positions.length);
        setBuffer(posBuffer, positions);
        pushVertexAttribData("aVertexPosition", VBO_POS, posBuffer, positions.length, 3, 0);

        // Normal
        if (gameObject.hasProperties[1]) {
            normals = gameObject.getTriangleNormal();
            if (normals != null && normals.length > 0) {
                normalBuffer = allocateDirectFloatBuffer(normals.length);
                setBuffer(normalBuffer, normals);
                pushVertexAttribData("aNormalPosition", VBO_NORMAL, normalBuffer, normals.length, 3, 0);
            } else {
                println("[MeshRenderer] Warning: has normal flag but normal data is empty");
            }
        }

        // UV
        if (gameObject.hasProperties[2]) {
            uvs = gameObject.getTriangleUV();
            if (uvs != null && uvs.length > 0) {
                uvBuffer = allocateDirectFloatBuffer(uvs.length);
                setBuffer(uvBuffer, uvs);
                pushVertexAttribData("aTexCoordPosition", VBO_UV, uvBuffer, uvs.length, 2, 0);
            } else {
                println("[MeshRenderer] Warning: has uv flag but uv data is empty");
            }
        }

        // Tangent
        if (gameObject.hasProperties[3]) {
            tangents = gameObject.getTriangleTangent();
            if (tangents != null && tangents.length > 0) {
                tangentBuffer = allocateDirectFloatBuffer(tangents.length);
                setBuffer(tangentBuffer, tangents);
                pushVertexAttribData("aTangentPosition", VBO_TANGENT, tangentBuffer, tangents.length, 3, 0);
            } else {
                println("[MeshRenderer] Warning: has tangent flag but tangent data is empty");
            }
        }

        gl3.glBindBuffer(GL.GL_ARRAY_BUFFER, 0);
        gl3.glBindVertexArray(0);
        material.shader.unbind();

        initialized = true;
    }

    void pushVertexAttribData(String name, int vboIndex, FloatBuffer buffer, int size, int num, int bias) {
        int vboId = vbo.get(vboIndex);
        int attribLoc = gl3.glGetAttribLocation(material.shader.glProgram, name);

        if (attribLoc < 0) {
            println("[MeshRenderer] Warning: attribute not found -> " + name);
            return;
        }

        gl3.glBindBuffer(GL.GL_ARRAY_BUFFER, vboId);
        gl3.glBufferData(GL.GL_ARRAY_BUFFER, Float.BYTES * size, buffer, GL.GL_STATIC_DRAW);

        gl3.glVertexAttribPointer(
            attribLoc,
            num,
            GL.GL_FLOAT,
            false,
            num * Float.BYTES,
            bias
        );

        gl3.glEnableVertexAttribArray(attribLoc);
    }

    public void setBuffer(FloatBuffer buffer, float[] data) {
        buffer.rewind();
        buffer.put(data);
        buffer.rewind();
    }

    public void render() {
        if (!initialized || vao == null) return;
    
        material.bind();
        material.run(gameObject);
    
        gl3.glBindVertexArray(vao.get(0));
        gl3.glDrawArrays(PGL.TRIANGLES, 0, count);
        gl3.glBindVertexArray(0);
    
        material.cleanup();
        material.unbind();
    }
    
    public void debugRender() {
        if (!initialized || vao == null) return;
    
        material.bind();
        material.run(gameObject);
    
        gl3.glBindVertexArray(vao.get(0));
        gl3.glDrawArrays(PGL.LINES, 0, count);
        gl3.glBindVertexArray(0);
    
        material.cleanup();
        material.unbind();
    }

    public void dispose() {
        if (vbo != null) {
            vbo.rewind();
            gl3.glDeleteBuffers(4, vbo);
            vbo = null;
        }

        if (vao != null) {
            vao.rewind();
            gl3.glDeleteVertexArrays(1, vao);
            vao = null;
        }

        posBuffer = null;
        normalBuffer = null;
        uvBuffer = null;
        tangentBuffer = null;

        positions = null;
        normals = null;
        uvs = null;
        tangents = null;

        count = 0;
        initialized = false;
    }
}
