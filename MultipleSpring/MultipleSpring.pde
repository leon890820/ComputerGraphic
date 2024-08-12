import java.util.Map;
float radius = 0.1;
ArrayList<Node> nodes;
float k = 60000;
float damp = 10;
Vector3 gravity = new Vector3(0,9.8,0);
float dt = 0.002;
boolean sw = false;
void setup(){
    size(600,600);
    nodes = new ArrayList<Node>();
    
    MatrixX a = new MatrixX(3,3);
    //MatrixX b = new MatrixX(3,3);
    a.setRow(0,new VectorX(new float[]{3,1,1}));
    a.setRow(1,new VectorX(new float[]{1,4,2}));
    a.setRow(2,new VectorX(new float[]{1,2,6}));
    //a.setRow(3,new VectorX(new float[]{9,10,11}));
    VectorX b = new VectorX(new float[]{2,3,4});
    VectorX r = MatrixX.JacobiIteration(a,b);
    
    println(r);
    
    //b.setRow(0,new VectorX(new float[]{2,1,0}));
    //b.setRow(1,new VectorX(new float[]{1,2,7}));
    //b.setRow(2,new VectorX(new float[]{5,4,3}));
    ////b.setRow(3,new VectorX(new float[]{2,1,2}));
    
    //MatrixX c = a.mult(b);
    
}

void draw(){
    background(0);
    drawMouseRange();
    nodes.forEach(Node::calcForce);
    nodes.forEach(Node::run);
    fill(255,255,0);
    stroke(255,255,0);
    text("k : " + k,10,10);
}

void mousePressed(){
    float x = map(mouseX,0,width,0,1);
    float y = map(mouseY,0,height,0,1);
    Node n = new Node(x,y);
    //n.is_gravity = sw;
    //sw = !sw;
    nodes.add(n);
}

void keyPressed(){
    if(key=='a'||key=='A'){
        k *=0.9;
    }
    if(key=='d'||key=='D'){
        k /=0.9;
    }
    
}

void drawMouseRange(){
    noFill();
    stroke(255);
    float r = map(radius,0,1,0,width);
    circle(mouseX,mouseY,r*2);
}
