public float calcDensity(Vector3 r,float h){
    float density = 0.0;
    float mass = 1.0;
    for(int i = 0; i < molecular.length;i++){
        float rl2 = r.sub(molecular[i].pos).magSq();

        if(sqrt(rl2) > h) continue;
        density += pow(h*h - rl2,3);
    }
    
    density *= mass * 4 / (PI * pow(h,8));
    return density;
}

public float calcDensity(int molecularIndex,float h){
    float density = 0.0;
    float mass = 1.0;
     Liquid m = molecular[molecularIndex];
    for(int i = 0; i < molecular.length;i++){
        if( i == molecularIndex) continue;
        float rl2 = m.pos.sub(molecular[i].pos).magSq();

        if(sqrt(rl2) > h) continue;
        density += pow(h*h - rl2,3);
    }
    
    density *= mass * 4 / (PI * pow(h,8));
    return density;
}

public float idealGas(float rho){
    return K * (rho - rho0);
}


public Vector3 calcPressure(int molecularIndex,float h){
    Vector3 pressure = new Vector3();
    Liquid m = molecular[molecularIndex];
    float p = idealGas(m.density);
    float mass = 1.0;
    for(int j = 0; j < molecular.length; j++){
        if(molecularIndex == j) continue;
        float rl2 = m.pos.sub(molecular[j].pos).magSq();
        float r = sqrt(rl2);
        if(sqrt(rl2) > h) continue;
        float pj = idealGas(molecular[j].density);
        float h2 = (h - r)*(h - r);
        if(m.density * molecular[j].density == 0) continue;
        Vector3 pp = m.pos.sub(molecular[j].pos).unit_vector().mult(h2 * (p + pj) / (2.0 * m.density * molecular[j].density));
        pressure = pressure.add(pp);
    }
    //println(pressure);
    pressure = pressure.mult(mass * 30.0 / (PI * pow(h,5)));
    
    return pressure;
}

public Vector3 calcPressure(Vector3 r,float h){
    Vector3 pressure = new Vector3();

    float p = calcDensity(r,h);
    float mass = 1.0;
    for(int j = 0; j < molecular.length; j++){
        
        float rl2 = r.sub(molecular[j].pos).magSq();
        float rr = sqrt(rl2);
        if(sqrt(rl2) > h) continue;
        float pj = idealGas(molecular[j].density);
        float h2 = (h - rr)*(h - rr);
        Vector3 pp = r.sub(molecular[j].pos).unit_vector().mult(h2 * (p + pj) * (1.0 / (2.0 * p * molecular[j].density)));
        pressure = pressure.add(pp);
    }
    pressure = pressure.mult(mass * 30.0 / (PI * pow(h,5)));
    
    return pressure;
}
