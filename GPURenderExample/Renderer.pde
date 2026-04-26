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
            light.renderShadow(ctx, this);
        }
    }
    
    private void renderScenePasses() {
        for (Light light : ctx.scene.getLights()) {
            light.renderLighting(ctx, this);
        }
    }
}
