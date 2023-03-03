String[] input_asc;
String[] output_asc;
String name = "skull";
void setup(){
  input_asc = loadStrings(name+".asc");
  StringList output = new StringList();
  String[] c=mySplit(input_asc[0],' ');
  for(int i=1;i<1+int(c[0]);i+=1){
    String[] s = mySplit(input_asc[i],' ');
    String ss = "v ";
    for(int j=0;j<s.length;j+=1){
      ss+=s[j]+" ";
    }
    output.append(ss);
  }
  
  for(int i=1+int(c[0]);i<1+int(c[0])+int(c[1]);i+=1){
    String[] s = mySplit(input_asc[i],' ');
    String ss = "f ";
    for(int j=1;j<s.length;j+=1){
      ss+=s[j]+" ";
    }
    output.append(ss);
  }
  
  saveStrings(name+".obj",output.values());


}

String[] mySplit(String input,char sp){
  StringList result =new StringList();
  int s = 0,e = 0;
  for(int i=0;i<input.length();i+=1){
    if(input.charAt(i)==sp){
      if(i+1==input.length()) continue;
      if(input.charAt(i+1)!=sp){
        s = i+1;
      }
      continue;
    }
    
    if(i+1==input.length()){
      e = i;
      result.append(input.substring(s,e+1));
      continue;
    }
    
    if(input.charAt(i+1)==sp){
      e = i;
      result.append(input.substring(s,e+1));
    } 
    
      
  }
  
  return result.values();

}
