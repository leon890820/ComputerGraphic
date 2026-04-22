public class FBO {
    IntBuffer fbo;
    IntBuffer rbo;
    Texture[] tex;
    Texture depthTex;

    int fboWidth;
    int fboHeight;
    int colorCount;

    public FBO(int w, int h, int num, int filter, boolean useDepthTexture) {
        fboWidth = w;
        fboHeight = h;
        colorCount = num;

        fbo = allocateDirectIntBuffer(1);
        rbo = allocateDirectIntBuffer(1);
        tex = new Texture[num];

        gl3.glGenFramebuffers(1, fbo);
        gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER, fbo.get(0));

        int[] colorAttachments = new int[num];

        // color attachments
        for (int i = 0; i < num; i++) {
            tex[i] = new Texture(w, h);

            gl3.glBindTexture(gl3.GL_TEXTURE_2D, tex[i].tex.get(0));
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

            gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MIN_FILTER, filter);
            gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MAG_FILTER, filter);
            gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_WRAP_S, gl3.GL_CLAMP_TO_EDGE);
            gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_WRAP_T, gl3.GL_CLAMP_TO_EDGE);

            gl3.glFramebufferTexture2D(
                gl3.GL_FRAMEBUFFER,
                gl3.GL_COLOR_ATTACHMENT0 + i,
                gl3.GL_TEXTURE_2D,
                tex[i].tex.get(0),
                0
            );

            colorAttachments[i] = gl3.GL_COLOR_ATTACHMENT0 + i;
        }

        gl3.glBindTexture(gl3.GL_TEXTURE_2D, 0);

        // depth attachment
        if (useDepthTexture) {
            depthTex = new Texture(w, h);

            gl3.glBindTexture(gl3.GL_TEXTURE_2D, depthTex.tex.get(0));
            gl3.glTexImage2D(
                gl3.GL_TEXTURE_2D,
                0,
                gl3.GL_DEPTH_COMPONENT24,
                w,
                h,
                0,
                gl3.GL_DEPTH_COMPONENT,
                gl3.GL_FLOAT,
                null
            );

            gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MIN_FILTER, gl3.GL_NEAREST);
            gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MAG_FILTER, gl3.GL_NEAREST);
            gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_WRAP_S, gl3.GL_CLAMP_TO_EDGE);
            gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_WRAP_T, gl3.GL_CLAMP_TO_EDGE);

            gl3.glFramebufferTexture2D(
                gl3.GL_FRAMEBUFFER,
                gl3.GL_DEPTH_ATTACHMENT,
                gl3.GL_TEXTURE_2D,
                depthTex.tex.get(0),
                0
            );

            gl3.glBindTexture(gl3.GL_TEXTURE_2D, 0);
        } else {
            gl3.glGenRenderbuffers(1, rbo);
            gl3.glBindRenderbuffer(gl3.GL_RENDERBUFFER, rbo.get(0));
            gl3.glRenderbufferStorage(gl3.GL_RENDERBUFFER, gl3.GL_DEPTH_COMPONENT24, w, h);
            gl3.glFramebufferRenderbuffer(
                gl3.GL_FRAMEBUFFER,
                gl3.GL_DEPTH_ATTACHMENT,
                gl3.GL_RENDERBUFFER,
                rbo.get(0)
            );
            gl3.glBindRenderbuffer(gl3.GL_RENDERBUFFER, 0);
        }

        gl3.glDrawBuffers(num, colorAttachments, 0);

        int status = gl3.glCheckFramebufferStatus(gl3.GL_FRAMEBUFFER);
        if (status != gl3.GL_FRAMEBUFFER_COMPLETE) {
            println("[FBO] Framebuffer incomplete! status = " + status);
        } else {
            println("[FBO] Framebuffer complete: " + w + "x" + h + ", attachments = " + num);
        }

        gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER, 0);
    }

    void bindFrameBuffer() {
        gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER, fbo.get(0));
        gl3.glViewport(0, 0, fboWidth, fboHeight);
        gl3.glClear(gl3.GL_COLOR_BUFFER_BIT | gl3.GL_DEPTH_BUFFER_BIT);
    }

    void unbindFrameBuffer(int screenW, int screenH) {
        gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER, 0);
        gl3.glViewport(0, 0, screenW, screenH);
    }

    Texture getColorTexture(int index) {
        if (index < 0 || index >= colorCount) {
            println("[FBO] invalid color attachment index: " + index);
            return null;
        }
        return tex[index];
    }

    Texture getDepthTexture() {
        return depthTex;
    }

    void dispose() {
        if (tex != null) {
            for (int i = 0; i < tex.length; i++) {
                if (tex[i] != null && tex[i].tex != null) {
                    tex[i].tex.rewind();
                    gl3.glDeleteTextures(1, tex[i].tex);
                }
            }
        }

        if (depthTex != null && depthTex.tex != null) {
            depthTex.tex.rewind();
            gl3.glDeleteTextures(1, depthTex.tex);
        }

        if (rbo != null) {
            rbo.rewind();
            gl3.glDeleteRenderbuffers(1, rbo);
        }

        if (fbo != null) {
            fbo.rewind();
            gl3.glDeleteFramebuffers(1, fbo);
        }
    }
}

public class CubeMapFBO {
    IntBuffer fbo;

    TextureCube[] colorTex;
    TextureCube depthTex;

    int size;
    int colorCount;

    public CubeMapFBO(int size, int colorCount, boolean useDepthTexture) {
        this.size = size;
        this.colorCount = colorCount;

        fbo = allocateDirectIntBuffer(1);
        gl3.glGenFramebuffers(1, fbo);

        colorTex = new TextureCube[colorCount];
        for (int i = 0; i < colorCount; i++) {
            colorTex[i] = new TextureCube(
                size,
                gl3.GL_RGBA32F,
                gl3.GL_RGBA,
                gl3.GL_FLOAT,
                gl3.GL_LINEAR
            );
        }

        if (useDepthTexture) {
            depthTex = new TextureCube(
                size,
                gl3.GL_DEPTH_COMPONENT24,
                gl3.GL_DEPTH_COMPONENT,
                gl3.GL_FLOAT,
                gl3.GL_NEAREST
            );
        }
    }

    public void bindFace(int faceIndex) {
        gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER, fbo.get(0));
        gl3.glViewport(0, 0, size, size);

        int[] drawBuffers = new int[colorCount];

        for (int i = 0; i < colorCount; i++) {
            gl3.glFramebufferTexture2D(
                gl3.GL_FRAMEBUFFER,
                gl3.GL_COLOR_ATTACHMENT0 + i,
                gl3.GL_TEXTURE_CUBE_MAP_POSITIVE_X + faceIndex,
                colorTex[i].tex.get(0),
                0
            );
            drawBuffers[i] = gl3.GL_COLOR_ATTACHMENT0 + i;
        }

        if (depthTex != null) {
            gl3.glFramebufferTexture2D(
                gl3.GL_FRAMEBUFFER,
                gl3.GL_DEPTH_ATTACHMENT,
                gl3.GL_TEXTURE_CUBE_MAP_POSITIVE_X + faceIndex,
                depthTex.tex.get(0),
                0
            );
        }

        if (colorCount > 0) {
            gl3.glDrawBuffers(colorCount, drawBuffers, 0);
        } else {
            gl3.glDrawBuffer(gl3.GL_NONE);
            gl3.glReadBuffer(gl3.GL_NONE);
        }

        int status = gl3.glCheckFramebufferStatus(gl3.GL_FRAMEBUFFER);
        if (status != gl3.GL_FRAMEBUFFER_COMPLETE) {
            println("[CubeMapFBO] incomplete on face " + faceIndex + " status = " + status);
        }

        gl3.glClear(gl3.GL_COLOR_BUFFER_BIT | gl3.GL_DEPTH_BUFFER_BIT);
    }

    public void unbind(int screenW, int screenH) {
        gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER, 0);
        gl3.glViewport(0, 0, screenW, screenH);
    }

    public TextureCube getColorTexture(int index) {
        if (index < 0 || index >= colorCount) {
            println("[CubeMapFBO] invalid color index: " + index);
            return null;
        }
        return colorTex[index];
    }

    public TextureCube getDepthTexture() {
        return depthTex;
    }

    public void dispose() {
        if (colorTex != null) {
            for (int i = 0; i < colorTex.length; i++) {
                if (colorTex[i] != null) {
                    colorTex[i].dispose();
                }
            }
        }

        if (depthTex != null) {
            depthTex.dispose();
        }

        if (fbo != null) {
            fbo.rewind();
            gl3.glDeleteFramebuffers(1, fbo);
            fbo = null;
        }
    }
}
