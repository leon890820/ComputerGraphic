public class SSBO {
    IntBuffer ssbo;
    int bindingPoint;
    int elementCount = 0;
    boolean initialized = false;

    public SSBO(int bindingPoint, float[] data) {
        this.bindingPoint = bindingPoint;

        ssbo = allocateDirectIntBuffer(1);
        gl3.glGenBuffers(1, ssbo);

        uploadData(data, gl3.GL_STATIC_DRAW);
        bindBase();
    }

    public void bind() {
        if (ssbo == null) return;
        gl3.glBindBuffer(gl3.GL_SHADER_STORAGE_BUFFER, ssbo.get(0));
    }

    public void unbind() {
        gl3.glBindBuffer(gl3.GL_SHADER_STORAGE_BUFFER, 0);
    }

    public void bindBase() {
        if (ssbo == null) return;
        gl3.glBindBufferBase(gl3.GL_SHADER_STORAGE_BUFFER, bindingPoint, ssbo.get(0));
    }

    public void uploadData(float[] data, int usage) {
        if (ssbo == null) return;

        FloatBuffer floatBuffer = allocateDirectFloatBuffer(data.length);
        floatBuffer.rewind();
        floatBuffer.put(data);
        floatBuffer.rewind();

        bind();
        gl3.glBufferData(
            gl3.GL_SHADER_STORAGE_BUFFER,
            Float.BYTES * data.length,
            floatBuffer,
            usage
        );
        unbind();

        elementCount = data.length;
        initialized = true;
    }

    public void updateData(float[] data) {
        if (ssbo == null || !initialized) return;

        FloatBuffer floatBuffer = allocateDirectFloatBuffer(data.length);
        floatBuffer.rewind();
        floatBuffer.put(data);
        floatBuffer.rewind();

        bind();
        gl3.glBufferSubData(
            gl3.GL_SHADER_STORAGE_BUFFER,
            0,
            Float.BYTES * data.length,
            floatBuffer
        );
        unbind();

        elementCount = data.length;
    }

    public int getBindingPoint() {
        return bindingPoint;
    }

    public int getBufferId() {
        return ssbo == null ? 0 : ssbo.get(0);
    }

    public int getElementCount() {
        return elementCount;
    }

    public void dispose() {
        if (ssbo != null) {
            ssbo.rewind();
            gl3.glDeleteBuffers(1, ssbo);
            ssbo = null;
        }
        initialized = false;
        elementCount = 0;
    }
}
