public Vector3[] findBoundBox(Vector4[] v) {
    Vector3 recordminV=new Vector3(1.0/0.0);
    Vector3 recordmaxV=new Vector3(-1.0/0.0);
    for (int i=0; i<v.length; i+=1) {
        recordmaxV.x=max(recordmaxV.x, v[i].x);
        recordminV.x=min(recordminV.x, v[i].x);

        recordmaxV.y=max(recordmaxV.y, v[i].y);
        recordminV.y=min(recordminV.y, v[i].y);

        recordmaxV.z=max(recordmaxV.z, v[i].z);
        recordminV.z=min(recordminV.z, v[i].z);
    }
    Vector3[] result={recordminV, recordmaxV};
    return result;
}
public Vector3[] findBoundBox(Vector3[] v) {
    Vector3 recordminV=new Vector3(1.0/0.0);
    Vector3 recordmaxV=new Vector3(-1.0/0.0);
    for (int i=0; i<v.length; i+=1) {
        recordmaxV.x=max(recordmaxV.x, v[i].x);
        recordminV.x=min(recordminV.x, v[i].x);

        recordmaxV.y=max(recordmaxV.y, v[i].y);
        recordminV.y=min(recordminV.y, v[i].y);

        recordmaxV.z=max(recordmaxV.z, v[i].z);
        recordminV.z=min(recordminV.z, v[i].z);
    }
    Vector3[] result={recordminV, recordmaxV};
    return result;
}
public boolean outOfMap(float x, float y) {
    if (x>=0 && x<width && y>=0 && y<height) return false;
    return true;
}

public Vector4[] clippingLineByPlane(Vector4[] points, Vector4 plane) {
    Vector3 N=plane.xyz();
    ArrayList<Vector3> output=new ArrayList<Vector3>();
    ArrayList<Vector3> input=new ArrayList<Vector3>();
    for (int i=0; i<points.length; i+=1) {
        input.add(points[i].xyz());
    }

    for (int i=0; i<input.size(); i++) {

        Vector3 s0=input.get(i);
        Vector3 s1=input.get((i+1)%input.size());

        float t=(plane.w-Vector3.dot(s0, N))/Vector3.dot(s1.sub(s0), N);
        Vector3 l=s0.add((s1.sub(s0)).mult(t));

        if (isInFrontOfThePlane(s0, l, N)) {
            output.add(s0);
            if (!isInFrontOfThePlane(s1, l, N)) {
                output.add(l);
            }
        } else if (isInFrontOfThePlane(s1, l, N)) {
            output.add(l);
        }
    }


    Vector4[] result=new Vector4[output.size()];
    for (int i=0; i<result.length; i+=1) {
        result[i]=new Vector4(output.get(i), 1);
    }
    return result;
}

public boolean isInFrontOfThePlane(Vector3 s, Vector3 l, Vector3 N) {
    if (Vector3.dot(s.sub(l), N)>0) return true;
    else return false;
}


public boolean pnpoly(float x, float y, Vector3[] vertexes) {
    boolean c=false;

    for (int i=0, j=vertexes.length-1; i<vertexes.length; j=i++) {
        if (((vertexes[i].y>y)!=(vertexes[j].y>y))&&(x<(vertexes[j].x-vertexes[i].x)*(y-vertexes[i].y)/(vertexes[j].y-vertexes[i].y)+vertexes[i].x)) {
            c=!c;
        }
    }
    return c;
}
public boolean pnpoly(float x, float y, Vector4[] vertexes) {
    boolean c=false;

    for (int i=0, j=vertexes.length-1; i<vertexes.length; j=i++) {
        if (((vertexes[i].y>y)!=(vertexes[j].y>y))&&(x<(vertexes[j].x-vertexes[i].x)*(y-vertexes[i].y)/(vertexes[j].y-vertexes[i].y)+vertexes[i].x)) {
            c=!c;
        }
    }
    return c;
}

public float dist(Vector3 a, Vector3 b) {
    return a.sub(b).length_squared();
}

public float clamp(float x, float a, float b) {
    if (x<a) return a;
    if (x>b) return b;
    return x;
}

public Vector4 calcInterpolation(float[] b, Vector4[] v) {
    return v[0].mult(b[0]).add(v[1].mult(b[1])).add(v[2].mult(b[2]));
}
public Vector3 calcInterpolation(float[] b, Vector3[] v) {
    return v[0].mult(b[0]).add(v[1].mult(b[1])).add(v[2].mult(b[2]));
}
public float calcInterpolation(float[] b, float[] v) {
    return v[0]*b[0]+v[1]*b[1]+v[2]*b[2];
}


public float[] barycentric(Vector3 P, Vector4[] verts) {



    Vector3 A=verts[0].homogenized();
    Vector3 B=verts[1].homogenized();
    Vector3 C=verts[2].homogenized();
    float AW=verts[0].w;
    float BW=verts[1].w;
    float CW=verts[2].w;




    float alpha=(P.x*(B.y-C.y)+P.y*(C.x-B.x)+(B.x*C.y-C.x*B.y))/(A.x*(B.y-C.y)+A.y*(C.x-B.x)+(B.x*C.y-C.x*B.y));
    float beta=(P.x*(C.y-A.y)+P.y*(A.x-C.x)+(C.x*A.y-A.x*C.y))/(B.x*(C.y-A.y)+B.y*(A.x-C.x)+(C.x*A.y-A.x*C.y));
    float gamma=1-alpha-beta;

    float s=alpha/AW+beta/BW+gamma/CW;
    float Walpha=alpha/(AW*s);
    float Wbeta=beta/(BW*s);
    float Wgamma=gamma/(CW*s);

    float[] result={Walpha, Wbeta, Wgamma};

    return result;
}

public float[] barycentric(Vector3 P, Vector3[] verts) {

    Vector3 A=verts[0];
    Vector3 B=verts[1];
    Vector3 C=verts[2];

    float alpha=(P.x*(B.y-C.y)+P.y*(C.x-B.x)+(B.x*C.y-C.x*B.y))/(A.x*(B.y-C.y)+A.y*(C.x-B.x)+(B.x*C.y-C.x*B.y));
    float beta=(P.x*(C.y-A.y)+P.y*(A.x-C.x)+(C.x*A.y-A.x*C.y))/(B.x*(C.y-A.y)+B.y*(A.x-C.x)+(C.x*A.y-A.x*C.y));
    float gamma=1-alpha-beta;
    float[] result={alpha, beta, gamma};

    return result;
}

public Vector3 colorToVector3(color c) {
    int B_MASK = 255;
    int G_MASK = 255<<8; //65280
    int R_MASK = 255<<16; //16711680
    float r = (c & R_MASK)>>16;
    float g = (c & G_MASK)>>8;
    float b = c & B_MASK;

    return new Vector3(r/255.0, g/255.0, b/255.0);
}

public Vector3 getTextureColor(PImage img, Vector3 uv) {

    float x=map(uv.x, 0, 1, 0, img.width-1);
    float y=map(uv.y, 0, 1, 0, img.height-1);


    int index=int(x%img.width)+int(y%img.height)*img.width;

    color pixel=img.pixels[index];
    int B_MASK = 255;
    int G_MASK = 255<<8; //65280
    int R_MASK = 255<<16; //16711680
    float r = (pixel & R_MASK)>>16;
    float g = (pixel & G_MASK)>>8;
    float b = pixel & B_MASK;

    return new Vector3(r/255.0, g/255.0, b/255.0);
}
public boolean intersectionTriangle(Vector3 o,Vector3 dir,Vector3[] P){
    Vector3 E1 = P[1].sub(P[0]);
    Vector3 E2 = P[2].sub(P[0]);
    Vector3 S = o.sub(P[0]);
    Vector3 S1 = Vector3.cross(dir,E2);
    Vector3 S2 = Vector3.cross(S,E1);
    float SE = 1.0/Vector3.dot(S1,E1);
    float t = Vector3.dot(S2,E2) * SE;
    float b1 = Vector3.dot(S1,S) * SE;
    float b2 = Vector3.dot(S2,dir) * SE;
    float b3 = 1-b2-b1;
    if(b1>0&&b2>0&&b3>0) return true;
    return false;
}

static public Vector3 toVector(float phi, float theta) {
    float r = sin(theta);
    return new Vector3(r * cos(phi), r * sin(phi), cos(theta));
}
