
class Builder
{
  // options
  boolean smooth = false;
  boolean shadow = false;
  int shadowOffset = 2;
  int charPadding = 4;
  int charSpacing = 0;
  int textColor = color(255,255,255);
  int outlineColor = color(255,0,0);
  float outlineWidth = 1.0;
  int charTempImageHeight = 100;
  int charTempImageWidth = 100;
  
  // private
  int maxTop = 0;
  
  String fontFace;
  int fontSize;
  int lineHeight;
  int spaceWidth;
  int base;
  
  Packer packer;
  Packer.Node [] nodes;
  PFont font;
  PImage [] images;
  ImageRect [] rects;

  int width;
  int height;
  
  Builder nextPage;
  
  class ImageRect
  {
    int x;
    int y;
    int w;
    int h;
    int charId;
  }
  
  ImageRect getMinimumRect(PImage img)
  {
    ImageRect imgRect = new ImageRect();
    img.loadPixels();
    
    int top = -1;
    int bottom = -1;
    int left = -1;
    int right = -1;
    
    for(int y=0;y<img.height-1;y++) {
      for(int x=0;x<img.width-1;x++) {
       int clr = img.pixels[y * img.width + x];
       int r = (int)red(clr);
       int g = (int)green(clr);
       int b = (int)blue(clr);
       
       if ((r + g + b) != 0) {
         if (top == -1 || y < top)
           top = y;
         if (bottom == -1 || y > bottom)
           bottom = y;
         if (left == -1 || x < left)
           left = x;
         if (right == -1 || x > right)
           right = x;
       }
      }
    }
    
    if (top == -1) {
      top = 0;
    }
    if (bottom == -1) {
      bottom = top+1;
    }
    if (left == -1) {
      left = 0;
    }
    if (right == -1) {
      right = left + 1;
    }
    
    if (charPadding < 2)
      charPadding = 2;
    
    imgRect.x = left;
    imgRect.y = top;
    imgRect.w = right - left + charPadding;
    imgRect.h = bottom - top + charPadding;
    
    if (imgRect.h > lineHeight)
      lineHeight = imgRect.h;
    if (maxTop == 0 || (maxTop > imgRect.y && imgRect.y != 0))
      maxTop = imgRect.y;
      
    return imgRect;
  }
  
  void init(int w, int h, String fontFile, int size) {
    
    if (fontFile != null) {
      if (fontFile.indexOf(".vlw") > 0)
        font = loadFont(fontFile);
      else
        font = createFont(fontFile, size);
    }
      
    fontFace = fontFile;
    fontSize = size;
    
    packer = new Packer();
    nodes = new Packer.Node[0];       
    nextPage = null; 
    width = w;
    height = h;
    
    lineHeight = 0;
  }
  
  void fit()
  {
    packer.fit(nodes);
    
    nextPage = new Builder();
    nextPage.init(width, height, null, 0);
    nextPage.font = font;
    nextPage.images = images;
    nextPage.rects = rects;

    nextPage.packer.init(width, height);
   ArrayList<Packer.Node> nextPageNodes = new ArrayList<Packer.Node>();
    for(int i=0;i<nodes.length;i++) {
          Packer.Node b = nodes[i];
          if (b == null)
            break;
          Packer.Node n = b.fit;
          if (n == null) {
            Packer.Node nn = nextPage.packer.createNode(0,0,b.w,b.h);
            nn.id = b.id;
            nextPageNodes.add(nn);
          }      
    }
    
    nextPage.nodes = new Packer.Node[nextPageNodes.size()];
    for(int i=0;i<nextPage.nodes.length;i++) {
      nextPage.nodes[i] = nextPageNodes.get(i);
    }
    
    if (nextPage.nodes.length > 0)
      nextPage.fit();
    else
      nextPage = null;
  }
  
  void build(String s)
  {    
    packer.init(width, height);
    
    int th = (int)textAscent();
    int td = (int)textDescent();
    spaceWidth = (int)textWidth(" ");
    
    base = td;
    
    images = new PImage[s.length()];
    rects = new ImageRect[s.length()];

    int cw = charTempImageWidth;
    int ch = charTempImageHeight;    
    PGraphics ig = createGraphics(cw,ch, JAVA2D);
      
    for(int i=0;i<s.length();i++) {
      char c = s.charAt(i);

      ig.beginDraw();
      ig.textFont(font);
      
      if (smooth)
        ig.smooth();
      else
        ig.noSmooth();  
      
      if (shadow) {
        ig.fill(color(0,0,0,200));
        ig.text(c, ig.width/2 - cw/2 + shadowOffset, ig.height/2 + td - th/2 + shadowOffset);
      }

      ig.fill(textColor);
      ig.text(c, ig.width/2 - cw/2, ig.height/2 + td - th/2);
      
      ig.endDraw();
      
      ImageRect rr = getMinimumRect(ig);
      rr.charId = (int)c;
      rects[i] = rr;
      
      if (rr.w < 1)
        rr.w = 1;
      if (rr.h < 1)
        rr.h = 1;
        
      PGraphics ig2 = createGraphics(rr.w, rr.h, JAVA2D);
      ig2.beginDraw();
      ig2.image(ig, -rr.x + charPadding/2, -rr.y + charPadding/2);
      ig2.endDraw();

      images[i] = ig2;
    
    
      ig.clear();
    }
    
    nodes = new Packer.Node[images.length];
    for(int i=0; i<images.length; i++) {
      PImage img = images[i];
      ImageRect rect = rects[i];
      Packer.Node node = packer.createNode(0, 0, img.width, img.height);
      node.id = i;
      nodes[i] = node;
    }
   
     fit();
  }
  
  void buildInMatch(String expression)
  {
    String s = new String();
    for(int i=0;i<255;i++) {
      s += (char)i;
    }
    
    String sm = new String();
    String [][] m = matchAll(s, expression);
    for(int i=0; i<m.length; i++) {
       sm += m[i][0]; 
    }
    build(sm);
  }
  
  void buildAllCharacters()
  {
    String s = new String();
    for(int i=0;i<255;i++) {
      s += (char)i;
    }
    build(s);
  }
  
  PImage render(boolean drawOutline)
  {
    PGraphics pg = createGraphics(width, height);
    
    pg.beginDraw();
    pg.noFill();
    
    if (smooth)
      pg.smooth();
    else
      pg.noSmooth();
        
    for(int i=0;i<nodes.length;i++) {
      Packer.Node b = nodes[i];
      if (b == null)
        continue;
      Packer.Node n = b.fit;
      if (n == null)
        continue;
      
      ImageRect rect = rects[b.id];
      
      if (drawOutline) {
        pg.stroke(255,255,0);
        pg.rect(n.x, n.y, b.w-1, b.h-1);
      }
      
      PImage img = images[b.id];
      int cx = img.width/2;
      int cy = img.height/2;

      pg.image(img, n.x + b.w/2 - cx, n.y + b.h/2 - cy);
    }
    
    pg.endDraw();
    
    return pg;
  }
  
  PGraphics renderAllPages(int w, int h, boolean drawoutline)
  {
    PGraphics img = createGraphics(w, h, JAVA2D);
    
    img.beginDraw();
    
    Builder r = this;
    int xx = 0;
    int yy = 0;
    int idx = 1;
    while(r != null) {
      println("rendering page " + idx++);
      PImage page = r.render(drawoutline);
      img.noFill();
      img.rect(xx,yy,page.width,page.height);
      img.image(page, xx, yy);
      xx += page.width;
      if (xx + page.width > w) {
        xx = 0;
        yy += page.height;
        if (yy > h)
          break;
      }
      page = null;
      r = r.nextPage;
    }
    img.endDraw();
    return img;
  }
  
  PGraphics renderCharMap(int w, int h)
  {
    PGraphics img = createGraphics(w, h, JAVA2D);
    img.beginDraw();
    
    int padd = 20;
    
    int xx = 0;
    int yy = 0;
    int minHeight = 0;
    for(int i=0;i<images.length;i++) {
      PImage charImage = images[i];
      ImageRect rect = rects[i];
      
      if (minHeight < rect.h)
        minHeight = rect.h;

      xx += rect.w + padd + 8;
      if (xx + rect.w + padd + 8> w) {
        xx = 0;
        yy += minHeight + 5;
        minHeight = 0;
        if (yy > h)
          break;
      }
      
    img.noFill();
    img.stroke(255,255,0);
      
      img.rect(xx,yy,rect.w+padd-1,rect.h);
      img.image(charImage, xx, yy);
      
      img.fill(255,0,0);
      img.text("" + (char)rect.charId, xx + rect.w + 2, yy + 15);
    }
    
    img.endDraw();
    return img;
    
  }

  class FontChar
  {
    int id=32;
    int x=0;
    int y=0;
    int width=0;
    int height=0;
    int xoffset=0;
    int yoffset=0;
    int xadvance=0;
    int page=0;
    int chnl=0;
  }
  
  void saveFNT(String fontName)
  {
    String s = new String();
    int charCount = 0;
    
     int page = 0;
     Builder r = this;
     while(r != null) {
       
      String fname = fontName;
      if (page > 0)
        fname += page;
      fname += ".png";
      
      page++; 
      
      int spaceAdvance = 0;
      
      for(int i=0;i<r.nodes.length;i++) {
        Packer.Node b = r.nodes[i];
        if (b == null)
          continue;
        Packer.Node n = b.fit;
        if (n == null)
          continue;
          
        ImageRect rect = rects[b.id];
        
        FontChar f = new FontChar();
        f.id = rect.charId;
        f.x=n.x+1;
        f.y=n.y+1;
        f.width=b.w-2;
        f.height=b.h-2;
        f.xoffset= 0;
        f.yoffset= lineHeight/2 - (maxTop - rect.y);
        f.xadvance=b.w - charPadding + charSpacing;
        f.page=page-1;
        f.chnl=0;
        
        s += "char id=" + f.id + " x=" + f.x + " y=" + f.y + " width=" + f.width + " height=" + f.height;
        s +=" xoffset=" + f.xoffset + " yoffset=" + (-(lineHeight/2) + f.yoffset) + " xadvance=" + f.xadvance + " page=" + f.page + " chnl=" + f.chnl + "\n";
        charCount++;
      } 
      
      // space
      s += "char id=32 x=0 y=0 width=1 height=1";
      s +=" xoffset=0 yoffset=0 xadvance=" + spaceWidth + " page=0 chnl=0\n";
      charCount++;
      
      PImage img = r.render(false);
      img.save(fname);
      
      r = r.nextPage;
     }
     
    String header = "info face=\"" + fontFace + "\" size=" + fontSize + " bold=0 italic=0 charset=\"\" unicode=0 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=0\n";
    header += "common lineHeight=" + lineHeight + " base=" + (lineHeight-base) + " scaleW=" + width + " scaleH=" + height + " pages=" + page + " packed=0\n";
    String sIdx = "";
    for(int i=0;i<page; i++) {
      String fname = fontName + sIdx + ".png";
      if (i > 0)
        header += "\n";
      header += "page id=" + i + " file=\"" + fname + "\"";
      sIdx = "" + (i+1);
    }
    
    String cc = "chars count=" + charCount;
    String [] list = {header, cc, s};
    saveStrings(fontName + ".fnt", list); 

  }
}
