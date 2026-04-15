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

        // 改成直接把 texture 指派到 submesh
        assignTexturesToSubMeshes();
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
    // Texture loading (map_Ka -> SubMesh.textureKa)
    //========================
    private void assignTexturesToSubMeshes() {
        if (subMeshes == null || subMeshes.size() == 0) return;
        if (mtlMaterials == null || mtlMaterials.size() == 0) return;

        for (String name : subMeshes.keySet()) {
            SubMesh sub = subMeshes.get(name);
            MtlMaterial m = mtlMaterials.get(name);

            if (sub == null || m == null) continue;

            if (m.mapKa != null && m.mapKa.trim().length() > 0) {
                Texture tex = loadTextureByRelativePath(m.mapKa);
                sub.textureKa = tex;

                if (tex != null) {
                    println("[Mesh] assigned map_Ka texture to submesh: material = " + name + ", file = " + m.mapKa);
                } else {
                    println("[Mesh] failed assigning map_Ka texture to submesh: material = " + name + ", file = " + m.mapKa);
                }
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

    public void printTextureKaInfo() {
        for (String key : subMeshes.keySet()) {
            SubMesh sub = subMeshes.get(key);
            boolean hasTex = sub != null && sub.textureKa != null && sub.textureKa.isUploaded();
            println("material = " + key + ", has map_Ka texture = " + hasTex);
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
}
