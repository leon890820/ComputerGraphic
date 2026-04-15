class Mesh {
    // 建構期 source data
    ArrayList<Vector3> sourceVerts = new ArrayList<Vector3>();
    ArrayList<Vector3> sourceUVs = new ArrayList<Vector3>();
    ArrayList<Vector3> sourceNormals = new ArrayList<Vector3>();

    // Runtime / render data
    ArrayList<Triangle> triangles = new ArrayList<Triangle>();
    LinkedHashMap<String, SubMesh> subMeshes = new LinkedHashMap<String, SubMesh>();

    String currentMaterialName = "default";
    SubMesh currentSubMesh = null;

    String mtllibName = null;
    LinkedHashMap<String, MtlMaterial> mtlMaterials = new LinkedHashMap<String, MtlMaterial>();
    LinkedHashMap<String, Texture> textureKaMap = new LinkedHashMap<String, Texture>();
    String objBasePath = null;

    public Mesh() {
        setCurrentMaterial("default");
    }

    private class FaceIndex {
        int v = -1;
        int vt = -1;
        int vn = -1;
    }

    public Mesh(String fname) {
        objBasePath = fname;

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
            if (line.length() == 0 || line.startsWith("#")) continue;

            String[] s = line.split("\\s+");
            if (s.length == 0) continue;

            if (line.startsWith("v ")) {
                if (s.length >= 4) {
                    sourceVerts.add(new Vector3(float(s[1]), float(s[2]), float(s[3])));
                }
            } else if (line.startsWith("vt ")) {
                if (s.length >= 3) {
                    sourceUVs.add(new Vector3(float(s[1]), float(s[2]), 0));
                }
            } else if (line.startsWith("vn ")) {
                if (s.length >= 4) {
                    sourceNormals.add(new Vector3(float(s[1]), float(s[2]), float(s[3])));
                }
            } else if (line.startsWith("usemtl ")) {
                setCurrentMaterial(line.substring(7).trim());
            } else if (line.startsWith("f ")) {
                parseFace(s);
            } else if (line.startsWith("mtllib ")) {
                mtllibName = line.substring(7).trim();
                loadMtlFile(fname, mtllibName);
            }
        }

        reCaculateNormal();
        releaseSourceData();

        loadTextureKaMaps();
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
    // OBJ parsing
    //========================
    private void parseFace(String[] s) {
        if (s.length < 4) return;

        FaceIndex[] face = new FaceIndex[s.length - 1];
        for (int i = 1; i < s.length; i++) {
            face[i - 1] = parseFaceVertex(s[i]);
        }

        // fan triangulation
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

        if (parts.length > 0 && parts[0].length() > 0) {
            idx.v = parseObjIndex(parts[0], sourceVerts.size());
        }

        if (parts.length > 1 && parts[1].length() > 0) {
            idx.vt = parseObjIndex(parts[1], sourceUVs.size());
        }

        if (parts.length > 2 && parts[2].length() > 0) {
            idx.vn = parseObjIndex(parts[2], sourceNormals.size());
        }

        return idx;
    }

    private String buildSiblingPath(String objBasePath, String fileName) {
        int slash1 = objBasePath.lastIndexOf('/');
        int slash2 = objBasePath.lastIndexOf('\\');
        int slash = max(slash1, slash2);

        if (slash < 0) return fileName;
        return objBasePath.substring(0, slash + 1) + fileName;
    }

    private void loadMtlFile(String objBasePath, String mtlFileName) {
        String mtlPath = buildSiblingPath(objBasePath, mtlFileName);
        String[] lines = loadStrings(mtlPath);

        if (lines == null) {
            println("[Mesh] loadMtlFile failed: " + mtlPath);
            return;
        }

        MtlMaterial current = null;

        for (int i = 0; i < lines.length; i++) {
            String line = lines[i];
            if (line == null) continue;

            line = line.trim();
            if (line.length() == 0 || line.startsWith("#")) continue;

            String[] s = line.split("\\s+");
            if (s.length == 0) continue;

            if (line.startsWith("newmtl ")) {
                String name = line.substring(7).trim();
                current = new MtlMaterial();
                current.name = name;
                mtlMaterials.put(name, current);
            } else if (current != null && line.startsWith("map_Ka ")) {
                current.mapKa = line.substring(7).trim();
            } else if (current != null && line.startsWith("map_Kd ")) {
                current.mapKd = line.substring(7).trim();
            } else if (current != null && line.startsWith("map_Ks ")) {
                current.mapKs = line.substring(7).trim();
            } else if (current != null && line.startsWith("bump ")) {
                current.bump = line.substring(5).trim();
            } else if (current != null && line.startsWith("map_Bump ")) {
                current.mapBump = line.substring(9).trim();
            } else if (current != null && line.startsWith("Ka ")) {
                if (s.length >= 4) current.Ka = new Vector3(float(s[1]), float(s[2]), float(s[3]));
            } else if (current != null && line.startsWith("Kd ")) {
                if (s.length >= 4) current.Kd = new Vector3(float(s[1]), float(s[2]), float(s[3]));
            } else if (current != null && line.startsWith("Ks ")) {
                if (s.length >= 4) current.Ks = new Vector3(float(s[1]), float(s[2]), float(s[3]));
            } else if (current != null && line.startsWith("Ns ")) {
                if (s.length >= 2) current.Ns = float(s[1]);
            } else if (current != null && line.startsWith("d ")) {
                if (s.length >= 2) current.d = float(s[1]);
            } else if (current != null && line.startsWith("Tr ")) {
                if (s.length >= 2) current.Tr = float(s[1]);
            } else if (current != null && line.startsWith("illum ")) {
                if (s.length >= 2) current.illum = int(s[1]);
            }
        }

        println("[Mesh] loaded mtl: " + mtlPath + ", material count = " + mtlMaterials.size());
    }

    //========================
    // Texture loading (only map_Ka)
    //========================
    private void loadTextureKaMaps() {
        textureKaMap.clear();

        if (mtlMaterials == null || mtlMaterials.size() == 0) {
            return;
        }

        for (String materialName : mtlMaterials.keySet()) {
            MtlMaterial m = mtlMaterials.get(materialName);
            if (m == null) continue;
            if (m.mapKa == null || m.mapKa.length() == 0) continue;

            Texture tex = loadTextureByRelativePath(m.mapKa);
            if (tex != null) {
                textureKaMap.put(materialName, tex);
                println("[Mesh] loaded map_Ka texture: material = " + materialName + ", file = " + m.mapKa);
            } else {
                println("[Mesh] failed to load map_Ka texture: material = " + materialName + ", file = " + m.mapKa);
            }
        }
    }

    private Texture loadTextureByRelativePath(String fileName) {
        if (fileName == null || fileName.trim().length() == 0) {
            return null;
        }

        String texPath = buildSiblingPath(objBasePath, fileName);

        try {
            return new Texture(texPath);
        } catch (Exception e) {
            println("[Mesh] load texture exception: " + texPath);
            e.printStackTrace();
            return null;
        }
    }

    public Texture getTextureKa(String materialName) {
        return textureKaMap.get(materialName);
    }

    public boolean hasTextureKa(String materialName) {
        return textureKaMap.containsKey(materialName);
    }

    public void printTextureKaInfo() {
        println("map_Ka texture count = " + textureKaMap.size());
        for (String key : textureKaMap.keySet()) {
            println("material = " + key + ", has map_Ka texture");
        }
    }

    //========================
    // MTL query
    //========================
    public MtlMaterial getMtlMaterial(String materialName) {
        return mtlMaterials.get(materialName);
    }

    public boolean hasMtlMaterial(String materialName) {
        return mtlMaterials.containsKey(materialName);
    }

    public void printMtlInfo() {
        println("mtllib = " + mtllibName);
        println("mtl material count = " + mtlMaterials.size());
        for (String key : mtlMaterials.keySet()) {
            MtlMaterial m = mtlMaterials.get(key);
            println("material = " + key + ", map_Ka = " + m.mapKa);
        }
    }

    private int parseObjIndex(String s, int size) {
        int idx = int(s);

        if (idx > 0) return idx - 1;    // OBJ 1-based
        if (idx < 0) return size + idx; // relative index
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
        if (ia.v >= sourceVerts.size() || ib.v >= sourceVerts.size() || ic.v >= sourceVerts.size()) return;

        Vector3[] vs = new Vector3[] {
            sourceVerts.get(ia.v),
            sourceVerts.get(ib.v),
            sourceVerts.get(ic.v)
        };

        int[] vertexIndices = new int[] { ia.v, ib.v, ic.v };

        Vector3 faceNormal = Vector3.cross(
            vs[1].sub(vs[0]),
            vs[2].sub(vs[0])
        ).unit_vector();

        Vector3[] ns = new Vector3[] {
            safeGet(sourceNormals, ia.vn, faceNormal),
            safeGet(sourceNormals, ib.vn, faceNormal),
            safeGet(sourceNormals, ic.vn, faceNormal)
        };

        Vector3 defaultUV = new Vector3(0, 0, 0);
        Vector3[] us = new Vector3[] {
            safeGet(sourceUVs, ia.vt, defaultUV),
            safeGet(sourceUVs, ib.vt, defaultUV),
            safeGet(sourceUVs, ic.vt, defaultUV)
        };

        Triangle tri = new Triangle(vs, us, ns, vertexIndices);
        tri.materialName = currentMaterialName;
        addTriangle(tri);
    }

    //========================
    // Export all triangles
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
    // Export single submesh
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
    // Shared export implementation
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
                Vector3 n = (tri.normals != null && tri.normals[j] != null)
                    ? tri.normals[j]
                    : new Vector3(0, 1, 0);

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
                Vector3 t = (tri.tangents != null && tri.tangents[j] != null)
                    ? tri.tangents[j]
                    : new Vector3(1, 0, 0);

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
                Vector3 uv = (tri.uvs != null && tri.uvs[j] != null)
                    ? tri.uvs[j]
                    : new Vector3(0, 0, 0);

                v[i * 6 + j * 2 + 0] = uv.x;
                v[i * 6 + j * 2 + 1] = uv.y;
            }
        }
        return v;
    }

    //========================
    // Normal / tangent
    //========================
    void reCaculateNormal() {
        if (sourceVerts == null || sourceVerts.size() == 0) return;

        Vector3[] smoothNormals = new Vector3[sourceVerts.size()];
        for (int i = 0; i < smoothNormals.length; i++) {
            smoothNormals[i] = new Vector3();
        }

        for (int i = 0; i < triangles.size(); i++) {
            Triangle tri = triangles.get(i);
            Vector3 n = Vector3.cross(
                tri.verts[1].sub(tri.verts[0]),
                tri.verts[2].sub(tri.verts[0])
            );

            for (int j = 0; j < 3; j++) {
                int idx = tri.vertexIndices[j];
                if (idx >= 0 && idx < smoothNormals.length) {
                    smoothNormals[idx] = smoothNormals[idx].add(n);
                }
            }
        }

        for (int i = 0; i < triangles.size(); i++) {
            Triangle tri = triangles.get(i);
            for (int j = 0; j < 3; j++) {
                int idx = tri.vertexIndices[j];
                if (idx >= 0 && idx < smoothNormals.length) {
                    tri.normals[j] = smoothNormals[idx].unit_vector();
                }
            }
            tri.calculateTangent();
        }
    }

    void releaseSourceData() {
        if (sourceVerts != null) sourceVerts.clear();
        if (sourceUVs != null) sourceUVs.clear();
        if (sourceNormals != null) sourceNormals.clear();

        sourceVerts = null;
        sourceUVs = null;
        sourceNormals = null;
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
