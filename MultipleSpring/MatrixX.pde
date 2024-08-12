public static class VectorX{
    int num;
    float[] vector;
    VectorX (int n){
        num = n;
        vector = new float[n];
    }
    VectorX(float[] f){
        vector = f;
        num = f.length;
    }
    
    public void set(int n,float value){
        if(n>=num) {
            println("Dimension dismiss");
            return;
        }
        vector[n] = value;
    }
    
   
    
    public VectorX add(VectorX other){
        if(other.num!=num) {
            println("Dimension dismiss");
            return null;
        }
        VectorX result = new VectorX(other.num);
        for(int i=0;i<num;i+=1){
            result.vector[i] = vector[i] + other.vector[i];
        }
        return result;
    }
    
    public VectorX sub(VectorX other){
        if(other.num!=num) {
            println("Dimension dismiss");
            return null;
        }
        VectorX result = new VectorX(other.num);
        for(int i=0;i<num;i+=1){
            result.vector[i] = vector[i] - other.vector[i];
        }
        return result;
    }
    
    public float dot(VectorX other){
        if(other.num!=num) {
            println("Dimension dismiss");
            return 0;
        }
        float result = 0;
        for(int i=0;i<num;i+=1){
            result += vector[i] * other.vector[i];
        }
        return result;
    }
    
    @Override
   public String toString() {
       String result = "[ ";
       for(int i=0;i<num;i++){
           result+= vector[i] + " , ";
       }
       result+="]\n";
        return result;
    }
    
}

public static class MatrixX{
    int col;
    int row;
    VectorX[] col_vector;
    VectorX[] row_vector;
    MatrixX(int c,int r){
        col = c;
        row = r;
        col_vector = new VectorX[r];
        row_vector = new VectorX[c];
        for(int i=0;i<row;i++){
            col_vector[i] = new VectorX(c);
        }
        
        for(int i=0;i<col;i++){
            row_vector[i] = new VectorX(r);
        }
    }
    
    public void set(int c,int r,float value){
        if(c>=col||r>=row){
            println("Dimession dismatch");
            return;
        }
        col_vector[r].set(c,value);
        row_vector[c].set(r,value);
    }
    
    public float get(int c,int r){
        if(c>=col||r>=row||c<0||r<0){
            println("Index Out Of Range");
            return 0;
        }
        return row_vector[c].vector[r];
    }
    
    
    public void setRow(int c,VectorX v){
        if(c>=col||v.num!=row){
            println("Dimession dismatch");
            return;
        }
        row_vector[c] = v;
        for(int i=0;i<v.num;i+=1){
            col_vector[i].vector[c] = v.vector[i];
        }
    }
    
    public void setCol(int r,VectorX v){
        if(r>=row||v.num!=col){
            println("Dimession dismatch");
            return;
        }
        col_vector[r] = v;
        for(int i=0;i<v.num;i+=1){
            row_vector[i].vector[r] = v.vector[i];
        }
    }
    
    public MatrixX add(MatrixX other){
        if(col!=other.col || row!=other.row){
             println("Dimession dismatch");
            return null;
        }
        
        MatrixX result = new MatrixX(col,row);
        for(int i=0;i<col;i+=1){
            result.setRow(i,row_vector[i].add(other.row_vector[i]));
        }
        return result;
        
    }
    
    
    public MatrixX sub(MatrixX other){
        if(col!=other.col || row!=other.row){
             println("Dimession dismatch");
            return null;
        }
        
        MatrixX result = new MatrixX(col,row);
        for(int i=0;i<col;i+=1){
            result.setRow(i,row_vector[i].sub(other.row_vector[i]));
        }
        return result;        
    }
    
    public MatrixX mult(MatrixX other){
        if(row!=other.col){
             println("Dimession dismatch");
            return null;
        }
        MatrixX result = new MatrixX(col,other.row);
        for(int i = 0;i<col;i+=1){
            for(int j=0;j<other.row;j++){
                result.set(i,j,row_vector[i].dot(other.col_vector[j]));
            }
        }
        return result;
    }
    
    static VectorX JacobiIteration(MatrixX A,VectorX b){        
        if(A.row!=b.num){
            println("Dimession dismatch");
            return null;
        }
        VectorX result = new VectorX(b.num);
        VectorX new_x = new VectorX(b.num);
        
        for(int k=0;k<100;k++){
            for(int i=0;i<b.num;i++){
                float r = b.vector[i];
                for(int j=0;j<A.row;j++){
                    if(i != j){
                       r -= A.get(i,j) * result.vector[j];
                    }
                }
                new_x.set(i,r/A.get(i,i));
            }            
            for(int i=0;i<new_x.num;i++){
                result.vector[i] = new_x.vector[i];
            }
        }
        
        
        return result;
    }
    
    public String toString() {
        String s = "";
        for(int i=0;i<col;i++){            
            s+=row_vector[i].toString();
        }
        return s;
    }
}
