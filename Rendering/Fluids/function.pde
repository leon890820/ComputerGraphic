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

public float sign(float x){
    return x > 0 ? 1.0 : x < 0 ? -1.0 : 0.0;
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


public int[] positionToCellCoord(Vector3 point){
    int cx = floor(point.x) + int(boundSize.x * 0.5) ;
    int cy = floor(point.y) + int(boundSize.y * 0.5) ;
    return new int[]{cx, cy};
}
