class Collider extends GameObject{
    Vector3 minB;
    Vector3 maxB;
    Vector3[] worldVertex =  new Vector3[8];
    boolean isCollide;
    ArrayList<GameObject> portalObject = new ArrayList<GameObject>();
    Collider linkPortal;
    
    public Collider(Material mat){
        minB = new Vector3(-1,-1,-1);
        maxB = new Vector3( 1, 1, 1);
        //worldVertex = getWorldSapceVertex();
        
        material = mat.setGameobject(this);
        hasProperties = new boolean[]{true,false,false,false};
        meshRenderer = new MeshRenderer(null, material,this);
    }
    
    public void logicalRun(){
        for(GameObject go : portalObject){
            Vector3 offsetFromPortal = go.transform.position.sub(transform.position);
            int portalSideOld = sign(Vector3.dot(((Player)go).previousOffsetFromPortal,forward()));
            int portalSide = sign(Vector3.dot(offsetFromPortal,forward()));
            if(portalSideOld != portalSide) {               
                go.transform.position = go.transform.position.add(linkPortal.transform.position.sub(transform.position));
            }
        }
    }
    
    public void onCollideEnter(GameObject go){
        isCollide = true;
        ((Player)go).previousOffsetFromPortal = go.transform.position.sub(transform.position);
        if(!portalObject.contains(go)) portalObject.add(go);
    }
    public void onCollideExit(GameObject go){
        isCollide = false;   
        portalObject.remove(go);
    }
    
    @Override
    public void update(){
        worldVertex = getWorldSapceVertex();
    }
    
    public Vector3[] getWorldSapceVertex(){
        Vector3[] result = new Vector3[8];
        
        result[0] = localToWorld().MulPoint(new Vector3(minB.x, minB.y, minB.z));
        result[1] = localToWorld().MulPoint(new Vector3(minB.x, minB.y, maxB.z));
        result[2] = localToWorld().MulPoint(new Vector3(maxB.x, minB.y, maxB.z));
        result[3] = localToWorld().MulPoint(new Vector3(maxB.x, minB.y, minB.z));
        result[4] = localToWorld().MulPoint(new Vector3(minB.x, maxB.y, minB.z));
        result[5] = localToWorld().MulPoint(new Vector3(minB.x, maxB.y, maxB.z));
        result[6] = localToWorld().MulPoint(new Vector3(maxB.x, maxB.y, maxB.z));
        result[7] = localToWorld().MulPoint(new Vector3(maxB.x, maxB.y, minB.z));
        
        return result;
    }
    
    @Override
    public int getNumber(){
        return 24;
    }
    
    @Override
    public float[] getTrianglePosition(){
        float[] result = new float[12*2*3];
        //1
        result[0] = minB.x;  result[3] = maxB.x;
        result[1] = minB.y;  result[4] = minB.y;
        result[2] = minB.z;  result[5] = minB.z;
        //2
        result[6] = maxB.x;  result[9]  = maxB.x;
        result[7] = minB.y;  result[10] = maxB.y;
        result[8] = minB.z;  result[11] = minB.z;
        //3
        result[12] = maxB.x;  result[15] = minB.x;
        result[13] = maxB.y;  result[16] = maxB.y;
        result[14] = minB.z;  result[17] = minB.z;
        //4
        result[18] = minB.x;  result[21] = minB.x;
        result[19] = maxB.y;  result[22] = minB.y;
        result[20] = minB.z;  result[23] = minB.z;
        
        //5
        result[24] = minB.x;  result[27] = minB.x;
        result[25] = minB.y;  result[28] = minB.y;
        result[26] = minB.z;  result[29] = maxB.z;
        //6
        result[30] = maxB.x;  result[33] = maxB.x;
        result[31] = minB.y;  result[34] = minB.y;
        result[32] = minB.z;  result[35] = maxB.z;
        //7
        result[36] = maxB.x;  result[39] = maxB.x;
        result[37] = maxB.y;  result[40] = maxB.y;
        result[38] = minB.z;  result[41] = maxB.z;
        //8
        result[42] = minB.x;  result[45] = minB.x;
        result[43] = maxB.y;  result[46] = maxB.y;
        result[44] = minB.z;  result[47] = maxB.z;
        
        //9
        result[48] = minB.x;  result[51] = maxB.x;
        result[49] = minB.y;  result[52] = minB.y;
        result[50] = maxB.z;  result[53] = maxB.z;
        //10
        result[54] = maxB.x;  result[57] = maxB.x;
        result[55] = minB.y;  result[58] = maxB.y;
        result[56] = maxB.z;  result[59] = maxB.z;
        //11
        result[60] = maxB.x;  result[63] = minB.x;
        result[61] = maxB.y;  result[64] = maxB.y;
        result[62] = maxB.z;  result[65] = maxB.z;
        //12
        result[66] = minB.x;  result[69] = minB.x;
        result[67] = maxB.y;  result[70] = minB.y;
        result[68] = maxB.z;  result[71] = maxB.z;
        
        return result;
    }
    
    
    public boolean collide(Vector3 v){
        // 1-2-6-5  +z   // 0-4-7-3  -z
        // 2-3-7-6  +x   // 0-1-5-4  -x
        // 4-5-6-7  +y   // 0-3-2-1  -y

        Vector3 Npz = Vector3.cross(worldVertex[2].sub(worldVertex[1]) , worldVertex[5].sub(worldVertex[1]));
        Vector3 Nnz = Npz.mult(-1);
        Vector3 Npx = Vector3.cross(worldVertex[3].sub(worldVertex[2]) , worldVertex[6].sub(worldVertex[2]));
        Vector3 Nnx = Npx.mult(-1);
        Vector3 Npy = Vector3.cross(worldVertex[6].sub(worldVertex[5]) , worldVertex[4].sub(worldVertex[5]));
        Vector3 Nny = Npy.mult(-1);
        
        if(Vector3.dot(v.sub(worldVertex[1]),Npz) > 0) return false;
        if(Vector3.dot(v.sub(worldVertex[0]),Nnz) > 0) return false;
        if(Vector3.dot(v.sub(worldVertex[2]),Npx) > 0) return false;
        if(Vector3.dot(v.sub(worldVertex[1]),Nnx) > 0) return false;
        if(Vector3.dot(v.sub(worldVertex[5]),Npy) > 0) return false;
        if(Vector3.dot(v.sub(worldVertex[1]),Nny) > 0) return false;
        
        return true;
    }
    
}
