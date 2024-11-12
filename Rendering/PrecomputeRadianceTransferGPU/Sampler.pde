public class Sampler {
    int sample_number;
    float[][] sample;
    Vector3[] sample_rays;

    Sampler(int s, int shOrder) {
        sample_number = s;
        sample = new float[sample_number][shOrder*shOrder];
        sample_rays = new Vector3[sample_number];

        for (int i = 0; i < sample_number; i++) {
            Vector3 sample_ray = random_unit_sphere_vector();
            sample_rays[i] = sample_ray;
            
            for (int l = 0; l < shCof; l++) {
                for (int m = -l; m <= l; m++) {
                    int sh_index = l * (l + 1) + m;
                    float sh = SphereHarmonic.EvalSH(l, m, sample_ray);
                    sample[i][sh_index] = sh;
                }
            }
        }

    }
}
