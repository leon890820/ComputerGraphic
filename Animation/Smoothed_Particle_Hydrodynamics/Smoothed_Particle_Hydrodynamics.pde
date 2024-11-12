int number = 10;
float delta_time = 0.0016;
float dump = 0.99;
Vector3 gravity;

Particle[] particles;

void setup() {
    size(600, 600);
    gravity = new Vector3(0,9.8,0);
    particles = new Particle[number*number];
    for (int i=0; i<number; i+=1) {
        for (int j=0; j<number; j+=1) {
           float x = map(j,0,number,1.0/3.0,2.0/3.0);
           float y = map(i,0,number,1.0/3.0,2.0/3.0);
           int index = i*number+j;
           particles[index] = new Particle(x,y);
        }
    }
}

void draw() {
    background(0);
    for(Particle p:particles){
       p.run();
    }
    
}
