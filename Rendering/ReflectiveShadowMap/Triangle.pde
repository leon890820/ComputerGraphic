class Triangle {
    String materialName = "default";

    Vector3[] verts;
    Vector3[] uvs;
    Vector3[] normals;
    Vector3[] tangents;

    // 保留 shared vertex index，給 smooth normal 計算用
    int[] vertexIndices;

    Vector3 center;

    Triangle(Vector3[] verts, Vector3[] uvs, Vector3[] normals, int[] vertexIndices) {
        this.verts = verts;
        this.uvs = uvs;
        this.normals = normals;
        this.vertexIndices = vertexIndices;
        this.center = (verts[0].add(verts[1]).add(verts[2])).mult(1.0 / 3.0);
        calculateTangent();
    }

    public void calculateTangent() {
        tangents = new Vector3[3];
        for (int i = 0; i < tangents.length; i++) {
            Vector3 n = (normals != null && normals[i] != null) ? normals[i] : new Vector3(0, 1, 0);
            tangents[i] = new Vector3(-n.z, 0.0, n.x);
        }
    }

    public boolean intersection(Vector3 o, Vector3 dir, Matrix4 ltw) {
        Vector3 v0 = ltw.transformPoint(verts[0]);
        Vector3 v1 = ltw.transformPoint(verts[1]);
        Vector3 v2 = ltw.transformPoint(verts[2]);

        Vector3 e1 = Vector3.sub(v1, v0);
        Vector3 e2 = Vector3.sub(v2, v0);
        Vector3 s = Vector3.sub(o, v0);
        Vector3 s1 = Vector3.cross(dir, e2);
        Vector3 s2 = Vector3.cross(s, e1);
        float se_inv = 1.0 / Vector3.dot(s1, e1);

        float t = Vector3.dot(s2, e2) * se_inv;
        float b1 = Vector3.dot(s1, s) * se_inv;
        float b2 = Vector3.dot(s2, dir) * se_inv;

        return b1 > 0.01 && b2 > 0.01 && 1 - b1 - b2 > 0.01 && t > 0.01;
    }
        

    @Override
        public String toString() {
        String s = "Material: " + materialName + "\n";

        s += "Vertices:\n";
        if (verts != null) {
            for (Vector3 v : verts) {
                s += (v == null ? "null" : v.toString()) + "\n";
            }
        }

        s += "UVs:\n";
        if (uvs != null) {
            for (Vector3 v : uvs) {
                s += (v == null ? "null" : v.toString()) + "\n";
            }
        }

        return s;
    }
}

private interface TriangleVectorGetter {
    Vector3 get(Triangle tri, int vertexIndex);
}
