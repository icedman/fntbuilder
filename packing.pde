/*
based on http://codeincomplete.com/posts/2011/5/7/bin_packing/
*/

class Packer
{
  Node root;
  int idx;
  
  class Node
  {
    int id;
    int x;
    int y;
    int w;
    int h;
    Node fit;
    Node down;
    Node right;
    boolean used = false;
    
    int area() {
      return w * h;
    }
  }
  
  Node createNode(int x, int y, int w, int h)
  {
    Node n = new Node();
    n.id = idx++;
    n.x = x;
    n.y = y;
    n.w = w;
    n.h = h;
    n.fit = null;
    n.used = false;
    n.down = null;
    n.right = null;
    return n;
  }
  
  void init(int w, int h)
  {
    root = createNode(0, 0, w, h);
    idx = 0;
  }
  
  Node splitNode(Node n, int w, int h)
  {
    n.used = true; 
    n.down  = createNode(n.x, n.y + h, n.w, n.h - h);
    n.right = createNode(n.x + w, n.y, n.w - w, h);
    return n;
  }
  
  Node findNode(Node r, int w, int h) {
    if (r.used) {
      Node rr = findNode(r.right, w, h);
      if (rr != null)
        return  rr;
      else
        return findNode(r.down, w, h);
    } else if ((w <= r.w) && (h <= r.h)) {
      return r;
    }
    
    return null;
  }
  
  // todo -- sort largest to smallest (height)
  
  Node[] sortBlocks(Node blocks[])
  {
    for(int i=0;i<blocks.length;i++) {
     for(int j=i+1; j<blocks.length-1; j++) {
      Node n1 = blocks[i];
      Node n2 = blocks[j];
      //if (n1.area() < n2.area()) {
      if (n1.h < n2.h) {
          blocks[i] = n2;
          blocks[j] = n1;
      }
     } 
    }
    return blocks;
  }
  
  void fit(Node bk[]) {
    
    Node [] blocks = sortBlocks(bk);
    
     Node block;
    for (int n = 0; n < blocks.length; n++) {
      block = blocks[n];
      if (block == null)
            break;
      Node node = findNode(root, block.w, block.h);
      if (node != null)
        block.fit = splitNode(node, block.w, block.h);
    }
  }
}
