public class Rule {
    int col;
    int row;
    int count;
    int max_count;
    
    ArrayList<ColorState> target;
    ArrayList<ColorState> goal;
    public Rule(int c, int r,int mc) {
        col = c;
        row = r;
        target = new ArrayList<ColorState>();
        goal = new ArrayList<ColorState>();
        max_count = mc;
    }

    public void add(ColorState t, ColorState g) {
        target.add(t);
        goal.add(g);
    }

    public boolean findCell(Cell[] cells) {
        if(max_count > 0){
            if(count == max_count) return false;
            count ++;
        }
        ArrayList<IntList> list = new ArrayList<IntList>();
        IntList index_list = new IntList();
        for (int y = 0; y < resolution; y++ ) {
            for (int x = 0; x < resolution; x++) {
                int index = y * resolution + x;
                IntList ilist = findGraphic(cells, x, y);
                if (ilist.size() != 0) {
                    list.add(ilist);
                    index_list.append(index);
                }
            }
        }
        

        if (list.size() == 0) return false;
        int i = (int)random(index_list.size());
        IntList rlist = list.get(i);
        int index = index_list.get(i);
        int rin = rlist.get((int)random(rlist.size()));
        modifyCell(cells, index, rin);
        return true;
    }

    public void modifyCell(Cell[] cells, int index, int rin) {
        for (int c = 0; c < col; c++) {
            for (int r = 0; r < row; r++) {

                Vector3 d1 = dir[rin];
                Vector3 d2 = dir[(rin+1)%4];
                                
                int x = index % resolution + (int)(d1.x * r + d2.x * c);
                int y = index / resolution + (int)(d1.y * r + d2.y * c);
                int i = y * resolution + x;
                int il = c * row + r;
                cells[i].colorState = goal.get(il);
                
            }
        }
    }

    public IntList findGraphic(Cell[] cells, int x, int y) {
        IntList result = new IntList();

        for (int i = 0; i < 4; i++) {
            boolean flag = false;
            for (int c = 0; c < col; c++) {
                for (int r = 0; r < row; r++) {
                    Vector3 d1 = dir[i];
                    Vector3 d2 = dir[(i+1)%4];
                    Vector3 p = new Vector3(x + d1.x * r + d2.x * c, y + d1.y * r + d2.y * c, 0);                   
                    if (outOfBondary(p)) {
                        flag = true;
                        break;
                    }
                    int index = (int)p.y * resolution + (int)p.x;
                    int color_index = c * row + r;
                    if (cells[index].colorState != target.get(color_index)) {
                        flag = true;
                        break;
                    }

                }
                if (flag) break;
            }
            if (!flag) result.append(i);
        }
        return result;
    }
}
