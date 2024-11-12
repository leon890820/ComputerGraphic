class Node{
    Vector3 position;
    Vector3 velocity;
    Vector3 force;
    float mass = 1.0;
    boolean is_gravity = true;
    
    ArrayList<NodeLength> childs = new ArrayList<NodeLength>();
    Node(){
        position = new Vector3();
        velocity = new Vector3();
        init();
    }
    
    Node(float x,float y){
        position = new Vector3(x,y,0);
        velocity = new Vector3();
        init();
    }
    
    void init(){
        for(Node n:nodes){
            float d = distSquare(n);
            if(d<radius*radius){
                float sd = sqrt(d);
                NodeLength nl = new NodeLength(n,sd);
                childs.add(nl);
                n.childs.add(new NodeLength(this,sd));
            }
        }
    }
    
    public Vector3 calcForce(){
       force = new Vector3();
       
       for(NodeLength nl:childs){
           Node n = nl.node;          
           float lx = n.position.sub(position).norm();
           float x = lx - nl.len;
           //println(lx,nl.len);
           Vector3 f = n.position.sub(position).mult(k*x);
           force = force.add(f);
       }
       force = force.mult(1/mass);
       //force = force.sub(velocity.mult(d*dt));
       if(is_gravity) force = force.add(gravity);
       return force;
    }
    
    float distSquare(Node node){
        float r = pow(node.position.x - position.x,2) + pow(node.position.y - position.y,2);        
        return r;
    }
    
    void run(){
        //calcForce();        
        update();
        show();
    }
    
    
    
    void update(){
        if(!is_gravity)return;
        velocity = velocity.mult(exp(-dt*damp));
        velocity = velocity.add(force.mult(dt));
        if(position.y>=1){
            position.y = 1;
            velocity.y = -velocity.y*0.8;
        }
        position = position.add(velocity.mult(dt));
    }
    
    void show(){
        noStroke();
        fill(255);
        float x = map(position.x,0,1,0,width);
        float y = map(position.y,0,1,0,height);
        
        circle(x,y,10);
        stroke(255);
        
        for(NodeLength nl:childs){
            Node n = nl.node;
            float nx = map(n.position.x,0,1,0,width);
            float ny = map(n.position.y,0,1,0,width);
            line(x,y,nx,ny);            
        }
        
    }
}

class NodeLength{
    Node node;
    float len;
    public NodeLength(Node n,float l){
        node = n;
        len = l;
    }
}
