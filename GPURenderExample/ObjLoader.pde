class ObjLoader {

    private class FaceIndex {
        int v = -1;
        int vt = -1;
        int vn = -1;
    }

    ArrayList<Vector3> sourceVerts = new ArrayList<Vector3>();
    ArrayList<Vector3> sourceUVs = new ArrayList<Vector3>();
    ArrayList<Vector3> sourceNormals = new ArrayList<Vector3>();

    String currentMaterialName = "default";
    String objBasePath = null;

    Mesh mesh;

    public Mesh load(String fname) {
        mesh = new Mesh();
        objBasePath = fname;
        currentMaterialName = "default";

        String[] fin = loadStrings(fname + ".obj");
        if (fin == null) {
            println("[ObjLoader] OBJ load failed: " + fname + ".obj");
            return mesh;
        }

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
                currentMaterialName = normalizeMaterialName(line.substring(7).trim());
            } else if (line.startsWith("f ")) {
                parseFace(s);
            } else if (line.startsWith("mtllib ")) {
                mesh.mtllibName = line.substring(7).trim();
                loadMtlFile(fname, mesh.mtllibName);
            }
        }

        mesh.reCaculateNormal();
        releaseSourceData();
        assignTexturesToSubMeshes();

        return mesh;
    }

    private String normalizeMaterialName(String materialName) {
        if (materialName == null || materialName.trim().length() == 0) {
            return "default";
        }
        return materialName.trim();
    }

    private void parseFace(String[] s) {
        if (s.length < 4) return;

        FaceIndex[] face = new FaceIndex[s.length - 1];
        for (int i = 1; i < s.length; i++) {
            face[i - 1] = parseFaceVertex(s[i]);
        }

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
        mesh.addTriangle(currentMaterialName, tri);
    }

    private int parseObjIndex(String s, int size) {
        int idx = int(s);

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
            println("[ObjLoader] loadMtlFile failed: " + mtlPath);
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
                mesh.mtlMaterials.put(name, current);
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

        println("[ObjLoader] loaded mtl: " + mtlPath + ", material count = " + mesh.mtlMaterials.size());
    }

    private void assignTexturesToSubMeshes() {
        if (mesh.subMeshes == null || mesh.subMeshes.size() == 0) return;
        if (mesh.mtlMaterials == null || mesh.mtlMaterials.size() == 0) return;

        for (String name : mesh.subMeshes.keySet()) {
            SubMesh sub = mesh.subMeshes.get(name);
            MtlMaterial m = mesh.mtlMaterials.get(name);

            if (sub == null || m == null) continue;

            if (m.mapKa != null && m.mapKa.trim().length() > 0) {
                Texture tex = loadTextureByRelativePath(m.mapKa);
                sub.textureKa = tex;

                if (tex != null) {
                    println("[ObjLoader] assigned map_Ka texture to submesh: material = " + name + ", file = " + m.mapKa);
                } else {
                    println("[ObjLoader] failed assigning map_Ka texture to submesh: material = " + name + ", file = " + m.mapKa);
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
            println("[ObjLoader] load texture exception: " + texPath);
            e.printStackTrace();
            return null;
        }
    }

    private void releaseSourceData() {
        if (sourceVerts != null) sourceVerts.clear();
        if (sourceUVs != null) sourceUVs.clear();
        if (sourceNormals != null) sourceNormals.clear();

        sourceVerts = null;
        sourceUVs = null;
        sourceNormals = null;
    }
}
