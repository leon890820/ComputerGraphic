public class Player extends GameObject {
    Vector3 previousOffsetFromPortal = new Vector3();
   
    public void move() {
        if (mousePressed) {
            if (mouseButton == RIGHT) {
                float dx = (pmouseX - mouseX) * GH_MOUSE_SENSITIVITY;
                float dy = (pmouseY - mouseY) * GH_MOUSE_SENSITIVITY;
                transform.eular.set(transform.eular.x + dy, transform.eular.y + dx, 0.0);
                cam1.transform.eular.set(transform.eular.x, transform.eular.y, 0.0);
                cam2.transform.eular.set(transform.eular.x, transform.eular.y, 0.0);
                cam3.transform.eular.set(transform.eular.x, transform.eular.y, 0.0);
            }
        }

        Vector3 forward = forward();
        Vector3 right = right();

        float wx = key_input[3] ? 1.0 * GH_WALK_SPEED : key_input[1] ? -1.0 * GH_WALK_SPEED : 0.0;
        float wz = key_input[0] ? 1.0 * GH_WALK_SPEED : key_input[2] ? -1.0 * GH_WALK_SPEED: 0.0;

        Vector3 mv = forward.mult(wz).add(right.mult(wx));
        transform.position = transform.position.add(mv);
        cam1.transform.position = transform.position.add(new Vector3());
        cam2.transform.position = transform.position.add(new Vector3(-12.0, 0.0, 0.0));
        cam3.transform.position = transform.position.add(new Vector3(12.0, 0.0, 0.0));

        cam1.update();
        cam2.update();
        cam3.update();
    }
    
    
    public void onCollideEnter(){

        println("123");
    }
    public void onCollideExit(){

        println("456");
    }
    
}
