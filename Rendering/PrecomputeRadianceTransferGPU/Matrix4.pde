public static class Matrix4{
  float m[]=new float[16];
  public Matrix4(){
      makeZero(); 
  }
  public Matrix4(float b){
      Fill(b);
  }
  
  public void Fill(float b){
      for(int i=0;i<m.length;i+=1){
          m[i]=b;
      }
  }
  
  public Matrix4(Vector3 a,Vector3 b,Vector3 c){
      m[0]  = a.x;  m[1]  = a.y;  m[2]  = a.z;    m[3]  = 0.0f;
      m[4]  = b.x;  m[5]  = b.y;  m[6]  = b.z;    m[7]  = 0.0f;
      m[8]  = c.x;  m[9]  = c.y;  m[10] = c.z;    m[11] = 0.0f;
      m[12] = 0.0f; m[13] = 0.0f; m[14] = 0.0f;   m[15] = 0.0f;
  }
  
  public Matrix4(float m00,float m01,float m02,float m03,float m10,float m11,float m12,float m13,float m20,float m21,float m22,float m23,float m30,float m31,float m32,float m33){
      m[0]  = m00;  m[1]  = m01;  m[2]  = m02;    m[3]  = m03;
      m[4]  = m10;  m[5]  = m11;  m[6]  = m12;    m[7]  = m13;
      m[8]  = m20;  m[9]  = m21;  m[10] = m22;    m[11] = m23;
      m[12] = m30;  m[13] = m31;  m[14] = m32;    m[15] = m33; 
  }
  
  public void makeZero(){
      Fill(0);
  }
  
  public void makeIdentity(){
     m[0]  = 1.0f; m[1]  = 0.0f; m[2]  = 0.0f; m[3]  = 0.0f;
     m[4]  = 0.0f; m[5]  = 1.0f; m[6]  = 0.0f; m[7]  = 0.0f;
     m[8]  = 0.0f; m[9]  = 0.0f; m[10] = 1.0f; m[11] = 0.0f;
     m[12] = 0.0f; m[13] = 0.0f; m[14] = 0.0f; m[15] = 1.0f;
    
  }
  public void makeRotX(float a) {
     m[0] =  1.0f; m[1]  = 0.0f;        m[2]  = 0.0f;         m[3]  = 0.0f;
     m[4] =  0.0f; m[5]  = cos(a);      m[6]  = -sin(a);      m[7]  = 0.0f;
     m[8] =  0.0f; m[9]  = sin(a);      m[10] = cos(a);       m[11] = 0.0f;
     m[12] = 0.0f; m[13] = 0.0f;        m[14] = 0.0f;         m[15] = 1.0f;
  }
  public void makeRotY(float a) {
    m[0]  = cos(a);       m[1]  = 0.0f; m[2]  = sin(a);      m[3]  = 0.0f;
    m[4]  = 0.0f;         m[5]  = 1.0f; m[6]  = 0.0f;        m[7]  = 0.0f;
    m[8]  = -sin(a);      m[9]  = 0.0f; m[10] = cos(a);      m[11] = 0.0f;
    m[12] = 0.0f;         m[13] = 0.0f; m[14] = 0.0f;        m[15] = 1.0f;
  }
  public void makeRotZ(float a) {
    m[0]  = cos(a);      m[1]  = -sin(a);      m[2]  = 0.0f; m[3]  = 0.0f;
    m[4]  = sin(a);      m[5]  = cos(a);       m[6]  = 0.0f; m[7]  = 0.0f;
    m[8]  = 0.0f;        m[9]  = 0.0f;         m[10] = 1.0f; m[11] = 0.0f;
    m[12] = 0.0f;        m[13] = 0.0f;         m[14] = 0.0f; m[15] = 1.0f;
  }
  public void makeGRM(Vector3 v1,Vector3 v2,Vector3 v3) {
    m[0]  = v1.x; m[1]  = v1.y; m[2]  = v1.z; m[3]  = 0;
    m[4]  = v2.x; m[5]  = v2.y; m[6]  = v2.z; m[7]  = 0;
    m[8]  = v3.x; m[9]  = v3.y; m[10] = v3.z; m[11] = 0;
    m[12] = 0.0f; m[13] = 0.0f; m[14] = 0.0f; m[15] = 1.0f;
  }
  public void makeTrans(Vector3 t) {
    m[0]  = 1.0f; m[1]  = 0.0f; m[2]  = 0.0f; m[3]  = t.x;
    m[4]  = 0.0f; m[5]  = 1.0f; m[6]  = 0.0f; m[7]  = t.y;
    m[8]  = 0.0f; m[9]  = 0.0f; m[10] = 1.0f; m[11] = t.z;
    m[12] = 0.0f; m[13] = 0.0f; m[14] = 0.0f; m[15] = 1.0f;
  }
  public void makeScale(Vector3 s) {
    m[0]  = s.x;  m[1]  = 0.0f; m[2]  = 0.0f; m[3]  = 0.0f;
    m[4]  = 0.0f; m[5]  = s.y;  m[6]  = 0.0f; m[7]  = 0.0f;
    m[8]  = 0.0f; m[9]  = 0.0f; m[10] = s.z;  m[11] = 0.0f;
    m[12] = 0.0f; m[13] = 0.0f; m[14] = 0.0f; m[15] = 1.0f;
  }
  
  public void makeMirror(){
    m[0]  = -1;  m[1]  = 0.0f; m[2]  = 0.0f; m[3]  = 0.0f;
    m[4]  = 0.0f; m[5]  = -1;  m[6]  = 0.0f; m[7]  = 0.0f;
    m[8]  = 0.0f; m[9]  = 0.0f; m[10] = 1;  m[11] = 0.0f;
    m[12] = 0.0f; m[13] = 0.0f; m[14] = 0.0f; m[15] = 1.0f;
  }
  public static Matrix4 Zero(){
    Matrix4 matrix=new Matrix4();
    matrix.makeZero();
    return matrix;
  }
  
  public static Matrix4 Identity(){
    Matrix4 matrix=new Matrix4();
    matrix.makeIdentity();
    return matrix;
  }
  public static Matrix4 Mirror(){
    Matrix4 matrix=new Matrix4();
    matrix.makeMirror();
    return matrix;
  }
  public static Matrix4 RotX(float a){
    Matrix4 matrix=new Matrix4();
    matrix.makeRotX(a);
    return matrix;
  }
  
  public static Matrix4 RotY(float a){
    Matrix4 matrix=new Matrix4();
    matrix.makeRotY(a);
    return matrix;
  }
  
  public static Matrix4 RotZ(float a){
    Matrix4 matrix=new Matrix4();
    matrix.makeRotZ(a);
    return matrix;
  }
  
  public static Matrix4 Trans(Vector3 t){
    Matrix4 matrix=new Matrix4();
    matrix.makeTrans(t);
    return matrix;
  }
  
  public static Matrix4 Scale(Vector3 s){
    Matrix4 matrix=new Matrix4();
    matrix.makeScale(s);
    return matrix;
  }
  
  public static Matrix4 Scale(float s){
    Matrix4 matrix=new Matrix4();
    matrix.makeScale(new Vector3(s));
    return matrix;
  }
  
  //setter
  public Vector3 xAxis(){
    return new Vector3(m[0], m[4], m[8]);
  }
  public Vector3 yAxis(){
    return new Vector3(m[1], m[5], m[9]);
  }
  public Vector3 zAxis(){
    return new Vector3(m[2], m[6], m[10]);
  }
  public Vector3 translation(){
    return new Vector3(m[3], m[7], m[11]);
  }
  public Vector3 Scale(){
    return new Vector3(m[0], m[5], m[10]);
  }
  
  //getter
  public void setTranslation(Vector3 t) {
    m[3] = t.x;
    m[7] = t.y;
    m[11] = t.z;
  }
  public void setXAxis(Vector3 t) {
    m[0] = t.x;
    m[4] = t.y;
    m[8] = t.z;
  }
  public void setYAxis(Vector3 t) {
    m[1] = t.x;
    m[5] = t.y;
    m[9] = t.z;
  }
  public void setZAxis(Vector3 t) {
    m[2] = t.x;
    m[6] = t.y;
    m[10] = t.z;
  }
  public void setScale(Vector3 s) {
    m[0] = s.x;
    m[5] = s.y;
    m[10] = s.z;
  }
  
  public PMatrix3D toPMatrix(){
      return new PMatrix3D(m[0], m[1],  m[2],  m[3],
                           m[4], m[5],  m[6],  m[7],
                           m[8], m[9],  m[10], m[11],
                           m[12],m[13], m[14], m[15]);
  }
  
  
  public Matrix4 transposed(){
    Matrix4 out=new Matrix4();
    out.m[0]  = m[0]; out.m[1]  = m[4]; out.m[2]  = m[8];  out.m[3]  = m[12];
    out.m[4]  = m[1]; out.m[5]  = m[5]; out.m[6]  = m[9];  out.m[7]  = m[13];
    out.m[8]  = m[2]; out.m[9]  = m[6]; out.m[10] = m[10]; out.m[11] = m[14];
    out.m[12] = m[3]; out.m[13] = m[7]; out.m[14] = m[11]; out.m[15] = m[15];
    return out;
  }
  
  public void Translate(Vector3 t) {
    m[3] += t.x;
    m[7] += t.y;
    m[11] += t.z;
  }
  public void stretch(Vector3 s) {
    m[0] *= s.x;
    m[5] *= s.y;
    m[10] *= s.z;
  }
  
  public Matrix4 add(Matrix4 b){
    Matrix4 out=new Matrix4();
    for(int i=0;i<m.length;i+=1){
      out.m[i]=m[i]+b.m[i];
    }
    return out;
  }
  
  public void plus(Matrix4 b){
    
    for(int i=0;i<m.length;i+=1){
     m[i]+=b.m[i];
    }
  }
  
  public Matrix4 sub(Matrix4 b){
    Matrix4 out=new Matrix4();
    for(int i=0;i<m.length;i+=1){
      out.m[i]=m[i]-b.m[i];
    }
    return out;
  }
  public void minus(Matrix4 b){
    
    for(int i=0;i<m.length;i+=1){
     m[i]-=b.m[i];
    }
  }
  public Matrix4 mult(float b){
    Matrix4 out=new Matrix4();
    for(int i=0;i<m.length;i+=1){
      out.m[i]=m[i]*b;
    }
    return out;
  }
  
  public void times(float b){   
    for(int i=0;i<m.length;i+=1){
     m[i]*=b;
    }
  }  
  
  public Matrix4 div(float b){
    Matrix4 out=new Matrix4();
    for(int i=0;i<m.length;i+=1){
      out.m[i]=m[i]/b;
    }
    return out;
  }
  
  public void dive(float b){
    
    for(int i=0;i<m.length;i+=1){
     m[i]/=b;
    }
  }
  
  public Matrix4 mult(Matrix4 b){
    Matrix4 out=new Matrix4();
    out.m[0]  = b.m[0]*m[0]  + b.m[4]*m[1]  + b.m[8] *m[2]  + b.m[12]*m[3];
    out.m[1]  = b.m[1]*m[0]  + b.m[5]*m[1]  + b.m[9] *m[2]  + b.m[13]*m[3];
    out.m[2]  = b.m[2]*m[0]  + b.m[6]*m[1]  + b.m[10]*m[2]  + b.m[14]*m[3];
    out.m[3]  = b.m[3]*m[0]  + b.m[7]*m[1]  + b.m[11]*m[2]  + b.m[15]*m[3];

    out.m[4]  = b.m[0]*m[4]  + b.m[4]*m[5]  + b.m[8] *m[6]  + b.m[12]*m[7];
    out.m[5]  = b.m[1]*m[4]  + b.m[5]*m[5]  + b.m[9] *m[6]  + b.m[13]*m[7];
    out.m[6]  = b.m[2]*m[4]  + b.m[6]*m[5]  + b.m[10]*m[6]  + b.m[14]*m[7];
    out.m[7]  = b.m[3]*m[4]  + b.m[7]*m[5]  + b.m[11]*m[6]  + b.m[15]*m[7];

    out.m[8]  = b.m[0]*m[8]  + b.m[4]*m[9]  + b.m[8] *m[10] + b.m[12]*m[11];
    out.m[9]  = b.m[1]*m[8]  + b.m[5]*m[9]  + b.m[9] *m[10] + b.m[13]*m[11];
    out.m[10] = b.m[2]*m[8]  + b.m[6]*m[9]  + b.m[10]*m[10] + b.m[14]*m[11];
    out.m[11] = b.m[3]*m[8]  + b.m[7]*m[9]  + b.m[11]*m[10] + b.m[15]*m[11];

    out.m[12] = b.m[0]*m[12] + b.m[4]*m[13] + b.m[8] *m[14] + b.m[12]*m[15];
    out.m[13] = b.m[1]*m[12] + b.m[5]*m[13] + b.m[9] *m[14] + b.m[13]*m[15];
    out.m[14] = b.m[2]*m[12] + b.m[6]*m[13] + b.m[10]*m[14] + b.m[14]*m[15];
    out.m[15] = b.m[3]*m[12] + b.m[7]*m[13] + b.m[11]*m[14] + b.m[15]*m[15];
    return out;
  }
  
  public void times(Matrix4 b){
      m=this.mult(b).m;  
  }
  
  public Vector4 mult(Vector4 b){
    return new Vector4(
      m[0]*b.x  + m[1]*b.y  + m[2]*b.z  + m[3]*b.w,
      m[4]*b.x  + m[5]*b.y  + m[6]*b.z  + m[7]*b.w,
      m[8]*b.x  + m[9]*b.y  + m[10]*b.z + m[11]*b.w,
      m[12]*b.x + m[13]*b.y + m[14]*b.z + m[15]*b.w
    );
  }
  public Vector3 mult(Vector3 b){
    return new Vector3(
      m[0]*b.x  + m[1]*b.y  + m[2]*b.z  ,
      m[4]*b.x  + m[5]*b.y  + m[6]*b.z  ,
      m[8]*b.x  + m[9]*b.y  + m[10]*b.z 
    );
  }
  
  public Vector3 MulPoint(Vector3 b){
    Vector3 p=new Vector3(
      m[0] * b.x + m[1] * b.y + m[2] * b.z + m[3],
      m[4] * b.x + m[5] * b.y + m[6] * b.z + m[7],
      m[8] * b.x + m[9] * b.y + m[10] * b.z + m[11]
    );
    float w = m[12] * b.x + m[13] * b.y + m[14] * b.z + m[15];
    return p.dive(w);
  }
  public Vector3 MulDirection(Vector3 b){
    return new Vector3(
      m[0] * b.x + m[1] * b.y + m[2] * b.z,
      m[4] * b.x + m[5] * b.y + m[6] * b.z,
      m[8] * b.x + m[9] * b.y + m[10] * b.z
    );
  }
  public Matrix4 Inverse(){
    Matrix4 inv=new Matrix4();

    inv.m[0] = m[5] * m[10] * m[15] -
      m[5] * m[11] * m[14] -
      m[9] * m[6] * m[15] +
      m[9] * m[7] * m[14] +
      m[13] * m[6] * m[11] -
      m[13] * m[7] * m[10];

    inv.m[4] = -m[4] * m[10] * m[15] +
      m[4] * m[11] * m[14] +
      m[8] * m[6] * m[15] -
      m[8] * m[7] * m[14] -
      m[12] * m[6] * m[11] +
      m[12] * m[7] * m[10];

    inv.m[8] = m[4] * m[9] * m[15] -
      m[4] * m[11] * m[13] -
      m[8] * m[5] * m[15] +
      m[8] * m[7] * m[13] +
      m[12] * m[5] * m[11] -
      m[12] * m[7] * m[9];

    inv.m[12] = -m[4] * m[9] * m[14] +
      m[4] * m[10] * m[13] +
      m[8] * m[5] * m[14] -
      m[8] * m[6] * m[13] -
      m[12] * m[5] * m[10] +
      m[12] * m[6] * m[9];

    inv.m[1] = -m[1] * m[10] * m[15] +
      m[1] * m[11] * m[14] +
      m[9] * m[2] * m[15] -
      m[9] * m[3] * m[14] -
      m[13] * m[2] * m[11] +
      m[13] * m[3] * m[10];

    inv.m[5] = m[0] * m[10] * m[15] -
      m[0] * m[11] * m[14] -
      m[8] * m[2] * m[15] +
      m[8] * m[3] * m[14] +
      m[12] * m[2] * m[11] -
      m[12] * m[3] * m[10];

    inv.m[9] = -m[0] * m[9] * m[15] +
      m[0] * m[11] * m[13] +
      m[8] * m[1] * m[15] -
      m[8] * m[3] * m[13] -
      m[12] * m[1] * m[11] +
      m[12] * m[3] * m[9];

    inv.m[13] = m[0] * m[9] * m[14] -
      m[0] * m[10] * m[13] -
      m[8] * m[1] * m[14] +
      m[8] * m[2] * m[13] +
      m[12] * m[1] * m[10] -
      m[12] * m[2] * m[9];

    inv.m[2] = m[1] * m[6] * m[15] -
      m[1] * m[7] * m[14] -
      m[5] * m[2] * m[15] +
      m[5] * m[3] * m[14] +
      m[13] * m[2] * m[7] -
      m[13] * m[3] * m[6];

    inv.m[6] = -m[0] * m[6] * m[15] +
      m[0] * m[7] * m[14] +
      m[4] * m[2] * m[15] -
      m[4] * m[3] * m[14] -
      m[12] * m[2] * m[7] +
      m[12] * m[3] * m[6];

    inv.m[10] = m[0] * m[5] * m[15] -
      m[0] * m[7] * m[13] -
      m[4] * m[1] * m[15] +
      m[4] * m[3] * m[13] +
      m[12] * m[1] * m[7] -
      m[12] * m[3] * m[5];

    inv.m[14] = -m[0] * m[5] * m[14] +
      m[0] * m[6] * m[13] +
      m[4] * m[1] * m[14] -
      m[4] * m[2] * m[13] -
      m[12] * m[1] * m[6] +
      m[12] * m[2] * m[5];

    inv.m[3] = -m[1] * m[6] * m[11] +
      m[1] * m[7] * m[10] +
      m[5] * m[2] * m[11] -
      m[5] * m[3] * m[10] -
      m[9] * m[2] * m[7] +
      m[9] * m[3] * m[6];

    inv.m[7] = m[0] * m[6] * m[11] -
      m[0] * m[7] * m[10] -
      m[4] * m[2] * m[11] +
      m[4] * m[3] * m[10] +
      m[8] * m[2] * m[7] -
      m[8] * m[3] * m[6];

    inv.m[11] = -m[0] * m[5] * m[11] +
      m[0] * m[7] * m[9] +
      m[4] * m[1] * m[11] -
      m[4] * m[3] * m[9] -
      m[8] * m[1] * m[7] +
      m[8] * m[3] * m[5];

    inv.m[15] = m[0] * m[5] * m[10] -
      m[0] * m[6] * m[9] -
      m[4] * m[1] * m[10] +
      m[4] * m[2] * m[9] +
      m[8] * m[1] * m[6] -
      m[8] * m[2] * m[5];

    float det = m[0] * inv.m[0] + m[1] * inv.m[4] + m[2] * inv.m[8] + m[3] * inv.m[12];
    inv.dive(det);
    return inv;
    
    
    
  }
  
 
    public String toString(){
      return str(m[0])+" "+str(m[1])+" "+str(m[2])+" "+str(m[3])+"\n"
            +str(m[4])+" "+str(m[5])+" "+str(m[6])+" "+str(m[7])+"\n"
            +str(m[8])+" "+str(m[9])+" "+str(m[10])+" "+str(m[11])+"\n"
            +str(m[12])+" "+str(m[13])+" "+str(m[14])+" "+str(m[15]) + "\n";
    }
}
