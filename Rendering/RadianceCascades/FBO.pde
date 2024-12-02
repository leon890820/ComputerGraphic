public class FBO {
    IntBuffer fbo;
    IntBuffer rbo;
    Texture[] tex;
    Texture depthtex;
    
    public FBO(int w,int h, int num ,int filter){
        fbo = IntBuffer.allocate(1);
        tex = new Texture[num];
        
        
        gl3.glGenFramebuffers(1, fbo);
        gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER , fbo.get(0));
        
        int[] color_attachment = new int[num];

        for(int i = 0; i < num ; i++){
            tex[i] = new Texture(w,h);
            gl3.glBindTexture(gl3.GL_TEXTURE_2D, tex[i].tex.get(0));
            gl3.glTexImage2D(gl3.GL_TEXTURE_2D, 0, gl3.GL_RGBA32F, w, h, 0, gl3.GL_RGBA, gl3.GL_FLOAT, null); 
            gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MIN_FILTER, filter);
            gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MAG_FILTER, filter);
            gl3.glBindTexture(gl3.GL_TEXTURE_2D, 0);
            gl3.glFramebufferTexture2D(gl3.GL_FRAMEBUFFER, gl3.GL_COLOR_ATTACHMENT1 + i, gl3.GL_TEXTURE_2D, tex[i].tex.get(0), 0);
            color_attachment[i] = gl3.GL_COLOR_ATTACHMENT1 + i;
        }
        
        //depthtex = new Texture(w,h);
        //gl3.glBindTexture(gl3.GL_TEXTURE_2D, depthtex.tex.get(0));
        //gl3.glTexImage2D(gl3.GL_TEXTURE_2D, 0, gl3.GL_DEPTH_COMPONENT24, w, h, 0, gl3.GL_DEPTH_COMPONENT, gl3.GL_UNSIGNED_INT, null);
        //gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MIN_FILTER, gl3.GL_NEAREST);
        //gl3.glTexParameteri(gl3.GL_TEXTURE_2D, gl3.GL_TEXTURE_MAG_FILTER, gl3.GL_NEAREST);
        //gl3.glFramebufferTexture2D(gl3.GL_FRAMEBUFFER, gl3.GL_DEPTH_ATTACHMENT, gl3.GL_TEXTURE_2D,  depthtex.tex.get(0), 0);

        rbo = IntBuffer.allocate(1);
        gl3.glGenRenderbuffers(1, rbo); 
        gl3.glBindRenderbuffer(gl3.GL_RENDERBUFFER, rbo.get(0)); 
        gl3.glRenderbufferStorage(gl3.GL_RENDERBUFFER, gl3.GL_DEPTH_COMPONENT16, width, height);        
        gl3.glFramebufferRenderbuffer(gl3.GL_FRAMEBUFFER, gl3.GL_DEPTH_ATTACHMENT, gl3.GL_RENDERBUFFER, rbo.get(0));

        
        gl3.glDrawBuffers(num, color_attachment ,0);
        gl3.glEnable(gl3.GL_DEPTH_TEST);
        
        gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER , 0);
        gl3.glBindTexture(gl3.GL_TEXTURE_2D, 0);
    }
    
    void bindFrameBuffer(){
        gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER , fbo.get(0));        
        gl3.glClear(gl3.GL_COLOR_BUFFER_BIT | gl3.GL_DEPTH_BUFFER_BIT);
        //background(0);
    }

    
}
