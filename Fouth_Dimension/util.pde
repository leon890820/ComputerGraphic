Vector4[] Gram_Schmidt(Vector4[] input){   
    Vector4 b1,b2,b3,b4;
    b1 = input[0].normalize();
    b2 = (input[1].sub(b1.mult(Vector4.Dot(input[1],b1)))).normalize();
    b3 = (input[2].sub(b1.mult(Vector4.Dot(input[2],b1))).sub(b2.mult(Vector4.Dot(input[2],b2)))).normalize();
    b4 = (input[3].sub(b1.mult(Vector4.Dot(input[3],b1))).sub(b2.mult(Vector4.Dot(input[3],b2))).sub(b3.mult(Vector4.Dot(input[3],b3)))).normalize();
    return new Vector4[]{b1,b2,b3,b4};
}
