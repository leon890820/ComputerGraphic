public class WorleyNoiseGenerator {
    PImage noise;
    int numCell;

    WorleyNoiseGenerator(int w, int h, int num) {
        numCell = num;
        noise = new PImage(w, h, 1);

        generate();
    }

    void generate() {

        Vector3[] cell = generateCell(numCell);

        float[] distances = new float[noise.height * noise.width];

        float maxRecord =  -1.0/0.0;
        for (int i = 0; i < noise.height; i++) {
            for (int j = 0; j < noise.width; j++) {
                float sum = 1.0 / 0.0;
                Vector3 pos = new Vector3((float)j / (float)noise.width, (float)i / (float)noise.height, 0);

                for (int k = 0; k < cell.length; k++) {
                    float distance = pos.sub(cell[k]).magSq();
                    sum = min(sum, distance);
                }


                float rd = sqrt(sum);
                distances[i * noise.width + j] = rd;

                maxRecord = max(maxRecord, rd);
            }
        }

        noise.loadPixels();
        for (int i = 0; i < noise.height; i++) {
            for (int j = 0; j < noise.width; j++) {
                noise.pixels[i * noise.width + j] =  color(distances[i * noise.width + j] / maxRecord * 255);
            }
        }


        noise.updatePixels();
    }

    Vector3[] generateCell(int num) {
        Vector3[] result = new Vector3[num * num];

        for (int i = 0; i < num; i++) {
            for (int j = 0; j < num; j++) {
                Vector3 cell = (new Vector3(random(1), random(1), 0).add(new Vector3(i, j, 0))).mult(1.0 / num);
                result[i * num + j] = cell;
            }
        }

        return result;
    }
}
