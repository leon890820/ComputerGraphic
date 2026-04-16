class SubMesh {
    String materialName;
    ArrayList<Triangle> triangles = new ArrayList<Triangle>();
    
    Texture textureKa;

    SubMesh(String materialName) {
        this.materialName = materialName;
    }

    float[] getTrianglePosition() {
        return exportTriangleVectors(3, new TriangleVectorGetter() {
            @Override
            public Vector3 get(Triangle tri, int vertexIndex) {
                return tri.verts[vertexIndex];
            }
        });
    }

    float[] getTriangleNormal() {
        return exportTriangleVectors(3, new TriangleVectorGetter() {
            @Override
            public Vector3 get(Triangle tri, int vertexIndex) {
                if (tri.normals != null && tri.normals[vertexIndex] != null) {
                    return tri.normals[vertexIndex];
                }
                return new Vector3(0, 1, 0);
            }
        });
    }

    float[] getTriangleTangent() {
        return exportTriangleVectors(3, new TriangleVectorGetter() {
            @Override
            public Vector3 get(Triangle tri, int vertexIndex) {
                if (tri.tangents != null && tri.tangents[vertexIndex] != null) {
                    return tri.tangents[vertexIndex];
                }
                return new Vector3(1, 0, 0);
            }
        });
    }

    float[] getTriangleUV() {
        return exportTriangleVectors(2, new TriangleVectorGetter() {
            @Override
            public Vector3 get(Triangle tri, int vertexIndex) {
                if (tri.uvs != null && tri.uvs[vertexIndex] != null) {
                    return tri.uvs[vertexIndex];
                }
                return new Vector3(0, 0, 0);
            }
        });
    }

    private float[] exportTriangleVectors(int componentCount, TriangleVectorGetter getter) {
        float[] out = new float[triangles.size() * 3 * componentCount];

        for (int i = 0; i < triangles.size(); i++) {
            Triangle tri = triangles.get(i);

            for (int j = 0; j < 3; j++) {
                Vector3 value = getter.get(tri, j);
                if (value == null) {
                    value = new Vector3(0, 0, 0);
                }

                int base = i * 3 * componentCount + j * componentCount;
                out[base + 0] = value.x;
                out[base + 1] = value.y;

                if (componentCount >= 3) {
                    out[base + 2] = value.z;
                }
            }
        }

        return out;
    }

    @Override
    public String toString() {
        return "SubMesh(material=" + materialName + ", triangles=" + triangles.size() + ")";
    }
}
