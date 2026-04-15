public class MeshRenderer {
    Mesh mesh;
    SubMesh subMesh;
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

    // 目前先固定把 map_Ka 綁在 texture unit 0
    private static final int TEXTURE_UNIT_KA = 0;

    public MeshRenderer() {
    }

    public MeshRenderer(Mesh m, SubMesh sub, Material mat, GameObject go) {
        setMeshAndMaterial(m, sub, mat, go);
    }

    public MeshRenderer setMeshAndMaterial(Mesh m, SubMesh sub, Material mat, GameObject go) {
        if (initialized) {
            dispose();
        }

        mesh = m;
        subMesh = sub;
        material = mat;
        gameObject = go;

        initialize();
        return this;
    }

    public void initialize() {
        if (mesh == null || subMesh == null || material == null || gameObject == null) {
            println("[MeshRenderer] initialize failed: mesh/subMesh/material/gameObject is null");
            return;
        }

        positions = mesh.getTrianglePosition(subMesh);
        if (positions == null || positions.length == 0) {
            println("[MeshRenderer] initialize failed: positions is empty, subMesh = " + subMesh.materialName);
            return;
        }

        count = positions.length / 3;

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
            normals = mesh.getTriangleNormal(subMesh);
            if (normals != null && normals.length > 0) {
                normalBuffer = allocateDirectFloatBuffer(normals.length);
                setBuffer(normalBuffer, normals);
                pushVertexAttribData("aNormalPosition", VBO_NORMAL, normalBuffer, normals.length, 3, 0);
            } else {
                println("[MeshRenderer] Warning: has normal flag but normal data is empty, subMesh = " + subMesh.materialName);
            }
        }

        // UV
        if (gameObject.hasProperties[2]) {
            uvs = mesh.getTriangleUV(subMesh);
            if (uvs != null && uvs.length > 0) {
                uvBuffer = allocateDirectFloatBuffer(uvs.length);
                setBuffer(uvBuffer, uvs);
                pushVertexAttribData("aTexCoordPosition", VBO_UV, uvBuffer, uvs.length, 2, 0);
            } else {
                println("[MeshRenderer] Warning: has uv flag but uv data is empty, subMesh = " + subMesh.materialName);
            }
        }

        // Tangent
        if (gameObject.hasProperties[3]) {
            tangents = mesh.getTriangleTangent(subMesh);
            if (tangents != null && tangents.length > 0) {
                tangentBuffer = allocateDirectFloatBuffer(tangents.length);
                setBuffer(tangentBuffer, tangents);
                pushVertexAttribData("aTangentPosition", VBO_TANGENT, tangentBuffer, tangents.length, 3, 0);
            } else {
                println("[MeshRenderer] Warning: has tangent flag but tangent data is empty, subMesh = " + subMesh.materialName);
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
            0,
            bias
        );

        gl3.glEnableVertexAttribArray(attribLoc);
    }

    public void setBuffer(FloatBuffer buffer, float[] data) {
        buffer.rewind();
        buffer.put(data);
        buffer.rewind();
    }

    private Texture getAutoTexture() {
        if (mesh == null || subMesh == null) return null;
        return mesh.getTextureKa(subMesh.materialName);
    }

    private void bindAutoTexture() {
        Texture tex = getAutoTexture();
        if (tex == null || !tex.isUploaded()) {
            return;
        }

        tex.bind(TEXTURE_UNIT_KA);

        // 你 shader 如果是用這幾個名字之一，都會自動設到 0
        setSamplerUniformIfExists("u_KaTexture", TEXTURE_UNIT_KA);
        setSamplerUniformIfExists("u_DiffuseTexture", TEXTURE_UNIT_KA);
        setSamplerUniformIfExists("u_MainTex", TEXTURE_UNIT_KA);
        setSamplerUniformIfExists("tex", TEXTURE_UNIT_KA);
    }

    private void unbindAutoTexture() {
        Texture tex = getAutoTexture();
        if (tex == null || !tex.isUploaded()) {
            return;
        }
        tex.unbind(TEXTURE_UNIT_KA);
    }

    private void setSamplerUniformIfExists(String uniformName, int textureUnit) {
        int loc = gl3.glGetUniformLocation(material.shader.glProgram, uniformName);
        if (loc >= 0) {
            gl3.glUniform1i(loc, textureUnit);
        }
    }

    public void render() {
        if (!initialized || vao == null) return;

        material.bind();

        // 先綁 shader，再綁 texture，再跑 material uniform
        bindAutoTexture();
        material.run(gameObject);

        gl3.glBindVertexArray(vao.get(0));
        gl3.glDrawArrays(PGL.TRIANGLES, 0, count);
        gl3.glBindVertexArray(0);

        unbindAutoTexture();

        material.cleanup();
        material.unbind();
    }

    public void debugRender() {
        if (!initialized || vao == null) return;

        material.bind();

        bindAutoTexture();
        material.run(gameObject);

        gl3.glBindVertexArray(vao.get(0));
        gl3.glDrawArrays(PGL.LINES, 0, count);
        gl3.glBindVertexArray(0);

        unbindAutoTexture();

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

    public String getMaterialName() {
        return subMesh == null ? "null" : subMesh.materialName;
    }

    public SubMesh getSubMesh() {
        return subMesh;
    }
}
