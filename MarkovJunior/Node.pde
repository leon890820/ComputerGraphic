public class Node{
    Node parent;
    ArrayList<Node> child;
    Rule rule;
    boolean expired = false;
    public Node(){
        child = new ArrayList<Node>();
    }
    public Node(Rule r , Node p){
        child = new ArrayList<Node>();
        rule = r;
        parent = p;
    }
    
    public void addChildNode(Node n){
        child.add(n);
    }
    
    public void setRule(Rule rule){
        this.rule = rule;
    }
    
    public Node findNodeAndRule(){
        if(rule != null)  {
            if(rule.findCell(cells)) return parent ;
            else{
                parent.expired = true;
                return null;
            }
        }
        for(Node n : child){
            if(n.expired) continue;
            Node p = n.findNodeAndRule();
            if( p != null) return p;
        }            
        return parent;    
    }
    
    
}

public class SequenceNode extends Node{
    
        
    public Node findNodeAndRule(){
        if(rule != null)  return rule.findCell(cells) ? parent : null;     
        boolean flag = false;
        for(Node n : child){
            if(n.findNodeAndRule() != null) flag = true;
        }      
        if(flag) return this;
        expired = true;
        return null;
 
    }



}
