
PImage img;

void setup()
{
  size(1024,512);
                    
  Builder builder = new Builder();
  //builder.init(256,256,"Marker Felt", 18);
  //builder.init(256,256,"VeniceClassic.ttf", 16);
  //builder.init(128,128,"fayet_scripts.otf", 32);
  builder.init(256,256,"VeniceClassic-19.vlw", 19);
  
  builder.smooth = true;
  builder.charPadding = 10;
  builder.charSpacing = 2;
  //builder.textColor = color(255,0,0);
  
 builder.build("abcdefghijklmnopqrstuvwxyz1234567890!ABCDEFGHIJKLMNOPQRSTUVWXYZ ");
 // builder.buildInMatch("[a-zA-Z0-9`~!@#$%^&*()_+-={}/[/];':\"<>]");
  //builder.buildAllCharacters();
  
  builder.saveFNT("veniceClassic-19");
  
  img = builder.renderAllPages(512,512,true);
  //img = builder.renderCharMap(1024,512);
}

void draw()
{
  background(50,50,50);
  noSmooth();
  scale(2,2);
  image(img, 0, 0);
}

