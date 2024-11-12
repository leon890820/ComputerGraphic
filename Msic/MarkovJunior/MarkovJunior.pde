int resolution = 50;
int size;
Cell[] cells;
Vector3[] dir;
ArrayList<Rule> rules = new ArrayList<Rule>();
Node node;
Node tempNode;

void setup() {
    size(600, 600);
    background(0);
    dir = new Vector3[]{new Vector3(1,0,0) , new Vector3(0,1,0), new Vector3(-1,0,0), new Vector3(0,-1,0)};
    size = width / resolution;
    cells = new Cell[resolution * resolution];
    for (int i = 0; i < cells.length; i++) {
        int x = i % resolution;
        int y = i / resolution;
        cells[i] = new Cell(x, y);
        //if(x == resolution/2 && y == resolution/2) cells[i] = new Cell(x, y , ColorState.R);
    }
    
    riverRule();
    frameRate(240);
}


void riverRule(){
    node = new Node();   
    Rule rule1 = new Rule(1,1,1); 
    rule1.add(ColorState.B ,ColorState.W);
    Node node1 = new Node(rule1 , node);
    
    Rule rule2 = new Rule(1,1,1); 
    rule2.add(ColorState.B ,ColorState.R);
    Node node2 = new Node(rule2 , node);
    
    SequenceNode node_1 = new SequenceNode();
    Rule rule3 = new Rule(1,2,-1); 
    rule3.add(ColorState.R ,ColorState.R);
    rule3.add(ColorState.B ,ColorState.R);
    Node node3 = new Node(rule3 , node_1);
    
    Rule rule4 = new Rule(1,2,-1); 
    rule4.add(ColorState.W ,ColorState.W);
    rule4.add(ColorState.B ,ColorState.W);
    Node node4 = new Node(rule4 , node_1);
    node_1.addChildNode(node3);
    node_1.addChildNode(node4);

    
    Rule rule5 = new Rule(1,2,-1); 
    rule5.add(ColorState.R ,ColorState.U);
    rule5.add(ColorState.W ,ColorState.U);
    Node node5 = new Node(rule5 , node);

    SequenceNode node_2 = new SequenceNode();
    Rule rule6 = new Rule(1,1,-1); 
    rule6.add(ColorState.W ,ColorState.B);
    Node node6 = new Node(rule6 , node_2);
    
    Rule rule7 = new Rule(1,1,-1); 
    rule7.add(ColorState.R ,ColorState.B);
    Node node7 = new Node(rule7 , node_2);
    node_2.addChildNode(node6);
    node_2.addChildNode(node7);
    
    Rule rule8 = new Rule(1,2,1); 
    rule8.add(ColorState.U ,ColorState.U);
    rule8.add(ColorState.B ,ColorState.U);
    Node node8 = new Node(rule8 , node);
    
    Rule rule9 = new Rule(2,2,-1); 
    rule9.add(ColorState.B ,ColorState.U);
    rule9.add(ColorState.U ,ColorState.U);
    rule9.add(ColorState.U ,ColorState.U);
    rule9.add(ColorState.B ,ColorState.B);
    Node node9 = new Node(rule9 , node);
    
    Rule rule10 = new Rule(1,2,-1); 
    rule10.add(ColorState.U ,ColorState.U);
    rule10.add(ColorState.B ,ColorState.G);
    Node node10 = new Node(rule10 , node);
    
    Rule rule11 = new Rule(1,1,13); 
    rule11.add(ColorState.B ,ColorState.E);
    Node node11 = new Node(rule11 , node);
    
    SequenceNode node_3 = new SequenceNode();
    Rule rule12 = new Rule(1,2,-1); 
    rule12.add(ColorState.E ,ColorState.E);
    rule12.add(ColorState.B ,ColorState.E);
    Node node12 = new Node(rule12 , node_3);
    
    Rule rule13 = new Rule(1,2,-1); 
    rule13.add(ColorState.G ,ColorState.G);
    rule13.add(ColorState.B ,ColorState.G);
    Node node13 = new Node(rule13 , node_3);
    
    node_3.addChildNode(node12);
    node_3.addChildNode(node13);
    
    
    node.addChildNode(node1);
    node.addChildNode(node2);
    node.addChildNode(node_1);
    node.addChildNode(node5);
    node.addChildNode(node_2);
    node.addChildNode(node8);
    node.addChildNode(node9);
    node.addChildNode(node10);
    node.addChildNode(node11);
    node.addChildNode(node_3);
    
    tempNode = node;
    //noLoop();
}








void draw() {
    background(0);    
   
    
    if(tempNode == null) tempNode = node;    
    tempNode = tempNode.findNodeAndRule();
    
    for (Cell c : cells) {
        c.show();
    }
    
    String txt_fps = String.format(getClass().getName()+ " [frame %d]   [fps %6.2f]", frameCount, frameRate);
    surface.setTitle(txt_fps);
}


void mousePressed(){
    if(key == 'k') loop();


}
