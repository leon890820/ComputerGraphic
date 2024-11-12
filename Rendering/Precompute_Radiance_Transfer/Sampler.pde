public class Sampler{
    ArrayList<Vector> samples = new ArrayList<Vector>();
    Matrix shValue;
    public Sampler(int n){
        for(int t=0;t<n;t+=1){
            for(int s=0;s<n;s+=1){
                float r1 = (float)Math.random();
                float r2 = (float)Math.random();
                float alpha = (t + r1)/(float)n;
                float beta = (s + r2)/(float)n;
                float phi = 2.0*PI*beta;
                float theta = acos(2.0*alpha-1.0);
                Vector spherical = new Vector(2);
                spherical.v[0] = phi; spherical.v[1] = theta;
                samples.add(spherical);
            }
        }
    }
    
    public void computeSH(int SHOrder){
        int order2 = SHOrder*SHOrder;
        int size = samples.size();
        shValue = new Matrix(size,order2);
        for(int i=0;i<size;i++){
            Vector spherical = samples.get(i);
            for(int l=0;l<SHOrder;l+=1){
                for(int m=-l;m<=l;m+=1){
                    int index = l*(l+1)+m;
                    shValue.m[i][index] = SphereHarmonic.EvalSH(l,m,spherical.v[0],spherical.v[1]);
                }
            }
        }
    }

}
