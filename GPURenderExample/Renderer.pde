public class Renderer {

    RenderContext ctx;
    
    
    GBufferPass gBufferPass;
    PointShadowPass pointShadowPass;
    ShadowPass shadowPass;
    SpotScenePass spotScenePass;
    DirectionalScenePass directionalScenePass;
    PointScenePass pointScenePass;

    public Renderer(RenderContext ctx) {
        this.ctx = ctx;
        gBufferPass = new GBufferPass();
        shadowPass = new ShadowPass();
        spotScenePass = new SpotScenePass();
        directionalScenePass = new DirectionalScenePass();
        pointShadowPass = new PointShadowPass();
        pointScenePass = new PointScenePass();
    }

    public void render() {
        renderShadowPasses();
        gBufferPass.render(ctx);
        renderScenePasses();
        
    }

    private void renderShadowPasses() {
        for (Light light : ctx.scene.getLights()) {
            if (light instanceof DirectionalLight || light instanceof SpotLight) {
                shadowPass.render(ctx);
            }
            else if (light instanceof PointLight) {
                pointShadowPass.render(ctx);
            }
        }
    }
    
    private void renderScenePasses() {
        for (Light light : ctx.scene.getLights()) {
            if (light instanceof SpotLight) {
                var buffer = gBufferPass.getBuffer();
                var depth = shadowPass.getDepthBuffer();
                spotScenePass.setGBuffer(buffer[0],buffer[1],buffer[2],depth);
                spotScenePass.render(ctx);
            }else if(light instanceof DirectionalLight){
                var buffer = gBufferPass.getBuffer();
                var depth = shadowPass.getDepthBuffer();
                directionalScenePass.setGBuffer(buffer[0],buffer[1],buffer[2],depth);
                directionalScenePass.render(ctx);
            }
            else if (light instanceof PointLight) {
                var buffer = gBufferPass.getBuffer();
                var depth = pointShadowPass.getDepthBuffer();
                pointScenePass.setGBuffer(buffer[0],buffer[1],buffer[2],depth);
                pointScenePass.render(ctx);
            }
        }
    }
}
