public class GLTFLoader{
    public GLTFLoader(String fname) {
        JSONObject GLTFData = loadJSONObject(fname);
        int scene = GLTFData.getInt("scene");
        JSONObject scenes = GLTFData.getJSONArray("scenes").getJSONObject(scene);
        int node = scenes.getJSONArray("nodes").getInt(0);
        int meshIndex = GLTFData.getJSONArray("nodes").getJSONObject(node).getInt("mesh");
        
        JSONObject mesh = GLTFData.getJSONArray("meshes").getJSONObject(meshIndex);
        
        JSONObject attributes = mesh.getJSONArray("primitives").getJSONObject(0).getJSONObject("attributes");
        int indices = mesh.getJSONArray("primitives").getJSONObject(0).getInt("indices");
        println(attributes);
        println(indices);
    }
}
