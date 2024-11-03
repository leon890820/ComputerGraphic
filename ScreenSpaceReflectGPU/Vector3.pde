static final public class Vector3 {
    private float x;
    private float y;
    private float z;

    Vector3() {
        x=0;
        y=0;
        z=0;
    }
    Vector3(float _a) {
        x=_a;
        y=_a;
        z=_a;
    }
    Vector3(float _x, float _y, float _z) {
        x=_x;
        y=_y;
        z=_z;
    }
    float x() {
        return x;
    }
    float y() {
        return y;
    }
    float z() {
        return z;
    }

    float xyz(int i) {
        if (i==0) return x;
        else if (i==1) return y;
        else return z;
    }
    static Vector3 Zero() {
        return new Vector3(0);
    }
    static Vector3 Ones() {
        return new Vector3(1);
    }
    static Vector3 UnitX() {
        return new Vector3(1, 0, 0);
    }
    static Vector3 UnitY() {
        return new Vector3(0, 1, 0);
    }
    static Vector3 UnitZ() {
        return new Vector3(0, 0, 1);
    }

    void set(float _x, float _y, float _z) {
        x = _x;
        y = _y;
        z = _z;
    }
    void setZero() {
        x = 0.0f;
        y = 0.0f;
        z = 0.0f;
    }
    void setOnes() {
        x = 1.0f;
        y = 1.0f;
        z = 1.0f;
    }
    void setUnitX() {
        x = 1.0f;
        y = 0.0f;
        z = 0.0f;
    }
    void setUnitY() {
        x = 0.0f;
        y = 1.0f;
        z = 0.0f;
    }
    void setUnitZ() {
        x = 0.0f;
        y = 0.0f;
        z = 1.0f;
    }


    public static Vector3 add(Vector3 a, Vector3 b) {
        Vector3 result=new Vector3();
        result.x=a.x+b.x;
        result.y=a.y+b.y;
        result.z=a.z+b.z;
        return result;
    }
    public static Vector3 sub(Vector3 a, Vector3 b) {
        Vector3 result=new Vector3();
        result.x=a.x-b.x;
        result.y=a.y-b.y;
        result.z=a.z-b.z;
        return result;
    }
    public static Vector3 mult(float n, Vector3 a) {
        Vector3 result=new Vector3();
        result.x=n*a.x;
        result.y=n*a.y;
        result.z=n*a.z;
        return result;
    }
    public Vector3 mult(float n) {
        Vector3 result=new Vector3();
        result.x=n*x;
        result.y=n*y;
        result.z=n*z;
        return result;
    }


    void product(float n) {

        x*=n;
        y*=n;
        z*=n;
    }

    public Vector3 dive(float n) {
        Vector3 result=new Vector3();
        result.x=x/n;
        result.y=y/n;
        result.z=z/n;
        return result;
    }
    public static Vector3 cross(Vector3 a, Vector3 b) {
        Vector3 result=new Vector3();
        result.x=a.y*b.z-a.z*b.y;
        result.y=a.z*b.x-a.x*b.z;
        result.z=a.x*b.y-a.y*b.x;
        return result;
    }

    public static float dot(Vector3 a, Vector3 b) {
        return a.x*b.x+a.y*b.y+a.z*b.z;
    }
    public float norm() {
        return sqrt(x*x+y*y+z*z);
    }

    public void print() {
        println("x: "+x+" y: "+y+" z: "+z);
    }
    Vector3 unit_vector() {
        return Vector3.mult(1/this.norm(), this);
    }
    void normalize() {
        float a=1/this.norm();
        this.product(a);
    }

    public static Vector3 unit_vector(Vector3 v) {
        return Vector3.mult(1/v.norm(), v);
    }
    public Vector3 sub(Vector3 b) {
        Vector3 result=new Vector3();
        result.x=x-b.x;
        result.y=y-b.y;
        result.z=z-b.z;
        return result;
    }
    public Vector3 add(Vector3 b) {
        Vector3 result=new Vector3();
        result.x=x+b.x;
        result.y=y+b.y;
        result.z=z+b.z;
        return result;
    }

    public void minus(Vector3 b) {

        x-=b.x;
        y-=b.y;
        z-=b.z;
    }
    public void plus(Vector3 b) {

        x+=b.x;
        y+=b.y;
        z+=b.z;
    }

    public float length_squared() {
        return x*x+y*y+z*z;
    }
    float length() {
        return sqrt(this.length_squared());
    }

    boolean near_zero() {
        float s=1e-8;
        return (abs(x)<s)&&abs(y)<s&&abs(z)<s;
    }
    Vector3 product(Vector3 v) {
        Vector3 result=new Vector3();
        result.x=x*v.x;
        result.y=y*v.y;
        result.z=z*v.z;
        return result;
    }



    Vector3 inv() {
        return new Vector3(1/x, 1/y, 1/z);
    }
    float magSq() {
        return x*x+y*y+z*z;
    }
    void clipMag(float m) {
        float r=magSq()/(m*m);
        if (r>1) {
            float sr=sqrt(r);
            x/=sr;
            y/=sr;
            z/=sr;
        }
    }

    Vector3 copy() {
        return new Vector3(x, y, z);
    }
    void copy(Vector3 b) {
        x=b.x;
        y=b.y;
        z=b.z;
    }

    Vector4 getVector4() {
        return new Vector4(this, 1);
    }
    Vector4 getVector4(float b) {
        return new Vector4(this, b);
    }

    @Override
        public String toString() {
        return "x : "+x+" y : "+y+" z : "+z;
    }
}


public Vector3 random_unit_sphere_vector() {
    float phi = random(0, 1) * 2 * PI;
    float theta = acos(-2 * random(-0.5, 0.5));
    return toVector(phi, theta);
}

public Vector3 vec_random() {
    return new Vector3(random(1), random(1), random(1));
}
public Vector3 vec_random(float min, float max) {
    return new Vector3(random(min, max), random(min, max), random(min, max));
}
public Vector3 random_in_unit_sphere() {
    while (true) {
        Vector3 p=vec_random(-1, 1);
        if (p.length_squared()>=1) continue;
        return p;
    }
}
Vector3 random_unit_vector() {
    return Vector3.unit_vector(random_in_unit_sphere());
}

Vector3 reflect(Vector3 v, Vector3 n) {
    Vector3 r=n.mult(2*Vector3.dot(v, n));
    return v.sub(r);
}

Vector3 refract(Vector3 uv, Vector3 n, float etai_over_etat) {
    float cos_theda=min(Vector3.dot(uv.mult(-1), n), 1);
    Vector3 r_out_perp=uv.add(n.mult(cos_theda)).mult(etai_over_etat);
    Vector3 r_out_parallel=n.mult(-sqrt(1-r_out_perp.length_squared()));
    return r_out_perp.add(r_out_parallel);
}

Vector3 random_in_unit_disk() {
    while (true) {
        Vector3 p=new Vector3(random(-1, 1), random(-1, 1), 0);
        if (p.length_squared()>=1)continue;
        return p;
    }
}



static public class Vector4 {
    float x, y, z, w;
    Vector4() {
    }
    Vector4(Vector3 xyz, float w) {
        this.x=xyz.x;
        this.y=xyz.y;
        this.z=xyz.z;
        this.w=w;
    }
    Vector4(float x, float y, float z, float w) {
        this.x=x;
        this.y=y;
        this.z=z;
        this.w=w;
    }
    Vector4(float x) {
        this.x=x;
        this.y=x;
        this.z=x;
        this.w=x;
    }

    Vector3 xyz() {
        return new Vector3(x, y, z);
    }
    Vector3 xyzNormalize() {
        return xyz().unit_vector();
    }
    Vector3 homogenized() {
        if (w<0) return new Vector3(-x/w, -y/w, -z/w);
        return new Vector3(x/w, y/w, z/w);
    }

    Vector4 reverseW() {
        return new Vector4(x, y, z, -abs(w));
    }

    void set(float _x, float _y, float _z, float _w) {
        x = _x;
        y = _y;
        z = _z;
        w = _w;
    }

    Vector4 add(Vector4 v) {
        return new Vector4(x+v.x, y+v.y, z+v.z, w);
    }

    Vector4 mult(float b) {
        return new Vector4(x*b, y*b, z*b, w);
    }
    Vector4 mult(Matrix4 m) {
        return new Vector4(
            m.m[0]*x  + m.m[1]*y  + m.m[2]*z  + m.m[3]*w,
            m.m[4]*x  + m.m[5]*y  + m.m[6]*z  + m.m[7]*w,
            m.m[8]*x  + m.m[9]*y  + m.m[10]*z + m.m[11]*w,
            m.m[12]*x + m.m[13]*y + m.m[14]*z + m.m[15]*w
            );
    }

    void multiply(float b) {
        x*=b;
        y*=b;
        z*=b;
    }


    Vector4 div(float b) {
        return new Vector4(x/b, y/b, z/b, w);
    }
    void dive(float b) {
        x/=b;
        y/=b;
        z/=b;
        w/=b;
    }
    float dot(Vector4 b) {
        return x*b.x + y*b.y + z*b.z;
    }

    float dot(Vector3 b) {
        return x*b.x + y*b.y + z*b.z;
    }

    @Override
        public String toString() {
        return "x : "+x+" y : "+y+" z : "+z + " w : " + w;
    }
}
