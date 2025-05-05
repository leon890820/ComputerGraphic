FloatBuffer allocateDirectFloatBuffer(int n) {
    return ByteBuffer.allocateDirect(n * Float.BYTES).order(ByteOrder.nativeOrder()).asFloatBuffer();
}

IntBuffer allocateDirectIntBuffer(int n) {
    return ByteBuffer.allocateDirect(n * Integer.BYTES).order(ByteOrder.nativeOrder()).asIntBuffer();
}

static public Vector3 toVector(float phi, float theta) {
    float r = sin(theta);
    return new Vector3(r * cos(phi), r * sin(phi), cos(theta));
}

static public Vector3 uniformCube(Vector3 v) {
    float x2 = v.x * v.x;
    float y2 = v.y * v.y;
    float z2 = v.z * v.z;


    float x = v.x * sqrt(1.0 - y2 * 0.5 - z2 * 0.5 + y2 * z2 / 3.0);
    float y = v.y * sqrt(1.0 - z2 * 0.5 - x2 * 0.5 + z2 * x2 / 3.0);
    float z = v.z * sqrt(1.0 - x2 * 0.5 - y2 * 0.5 + x2 * y2 / 3.0);
    return new Vector3(x, y, z);
}

public float dot(float[] a, float[] b) {
    float r = 0.0;
    for (int i=0; i<a.length; i++) {
        r += a[i] * b[i];
    }
    return r;
}

public Vector3 dot(Vector3[] a, float[] b) {
    Vector3 r = new Vector3(0.0);
    for (int i=0; i<a.length; i++) {
        r = r.add(a[i].mult(b[i]));
    }

    return r;
}



public float glossy_brdf(Vector3 wo, Vector3 wi, Vector3 normal) {
    wo = wo.unit_vector();
    wi = wi.unit_vector();
    normal = normal.unit_vector();
    Vector3 h = Vector3.add(wo, wi).unit_vector();
    return pow(max(Vector3.dot(h, normal), 0.0), 1.0);
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


public float calcArea(float _u, float _v, float w, float h) {
    float u = (2.0 * (_u + 0.5) / w) - 1.0;
    float v = (2.0 * (_v + 0.5) / h) - 1.0;

    // shift from a demi texel, mean 1.0 / size  with u and v in [-1..1]
    float invResolutionW = 1.0 / w;
    float invResolutionH = 1.0 / h;
    float x0 = u - invResolutionW;
    float y0 = v - invResolutionH;
    float x1 = u + invResolutionW;
    float y1 = v + invResolutionH;
    float angle = calcPreArea(x0, y0) - calcPreArea(x0, y1) - calcPreArea(x1, y0) + calcPreArea(x1, y1);

    return angle;
}

public float calcPreArea(float x, float y) {
    return atan2(x * y, sqrt(x * x + y * y + 1.0));
}


public Vector3 lerp(Vector3 a, Vector3 b, float t) {
    return new Vector3(lerp(a.x, b.x, t), lerp(a.y, b.y, t), lerp(a.z, b.z, t));
}

public float clamp(float a) {
    return max( min(a, 1.0), 0.0);
}

public float biasFunction(float x, float bias) {
    float k = pow(1.0 - bias, 3);
    return (x * k) / (x * k - x + 1.0);
}


public float smoothMin(float a, float b, float k) {
     k = max(0, k);
    float h = max(0, min(1, (b - a + k) / (2 * k)));
    return a * h + b * (1 - h) - k * h * (1 - h);
}

public float smoothMax(float a, float b, float k) {
    k = min(0, -k);
    float h = max(0, min(1, (b - a + k) / (2 * k)));
    return a * h + b * (1 - h) - k * h * (1 - h);
}

void intergerToRGB(int pixel) {
    int B_MASK = 255;
    int G_MASK = 255<<8; //65280
    int R_MASK = 255<<16; //16711680


    float r = (pixel & R_MASK)>>16;
    float g = (pixel & G_MASK)>>8;
    float b = pixel & B_MASK;
    
    println(r,g,b);
}

public FloatBuffer toFloatBuffer(Matrix4 m) {
    FloatBuffer result;
    result = allocateDirectFloatBuffer(16);
    float[] data = new float[]{m.m[0], m.m[1], m.m[2], m.m[3],
                               m.m[4], m.m[5], m.m[6], m.m[7],
                               m.m[8], m.m[9], m.m[10],m.m[11],
                               m.m[12],m.m[13],m.m[14],m.m[15]};
    result.rewind();
    result.put(data);
    result.rewind();
    
    return result;
}



public Vector3[] getVertexData(Vector3 center, Vector3 size) {
    Vector3 P0 = center.sub(size.mult(0.5));
    Vector3 P6 = center.add(size.mult(0.5));
    Vector3 P1 = new Vector3(P6.x, P0.y, P0.z);
    Vector3 P2 = new Vector3(P6.x, P6.y, P0.z);
    Vector3 P3 = new Vector3(P0.x, P6.y, P0.z);
    Vector3 P4 = new Vector3(P0.x, P0.y, P6.z);
    Vector3 P5 = new Vector3(P6.x, P0.y, P6.z);
    Vector3 P7 = new Vector3(P0.x, P6.y, P6.z);

    return new Vector3[]{P0, P1, P2, P3, P4, P5, P6, P7};
}

public float[] getCubeData(Vector3 center, Vector3 size) {
    float[] data = new float[24 * 12];
    int[] index = new int[]{1, 0, 3, 1, 3, 2, 4, 5, 6, 4, 6, 7, 5, 1, 2, 5, 2, 6, 0, 4, 7, 0, 7, 3, 7, 6, 2, 7, 2, 3, 0, 1, 5, 0, 5, 4};


    Vector3[] vertex = getVertexData(center, size);
    int count = 0;
    for (int i = 0; i < 12; i++) {
        float[] f = getTriangleData(new Vector3[]{vertex[index[i * 3 + 0]], vertex[index[i * 3 + 1]], vertex[index[i * 3 + 2]]}, 0, new Vector3(0.48, 0.83, 0.53), 0.0, 0.0);
        for (int j = 0; j < f.length; j++) {
            data[count + j] = f[j];
        }
        count += f.length;
    }
    return data;
}
public float[] getSphereData(Vector3 center, float r, int type, Vector3 albedo, float fuzz, float refraction_index) {
    float[] data = new float[]{center.x, center.y, center.z, r,
                               type, 0.0, 0.0, 0.0, // material
                               albedo.x, albedo.y, albedo.z, fuzz,
                               refraction_index, 0.0, 0.0, 0.0};
    return data;
}

public float[] getTriangleData(Vector3[] T, int type, Vector3 albedo, float fuzz, float refraction_index) {
    float[] data = new float[]{T[0].x, T[0].y, T[0].z, 0.0,
                               T[1].x, T[1].y, T[1].z, 0.0,
                               T[2].x, T[2].y, T[2].z, 0.0,
                               type, 0.0, 0.0, 0.0, // material
                               albedo.x, albedo.y, albedo.z, fuzz,
                               refraction_index, 0.0, 0.0, 0.0};
    return data;
}



public Vector3 getAverageTriangleCenter(ArrayList<Triangle> triangles){
    Vector3 center = new Vector3();
    for(Triangle triangle : triangles){
        center = center.add(triangle.getCenter());
    }
    return center.mult(1.0 / (float)triangles.size());
}
