public abstract class RenderPass {
    public abstract void render(RenderContext ctx);
}

public class ShadowPass extends RenderPass {
    FBO ShadowBuffer;
    ShadowMaterial shadowMaterial;
    public ShadowPass(){
        ShadowBuffer = new FBO(width, height, 1, gl3.GL_LINEAR, true);
        shadowMaterial = new ShadowMaterial("Shaders/Shadow.frag", "Shaders/Shadow.vert");
    }  
    
    @Override
    public void render(RenderContext ctx) {
        ShadowBuffer.bindFrameBuffer();
        var light = ctx.scene.getLights();
        shadowMaterial.setLight(light.get(0));
        for(GameObject go : worldObject){
            go.runWithMaterial(shadowMaterial);    
        }    
        ShadowBuffer.unbindFrameBuffer(width,height);
    }
    
    public Texture[] getBuffer(){
        return ShadowBuffer.tex;
    }
    public Texture getDepthBuffer(){
        return ShadowBuffer.depthTex;
    }
}

public class PointShadowPass extends RenderPass {
    CubeMapFBO ShadowBuffer;
    PointShadowMaterial shadowMaterial;
    public PointShadowPass(){
        ShadowBuffer = new CubeMapFBO(width, 1, true);
        shadowMaterial = new PointShadowMaterial("Shaders/Shadow.frag", "Shaders/Shadow.vert");
    }  
    
    @Override
    public void render(RenderContext ctx) {
        var light = ctx.scene.getLights().get(0);
        shadowMaterial.setLight(light);
        Matrix4[] shadowMatrices = ((PointLight)light).getShadowMatrices();    
        gl3.glEnable(gl3.GL_DEPTH_TEST);    
        for (int face = 0; face < 6; face++) {
            ShadowBuffer.bindFace(face);    
            gl3.glClear(gl3.GL_DEPTH_BUFFER_BIT); // ⭐ 必加    
            shadowMaterial.setShadowMatrix(shadowMatrices[face]);    
            for(GameObject go : ctx.scene.getObjects()){
                go.runWithMaterial(shadowMaterial);    
            }
        }    
        ShadowBuffer.unbind(width, height); // ⭐ 必加
    }
    public TextureCube[] getBuffer(){
        return ShadowBuffer.colorTex;
    }
    public TextureCube getDepthBuffer(){
        return ShadowBuffer.depthTex;
    }
}

public class GBufferPass extends RenderPass {

    FBO GBuffer;
    public GBufferPass(){
        GBuffer = new FBO(width, height, 3, gl3.GL_LINEAR, true);
    }   
    
    public Texture[] getBuffer(){
        return GBuffer.tex;
    }
    
    @Override
    public void render(RenderContext ctx) {
        GBuffer.bindFrameBuffer();

        gl3.glEnable(gl3.GL_DEPTH_TEST);
        gl3.glDisable(gl3.GL_BLEND);
        gl3.glClearColor(0, 0, 0, 1);
        gl3.glClear(gl3.GL_COLOR_BUFFER_BIT | gl3.GL_DEPTH_BUFFER_BIT);
        
        var light = ctx.scene.getLights();
        for (GameObject go : ctx.scene.getObjects()) {
            Material mat = go.getMaterial();
            mat.setLight(light.get(0));
            go.run();
        }

        GBuffer.unbindFrameBuffer(width, height);
    }
}

abstract public class ScenePass extends RenderPass {
    LightMaterial lightMaterial;
    Texture albedoTex;
    Texture normalTex;
    Texture positionTex;
    Texture depthTex;
    
    public ScenePass(){
        lightMaterial = new LightMaterial("Shaders/spotLight.frag", "Shaders/quad.vert");
    }  
    
    public void setGBuffer(Texture albedo, Texture normal, Texture position, Texture depth) {
        albedoTex = albedo;
        normalTex = normal;
        positionTex = position;
        depthTex = depth;
    }
    
    
    @Override
    public void render(RenderContext ctx) {
        var light = ctx.scene.getLights();
        lightMaterial.setAlbedoTex(albedoTex).setNormalTex(normalTex).setPositionTex(positionTex).setDepthTex(depthTex);
        lightMaterial.setLight(light.get(0));
        Camera camera = ctx.scene.camera;
        camera.runWithMaterial(lightMaterial);  
    }
}

public class DirectionalScenePass extends ScenePass{
    public DirectionalScenePass(){
        lightMaterial = new LightMaterial("Shaders/directionalLight.frag", "Shaders/quad.vert");
    }
}

public class SpotScenePass extends ScenePass{
    public SpotScenePass(){
        lightMaterial = new LightMaterial("Shaders/spotLight.frag", "Shaders/quad.vert");
    }
}

public class PointScenePass extends ScenePass{
    PointLightMaterial pointLightMaterial;
    TextureCube shadowCubeMap; 
    public PointScenePass(){
        pointLightMaterial = new PointLightMaterial("Shaders/pointLight.frag", "Shaders/quad.vert");
    }
    
    public void setGBuffer(Texture albedo, Texture normal, Texture position, TextureCube depth) {
        albedoTex = albedo;
        normalTex = normal;
        positionTex = position;
        shadowCubeMap = depth;
    }
    
    @Override
    public void render(RenderContext ctx) {
        var light = ctx.scene.getLights();
        pointLightMaterial.setAlbedoTex(albedoTex).setNormalTex(normalTex).setPositionTex(positionTex);
        pointLightMaterial.setDepthTex(shadowCubeMap);
        pointLightMaterial.setLight(light.get(0));        
        Camera camera = ctx.scene.camera;
        camera.runWithMaterial(pointLightMaterial);  
    }
}
