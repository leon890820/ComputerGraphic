class MtlMaterial {
    String name;

    // 最常用
    String mapKd;   // diffuse texture
    String mapKa;   // ambient texture
    String mapKs;   // specular texture
    String bump;    // bump / normal map
    String mapBump; // 有些檔案會這樣寫

    // 顏色與參數
    Vector3 Ka = new Vector3(0, 0, 0);
    Vector3 Kd = new Vector3(1, 1, 1);
    Vector3 Ks = new Vector3(0, 0, 0);

    float Ns = 0.0;   // shininess
    float d = 1.0;    // dissolve / alpha
    float Tr = 0.0;   // transparency，有些檔案用這個
    int illum = 0;

    @Override
    public String toString() {
        return "MtlMaterial{name=" + name + ", mapKd=" + mapKd + "}";
    }
}
