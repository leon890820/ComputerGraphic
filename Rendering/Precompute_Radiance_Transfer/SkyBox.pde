public interface SphericalFunction {
    public abstract float getValue(float phi, float theta);
}

public class SkyBox {
    PImage[] sky_img;
    String[] index_path = {"posx", "negx", "posy", "negy", "posz", "negz"};
    float rotX, rotY;
    int w, h;
    int SHOrder = 5;
    int sample_time = 10;
    Sampler sampler;
    Vector3[] shCoeffs;
    Vector3[][] cubemapFaceDirections= {
        {new Vector3(0, 0, 1), new Vector3(0, -1, 0), new Vector3(1, 0, 0) }, // posx
        {new Vector3(0, 0, 1), new Vector3(0, -1, 0), new Vector3(-1, 0, 0) }, // negx
        {new Vector3(1, 0, 0), new Vector3(0, 0, 1), new Vector3(0, 1, 0) }, // posy
        {new Vector3(1, 0, 0), new Vector3(0, 0, -1), new Vector3(0, -1, 0) }, // negy
        {new Vector3(1, 0, 0), new Vector3(0, -1, 0), new Vector3(0, 0, 1) }, // posz
        {new Vector3(-1, 0, 0), new Vector3(0, -1, 0), new Vector3(0, 0, -1) }   // negz

    };

    Matrix4 rotation;
    public SkyBox(String path) {
        sky_img = new PImage[6];
        rotation = Matrix4.Identity();
        sampler = new Sampler(sample_time);
        sampler.computeSH(SHOrder);
        for (int i=0; i<sky_img.length; i++) {
            sky_img[i] = loadImage(path + "\\" + index_path[i] + ".jpg");
        }
        w = sky_img[0].width;
        h = sky_img[0].height;
        shCoeffs = precomputeSphereHarmonicParameter(SHOrder);
        if (engine.v_objects.size()>0) {
            Mesh mesh = engine.v_objects.get(0).mesh;
            ArrayList<Vector> m_TransportSHCoeffs = new ArrayList<Vector>();
            ArrayList<Matrix> matrix_TransportSHCoeffs = new ArrayList<Matrix>();
            ShadowType st= engine.v_objects.get(0).shadowType;
            for (int i=0; i<mesh.verts.size(); i+=1) {
                Vector3 n = mesh.normals.get(i);
                Vector3 p = mesh.verts.get(i);
                if (engine.v_objects.get(0).materialType == MaterialType.Diffuse) {
                    Vector cof = SphereHarmonic.ProjectFunctionDiffuse(SHOrder, (phi, theta)-> {
                        Vector3 wi = toVector(phi, theta);
                        float H = Vector3.dot(wi.unit_vector(), n.unit_vector());
                        if (st == ShadowType.NonShadowed) {
                            return H > 0 ? H : 0;
                        } else if (st == ShadowType.Shadowed) {
                            if (H>0 && !engine.intersection(p, wi.unit_vector())) return H;
                            return 0;
                        }
                        return 0;
                    }
                    , sampler);
                    m_TransportSHCoeffs.add(cof);
                } else {
                    Matrix m = SphereHarmonic.ProjectFunctionGlossy(SHOrder, (phi, theta)-> {
                        Vector3 wi = toVector(phi, theta);
                        float H = Vector3.dot(wi.unit_vector(), n.unit_vector());
                        if (st == ShadowType.NonShadowed) {
                            return H > 0 ? H : 0;
                        } else if (st == ShadowType.Shadowed) {
                            if (H>0 && !engine.intersection(p, wi.unit_vector())) return H;
                            return 0;
                        }
                        return 0;
                    }
                    , sampler);
                    matrix_TransportSHCoeffs.add(m);
                }
            }
            engine.v_objects.get(0).m_TransportSHCoeffs = m_TransportSHCoeffs;
            engine.v_objects.get(0).matrix_TransportSHCoeffs = matrix_TransportSHCoeffs;
        }
    }

    public void setRotXandY(float x, float y) {
        rotX+=y;
        rotY-=x;
        rotation = Matrix4.RotY(rotY).mult(Matrix4.RotX(rotX));
    }

    public Vector3[] precomputeSphereHarmonicParameter(int shOrder) {
        Vector3[] shParameter = new Vector3[shOrder*shOrder];
        for (int i=0; i<shParameter.length; i+=1) {
            shParameter[i] = new Vector3();
        }
        for (int i = 0; i<6; i+=1) {
            Vector3 faceDirX = cubemapFaceDirections[i][0];
            Vector3 faceDirY = cubemapFaceDirections[i][1];
            Vector3 faceDirZ = cubemapFaceDirections[i][2];
            for (int y = 0; y < h; y+=1) {
                println((float)(i*h+y)/(float)(6*h)*100+"%");
                for (int x = 0; x < w; x+=1) {
                    float u = map(x, 0, w-1, -1, 1);
                    float v = map(y, 0, h-1, 1, -1);
                    //println((float)(i*h*w+y*w+x)*100/(float)(6*h*w)+"%");
                    Vector3 dir = (faceDirX.mult(u).add(faceDirY.mult(v)).add(faceDirZ)).unit_vector();
                    int index = (h-y-1) *w + x;
                    Vector3 Le = colorToVector3(sky_img[i].pixels[index]);
                    float delta_w = calcArea(x, h-y-1);
                    for (int l=0; l<shOrder; l+=1) {
                        for (int m=-l; m<=l; m+=1) {

                            float cof = SphereHarmonic.EvalSH(l, m, dir.unit_vector());
                            int sh_index = l*(l+1)+m;
                            shParameter[sh_index] = shParameter[sh_index].add(Le.mult(cof*delta_w));
                        }
                    }
                }
            }
        }

        return shParameter;
    }

    public float calcArea(float _u, float _v) {
        float u = (2.0 * (_u + 0.5) / w) - 1.0;
        float v = (2.0 * (_v + 0.5) / h) - 1.0;

        // shift from a demi texel, mean 1.0 / size  with u and v in [-1..1]
        float invResolutionW = 1.0 / w;
        float invResolutionH = 1.0 / h;
        float x0 = u - invResolutionW;
        float y0 = v - invResolutionH;
        float x1 = u + invResolutionW;
        float y1 = v + invResolutionH;
        float angle = calcPreArea(x0, y0) - calcPreArea(x0, y1) - calcPreArea(x1, y0) + calcPreArea(x1, y1);

        return angle;
    }
    public float calcPreArea(float x, float y) {
        return atan2(x * y, sqrt(x * x + y * y + 1.0));
    }

    public color getLightColor(Vector3 p) {
        p = rotation.mult(p.getVector4()).xyz();
        float absX = abs(p.x);
        float absY = abs(p.y);
        float absZ = abs(p.z);

        boolean isXPositive = p.x > 0 ? true:false;
        boolean isYPositive = p.y > 0 ? true:false;
        boolean isZPositive = p.z > 0 ? true:false;
        float maxAxis = 0, uc = 0, vc= 0;
        int index = 0;
        if (isXPositive && absX >= absY && absX >= absZ) {
            maxAxis = absX;
            uc = -p.z;
            vc = p.y;
            index = 0;
        }
        // NEGATIVE X
        if (!isXPositive && absX >= absY && absX >= absZ) {
            maxAxis = absX;
            uc = p.z;
            vc = p.y;
            index = 1;
        }
        // POSITIVE Y
        if (isYPositive && absY >= absX && absY >= absZ) {
            maxAxis = absY;
            uc = p.x;
            vc = -p.z;
            index = 2;
        }
        // NEGATIVE Y
        if (!isYPositive && absY >= absX && absY >= absZ) {
            maxAxis = absY;
            uc = p.x;
            vc = p.z;
            index = 3;
        }
        // POSITIVE Z
        if (isZPositive && absZ >= absX && absZ >= absY) {
            maxAxis = absZ;
            uc = p.x;
            vc = p.y;
            index = 4;
        }
        // NEGATIVE Z
        if (!isZPositive && absZ >= absX && absZ >= absY) {
            maxAxis = absZ;
            uc = -p.x;
            vc = p.y;
            index = 5;
        }

        PImage img = sky_img[index];
        int u =(int) map( 0.5f * (uc / maxAxis + 1.0f), 0, 1, 0, img.width-1 );
        int v =(int) map( 0.5f * (vc / maxAxis + 1.0f), 0, 1, img.height-1, 0);

        return img.pixels[v*img.width + u];
    }
}
