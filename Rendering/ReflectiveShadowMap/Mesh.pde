class Mesh {
    int NUM_VBOS = 3;

    ArrayList<Vector3> verts = new ArrayList<Vector3>();
    ArrayList<Vector3> uvs = new ArrayList<Vector3>();
    ArrayList<Vector3> normals = new ArrayList<Vector3>();
    ArrayList<Vector3> tangents = new ArrayList<Vector3>();

    // 全部 triangle 總表，保留你原本的使用方式
    ArrayList<Triangle> triangles = new ArrayList<Triangle>();

    // SubMesh：依 usemtl 分組
    LinkedHashMap<String, SubMesh> subMeshes = new LinkedHashMap<String, SubMesh>();
    String currentMaterialName = "default";
    SubMesh currentSubMesh = null;

    public Mesh() {
        setCurrentMaterial("default");
    }

    // 不能宣告 static，否則你前面那個錯誤又會出現
    private class FaceIndex {
        int v = -1;
        int vt = -1;
        int vn = -1;
    }

    public Mesh(String fname) {
        String[] fin = loadStrings(fname + ".obj");
        if (fin == null) {
            println("OBJ load failed: " + fname + ".obj");
            setCurrentMaterial("default");
            return;
        }

        setCurrentMaterial("default");

        for (int i = 0; i < fin.length; i++) {
            String line = fin[i];
            if (line == null) continue;

            line = line.trim();
            if (line.length() == 0 || line.startsWith("#")) {
                continue;
            }

            String[] s = line.split("\\s+");
            if (s.length == 0) continue;

            if (line.startsWith("v ")) {
                if (s.length >= 4) {
                    verts.add(new Vector3(float(s[1]), float(s[2]), float(s[3])));
                }
            } else if (line.startsWith("vt ")) {
                if (s.length >= 3) {
                    uvs.add(new Vector3(float(s[1]), float(s[2]), 0));
                }
            } else if (line.startsWith("vn ")) {
                if (s.length >= 4) {
                    normals.add(new Vector3(float(s[1]), float(s[2]), float(s[3])));
                }
            } else if (line.startsWith("usemtl ")) {
                String materialName = line.substring(7).trim();
                setCurrentMaterial(materialName);
            } else if (line.startsWith("f ")) {
                parseFace(s);
            }
        }

        reCaculateNormal();
    }

    //========================
    // SubMesh helpers
    //========================
    private SubMesh getOrCreateSubMesh(String materialName) {
        if (materialName == null || materialName.trim().length() == 0) {
            materialName = "default";
        }

        SubMesh sub = subMeshes.get(materialName);
        if (sub == null) {
            sub = new SubMesh(materialName);
            subMeshes.put(materialName, sub);
        }
        return sub;
    }

    private void setCurrentMaterial(String materialName) {
        if (materialName == null || materialName.trim().length() == 0) {
            materialName = "default";
        }

        currentMaterialName = materialName.trim();
        currentSubMesh = getOrCreateSubMesh(currentMaterialName);
    }

    private void addTriangle(Triangle tri) {
        if (tri == null) return;

        triangles.add(tri);

        if (currentSubMesh == null) {
            currentSubMesh = getOrCreateSubMesh(currentMaterialName);
        }

        currentSubMesh.triangles.add(tri);
    }

    public void printSubMeshInfo() {
        println("SubMesh count: " + subMeshes.size());
        for (String key : subMeshes.keySet()) {
            SubMesh sub = subMeshes.get(key);
            println("material = " + key + ", triangles = " + sub.triangles.size());
        }
    }

    public SubMesh getSubMesh(String materialName) {
        return subMeshes.get(materialName);
    }

    public ArrayList<SubMesh> getAllSubMeshes() {
        return new ArrayList<SubMesh>(subMeshes.values());
    }

    //========================
    // Face parsing
    //========================
    private void parseFace(String[] s) {
        // s[0] = "f"
        if (s.length < 4) return;

        FaceIndex[] face = new FaceIndex[s.length - 1];
        for (int i = 1; i < s.length; i++) {
            face[i - 1] = parseFaceVertex(s[i]);
        }

        // fan triangulation:
        // (0,1,2), (0,2,3), (0,3,4)...
        for (int i = 1; i < face.length - 1; i++) {
            addFace(face[0], face[i], face[i + 1]);
        }
    }

    private FaceIndex parseFaceVertex(String token) {
        FaceIndex idx = new FaceIndex();

        if (token == null || token.length() == 0) {
            return idx;
        }

        String[] parts = token.split("/", -1);

        // v
        if (parts.length > 0 && parts[0].length() > 0) {
            idx.v = parseObjIndex(parts[0], verts.size());
        }

        // vt
        if (parts.length > 1 && parts[1].length() > 0) {
            idx.vt = parseObjIndex(parts[1], uvs.size());
        }

        // vn
        if (parts.length > 2 && parts[2].length() > 0) {
            idx.vn = parseObjIndex(parts[2], normals.size());
        }

        return idx;
    }

    private int parseObjIndex(String s, int size) {
        int idx = int(s);

        // OBJ index:
        //  > 0 : 1-based
        //  < 0 : relative index from end
        // == 0 : invalid
        if (idx > 0) return idx - 1;
        if (idx < 0) return size + idx;
        return -1;
    }

    private Vector3 safeGet(ArrayList<Vector3> list, int idx, Vector3 fallback) {
        if (idx >= 0 && idx < list.size()) {
            return list.get(idx);
        }
        return fallback;
    }

    private void addFace(FaceIndex ia, FaceIndex ib, FaceIndex ic) {
        if (ia == null || ib == null || ic == null) return;
        if (ia.v < 0 || ib.v < 0 || ic.v < 0) return;
        if (ia.v >= verts.size() || ib.v >= verts.size() || ic.v >= verts.size()) return;

        Vector3[] vs = new Vector3[] {
            verts.get(ia.v),
            verts.get(ib.v),
            verts.get(ic.v)
        };

        int[] v_ix = new int[] { ia.v, ib.v, ic.v };

        Vector3 faceNormal = Vector3.cross(
            vs[1].sub(vs[0]),
            vs[2].sub(vs[0])
        ).unit_vector();

        Vector3[] ns = new Vector3[] {
            safeGet(normals, ia.vn, faceNormal),
            safeGet(normals, ib.vn, faceNormal),
            safeGet(normals, ic.vn, faceNormal)
        };

        Vector3 defaultUV = new Vector3(0, 0, 0);
        Vector3[] us = new Vector3[] {
            safeGet(uvs, ia.vt, defaultUV),
            safeGet(uvs, ib.vt, defaultUV),
            safeGet(uvs, ic.vt, defaultUV)
        };

        Triangle tri = new Triangle(vs, us, ns, v_ix, triangles.size());
        tri.materialName = currentMaterialName;
        addTriangle(tri);
    }

    //========================
    // 全 mesh 輸出
    //========================
    float[] getTrianglePosition() {
        return getTrianglePosition(triangles);
    }

    float[] getTriangleNormal() {
        return getTriangleNormal(triangles);
    }

    float[] getTriangleTangent() {
        return getTriangleTangent(triangles);
    }

    float[] getTriangleUV() {
        return getTriangleUV(triangles);
    }

    //========================
    // 單一 submesh 輸出
    //========================
    float[] getTrianglePosition(SubMesh sub) {
        if (sub == null) return new float[0];
        return getTrianglePosition(sub.triangles);
    }

    float[] getTriangleNormal(SubMesh sub) {
        if (sub == null) return new float[0];
        return getTriangleNormal(sub.triangles);
    }

    float[] getTriangleTangent(SubMesh sub) {
        if (sub == null) return new float[0];
        return getTriangleTangent(sub.triangles);
    }

    float[] getTriangleUV(SubMesh sub) {
        if (sub == null) return new float[0];
        return getTriangleUV(sub.triangles);
    }

    //========================
    // 共用輸出實作
    //========================
    private float[] getTrianglePosition(ArrayList<Triangle> tris) {
        float[] v = new float[tris.size() * 9];
        for (int i = 0; i < tris.size(); i++) {
            Triangle tri = tris.get(i);
            for (int j = 0; j < 3; j++) {
                v[i * 9 + j * 3 + 0] = tri.verts[j].x;
                v[i * 9 + j * 3 + 1] = tri.verts[j].y;
                v[i * 9 + j * 3 + 2] = tri.verts[j].z;
            }
        }
        return v;
    }

    private float[] getTriangleNormal(ArrayList<Triangle> tris) {
        float[] v = new float[tris.size() * 9];
        for (int i = 0; i < tris.size(); i++) {
            Triangle tri = tris.get(i);
            for (int j = 0; j < 3; j++) {
                Vector3 n = (tri.normal != null && tri.normal[j] != null) ? tri.normal[j] : new Vector3(0, 1, 0);
                v[i * 9 + j * 3 + 0] = n.x;
                v[i * 9 + j * 3 + 1] = n.y;
                v[i * 9 + j * 3 + 2] = n.z;
            }
        }
        return v;
    }

    private float[] getTriangleTangent(ArrayList<Triangle> tris) {
        float[] v = new float[tris.size() * 9];
        for (int i = 0; i < tris.size(); i++) {
            Triangle tri = tris.get(i);
            for (int j = 0; j < 3; j++) {
                Vector3 t = (tri.tangents != null && tri.tangents[j] != null) ? tri.tangents[j] : new Vector3(1, 0, 0);
                v[i * 9 + j * 3 + 0] = t.x;
                v[i * 9 + j * 3 + 1] = t.y;
                v[i * 9 + j * 3 + 2] = t.z;
            }
        }
        return v;
    }

    private float[] getTriangleUV(ArrayList<Triangle> tris) {
        float[] v = new float[tris.size() * 6];
        for (int i = 0; i < tris.size(); i++) {
            Triangle tri = tris.get(i);
            for (int j = 0; j < 3; j++) {
                Vector3 uv = (tri.uvs != null && tri.uvs[j] != null) ? tri.uvs[j] : new Vector3(0, 0, 0);
                v[i * 6 + j * 2 + 0] = uv.x;
                v[i * 6 + j * 2 + 1] = uv.y;
            }
        }
        return v;
    }

    //========================
    // Normal / tangent
    //========================
    void calcNormal() {
        Vector3[] normal = new Vector3[verts.size()];
        for (int i = 0; i < normal.length; i++) {
            normal[i] = new Vector3();
        }

        for (int i = 0; i < triangles.size(); i++) {
            for (int j = 0; j < 3; j++) {
                if (triangles.get(i).normal != null && triangles.get(i).normal[j] != null) {
                    normal[triangles.get(i).triangle[j]].plus(triangles.get(i).normal[j]);
                }
            }
        }

        normals.clear();
        for (int i = 0; i < normal.length; i++) {
            normals.add(normal[i].unit_vector());
        }

        for (int i = 0; i < triangles.size(); i++) {
            for (int j = 0; j < 3; j++) {
                triangles.get(i).normal[j] = normals.get(triangles.get(i).triangle[j]);
            }
        }
    }

    void reCaculateNormal() {
        Vector3[] result = new Vector3[verts.size()];
        for (int i = 0; i < result.length; i++) {
            result[i] = new Vector3();
        }

        for (int i = 0; i < triangles.size(); i++) {
            Triangle tri = triangles.get(i);
            Vector3 n = Vector3.cross(
                tri.verts[1].sub(tri.verts[0]),
                tri.verts[2].sub(tri.verts[0])
            );

            for (int j = 0; j < 3; j++) {
                result[tri.triangle[j]] = result[tri.triangle[j]].add(n);
            }
        }

        for (int i = 0; i < triangles.size(); i++) {
            Triangle tri = triangles.get(i);
            for (int j = 0; j < 3; j++) {
                tri.normal[j] = result[tri.triangle[j]].unit_vector();
            }
            tri.caculateTangent();
        }
    }

    @Override
    public String toString() {
        int c = 1;
        String s = "";
        for (Triangle t : triangles) {
            s += "Triangle " + c++ + ":\n";
            s += t.toString();
        }
        return s;
    }
}

class SubMesh {
    String materialName;
    ArrayList<Triangle> triangles = new ArrayList<Triangle>();

    SubMesh(String materialName) {
        this.materialName = materialName;
    }

    @Override
    public String toString() {
        return "SubMesh(material=" + materialName + ", triangles=" + triangles.size() + ")";
    }
}

class Triangle {
    String materialName = "default";

    Vector3[] verts;
    Vector3[] uvs;
    Vector3[] normal;
    Vector3[] tangents;
    int[] triangle;
    Vector3 center;
    int idx;

    Triangle(Vector3[] verts, Vector3[] uvs, Vector3[] normal, int[] triangle, int id) {
        this.verts = verts;
        this.uvs = uvs;
        this.normal = normal;
        this.triangle = triangle;
        this.idx = id;
        this.center = (verts[0].add(verts[1]).add(verts[2])).mult(1.0 / 3.0);
        caculateTangent();
    }

    Triangle(Vector3[] verts, int[] triangle, int id) {
        this.verts = verts;
        this.uvs = new Vector3[] { new Vector3(), new Vector3(), new Vector3() };
        this.normal = new Vector3[] { new Vector3(), new Vector3(), new Vector3() };
        this.triangle = triangle;
        this.idx = id;
        this.center = (verts[0].add(verts[1]).add(verts[2])).mult(1.0 / 3.0);
        caculateTangent();
    }

    Triangle(Vector3[] verts, Vector3[] normal, int[] triangle, int id) {
        this.verts = verts;
        this.uvs = new Vector3[] { new Vector3(), new Vector3(), new Vector3() };
        this.normal = normal;
        this.triangle = triangle;
        this.idx = id;
        this.center = (verts[0].add(verts[1]).add(verts[2])).mult(1.0 / 3.0);
        caculateTangent();
    }

    public void caculateTangent() {
        tangents = new Vector3[3];
        for (int i = 0; i < tangents.length; i++) {
            Vector3 n = (normal != null && normal[i] != null) ? normal[i] : new Vector3(0, 1, 0);
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

        if (b1 > 0.01 && b2 > 0.01 && 1 - b1 - b2 > 0.01 && t > 0.01) return true;
        return false;
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

        s += "Uvs:\n";
        if (uvs != null) {
            for (Vector3 v : uvs) {
                s += (v == null ? "null" : v.toString()) + "\n";
            }
        }

        return s;
    }
}
