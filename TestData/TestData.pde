String s = "A";
void setup(){
  for(int i=0;i<2;i+=1){
    String r = "";
    for(int j=0;j<s.length();j+=1){
      char w = s.charAt(j);
      if(w=='A'){
        r+="B-A-B";
      }else if(w=='B'){
        r+="A+B+A";
      }else{
        r+=w;
      }
    }
    s = r;
  }
  
  StringList out=new StringList();
  for(int i=0;i<s.length();i+=1){
    char w = s.charAt(i);
    switch(w){
      case 'A':        
      case 'B':
        out.push("translate 1.0 0.0");
        out.push("line");
        break;
      case '+':
        out.push("rotate 60");
        break;
      case '-':
        out.push("rotate -60");
        break;
    }
  
  }
  
  
  
  
  saveStrings("data/Bonus.in",out.array());

}
