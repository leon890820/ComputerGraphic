class Mesh {
    int NUM_VBOS=3;
    ArrayList<Vector3> verts=new ArrayList<Vector3>();
    ArrayList<Vector3> uvs=new ArrayList<Vector3>();
    ArrayList<Vector3> normals=new ArrayList<Vector3>();
    ArrayList<Vector3> tangents=new ArrayList<Vector3>();
    ArrayList<Triangle> triangles=new ArrayList<Triangle>();

    public Mesh(){}
    
    

    public Mesh(String fname) {
        String[] fin=loadStrings(fname + ".obj");
        for (int i=0; i<fin.length; i+=1) {
            String line=fin[i];
            if (line.indexOf("# ")!=-1) {
                continue;
            } else if (line.indexOf("v ")!=-1) {
                String[] s=line.split(" ");
                verts.add(new Vector3(float(s[1]), float(s[2]), float(s[3])));
            } else if (line.indexOf("vt ")!=-1) {
                String[] s=line.split(" ");
                uvs.add(new Vector3(float(s[1]), float(s[2]), 0));
            } else if (line.indexOf("vn ")!=-1) {
                String[] s=line.split(" ");
                normals.add(new Vector3(float(s[1]), float(s[2]), float(s[3])));
            } else if (line.indexOf("c ")!=-1) {
                int a, b, c=0;
                if (line.charAt(2)=='*') {
                    int v_ix=verts.size();
                    a=v_ix-2;
                    b=v_ix-1;
                    c=v_ix;
                } else {
                    String[] s=line.split(" ");
                    a=int(s[1]);
                    b=int(s[2]);
                    c=int(s[3]);
                }
                Vector3 v1=verts.get(a-1);
                Vector3 v2=verts.get(b-1);
                Vector3 v3=verts.get(c-1);
            } else if (line.indexOf("f ")!=-1) {
                int num_slashes=0;
                int last_slash_ix=0;
                boolean double_slashes=false;
                StringBuilder sb=new StringBuilder(line);
                for (int j=0; j<line.length(); j+=1) {


                    if (sb.charAt(j)=='/') {
                        sb.setCharAt(j, ' ');
                        if (last_slash_ix==i-1) double_slashes=true;
                        last_slash_ix=i;
                        num_slashes++;
                    }
                }
                line=new String(sb);

                int a = -1, b = -1, c = -1, d = -1;
                int at = -1, bt = -1, ct = -1, dt = -1;
                int an = -1, bn = -1, cn = -1, dn = -1;
                boolean wild=line.charAt(2)=='*';
                boolean wild2=line.charAt(3)=='*';
                boolean isQuad=false;
                String[] s=line.split(" ");

                if (wild) {
                } else if (num_slashes==0) {
                    isQuad= s.length==5;
                    if (isQuad) {
                        a = int(s[1]) - 1;
                        b = int(s[2]) - 1;
                        c = int(s[3]) - 1;
                        d = int(s[4]) - 1;
                    } else {
                        a = int(s[1]) - 1;
                        b = int(s[2]) - 1;
                        c = int(s[3]) - 1;
                    }

                } else if (num_slashes==3) {
                    a = int(s[1]) - 1;
                    at = int(s[2]) - 1;
                    b = int(s[3]) - 1;
                    bt = int(s[4]) - 1;
                    c = int(s[5]) - 1;
                    ct = int(s[6]) - 1;
                } else if (num_slashes==4) {
                    a = int(s[1]) - 1;
                    at = int(s[2]) - 1;
                    b = int(s[3]) - 1;
                    bt = int(s[4]) - 1;
                    c = int(s[5]) - 1;
                    ct = int(s[6]) - 1;
                    d = int(s[7]) - 1;
                    dt = int(s[8]) - 1;
                    isQuad = true;
                } else if (num_slashes==6) {
                    if (double_slashes) {
                        
                        a=int(s[1]) - 1;
                        an=int(s[2]) - 1;
                        b=int(s[3]) - 1;
                        bn=int(s[4]) - 1;
                        c=int(s[5]) - 1;
                        cn=int(s[6]) - 1;
                    } else {
                        a=int(s[1]) - 1;
                        at=int(s[2]) - 1;
                        an=int(s[3]) - 1;
                        b=int(s[4]) - 1;
                        bt=int(s[5]) - 1;
                        bn=int(s[6]) - 1;
                        c=int(s[7]) - 1;
                        ct=int(s[8]) - 1;
                        cn=int(s[9]) - 1;
                       
                    }
                } else if (num_slashes==8) {
                    isQuad=true;
                    if (double_slashes) {
                        a=int(s[1]) - 1;
                        at=int(s[1]) - 1;
                        b=int(s[3]) - 1;
                        bt=int(s[3]) - 1;
                        c=int(s[5]) - 1;
                        ct=int(s[5]) - 1;
                        d=int(s[7]) - 1;
                        dt=int(s[7]) - 1;
                    } else {
                        a=int(s[1]) - 1;
                        at=int(s[2]) - 1;
                        an=int(s[3]) - 1;
                        b=int(s[4]) - 1;
                        bt=int(s[5]) - 1;
                        bn=int(s[6]) - 1;
                        c=int(s[7]) - 1;
                        ct=int(s[8]) - 1;
                        cn=int(s[9]) - 1;
                        d=int(s[10]) - 1;
                        dt=int(s[11]) - 1;
                        dn=int(s[12]) - 1;
                    }
                } else {
                    continue;
                }

               
                addFace(a, an , at , b, bn,bt, c, cn,ct);
                if (isQuad) {
                    addFace(a, an,at, c, cn,ct, d, dn,dt);
                }
            }
        }
        reCaculateNormal();
    }

    

    void calcNormal() {
        Vector3[] normal = new Vector3[verts.size()];
        for (int i=0; i<normal.length; i+=1) {
            normal[i] = new Vector3();
        }
        for (int i=0; i<triangles.size(); i+=1) {
            for (int j=0; j<3; j+=1) {
                normal[triangles.get(i).triangle[j]].plus(triangles.get(i).normal[j]);
            }
        }

        for (int i=0; i<normal.length; i+=1) {
            normals.add(normal[i].unit_vector());
        }
        for (int i=0; i<triangles.size(); i+=1) {
            for (int j=0; j<3; j+=1) {
                triangles.get(i).normal[j] = normals.get(triangles.get(i).triangle[j]);
            }
        }
    }

    void addFace(int a, int b,int c){
        int[] v_ix={a, b, c};
        Vector3[] vs = {verts.get(a),  verts.get(b) , verts.get(c)};
        triangles.add(new Triangle(vs, v_ix, triangles.size()));
    }
    
    void addFace(int a,int an, int b,int bn,int c,int cn){
        int[] v_ix={a, b, c};
        Vector3[] vs = {verts.get(a),  verts.get(b) , verts.get(c)};
        //Vector3[] ns = {normals.get(an),  normals.get(bn) , normals.get(cn)};
        Vector3 n = Vector3.cross(vs[1].sub(vs[0]),vs[2].sub(vs[0])).unit_vector();
        Vector3[] normal = {n,n,n};
        triangles.add(new Triangle(vs,normal, v_ix, triangles.size()));
    }

    void addFace(int a, int at,int an, int b, int bt,int bn, int c, int ct,int cn) {

        int[] v_ix={a, b, c};
        int[] uv_ix={at, bt, ct};
        int[] n_ix={an, bn, cn};
        Vector3[] vs = {verts.get(a),  verts.get(b) , verts.get(c)};
        Vector3 n = Vector3.cross(vs[1].sub(vs[0]),vs[2].sub(vs[0])).unit_vector();
        Vector3[] normal = {n,n,n};

        Vector3[] us;
        if(at >= uvs.size() || bt >= uvs.size() || ct >= uvs.size()){
            us = new Vector3[]{new Vector3(0),new Vector3(0),new Vector3(0)};
        }
        else us = uv_ix[0] == -1 ? new Vector3[]{null,null,null} : new Vector3[]{uvs.get(at), uvs.get(bt), uvs.get(ct)};

        triangles.add(new Triangle(vs, us, normal, v_ix,triangles.size()));

    }
    
    
    float[] getTrianglePosition(){
        float[] v = new float[triangles.size() * 9];
        for(int i = 0; i < triangles.size(); i++){
            Triangle tri = triangles.get(i);
            for(int j = 0; j < 3; j++){
                v[i * 9 + j * 3 + 0] = tri.verts[j].x;
                v[i * 9 + j * 3 + 1] = tri.verts[j].y;
                v[i * 9 + j * 3 + 2] = tri.verts[j].z;
            }
        }
        
        return v;
    }
    
    float[] getTriangleNormal(){
        float[] v = new float[triangles.size() * 9];
        for(int i = 0; i < triangles.size(); i++){
            Triangle tri = triangles.get(i);
            for(int j = 0; j < 3; j++){
                v[i * 9 + j * 3 + 0] = tri.normal[j].x;
                v[i * 9 + j * 3 + 1] = tri.normal[j].y;
                v[i * 9 + j * 3 + 2] = tri.normal[j].z;
            }
        }
        
        return v;
    }
    
    float[] getTriangleTangent(){
        float[] v = new float[triangles.size() * 9];
        for(int i = 0; i < triangles.size(); i++){
            Triangle tri = triangles.get(i);
            for(int j = 0; j < 3; j++){
                //v[i * 9 + j * 3 + 0] = tri.tangents[j].x;
                //v[i * 9 + j * 3 + 1] = tri.tangents[j].y;
                //v[i * 9 + j * 3 + 2] = tri.tangents[j].z;
            }
        }
        
        return v;
    }
    
    float[] getTriangleUV(){
        float[] v = new float[triangles.size() * 6];
        for(int i = 0; i < triangles.size(); i++){
            Triangle tri = triangles.get(i);
            for(int j = 0; j < 3; j++){
                v[i * 6 + j * 2 + 0] = tri.uvs[j].x;
                v[i * 6 + j * 2 + 1] = tri.uvs[j].y;                
            }
        }
        
        return v;
    
    }
    
    void reCaculateNormal(){
        Vector3[] result = new Vector3[verts.size()];
        for(int i = 0; i < result.length;i++){
            result[i] = new Vector3();
        }
        for(int i=0;i<triangles.size();i++){
            Triangle tri = triangles.get(i);
            Vector3 n = Vector3.cross( tri.verts[1].sub(tri.verts[0]),tri.verts[2].sub(tri.verts[0]));
            for(int j = 0; j< 3; j++){                
                result[tri.triangle[j]] = result[tri.triangle[j]].add(n);
            }        
        }
        
        for(int i=0;i<triangles.size();i++){
            Triangle tri = triangles.get(i);
            for(int j = 0; j< 3; j++){  
                tri.normal[j] = result[tri.triangle[j]].unit_vector();
            }    
            tri.caculateTangent();
        }
    
    }
    

    @Override
        public String toString() {
        int c=1;
        String s=new String();
        for (Triangle t : triangles) {
            s+="Trangle"+ c+++":\n";
            s+=t.toString();
        }
        return s;
    }
}

class Triangle {
    Vector3[] verts;
    Vector3[] uvs;
    Vector3[] normal;
    Vector3[] tangents;
    int[] triangle;
    Vector3 center;
    int idx;
    
    Triangle(Vector3[] verts, Vector3[] uvs, Vector3[] normal, int[] triangle,int id) {
        this.verts=verts;
        this.uvs=uvs;
        this.normal=normal;
        caculateTangent();
        this.triangle=triangle;
        this.idx = id;        
        center = (verts[0].add(verts[1]).add(verts[2])).mult(1.0/3.0);
    }
    
    Triangle(Vector3[] verts,int[] triangle,int id) {
        this.verts=verts;

        this.triangle=triangle;
        this.idx = id;
        
        center = (verts[0].add(verts[1]).add(verts[2])).mult(1.0/3.0);
    }
    
    Triangle(Vector3[] verts, Vector3[] normal,int[] triangle,int id) {
        this.verts=verts;
        this.normal=normal;
        this.triangle=triangle;
        this.idx = id;
        
        center = (verts[0].add(verts[1]).add(verts[2])).mult(1.0/3.0);
    }
    
    public void caculateTangent(){
        tangents = new Vector3[3];
        for(int i = 0; i < tangents.length; i++){
            tangents[i] = new Vector3(-normal[i].z, 0.0, normal[i].x);
        }
    }
    
    public boolean intersection(Vector3 o,Vector3 dir,Matrix4 ltw){
        Vector3 v0 = ltw.mult(verts[0]);
        Vector3 v1 = ltw.mult(verts[1]);
        Vector3 v2 = ltw.mult(verts[2]);
        
        Vector3 e1 = Vector3.sub(v1,v0);
        Vector3 e2 = Vector3.sub(v2,v0);
        Vector3 s = Vector3.sub(o , v0);
        Vector3 s1 = Vector3.cross(dir , e2);
        Vector3 s2 = Vector3.cross(s , e1);
        float se_inv = 1.0 / Vector3.dot(s1,e1);
        
        float t = Vector3.dot(s2,e2) * se_inv;
        float b1 = Vector3.dot(s1,s) * se_inv;
        float b2 = Vector3.dot(s2,dir) * se_inv;
        
        if(b1 > 0.01 && b2 > 0.01 && 1-b1-b2 > 0.01 && t > 0.01) return true;
        return false;
    }
    
    
    

    @Override
        public String toString() {
        String s="Verties: \n";
        for (Vector3 v : verts) {
            s+=v.toString()+"\n";
        }
        s+="Uvs: \n";
        for (Vector3 v : uvs) {
            s+=v.toString()+"\n";
        }
        return s;
    }
}
