abstract interface Scene {
    abstract void load(ArrayList<Object> objs);
}

class Level1 implements Scene {

    void load(ArrayList<Object> objs) {
        Knot knot = new Knot();
        knot.setScale(new Vector3(1, 1, 1));
        knot.setEular(new Vector3(0, PI, PI));
        knot.setPos(new Vector3(0, 0, -1));
        objs.add(knot);
    }
}
