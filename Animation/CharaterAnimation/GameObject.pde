public abstract class GameObject {
    String name;
    GameObject parent;
    Transform transform;
    Mesh mesh;
    Material material;
    MeshRenderer meshRenderer;
    boolean[] hasProperties = new boolean[4];

    public GameObject() {
        transform = new Transform();
    }
    public GameObject setTransform(Transform trans) {
        transform = trans;
        return this;
    }
    public GameObject setTransform(Vector3 pos, Vector3 eular, Vector3 scale) {
        transform.setPosition(pos).setEular(eular).setScale(scale);
        return this;
    }

    public GameObject setPosition(Vector3 pos) {
        transform.setPosition(pos);
        return this;
    }

    public GameObject setEular(Vector3 eular) {
        transform.setEular(eular);
        return this;
    }
    public GameObject setScale(Vector3 scale) {
        transform.setScale(scale);
        return this;
    }

    public GameObject setPosition(float x, float y, float z) {
        transform.setPosition(x, y, z);
        return this;
    }

    public GameObject setEular(float x, float y, float z) {
        transform.setEular(x, y, z);
        return this;
    }
    public GameObject setScale(float x, float y, float z) {
        transform.setScale(x, y, z);
        return this;
    }
    
    public GameObject setParent(GameObject parent) {
        this.parent = parent;
        return this;
    }

    public GameObject setMesh(Mesh m) {
        this.mesh = m;
        return this;
    }

    public GameObject setMeshRenderer(MeshRenderer mr) {
        this.meshRenderer = mr;
        return this;
    }


    Vector3 getPosition() {
        return transform.position;
    }
    Vector3 getEular() {
        return transform.eular;
    }
    Vector3 getScale() {
        return transform.scale;
    }

    public GameObject setMaterial(Material m) {
        material = m;
        return this;
    }

    public GameObject setName(String s) {
        name = s;
        return this;
    }
    
    public float[] getTrianglePosition(){
        return mesh.getTrianglePosition();
    }
    public float[] getTriangleNormal(){
        return mesh.getTriangleNormal();
    }
    public float[] getTriangleUV(){
        return mesh.getTriangleUV();
    }
    public float[] getTriangleTangent(){
        return mesh.getTriangleTangent();
    }
    
    public int getNumber(){
        return mesh.triangles.size();
    }


    public void update() {
    }
    public void run() {
        meshRenderer.render();
    }
    public void debugRun() {
        meshRenderer.debugRender();
    }
    
    public Matrix4 modelMatrix(){
        Vector3 pos = getPosition();
        Vector3 eular = getEular();
        Vector3 scale = getScale();
        return Matrix4.Trans(pos).mult(Matrix4.RotX(eular.x)).mult(Matrix4.RotY(eular.y)).mult(Matrix4.RotZ(eular.z)).mult(Matrix4.Scale(scale));
    }
    
    public Matrix4 rotationMatrix(){
        Vector3 eular = getEular();
        return Matrix4.RotX(eular.x).mult(Matrix4.RotY(eular.y)).mult(Matrix4.RotZ(eular.z));
    }
    
    public Matrix4 parentRotationMatrix(){
        Vector3 eular = getEular();
        Matrix4 parentMatrix = parent == null ? Matrix4.Identity() : parent.worldRotationMatrix();
        return parentMatrix;
    }
    
    public Matrix4 worldRotationMatrix(){
        Vector3 eular = getEular();
        Matrix4 parentMatrix = parent == null ? Matrix4.Identity() : parent.worldRotationMatrix();
        return parentMatrix.mult(Matrix4.RotX(eular.x).mult(Matrix4.RotY(eular.y)).mult(Matrix4.RotZ(eular.z)));
    }

    public Matrix4 localToWorld() {
        Vector3 pos = getPosition();
        Vector3 eular = getEular();
        Vector3 scale = getScale();
        Matrix4 parentMatrix = parent == null ? Matrix4.Identity() : parent.localToWorld();        
        return parentMatrix.mult(Matrix4.Trans(pos).mult(Matrix4.RotX(eular.x)).mult(Matrix4.RotY(eular.y)).mult(Matrix4.RotZ(eular.z)).mult(Matrix4.Scale(scale)));
    }
    
    
    public Matrix4 worldToLocal() {
        Vector3 pos = getPosition();
        Vector3 eular = getEular();
        Vector3 scale = getScale();
        Matrix4 parentMatrix = parent == null ? Matrix4.Identity() : parent.worldToLocal();
        return Matrix4.Scale(scale.inv()).mult(Matrix4.RotZ(-eular.z)).mult(Matrix4.RotX(-eular.x)).mult(Matrix4.RotY(-eular.y)).mult(Matrix4.Trans(pos.mult(-1))).mult(parentMatrix);
    }
    public Vector3 forward() {
        return localToWorld().mult(new Vector3(0, 0, -1));
    }
    public Vector3 right() {
        return localToWorld().mult(new Vector3(1, 0, 0));
    }

    

    public Matrix4 MVP() {
        return main_camera.Matrix().mult(localToWorld());
    }
}



public class PhongObject extends GameObject {

    public PhongObject() {
    }

    public PhongObject(String name, Material mat) {
        mesh = new Mesh(name);
        hasProperties = new boolean[]{true,true,false,false};
        material = mat.setGameobject(this);
        meshRenderer = new MeshRenderer(mesh, material, this);
    }
}

public class Link extends GameObject{
    public Link(Material mat){
        mesh = new Mesh("Meshes/cube");
        hasProperties = new boolean[]{true,true,false,false};
        material = mat;
        meshRenderer = new MeshRenderer(mesh, material, this);        
    }

}

public class Marker extends GameObject{
    public Marker(Material mat){
        mesh = new Mesh("Meshes/cube");
        hasProperties = new boolean[]{true,true,false,false};
        material = mat;
        meshRenderer = new MeshRenderer(mesh, material, this);        
    }

}


public class Joint extends GameObject{
    int channel = -1;
    int channel_size = 0;
    public Joint(String name, Material mat) {
        this.name = name;
        mesh = new Mesh("Meshes/cube");
        hasProperties = new boolean[]{true,true,false,false};
        material = mat;
        meshRenderer = new MeshRenderer(mesh, material, this);        
        setScale(1, 1, 1);
    }

}

public class IKLink{
    ArrayList<Joint> jointLinks = new ArrayList<Joint>();
    ArrayList<Joint> part1 = new ArrayList<Joint>();
    ArrayList<Joint> part2 = new ArrayList<Joint>();
    
    ArrayList<Vector3> rotation = new ArrayList<Vector3>();
    MatrixX jacobian;
    float learning_rate = 0.0;
    Vector3 rootPosition;
    public IKLink(Joint base , Joint end){
        getJointLink(part1,base);
        getJointLink(part2,end);
        rootPosition = base.localToWorld().mult(new Vector4(0,0,0,1)).xyz();
        
        for(int i = 0; i < part1.size(); i++){
            jointLinks.add(part1.get(i));
        }    
        for(int i = part2.size() - 2; i >= 0; i--){
            jointLinks.add(part2.get(i));
        }    
        for(int i = 0; i < jointLinks.size(); i++){
            rotation.add(new Vector3(0,0,0));
        }

        
        updateRotation();

    }
    
    public Vector3 getRootPosition(){
        Matrix4 m = Matrix4.Identity();
        for(int i = 0; i < part1.size() - 1; i++){
            Joint joint = part1.get(i);
            Vector3 rotate = rotation.get(i);
            Vector3 pos = joint.getPosition().mult(-1);           
            m = Matrix4.Trans(pos).mult(Matrix4.RotX(rotate.x)).mult(Matrix4.RotY(rotate.y)).mult(Matrix4.RotZ(rotate.z)).mult(m);   

        }
        return m.mult(new Vector4(rootPosition,1)).xyz();
    }
    
    public void getJointLink(ArrayList<Joint> links , Joint joint){
        links.add(joint);
        if(joint.parent == null) return;
        getJointLink(links , (Joint)joint.parent);
    }
    
    public void updateRotation(){
        updateJacobian();
        Vector3 x = jointLinks.get(jointLinks.size() - 1).localToWorld().mult(new Vector4(0,0,0,1)).xyz();
        Vector3 delta = x.sub(marker.getPosition());
        VectorX d = new VectorX(new float[]{delta.x, delta.y, delta.z});
        VectorX ajd = jacobian.mult(d).mult(learning_rate);
        VectorX theta_i = getRotationVector();
        VectorX theta_i1 = theta_i.sub(ajd);
        //println(ajd);
        for(int i = 1; i < jointLinks.size(); i++){
            Vector3 rotate = rotation.get(i);
            rotate.set(theta_i1.v[i * 3 + 0], theta_i1.v[i * 3 + 1], theta_i1.v[i * 3 + 2]);
        }


                
    }
    
    public VectorX getRotationVector(){
        VectorX result = new VectorX(jointLinks.size() * 3);
        for(int i = 0; i < jointLinks.size(); i++){
            Vector3 rotate = rotation.get(i);
            result.v[i * 3 + 0] = rotate.x;
            result.v[i * 3 + 1] = rotate.y;
            result.v[i * 3 + 2] = rotate.z;
        }                
        return result;
    }
    
    public void updateJacobian(){
        jacobian = new MatrixX(jointLinks.size() * 3,3);
        Vector3 x = jointLinks.get(jointLinks.size() - 1).localToWorld().mult(new Vector4(0,0,0,1)).xyz();
        for(int i = 0; i < jointLinks.size(); i++){
            Vector3 rotate = rotation.get(i);
            Vector3 xp = jointLinks.get(i).localToWorld().mult(new Vector4(0,0,0,1)).xyz();
            Vector3 r = x.sub(xp);
            
            Vector3 Ax = getLinkOrientation(i).mult(new Vector3(1,0,0));
            Vector3 Ay = getLinkOrientation(i).mult(Matrix4.RotX(rotate.x)).mult(new Vector3(0,1,0));
            Vector3 Az = getLinkOrientation(i).mult(Matrix4.RotX(rotate.x)).mult(Matrix4.RotY(rotate.y)).mult(new Vector3(0,0,1));
            
            Vector3 dfx = Vector3.cross(Ax,r);
            Vector3 dfy = Vector3.cross(Ay,r);
            Vector3 dfz = Vector3.cross(Az,r);
            
            jacobian.setColumn(i * 3 + 0 , new float[]{dfx.x, dfx.y, dfx.z});
            jacobian.setColumn(i * 3 + 1 , new float[]{dfy.x, dfy.y, dfy.z});
            jacobian.setColumn(i * 3 + 2 , new float[]{dfz.x, dfz.y, dfz.z});            
        }
        
        
        
    
    }
    
    
    public Vector3 getLinkPosition(){
        Matrix4 m = Matrix4.Identity();
        for(int i = jointLinks.size() - 1; i >= 0; i--){
            Joint joint = jointLinks.get(i);
            m = joint.modelMatrix().mult(m);            
        }        
        return m.mult(new Vector4(0 ,0, 0, 1)).xyz();        
    }
    
    public Vector3 getLinkPosition(int index){
        Matrix4 m = Matrix4.Identity();
        for(int i = index; i >= 0; i--){
            Joint joint = jointLinks.get(i);
            m = joint.modelMatrix().mult(m);            
        }
        
        return m.mult(new Vector4(0 ,0, 0, 1)).xyz();        
    }
    
    public Matrix4 getLinkOrientation(int index){
        Matrix4 m = Matrix4.Identity();
        for(int i = index - 1; i >= 0; i--){
            Vector3 rotate = rotation.get(i);
            m = Matrix4.RotX(rotate.x).mult(Matrix4.RotY(rotate.y)).mult(Matrix4.RotZ(rotate.z)).mult(m);            
        }
        return m;     
    }
    
}



public class Skeleton{
    ArrayList<Joint> base = new ArrayList<Joint>();
    ArrayList<Link> links = new ArrayList<Link>();
    ArrayList<float[]> frames = new ArrayList<float[]>();
    boolean aPose = false;
    
    public Skeleton(String animation, Material mat) {
        String[] animate = loadStrings(animation);
        base = createSkeleton(animate , mat);
        frames = createFrame(animate);
        //createJointBonding(mat);
    }
    
    public Skeleton(String animation ,String animationA, Material mat) {
        String[] animate = loadStrings(animation);
        String[] animateA = loadStrings(animationA);
        aPose = true;
        base = createSkeleton(animate , mat);
        frames = createFrame(animate , animateA , mat);
        createJointBonding(mat);
    }
    
    public Joint findJoint(String name){
        for(Joint joint : base){
            if(joint.name.equals(name)) return joint;
        }       
        return null;
    }
    
    public ArrayList<float[]> createFrame(String[] animate){
        ArrayList<float[]> frames = new ArrayList<float[]>();
        boolean flag = false;
        for(int i = 0; i < animate.length; i++){
            String[] ss = animate[i].trim().split("\\s+");                   
            if(ss[0].equals("Frame") && !flag) flag = true;
            else if(flag) frames.add(stringToFloat(ss));    
        }             
        return frames;
    }
    
    public ArrayList<float[]> createFrame(String[] animate , String[] animateA , Material mat){
        ArrayList<Joint> baseA = createSkeleton(animateA, mat);
        IntList order = getNameOrder(baseA , base);
        ArrayList<float[]> frames = new ArrayList<float[]>();
        boolean flag = false;
        for(int i = 0; i < animateA.length; i++){
            String[] ss = animateA[i].trim().split("\\s+");                   
            if(ss[0].equals("Frame") && !flag) flag = true;
            else if(flag) {
                frames.add(stringToFloat(ss, baseA , order));   
            }    
        }    
        
        return frames;
    }
    
    public IntList getNameOrder(ArrayList<Joint> a , ArrayList<Joint> b){
        IntList result = new IntList();
        if(a.size() != b.size()) return null;
        for(int i = 0; i < b.size(); i++){
            String sb = b.get(i).name;
            for(int j = 0; j < a.size(); j++){
                String sa = a.get(j).name;
                if(sa.equals(sb)){                   
                    result.append(j);
                    break;
                }
            }
            
        }
        return result;
    }
    
    public void createJointBonding(Material mat){
        Link body = new Link(mat);
        body.setParent(base.get(0)).setScale(5,5,3);
        links.add(body);
        
        Link lHip = new Link(mat);
        lHip.setParent(base.get(1)).setScale(3,18,3).setPosition(0,-0.20,0);
        links.add(lHip);
        
        Link lKnee = new Link(mat);
        lKnee.setParent(base.get(2)).setScale(3,17,3).setPosition(0,-0.19,0);
        links.add(lKnee);
        
        Link lAnkle = new Link(mat);
        lAnkle.setParent(base.get(3)).setScale(4,2.5,7).setPosition(0,-0.05,0.035);
        links.add(lAnkle);
        
        Link lToe = new Link(mat);
        lToe.setParent(base.get(4)).setScale(4,1.2,3).setPosition(0,-0.01,0.03);
        links.add(lToe);
        
        Link rHip = new Link(mat);
        rHip.setParent(base.get(20)).setScale(3,18,3).setPosition(0,-0.20,0);
        links.add(rHip);
        
        Link rKnee = new Link(mat);
        rKnee.setParent(base.get(21)).setScale(3,17,3).setPosition(0,-0.19,0);
        links.add(rKnee);
        
        Link rAnkle = new Link(mat);
        rAnkle.setParent(base.get(22)).setScale(4,2.5,7).setPosition(0,-0.05,0.035);
        links.add(rAnkle);
        
        Link rToe = new Link(mat);
        rToe.setParent(base.get(23)).setScale(4,1.2,3).setPosition(0,-0.01,0.03);
        links.add(rToe);
        
        Link pelvisLowerback = new Link(mat);
        pelvisLowerback.setParent(base.get(6)).setScale(3,3.8,3).setPosition(0,0.05,0.0);
        links.add(pelvisLowerback);
        
        Link lowerbackTorso = new Link(mat);
        lowerbackTorso.setParent(base.get(7)).setScale(3,6.0,3).setPosition(0,0.07,0.0);
        links.add(lowerbackTorso);
        
        Link lTorsoClavicle = new Link(mat);
        lTorsoClavicle.setParent(base.get(8)).setScale(5,3,3).setPosition(0.055,0.0,0.0);
        links.add(lTorsoClavicle);
        
        Link lShoulder = new Link(mat);
        lShoulder.setParent(base.get(9)).setScale(10,3,3).setPosition(0.12,0.0,0.0);
        links.add(lShoulder);
        
        Link lElbow = new Link(mat);
        lElbow.setParent(base.get(10)).setScale(10,3,3).setPosition(0.12,0.0,0.0);
        links.add(lElbow);
        
        Link lWrist = new Link(mat);
        lWrist.setParent(base.get(11)).setScale(5,3,3).setPosition(0.055,0.0,0.0);
        links.add(lWrist);
        
        
        Link rTorsoClavicle = new Link(mat);
        rTorsoClavicle.setParent(base.get(13)).setScale(5,3,3).setPosition(-0.055,0.0,0.0);
        links.add(rTorsoClavicle);
        
        Link rShoulder = new Link(mat);
        rShoulder.setParent(base.get(14)).setScale(10,3,3).setPosition(-0.12,0.0,0.0);
        links.add(rShoulder);
        
        Link rElbow = new Link(mat);
        rElbow.setParent(base.get(15)).setScale(10,3,3).setPosition(-0.12,0.0,0.0);
        links.add(rElbow);
        
        Link rWrist = new Link(mat);
        rWrist.setParent(base.get(16)).setScale(5,3,3).setPosition(-0.055,0.0,0.0);
        links.add(rWrist);
        
        Link torsoHead = new Link(mat);
        torsoHead.setParent(base.get(18)).setScale(5,6,3).setPosition(-0.0,0.10,0.0);
        links.add(torsoHead);
    } 
    
    public ArrayList<Joint> createSkeleton(String[] animate , Material material){
        ArrayList<Joint> queue = new ArrayList<Joint>();
        ArrayList<Joint> base = new ArrayList<Joint>();
        int channel_count = 0;
        for(int i = 0; i < animate.length; i++){
            String[] ss = animate[i].trim().split("\\s+");
            if(ss[0].equals("ROOT")){
                Joint joint = new Joint(ss[1] , material);
                queue.add(joint);
                base.add(joint);
            }else if(ss[0].equals("OFFSET")){
                queue.get(queue.size() - 1).setPosition(float(ss[1]),float(ss[2]),float(ss[3]));
            }else if(ss[0].equals("JOINT")){
                Joint joint = new Joint(ss[1] , material);
                joint.setParent(queue.get(queue.size() - 1));
                base.add(joint);
                queue.add(joint);                
            }else if(ss[0].equals("}")){
                queue.remove(queue.size() - 1);
            }else if(ss[0].equals("End")){
                Joint joint = new Joint(queue.get(queue.size() - 1).name + "_end", material);
                joint.setParent(queue.get(queue.size() - 1));
                base.add(joint);
                queue.add(joint);
            }else if(ss[0].equals("CHANNELS")){
                queue.get(queue.size() - 1).channel = channel_count;
                queue.get(queue.size() - 1).channel_size = int(ss[1]);
                channel_count += int(ss[1]);
            }                        
        } 
        
        return base;

    }
    
    public void updateFrame(int f){
        f = f % frames.size();
       
        float[] frame = frames.get(f);
        for(Joint joint : base){
            if(joint.parent == null){
                //joint.setPosition(frame[0] , frame[1] , frame[2]);
                joint.setEular(degToRad(frame[3]) , degToRad(frame[4]) , degToRad(frame[5]));
            }else{
                if(joint.channel == -1) continue;
                float bias = aPose ? joint.name.equals("lShoulder") ? -45.0 : (joint.name.equals("rShoulder") ? 45 : 0) : 0.0;
                int channel = joint.channel;
                joint.setEular(degToRad(frame[channel]) , degToRad(frame[channel + 1]) , degToRad(frame[channel + 2] + bias));
            }
        }
    }
    
    public void run(){
        for(Joint joint : base){
            joint.run();
        }  
        
        for(Link link : links){
            link.run();
        } 
    }
    
}
