class BlockCompress {
    PImage img;
    BlockCompress(PImage _img) {
        img = _img;
    }
    
    PVector getMinMaxColor(PVector xs,PVector ys){
        
        float maxr = -1.0/0.0;
        float minr =  1.0/0.0;
        int mini = 0;
        int maxi = 0;
        for(int i = (int)ys.x; i <= ys.y; i++){
            for(int j = (int)xs.x;j <= xs.y; j++){
                int index = i * img.width + j;
                PVector rgb = getRGB(img.pixels[index]);
                
                if(rgb.magSq() > maxr ){
                    maxr = rgb.magSq();
                    maxi = index;
                }
                if(rgb.magSq() < minr ){
                    minr = rgb.magSq();
                    mini = index;
                }                
            }
        }
        
        return new PVector(mini,maxi);
    }

    void compress() {
        byte[] data = new byte[img.width*img.height/2];
        if (img.width % 4 != 0 || img.height % 4 != 0) {
            println("The Image width or height is not a multiple of 4");
            return;
        }

        for (int i = 0; i < img.height/4; i++) {
            for (int j = 0; j < img.width/4; j++) {
                int bl = i*img.width/4 + j;
                PVector mm = getMinMaxColor(new PVector(j,j+3,0),new PVector(i,i+3,0));
                PVector minc = getRGB(img.pixels[(int)mm.x]);
                PVector maxc = getRGB(img.pixels[(int)mm.y]);
                String b1 = intToBinaryString((int)minc.x).substring(24,32-3) + intToBinaryString((int)minc.y).substring(24,32-2) + intToBinaryString((int)minc.z).substring(24,32-3);
                String b2 = intToBinaryString((int)maxc.x).substring(24,32-3) + intToBinaryString((int)maxc.y).substring(24,32-2) + intToBinaryString((int)maxc.z).substring(24,32-3);
                data[0 + bl] = (byte)Integer.parseInt(b1.substring(0,8), 2);
                data[1 + bl] = (byte)Integer.parseInt(b1.substring(8,16), 2);
                data[2 + bl] = (byte)Integer.parseInt(b2.substring(0,8), 2);
                data[3 + bl] = (byte)Integer.parseInt(b2.substring(8,16), 2);
                PVector c1 = PVector.mult(minc,2.0/3.0).add(PVector.mult(maxc,1.0/3.0));
                PVector c2 = PVector.mult(minc,1.0/3.0).add(PVector.mult(maxc,2.0/3.0));
                PVector[] c = new PVector[]{minc,c1,c2,maxc};
                
                String ss = "";
                
                for(int k = 0; k < 4; k++){
                    for(int l = 0; l < 4; l++){
                        int x = j * 4 + l;
                        int y = i * 4 + k;
                        int index = y * img.width + x;
                        PVector cc = getRGB(img.pixels[index]);
                        int ic = 0;
                        float minr = 1.0/0.0;
                        for(int m = 0;m<4;m++){
                            if(minr>PVector.sub(cc,c[m]).magSq()){
                                minr = PVector.sub(cc,c[m]).magSq();
                                ic = m;
                            }
                        }
                        if(ic == 0) ss+="00";
                        else if(ic == 1) ss+="01";
                        else if(ic == 2) ss+="10";
                        else if(ic == 3) ss+="11";                       
                    }
                }
                data[4 + bl] = (byte)Integer.parseInt(ss.substring(0,8), 2);
                data[5 + bl] = (byte)Integer.parseInt(ss.substring(8,16), 2);
                data[6 + bl] = (byte)Integer.parseInt(ss.substring(16,24), 2);
                data[7 + bl] = (byte)Integer.parseInt(ss.substring(24,32), 2);

            }
        }
        
        saveBytes("compress.data",data);
    }
}
