public class BoundingVolumeHierarchy{
    BoundingVolumeHierarchy childA;
    BoundingVolumeHierarchy childB;
    Vector3 minB = new Vector3(1.0/0.0);
    Vector3 maxB = new Vector3(-1.0/0.0);
    ArrayList<Triangle> triangles = new ArrayList<Triangle>();

    
    BoundingVolumeHierarchy(ArrayList<Triangle> triangles,int depth){
        if(triangles.size() == 0){
            minB.set(0,0,0);
            maxB.set(0,0,0);
            return;
        }
        //BoundingBox
        for(int i = 0; i < triangles.size(); i++){
            Triangle tri = triangles.get(i);
            for(int j = 0; j < 3; j++){
                minB.set(min(minB.x, tri.verts[j].x), min(minB.y, tri.verts[j].y), min(minB.z, tri.verts[j].z));
                maxB.set(max(maxB.x, tri.verts[j].x), max(maxB.y, tri.verts[j].y), max(maxB.z, tri.verts[j].z));
            }            
        }
        if(depth == 0 || triangles.size() <= 5){
            this.triangles = triangles;
            return;
        }

        Vector3 size = maxB.sub(minB);
        Vector3 boundcenter = (maxB.add(minB)).mult(0.5);
        Vector3 triangleCenter = getAverageTriangleCenter(triangles);
        int a = size.x > size.y && size.x > size.z ? 0 : size.y > size.z? 1 :2 ;
        println(a);
        ArrayList<Triangle> triA = new ArrayList<Triangle>();
        ArrayList<Triangle> triB = new ArrayList<Triangle>();
        for(int i = 0; i < triangles.size(); i++){
            Vector3 center = triangles.get(i).getCenter();
            Triangle tri = triangles.get(i);
            if(center.xyz(a) < triangleCenter.xyz(a)) triA.add(tri);
            else triB.add(tri);        
        }
        childA = new BoundingVolumeHierarchy(triA , depth - 1);
        childB = new BoundingVolumeHierarchy(triB , depth - 1);
    }


    void calcAverage(BVHRecord record,int depth){
        if(childA == null && childB == null) {
            record.maxDepth = max(record.maxDepth,depth);
            record.totalBVH++;
            record.totalTriangles += triangles.size();
            record.maxTriglesCount = max(record.maxTriglesCount, triangles.size());
            return;
        }        
        childA.calcAverage(record, depth + 1);
        childB.calcAverage(record, depth + 1);
        
    }
}


public class BVHRecord{
    int maxDepth;
    int totalTriangles;
    int totalBVH;
    float averageTriangles;
    int maxTriglesCount;
    
    void calcAverageTriangles(){
        averageTriangles = (float)totalTriangles / (float)totalBVH;
    }
    
    @Override
    public String toString(){
        return "Max Depth : " + maxDepth +"\n" 
             + "Average Triangles : " + averageTriangles + "\n"
             + "Max Trigles Count : " + maxTriglesCount;
    }
}

public class Node{
    Vector3 minB;
    Vector3 maxB;
    int triangleIndex;
    int triangleSize;
    int childAIndex;
    int childBIndex;
    
    public Node(Vector3 minB, Vector3 maxB, int ti, int ts, int cai, int cbi){
        this.minB = minB; this.maxB = maxB;
        triangleIndex = ti; triangleSize = ts;
        childAIndex = cai; childBIndex = cbi;
    }
    
    public String toString(){
        return "Min BoundingBox : " + minB +"\n" 
             + "Max BoundingBox : " + maxB +"\n" 
             + "Triangle Index : " + triangleIndex +"\n" 
             + "Triangle Size : " + triangleSize +"\n" 
             + "ChildA Index : " + childAIndex +"\n" 
             + "ChildB Index : " + childBIndex +"\n"; 
    }
    
    public float[] getNodeData(){
        float[] data = new float[]{minB.x, minB.y, minB.z, triangleIndex,
                                   maxB.x, maxB.y, maxB.z, triangleSize,
                                   childAIndex,childBIndex,0.0,0.0};
        return data;
    }
}
