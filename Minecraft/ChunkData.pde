public static class VoxelData {
    static int chunkWidth = 32;
    static int chunkHeight = 256;
    
    public static int textureSizeInBlock = 4;
    public static int viewSize = 5;

    public static Vector3[] voxelVertors = new Vector3[]{
        new Vector3(0.0f, 0.0f, 0.0f),
        new Vector3(1.0f, 0.0f, 0.0f),
        new Vector3(1.0f, 1.0f, 0.0f),
        new Vector3(0.0f, 1.0f, 0.0f),
        new Vector3(0.0f, 0.0f, 1.0f),
        new Vector3(1.0f, 0.0f, 1.0f),
        new Vector3(1.0f, 1.0f, 1.0f),
        new Vector3(0.0f, 1.0f, 1.0f)
    };

    // Left //Right // Up // Botton // Back // Front
    public static Vector3[] faceCheck = new Vector3[]{
        new Vector3(0.0f, 0.0f, -1.0f),
        new Vector3(0.0f, 0.0f, 1.0f),
        new Vector3(0.0f, 1.0f, 0.0f),
        new Vector3(0.0f, -1.0f, 0.0f),
        new Vector3(-1.0f, 0.0f, 0.0f),
        new Vector3(1.0f, 0.0f, 0.0f)
    };

    public static int[][] voxelTriangles = new int[][]{
        {0, 3, 1, 2 },
        {5, 6, 4, 7 },
        {3, 7, 2, 6 },
        {1, 5, 0, 4 },
        {4, 7, 0, 3 },
        {1, 2, 5, 6 }
    };
}
