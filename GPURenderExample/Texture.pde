public class Texture {
    PImage img;
    IntBuffer tex;

    int width = 0;
    int height = 0;
    boolean uploaded = false;

    // 可選：控制是否在 upload 前做 Y flip
    boolean flipYOnUpload = true;

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

    public Texture(String path) {
        this();
        setTexture(path);
    }

    public Texture(String path, boolean flipY) {
        this();
        this.flipYOnUpload = flipY;
        setTexture(path);
    }

    public Texture setFlipYOnUpload(boolean flipY) {
        this.flipYOnUpload = flipY;
        return this;
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

        int[] pixelsToUpload;
        if (flipYOnUpload) {
            pixelsToUpload = flipPixelsY(img.pixels, img.width, img.height);
        } else {
            pixelsToUpload = img.pixels;
        }

        IntBuffer pixelBuffer = allocateDirectIntBuffer(pixelsToUpload.length);
        pixelBuffer.put(pixelsToUpload);
        pixelBuffer.rewind();

        gl3.glBindTexture(gl3.GL_TEXTURE_2D, tex.get(0));

        gl3.glTexImage2D(
            gl3.GL_TEXTURE_2D,
            0,
            gl3.GL_RGBA8,
            img.width,
            img.height,
            0,
            gl3.GL_BGRA,
            gl3.GL_UNSIGNED_BYTE,
            pixelBuffer
        );

        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MIN_FILTER, gl3.GL_LINEAR);
        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MAG_FILTER, gl3.GL_LINEAR);
        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_WRAP_S, gl3.GL_REPEAT);
        gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_WRAP_T, gl3.GL_REPEAT);

        gl3.glBindTexture(gl3.GL_TEXTURE_2D, 0);

        uploaded = true;
    }

    private int[] flipPixelsY(int[] src, int w, int h) {
        int[] dst = new int[src.length];

        for (int y = 0; y < h; y++) {
            int srcRow = y * w;
            int dstRow = (h - 1 - y) * w;
            arrayCopy(src, srcRow, dst, dstRow, w);
        }

        return dst;
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


public class TextureCube {
    IntBuffer tex;
    int size;

    public TextureCube(int size, int internalFormat, int format, int type, int filter) {
        this.size = size;
        tex = allocateDirectIntBuffer(1);

        gl3.glGenTextures(1, tex);
        gl3.glBindTexture(gl3.GL_TEXTURE_CUBE_MAP, tex.get(0));

        for (int i = 0; i < 6; i++) {
            gl3.glTexImage2D(
                gl3.GL_TEXTURE_CUBE_MAP_POSITIVE_X + i,
                0,
                internalFormat,
                size,
                size,
                0,
                format,
                type,
                null
            );
        }

        gl3.glTexParameteri(gl3.GL_TEXTURE_CUBE_MAP, gl3.GL_TEXTURE_MIN_FILTER, filter);
        gl3.glTexParameteri(gl3.GL_TEXTURE_CUBE_MAP, gl3.GL_TEXTURE_MAG_FILTER, filter);
        gl3.glTexParameteri(gl3.GL_TEXTURE_CUBE_MAP, gl3.GL_TEXTURE_WRAP_S, gl3.GL_CLAMP_TO_EDGE);
        gl3.glTexParameteri(gl3.GL_TEXTURE_CUBE_MAP, gl3.GL_TEXTURE_WRAP_T, gl3.GL_CLAMP_TO_EDGE);
        gl3.glTexParameteri(gl3.GL_TEXTURE_CUBE_MAP, gl3.GL_TEXTURE_WRAP_R, gl3.GL_CLAMP_TO_EDGE);

        gl3.glBindTexture(gl3.GL_TEXTURE_CUBE_MAP, 0);
    }

    public void bind(int unit) {
        gl3.glActiveTexture(gl3.GL_TEXTURE0 + unit);
        gl3.glBindTexture(gl3.GL_TEXTURE_CUBE_MAP, tex.get(0));
    }

    public void unbind(int unit) {
        gl3.glActiveTexture(gl3.GL_TEXTURE0 + unit);
        gl3.glBindTexture(gl3.GL_TEXTURE_CUBE_MAP, 0);
    }

    public boolean isUploaded() {
        return tex != null && tex.get(0) != 0;
    }

    public void dispose() {
        if (tex != null) {
            tex.rewind();
            gl3.glDeleteTextures(1, tex);
            tex = null;
        }
    }
}
