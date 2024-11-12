PVector getRGB(color c){
    int B_MASK = 255;
    int G_MASK = 255<<8; //65280
    int R_MASK = 255<<16; //16711680      
    float r = (c & R_MASK)>>16;
    float g = (c & G_MASK)>>8;
    float b = c & B_MASK;
    return new PVector(r,g,b);
}

String intToBinaryString(int in){
    String s = Integer.toBinaryString((byte)in);
    String ss = "";
    for(int i=0;i < 32 - s.length();i++){
        ss += "0";
    }
    return ss + s;    

}
