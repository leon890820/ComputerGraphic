public class RenderContext {
    Scene scene;
    Camera camera;

    int screenW;
    int screenH;

    public RenderContext(Scene scene, Camera camera, int screenW, int screenH) {
        this.scene = scene;
        this.camera = camera;
        this.screenW = screenW;
        this.screenH = screenH;
    }

}
