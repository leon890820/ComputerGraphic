public class Shader{
    int program;
    Shader(String vert, String frag){
        String[] vertSrc = loadStrings(vert);
        String[] fragSrc = loadStrings(frag);
        int vs = compileShader(vertSrc, gl3.GL_VERTEX_SHADER);
        int fs = compileShader(fragSrc, gl3.GL_FRAGMENT_SHADER);
        program = linkShader(vs, fs);
    }
    
    int compileShader(String[] shaderSource, int shaderType){
        int shader = gl3.glCreateShader(shaderType);
        gl3.glShaderSource(shader, 1, shaderSource, null);
        gl3.glCompileShader(shader);

        return shader;
    }
    
    int linkShader(int vs, int fs){
        int prog = gl3.glCreateProgram();
        gl3.glAttachShader(prog, vs);
        gl3.glAttachShader(prog, fs);
        gl3.glLinkProgram(prog);
        
        return prog;
    }
    
    void bind(){
        gl3.glUseProgram(program);
    }
    
    void unbind(){
        gl3.glUseProgram(0);
    }

}
