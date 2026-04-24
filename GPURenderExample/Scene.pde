public class Scene {
    ArrayList<GameObject> objects = new ArrayList<GameObject>();
    ArrayList<Light> lights = new ArrayList<Light>();
    Camera camera;

    public Scene setCamera(Camera cam) {
        camera = cam;
        return this;
    }

    public Scene addObject(GameObject go) {
        objects.add(go);
        return this;
    }

    public Scene addLight(Light light) {
        lights.add(light);
        return this;
    }

    public ArrayList<GameObject> getObjects() {
        return objects;
    }

    public ArrayList<Light> getLights() {
        return lights;
    }

    public Camera getCamera() {
        return camera;
    }
}
