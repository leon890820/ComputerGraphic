static class Matrix5x5{
  float m[]=new float[25];
  Matrix5x5(){
    makeZero();
  
  }
  Matrix5x5(float b){
    Fill(b);
  }
  void Fill(float b){
    for(int i=0;i<m.length;i+=1){
      m[i]=b;
    }
  }
  
  Matrix5x5(Vector4 a,Vector4 b,Vector4 c,Vector4 d){
     m[0]  = a.x;   m[1]  = a.y;  m[2]  = a.z;   m[3]  = a.w;   m[3]   = 0.0f;
     m[5]  = b.x;   m[6]  = b.y;  m[7]  = b.z;   m[8]  = b.w;   m[9]   = 0.0f;
     m[10] = c.x;   m[11] = c.y;  m[12] = c.z;   m[13] = c.w;   m[14]  = 0.0f;
     m[15] = d.x;   m[16] = d.y;  m[17] = d.z;   m[18] = d.w;   m[19]  = 0.0f;
     m[20] = 0.0f;  m[21] = 0.0f; m[22] = 0.0f;  m[23] = 0.0f;  m[24]  = 1.0f;
  
  }
  
  void makeZero(){
      Fill(0);
  }
  void makeIdentity(){
     m[0]  = 1.0f;   m[1]  = 0.0f;  m[2]  = 0.0f;   m[3]  = 0.0f;   m[3]   = 0.0f;
     m[5]  = 0.0f;   m[6]  = 1.0f;  m[7]  = 0.0f;   m[8]  = 0.0f;   m[9]   = 0.0f;
     m[10] = 0.0f;   m[11] = 0.0f;  m[12] = 1.0f;   m[13] = 0.0f;   m[14]  = 0.0f;
     m[15] = 0.0f;   m[16] = 0.0f;  m[17] = 0.0f;   m[18] = 1.0f;   m[19]  = 0.0f;
     m[20] = 0.0f;   m[21] = 0.0f;  m[22] = 0.0f;   m[23] = 0.0f;   m[24]  = 1.0f;
    
  }
  void makeRotXYPlane(float a) {
     m[0]  = cos(a);   m[1]  = -sin(a); m[2]  = 0.0f;   m[3]  = 0.0f;   m[3]   = 0.0f;
     m[5]  = sin(a);   m[6]  = cos(a);  m[7]  = 0.0f;   m[8]  = 0.0f;   m[9]   = 0.0f;
     m[10] = 0.0f;     m[11] = 0.0f;    m[12] = 1.0f;   m[13] = 0.0f;   m[14]  = 0.0f;
     m[15] = 0.0f;     m[16] = 0.0f;    m[17] = 0.0f;   m[18] = 1.0f;   m[19]  = 0.0f;
     m[20] = 0.0f;     m[21] = 0.0f;    m[22] = 0.0f;   m[23] = 0.0f;   m[24]  = 1.0f;
  }
  void makeRotXZPlane(float a) {
     m[0]  = cos(a);   m[1]  = 0.0f;    m[2]  = -sin(a);  m[3]  = 0.0f;   m[3]   = 0.0f;
     m[5]  = 0.0f;     m[6]  = 1.0f;    m[7]  = 0.0f;     m[8]  = 0.0f;   m[9]   = 0.0f;
     m[10] = sin(a);   m[11] = 0.0f;    m[12] = cos(a);   m[13] = 0.0f;   m[14]  = 0.0f;
     m[15] = 0.0f;     m[16] = 0.0f;    m[17] = 0.0f;     m[18] = 1.0f;   m[19]  = 0.0f;
     m[20] = 0.0f;     m[21] = 0.0f;    m[22] = 0.0f;     m[23] = 0.0f;   m[24]  = 1.0f;
  }
  
  void makeRotXWPlane(float a) {
     m[0]  = cos(a);   m[1]  = 0.0f;    m[2]  = 0.0f;    m[3]  = -sin(a);  m[3]   = 0.0f;
     m[5]  = 0.0f;     m[6]  = 1.0f;    m[7]  = 0.0f;    m[8]  = 0.0f;     m[9]   = 0.0f;
     m[10] = 0.0f;     m[11] = 0.0f;    m[12] = 1.0f;    m[13] = 0.0f;     m[14]  = 0.0f;
     m[15] = sin(a);   m[16] = 0.0f;    m[17] = 0.0f;    m[18] = cos(a);   m[19]  = 0.0f;
     m[20] = 0.0f;     m[21] = 0.0f;    m[22] = 0.0f;    m[23] = 0.0f;     m[24]  = 1.0f;
  }
  
  void makeRotYZPlane(float a) {
     m[0]  = 1.0f;     m[1]  = 0.0f;    m[2]  = 0.0f;     m[3]  = 0.0f;   m[3]   = 0.0f;
     m[5]  = 0.0f;     m[6]  = cos(a);  m[7]  = -sin(a);  m[8]  = 0.0f;   m[9]   = 0.0f;
     m[10] = 0.0f;     m[11] = sin(a);  m[12] = cos(a);   m[13] = 0.0f;   m[14]  = 0.0f;
     m[15] = 0.0f;     m[16] = 0.0f;    m[17] = 0.0f;     m[18] = 1.0f;   m[19]  = 0.0f;
     m[20] = 0.0f;     m[21] = 0.0f;    m[22] = 0.0f;     m[23] = 0.0f;   m[24]  = 1.0f;
  }
  
  void makeRotYWPlane(float a) {
     m[0]  = 1.0f;     m[1]  = 0.0f;    m[2]  = 0.0f;     m[3]  = 0.0f;      m[3]   = 0.0f;
     m[5]  = 0.0f;     m[6]  = cos(a);  m[7]  = 0.0f;     m[8]  = -sin(a);   m[9]   = 0.0f;
     m[10] = 0.0f;     m[11] = 0.0f;    m[12] = 1.0f;     m[13] = 0.0f;      m[14]  = 0.0f;
     m[15] = 0.0f;     m[16] = sin(a);  m[17] = 0.0f;     m[18] = cos(a);    m[19]  = 0.0f;
     m[20] = 0.0f;     m[21] = 0.0f;    m[22] = 0.0f;     m[23] = 0.0f;      m[24]  = 1.0f;
  }
  void makeRotZWPlane(float a) {
     m[0]  = 1.0f;     m[1]  = 0.0f;    m[2]  = 0.0f;     m[3]  = 0.0f;      m[3]   = 0.0f;
     m[5]  = 0.0f;     m[6]  = 1.0f;    m[7]  = 0.0f;     m[8]  = 0.0f;      m[9]   = 0.0f;
     m[10] = 0.0f;     m[11] = 0.0f;    m[12] = cos(a);   m[13] = -sin(a);   m[14]  = 0.0f;
     m[15] = 0.0f;     m[16] = 0.0f;    m[17] = sin(a);   m[18] = cos(a);    m[19]  = 0.0f;
     m[20] = 0.0f;     m[21] = 0.0f;    m[22] = 0.0f;     m[23] = 0.0f;      m[24]  = 1.0f;
  }

  void makeTrans(Vector4 t) {
     m[0]  = 1.0f;   m[1]  = 0.0f;  m[2]  = 0.0f;   m[3]  = 0.0f;   m[3]   = t.x;
     m[5]  = 0.0f;   m[6]  = 1.0f;  m[7]  = 0.0f;   m[8]  = 0.0f;   m[9]   = t.y;
     m[10] = 0.0f;   m[11] = 0.0f;  m[12] = 1.0f;   m[13] = 0.0f;   m[14]  = t.z;
     m[15] = 0.0f;   m[16] = 0.0f;  m[17] = 0.0f;   m[18] = 1.0f;   m[19]  = t.w;
     m[20] = 0.0f;   m[21] = 0.0f;  m[22] = 0.0f;   m[23] = 0.0f;   m[24]  = 1.0f;
  }
  void makeScale(Vector4 s) {
     m[0]  = s.x;    m[1]  = 0.0f;  m[2]  = 0.0f;   m[3]  = 0.0f;   m[3]   = 0.0f;
     m[5]  = 0.0f;   m[6]  = s.y;   m[7]  = 0.0f;   m[8]  = 0.0f;   m[9]   = 0.0f;
     m[10] = 0.0f;   m[11] = 0.0f;  m[12] = s.z;    m[13] = 0.0f;   m[14]  = 0.0f;
     m[15] = 0.0f;   m[16] = 0.0f;  m[17] = 0.0f;   m[18] = s.w;    m[19]  = 0.0f;
     m[20] = 0.0f;   m[21] = 0.0f;  m[22] = 0.0f;   m[23] = 0.0f;   m[24]  = 1.0f;
  }

  static Matrix5x5 Zero(){
    Matrix5x5 matrix=new Matrix5x5();
    matrix.makeZero();
    return matrix;
  }
  
  static Matrix5x5 Identity(){
    Matrix5x5 matrix=new Matrix5x5();
    matrix.makeIdentity();
    return matrix;
  }

  static Matrix5x5 RotXY(float a){
    Matrix5x5 matrix=new Matrix5x5();
    matrix.makeRotXYPlane(a);
    return matrix;
  }
  
  static Matrix5x5 RotXZ(float a){
    Matrix5x5 matrix=new Matrix5x5();
    matrix.makeRotXZPlane(a);
    return matrix;
  }
  
  static Matrix5x5 RotXW(float a){
    Matrix5x5 matrix=new Matrix5x5();
    matrix.makeRotXWPlane(a);
    return matrix;
  }
  
  static Matrix5x5 RotYZ(float a){
    Matrix5x5 matrix=new Matrix5x5();
    matrix.makeRotYZPlane(a);
    return matrix;
  }
  
  static Matrix5x5 RotYW(float a){
    Matrix5x5 matrix=new Matrix5x5();
    matrix.makeRotYWPlane(a);
    return matrix;
  }
  
  static Matrix5x5 RotZW(float a){
    Matrix5x5 matrix=new Matrix5x5();
    matrix.makeRotZWPlane(a);
    return matrix;
  }
  
  
  static Matrix5x5 Trans(Vector4 t){
    Matrix5x5 matrix=new Matrix5x5();
    matrix.makeTrans(t);
    return matrix;
  }
  
  static Matrix5x5 Scale(Vector4 s){
    Matrix5x5 matrix=new Matrix5x5();
    matrix.makeScale(s);
    return matrix;
  }
  
  static Matrix5x5 Scale(float s){
    Matrix5x5 matrix=new Matrix5x5();
    matrix.makeScale(new Vector4(s));
    return matrix;
  }
  
  
  
  
  Matrix5x5 transposed(){
    Matrix5x5 out=new Matrix5x5();
    out.m[0]  = m[0];  out.m[1]  = m[5];  out.m[2]  = m[10];  out.m[3]  = m[15];  out.m[4]  = m[20];
    out.m[5]  = m[1];  out.m[6]  = m[6];  out.m[7]  = m[11];  out.m[8]  = m[16];  out.m[9]  = m[21];
    out.m[10] = m[2]; out.m[11]  = m[7];  out.m[12] = m[12];  out.m[13] = m[17];  out.m[14]  = m[22];
    out.m[15] = m[3];  out.m[16] = m[8];  out.m[17] = m[13];  out.m[18] = m[18];  out.m[19]  = m[23];
    out.m[20] = m[4];  out.m[21] = m[9];  out.m[22] = m[14];  out.m[23] = m[19];  out.m[24]  = m[24];
    return out;
  }
    
  
  Matrix5x5 add(Matrix5x5 b){
      Matrix5x5 out=new Matrix5x5();
      for(int i=0;i<m.length;i+=1){
          out.m[i]=m[i]+b.m[i];
      }
      return out;
  }
  void plus(Matrix5x5 b){   
      for(int i=0;i<m.length;i+=1){
          m[i]+=b.m[i];
      }
  }
  
  Matrix5x5 sub(Matrix5x5 b){
      Matrix5x5 out=new Matrix5x5();
          for(int i=0;i<m.length;i+=1){
              out.m[i]=m[i]-b.m[i];
          }
      return out;
  }
  
  void minus(Matrix5x5 b){    
      for(int i=0;i<m.length;i+=1){
          m[i]-=b.m[i];
      }
  }
  
  Matrix5x5 mult(float b){
      Matrix5x5 out=new Matrix5x5();
      for(int i=0;i<m.length;i+=1){
          out.m[i]=m[i]*b;
      }
      return out;
  }
  
  void times(float b){   
      for(int i=0;i<m.length;i+=1){
          m[i]*=b;
      }
  }  
  
  Matrix5x5 div(float b){
      Matrix5x5 out=new Matrix5x5();
      for(int i=0;i<m.length;i+=1){
          out.m[i]=m[i]/b;
      }
      return out;
  }
  
  void dive(float b){    
      for(int i=0;i<m.length;i+=1){
          m[i]/=b;
      }
  }
  
  Matrix5x5 mult(Matrix5x5 b){
        Matrix5x5 out=new Matrix5x5();
        out.m[0]  = b.m[0]*m[0]  + b.m[5]*m[1]  + b.m[10] *m[2]  + b.m[15]*m[3] + b.m[20]*m[4];
        out.m[1]  = b.m[1]*m[0]  + b.m[6]*m[1]  + b.m[11] *m[2]  + b.m[16]*m[3] + b.m[21]*m[4];
        out.m[2]  = b.m[2]*m[0]  + b.m[7]*m[1]  + b.m[12] *m[2]  + b.m[17]*m[3] + b.m[22]*m[4];
        out.m[3]  = b.m[3]*m[0]  + b.m[8]*m[1]  + b.m[13] *m[2]  + b.m[18]*m[3] + b.m[23]*m[4];
        out.m[4]  = b.m[4]*m[0]  + b.m[9]*m[1]  + b.m[14] *m[2]  + b.m[19]*m[3] + b.m[24]*m[4];
        
        out.m[5]  = b.m[0]*m[5]  + b.m[5]*m[6]  + b.m[10] *m[7]  + b.m[15]*m[8] + b.m[20]*m[9];
        out.m[6]  = b.m[1]*m[5]  + b.m[6]*m[6]  + b.m[11] *m[7]  + b.m[16]*m[8] + b.m[21]*m[9];
        out.m[7]  = b.m[2]*m[5]  + b.m[7]*m[6]  + b.m[12] *m[7]  + b.m[17]*m[8] + b.m[22]*m[9];
        out.m[8]  = b.m[3]*m[5]  + b.m[8]*m[6]  + b.m[13] *m[7]  + b.m[18]*m[8] + b.m[23]*m[9];
        out.m[9]  = b.m[4]*m[5]  + b.m[9]*m[6]  + b.m[14] *m[7]  + b.m[19]*m[8] + b.m[24]*m[9];
        
        out.m[10]  = b.m[0]*m[10]  + b.m[5]*m[11]  + b.m[10] *m[12]  + b.m[15]*m[13] + b.m[20]*m[14];
        out.m[11]  = b.m[1]*m[10]  + b.m[6]*m[11]  + b.m[11] *m[12]  + b.m[16]*m[13] + b.m[21]*m[14];
        out.m[12]  = b.m[2]*m[10]  + b.m[7]*m[11]  + b.m[12] *m[12]  + b.m[17]*m[13] + b.m[22]*m[14];
        out.m[13]  = b.m[3]*m[10]  + b.m[8]*m[11]  + b.m[13] *m[12]  + b.m[18]*m[13] + b.m[23]*m[14];
        out.m[14]  = b.m[4]*m[10]  + b.m[9]*m[11]  + b.m[14] *m[12]  + b.m[19]*m[13] + b.m[24]*m[14];
        
        out.m[15]  = b.m[0]*m[15]  + b.m[5]*m[16]  + b.m[10] *m[17]  + b.m[15]*m[18] + b.m[20]*m[19];
        out.m[16]  = b.m[1]*m[15]  + b.m[6]*m[16]  + b.m[11] *m[17]  + b.m[16]*m[18] + b.m[21]*m[19];
        out.m[17]  = b.m[2]*m[15]  + b.m[7]*m[16]  + b.m[12] *m[17]  + b.m[17]*m[18] + b.m[22]*m[19];
        out.m[18]  = b.m[3]*m[15]  + b.m[8]*m[16]  + b.m[13] *m[17]  + b.m[18]*m[18] + b.m[23]*m[19];
        out.m[19]  = b.m[4]*m[15]  + b.m[9]*m[16]  + b.m[14] *m[17]  + b.m[19]*m[18] + b.m[24]*m[19];
        
        out.m[20]  = b.m[0]*m[20]  + b.m[5]*m[21]  + b.m[10] *m[22]  + b.m[15]*m[23] + b.m[20]*m[24];
        out.m[21]  = b.m[1]*m[20]  + b.m[6]*m[21]  + b.m[11] *m[22]  + b.m[16]*m[23] + b.m[21]*m[24];
        out.m[22]  = b.m[2]*m[20]  + b.m[7]*m[21]  + b.m[12] *m[22]  + b.m[17]*m[23] + b.m[22]*m[24];
        out.m[23]  = b.m[3]*m[20]  + b.m[8]*m[21]  + b.m[13] *m[22]  + b.m[18]*m[23] + b.m[23]*m[24];
        out.m[24]  = b.m[4]*m[20]  + b.m[9]*m[21]  + b.m[14] *m[22]  + b.m[19]*m[23] + b.m[24]*m[24];
        
        return out;
  }
  
  void times(Matrix5x5 b){
      m=this.mult(b).m;  
  }
  
  Vector5 mult(Vector5 b){
      return new Vector5(
          m[0]*b.v.x  + m[1]*b.v.y  + m[2]*b.v.z  + m[3]*b.v.w + m[4]*b.h,
          m[5]*b.v.x  + m[6]*b.v.y  + m[7]*b.v.z  + m[8]*b.v.w + m[9]*b.h,
          m[10]*b.v.x  + m[11]*b.v.y  + m[12]*b.v.z  + m[13]*b.v.w + m[14]*b.h,
          m[15]*b.v.x  + m[16]*b.v.y  + m[17]*b.v.z  + m[18]*b.v.w + m[19]*b.h,
          m[20]*b.v.x  + m[21]*b.v.y  + m[22]*b.v.z  + m[23]*b.v.w + m[24]*b.h
      );
  }
  
  
  
 
    String toString(){
      return str(m[0])+" "+str(m[1])+" "+str(m[2])+" "+str(m[3])+" "+str(m[4]) + "\n"
            +str(m[5])+" "+str(m[6])+" "+str(m[7])+" "+str(m[8])+" "+str(m[9]) + "\n"
            +str(m[10])+" "+str(m[11])+" "+str(m[12])+" "+str(m[13])+" "+str(m[14]) + "\n"
            +str(m[15])+" "+str(m[16])+" "+str(m[17])+" "+str(m[18])+" "+str(m[19]) + "\n"
            +str(m[20])+" "+str(m[21])+" "+str(m[22])+" "+str(m[23])+" "+str(m[24]) + "\n";
    }
}
