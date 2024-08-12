public class Light {
    public Vector3 pos;
    public Vector3 light_dir;
    public Vector3 light_color;

    Light(Vector3 pos, Vector3 ld, Vector3 lc) {
        this.pos = pos;
        this.light_dir = ld;
        this.light_color = lc;
    }
    public void setPos(Vector3 v) {
        this.pos = v;
    }
    public void setPos(float x, float y, float z) {
        this.pos.set(x, y, z);
    }

    public void setLightColor(Vector3 v) {
        this.light_color = v;
    }

    public void setLightColor(float x, float y, float z) {
        this.light_color.set(x, y, z);
    }

    public void setLightdirection(Vector3 v) {
        this.light_dir = v;
    }

    public void setLightdirection(float x, float y, float z) {
        this.light_dir.set(x, y, z);
    }
}
