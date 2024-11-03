abstract class Scene {
    ArrayList<GameObject> objs;
    public Scene() {
        objs = new ArrayList<GameObject>();
        load();
    }
    abstract void load();
    abstract void run();
}

class Level1 extends Scene {
    
    FBO shadow_FBO;
    FBO GBuffer_FBO;
    
    Texture checkTexture;

    PhongMaterial phongMaterial1;
    PhongMaterial phongMaterial2;
    SSRMaterial ssrMaterial;
    ShadowMaterial shadowMaterial;
    
    PhongObject scube;
    PhongObject sfloor;
    
    PhongObject pcube;
    PhongObject pfloor;
    
    PhongObject sscube;
    PhongObject ssfloor;
    
    Quad quad;
    
    
    public void load() {
        setMaterial();
        setGameObject();
    }

    public void run() {
        //shadow pass
        shadow_FBO.bindFrameBuffer();
        gl3.glClear(gl3.GL_COLOR_BUFFER_BIT|gl3.GL_DEPTH_BUFFER_BIT);
        scube.run();
        sfloor.run();
        
        //GBuffer pass
        GBuffer_FBO.bindFrameBuffer();
        gl3.glClear(gl3.GL_COLOR_BUFFER_BIT|gl3.GL_DEPTH_BUFFER_BIT);
        //pcube.run();
        pfloor.run();
        
        // SSR pass        
        gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER , 0);
        gl3.glClear(gl3.GL_COLOR_BUFFER_BIT|gl3.GL_DEPTH_BUFFER_BIT);
        //sscube.run();
        ssfloor.run();
    }


    void setGameObject() {
        scube = new PhongObject("Meshes/cube", shadowMaterial);
        sfloor = new PhongObject("Meshes/quad", shadowMaterial);
        pcube = new PhongObject("Meshes/cube", phongMaterial1);
        pfloor = new PhongObject("Meshes/quad", phongMaterial2);
        sscube = new PhongObject("Meshes/cube", ssrMaterial);
        ssfloor = new PhongObject("Meshes/quad", ssrMaterial);

        
        
        sfloor.setPosition(0.0, -1.0, 0.0).setScale(5.0, 5.0, 1.0).setEular(-PI/2, 0.0, 0.0);
        pfloor.setPosition(0.0, -1.0, 0.0).setScale(5.0, 5.0, 1.0).setEular(-PI/2, 0.0, 0.0);
        ssfloor.setPosition(0.0, -1.0, 0.0).setScale(5.0, 5.0, 1.0).setEular(-PI/2, 0.0, 0.0);
        
        quad = new Quad(ssrMaterial);
        //dragon.setScale(50, 50, 50);
    }

    void setMaterial() {
               
        shadow_FBO = new FBO(width,height,1);
        GBuffer_FBO = new FBO(width,height,5);
        
        phongMaterial1 = new PhongMaterial("Shaders/GBuffer.frag", "Shaders/GBuffer.vert");
        phongMaterial1.setAlbedo(0.8, 0.8, 0.8).setLightDepth(shadow_FBO.tex[0]);

        checkTexture = new Texture("Textures/checker.png");
        phongMaterial2 = new PhongMaterial("Shaders/GBuffer.frag", "Shaders/GBuffer.vert");
        phongMaterial2.setAlbedo(0.6, 0.2, 0.8).setTexture(checkTexture).setLightDepth(shadow_FBO.tex[0]);
        
        ssrMaterial = new SSRMaterial("Shaders/ScreenSpaceReflect.frag", "Shaders/ScreenSpaceReflect.vert");
        ssrMaterial.setKds(GBuffer_FBO.tex[0]).setNormal(GBuffer_FBO.tex[1]).setWorldPos(GBuffer_FBO.tex[2]).setDepth(GBuffer_FBO.tex[3]).setShadow(GBuffer_FBO.tex[4]);
        
        shadowMaterial = new ShadowMaterial("Shaders/Shadow.frag", "Shaders/Shadow.vert");
    }
}


class Level2 extends Scene {
    FBO shadow_FBO;
    FBO GBuffer_FBO;
    
    Texture checkTexture;

    PhongMaterial phongMaterial1;
    PhongMaterial phongMaterial2;
    SSRMaterial ssrMaterial;
    ShadowMaterial shadowMaterial;
    
    PhongObject scube;
    PhongObject sfloor;
    
    PhongObject pcube;
    PhongObject pfloor;
    
    Quad quad;
    
    
    public void load() {
        setMaterial();
        setGameObject();
    }

    public void run() {
        //shadow pass
        shadow_FBO.bindFrameBuffer();
        gl3.glClear(gl3.GL_COLOR_BUFFER_BIT|gl3.GL_DEPTH_BUFFER_BIT);
        scube.run();
        sfloor.run();
        
        //GBuffer pass
         GBuffer_FBO.bindFrameBuffer();
         gl3.glClear(gl3.GL_COLOR_BUFFER_BIT|gl3.GL_DEPTH_BUFFER_BIT);
         pcube.run();
         pfloor.run();
        
        // SSR pass        
        gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER , 0);
        gl3.glClear(gl3.GL_COLOR_BUFFER_BIT|gl3.GL_DEPTH_BUFFER_BIT);
        quad.run();
    }


    void setGameObject() {
        scube = new PhongObject("Meshes/cube1", shadowMaterial);
        sfloor = new PhongObject("Meshes/quad", shadowMaterial);
        pcube = new PhongObject("Meshes/cube1", phongMaterial2);
        pfloor = new PhongObject("Meshes/quad", phongMaterial1);
        sfloor.setPosition(0.0, -1.0, 0.0).setScale(5.0, 5.0, 1.0).setEular(-PI/2, 0.0, 0.0);
        pfloor.setPosition(0.0, -1.0, 0.0).setScale(5.0, 5.0, 1.0).setEular(-PI/2, 0.0, 0.0);
        
        quad = new Quad(ssrMaterial);
        //dragon.setScale(50, 50, 50);
    }

    void setMaterial() {
        shadow_FBO = new FBO(width,height,1);
        GBuffer_FBO = new FBO(width,height,5);
        
        phongMaterial1 = new PhongMaterial("Shaders/GBuffer.frag", "Shaders/GBuffer.vert");
        phongMaterial1.setAlbedo(0.8, 0.8, 0.8).setLightDepth(shadow_FBO.tex[0]);

        checkTexture = new Texture("Textures/checker.png");
        phongMaterial2 = new PhongMaterial("Shaders/GBuffer.frag", "Shaders/GBuffer.vert");
        phongMaterial2.setAlbedo(0.6, 0.2, 0.8).setTexture(checkTexture).setLightDepth(shadow_FBO.tex[0]);
        
        ssrMaterial = new SSRMaterial("Shaders/ScreenSpaceReflect.frag", "Shaders/ScreenSpaceReflect.vert");
        ssrMaterial.setKds(GBuffer_FBO.tex[0]).setNormal(GBuffer_FBO.tex[1]).setWorldPos(GBuffer_FBO.tex[2]).setDepth(GBuffer_FBO.tex[3]).setShadow(GBuffer_FBO.tex[4]);
        
        shadowMaterial = new ShadowMaterial("Shaders/Shadow.frag", "Shaders/Shadow.vert");
    }
}
