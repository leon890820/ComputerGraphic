abstract class Scene{
    ArrayList<GameObject> objs;
    public Scene(){
        objs = new ArrayList<GameObject>();
        load();
    }
    abstract void load();
    abstract void run();
}

class Level1 extends Scene{ 
    
    PhongMaterial phongMaterial1;
    PhongMaterial phongMaterial2;
    PhongMaterial phongMaterial3;
    PhongMaterial phongMaterial4;
    PhongMaterial phongMaterial5;
    PortalMaterial portalMaterial1;
    PortalMaterial portalMaterial2;
    LineMaterial lineMaterial;


    PhongObject floor1;
    PhongObject floor2;
    PhongObject[] cubes;

    PhongObject tunnel1;
    PhongObject tunnel2;   
    
    PortalObject portal1;    
    PortalObject portal2;
    Collider collider1;
    Collider collider2;
    
    FBO cam_texture1;
    FBO cam_texture2;

        
    void load(){
        setMaterial();
        setGameObject();      
    }
    
    void run(){
        
        main_camera = cam3;
        cam_texture2.bindFrameBuffer();
        background(0);
        objs.forEach(GameObject::run);
        
        main_camera = cam2;
        cam_texture1.bindFrameBuffer();
        background(0);
        objs.forEach(GameObject::run);

        main_camera = cam1;
        gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER , 0);
        background(0);      
        objs.forEach(GameObject::run);
        portal1.run();
        portal2.run();
        collider1.debugRun();
        collider2.debugRun();
        
        
        boolean collideEnter1 = collider1.collide(player.transform.position);
        if(collideEnter1 != collider1.isCollide){
            if(collideEnter1)collider1.onCollideEnter(player);
            else collider1.onCollideExit(player);
        }
        boolean collideEnter2 = collider2.collide(player.transform.position);
        if(collideEnter2 != collider2.isCollide){
            if(collideEnter2)collider2.onCollideEnter(player);
            else collider2.onCollideExit(player);
        }
        collider1.logicalRun();
        collider2.logicalRun();


    }
    
    void setGameObject() {
        floor1 = new PhongObject("Meshes/cube", phongMaterial1);  
        floor1.setScale(5.0,0.1,10.0).setPosition(-6.0,0.0,0.0);
        objs.add(floor1);
        
        floor2 = new PhongObject("Meshes/cube", phongMaterial2);  
        floor2.setScale(5.0,0.1,10.0).setPosition(6.0,0.0,0.0);
        objs.add(floor2);
        
        cubes = new PhongObject[8];
        
        cubes[0] = new PhongObject("Meshes/cube", phongMaterial3);  
        cubes[0].setScale(0.5,0.5,0.5).setPosition(8.0,0.6,8.0).setEular(0.0,0.2,0.0);
        objs.add(cubes[0]);
        
        cubes[1] = new PhongObject("Meshes/cube", phongMaterial3);  
        cubes[1].setScale(0.5,0.5,0.5).setPosition(4.0,0.6,5.0).setEular(0.0,0.8,0.0);
        objs.add(cubes[1]);
        
        cubes[2] = new PhongObject("Meshes/cube", phongMaterial3);  
        cubes[2].setScale(0.5,0.5,0.5).setPosition(4.0,0.6,-6.0).setEular(0.0,2.8,0.0);
        objs.add(cubes[2]);
        
        cubes[3] = new PhongObject("Meshes/cube", phongMaterial3);  
        cubes[3].setScale(0.5,0.5,0.5).setPosition(7.0,0.6,-5.0).setEular(0.0,1.5,0.0);
        objs.add(cubes[3]);
        
        cubes[4] = new PhongObject("Meshes/cube", phongMaterial3);  
        cubes[4].setScale(0.5,0.5,0.5).setPosition(-8.0,0.6,9.0).setEular(0.0,0.2,0.0);
        objs.add(cubes[4]);
        
        cubes[5] = new PhongObject("Meshes/cube", phongMaterial3);  
        cubes[5].setScale(0.5,0.5,0.5).setPosition(-4.0,0.6,4.0).setEular(0.0,0.8,0.0);
        objs.add(cubes[5]);
        
        cubes[6] = new PhongObject("Meshes/cube", phongMaterial3);  
        cubes[6].setScale(0.5,0.5,0.5).setPosition(-4.0,0.6,-7.0).setEular(0.0,2.8,0.0);
        objs.add(cubes[6]);
        
        cubes[7] = new PhongObject("Meshes/cube", phongMaterial3);  
        cubes[7].setScale(0.5,0.5,0.5).setPosition(-7.0,0.6,-8.0).setEular(0.0,1.5,0.0);
        objs.add(cubes[7]);
        
        tunnel1 = new PhongObject("Meshes/tunnel", phongMaterial4);  
        tunnel1.setScale(3.0, 2.0, 0.2).setPosition(-6.0, 0.1, 0.0).setEular(0.0, 0.0 , 0.0);
        objs.add(tunnel1);
        
        tunnel2 = new PhongObject("Meshes/tunnel", phongMaterial4);  
        tunnel2.setScale(3.0, 2.0, 0.2).setPosition(6.0, 0.1, 0.0).setEular(0.0, 0.0 , 0.0);
        objs.add(tunnel2);
        
        portal1 = new PortalObject("Meshes/quad",portalMaterial2); 
        portal1.setScale(1.8, 2.0, 1.0).setPosition(-6.0, 2.1, 0.0).setEular(0.0, 0.0 , 0.0);
        //objs.add(portal1);
        
        portal2 = new PortalObject("Meshes/quad",portalMaterial1); 
        portal2.setScale(1.8, 2.0, 1.0).setPosition(6.0, 2.1, 0.0).setEular(0.0, 0.0 , 0.0);
        //objs.add(portal2);
        
        collider1 = new Collider(lineMaterial);
        collider1.setScale(1.8, 2.0, 0.3).setPosition(-6.0, 2.1, 0.0).setEular(0.0, 0.0 , 0.0);
        collider1.update();
        
        collider2 = new Collider(lineMaterial);
        collider2.setScale(1.8, 2.0, 0.3).setPosition(6.0, 2.1, 0.0).setEular(0.0, 0.0 , 0.0);
        collider2.update();
        
        collider1.linkPortal = collider2;
        collider2.linkPortal = collider1;
    }
    
    void setMaterial() {  
        
        cam_texture1 = new FBO(width,height,1);
        cam_texture2 = new FBO(width,height,1);
        
        phongMaterial1 = new PhongMaterial("Shaders/BlinnPhong.frag", "Shaders/BlinnPhong.vert");
        phongMaterial1.setAlbedo(170.0/255.0, 52.0/255.0, 90.0/255.0);     
        
        phongMaterial2 = new PhongMaterial("Shaders/BlinnPhong.frag", "Shaders/BlinnPhong.vert");
        phongMaterial2.setAlbedo(34.0/255.0, 61.0/255.0, 116.0/255.0);
        
        phongMaterial3 = new PhongMaterial("Shaders/BlinnPhong.frag", "Shaders/BlinnPhong.vert");
        phongMaterial3.setAlbedo(17.0/255.0, 19.0/255.0, 21.0/255.0);
        
        phongMaterial4 = new PhongMaterial("Shaders/BlinnPhong.frag", "Shaders/BlinnPhong.vert");
        phongMaterial4.setAlbedo(27.0/255.0, 29.0/255.0, 31.0/255.0);
        
        phongMaterial5 = new PhongMaterial("Shaders/BlinnPhong.frag", "Shaders/BlinnPhong.vert");
        phongMaterial5.setAlbedo(1.0,1.0,1.0);
        
        portalMaterial1 = new PortalMaterial("Shaders/Portal.frag", "Shaders/Portal.vert");
        portalMaterial1.setMainTexture(cam_texture1.tex[0]);
        
        portalMaterial2 = new PortalMaterial("Shaders/Portal.frag", "Shaders/Portal.vert");
        portalMaterial2.setMainTexture(cam_texture2.tex[0]);
        
        lineMaterial = new LineMaterial("Shaders/Line.frag", "Shaders/Line.vert");
        lineMaterial.setAlbedo(0.0,0.9,0.1);
    }
    
}
