public class Texture {
    PImage img;
    IntBuffer tex;

    int width = 0;
    int height = 0;
    boolean uploaded = false;

    public Texture() {
        tex = allocateDirectIntBuffer(1);
        gl3.glGenTextures(1, tex);
    }

    // 建立空白 texture，常給 FBO 用
    public Texture(int w, int h) {
        this();
        width = w;
        height = h;

        gl3.glBindTexture(gl3.GL_TEXTURE_2D, tex.get(0));
        gl3.glTexImage2D(
            gl3.GL_TEXTURE_2D,
            0,
            gl3.GL_RGBA32F,
            w,
            h,
            0,
            gl3.GL_RGBA,
            gl3.GL_FLOAT,
            null
            );

        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MIN_FILTER, gl3.GL_LINEAR);
        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MAG_FILTER, gl3.GL_LINEAR);
        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_WRAP_S, gl3.GL_CLAMP_TO_EDGE);
        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_WRAP_T, gl3.GL_CLAMP_TO_EDGE);

        gl3.glBindTexture(gl3.GL_TEXTURE_2D, 0);

        uploaded = true;
    }

    // 從圖片路徑載入並上傳到 GPU
    public Texture(String path) {
        this();
        setTexture(path);
    }

    public Texture setTexture(String path) {
        PImage loaded = loadImage(path);
        if (loaded == null) {
            println("[Texture] Failed to load image: " + path);
            return this;
        }

        return setTexture(loaded);
    }

    public Texture setTexture(PImage image) {
        if (image == null) {
            println("[Texture] setTexture failed: image is null");
            return this;
        }

        this.img = image;
        this.width = image.width;
        this.height = image.height;

        uploadImageToGPU();

        return this;
    }

    private void uploadImageToGPU() {
        if (img == null) {
            println("[Texture] upload failed: img is null");
            return;
        }

        img.loadPixels();

        IntBuffer pixelBuffer = allocateDirectIntBuffer(img.pixels.length);
        pixelBuffer.put(img.pixels);
        pixelBuffer.rewind();

        gl3.glBindTexture(gl3.GL_TEXTURE_2D, tex.get(0));

        // Processing 的 pixels 通常是 ARGB packed int
        // 在 JOGL / OpenGL 中常見對應是 BGRA + UNSIGNED_BYTE
        gl3.glTexImage2D(gl3.GL_TEXTURE_2D, 0, gl3.GL_RGBA8, img.width, img.height, 0, gl3.GL_BGRA, gl3.GL_UNSIGNED_BYTE, pixelBuffer);

        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MIN_FILTER, gl3.GL_LINEAR);
        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MAG_FILTER, gl3.GL_LINEAR);
        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_WRAP_S, gl3.GL_REPEAT);
        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_WRAP_T, gl3.GL_REPEAT);

        gl3.glBindTexture(gl3.GL_TEXTURE_2D, 0);

        uploaded = true;
    }

    public Texture bind(int unit) {
        if (tex == null) return this;

        gl3.glActiveTexture(gl3.GL_TEXTURE0 + unit);
        gl3.glBindTexture(gl3.GL_TEXTURE_2D, tex.get(0));
        return this;
    }

    public Texture unbind(int unit) {
        gl3.glActiveTexture(gl3.GL_TEXTURE0 + unit);
        gl3.glBindTexture(gl3.GL_TEXTURE_2D, 0);
        return this;
    }

    public Texture setWrapMode(int mode) {
        if (tex == null) return this;

        gl3.glBindTexture(gl3.GL_TEXTURE_2D, tex.get(0));
        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_WRAP_S, mode);
        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_WRAP_T, mode);
        gl3.glBindTexture(gl3.GL_TEXTURE_2D, 0);

        return this;
    }

    public Texture setSamplingMode(int mode) {
        if (tex == null) return this;

        gl3.glBindTexture(gl3.GL_TEXTURE_2D, tex.get(0));
        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MIN_FILTER, mode);
        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MAG_FILTER, mode);
        gl3.glBindTexture(gl3.GL_TEXTURE_2D, 0);

        return this;
    }

    public int getID() {
        if (tex == null) return 0;
        return tex.get(0);
    }

    public boolean isUploaded() {
        return uploaded;
    }

    public void dispose() {
        if (tex != null) {
            tex.rewind();
            gl3.glDeleteTextures(1, tex);
            tex = null;
        }

        img = null;
        uploaded = false;
        width = 0;
        height = 0;
    }
}
