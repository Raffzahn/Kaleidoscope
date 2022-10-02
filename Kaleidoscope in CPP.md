A few hours after the [commented disassembly](Kaleidoscope.asm) was [linked](https://retrocomputing.stackexchange.com/a/25308/6659) on Retrocomputing.SE, [Spectre](https://retrocomputing.stackexchange.com/users/6868/spektre) posted a [C++ version](https://retrocomputing.stackexchange.com/a/25310/6659). This vrsion might be a bit more pleasant to today's programmer than Assembler, thus added here with permission:

---

Thanks to @Raffzahn commented code (in his answer) I was able to port the code into simple C++ code:

````cpp
//---------------------------------------------------------------------------
const int VRAM_xs=64,VRAM_ys=64; // resolution
BYTE VRAM[VRAM_ys][VRAM_xs];     // video ram
const DWORD pal[16]=             // color palette (VCL pf32bit format)
  {
  //00BBGGRR
  0x00000000,
  0x00000080,
  0x00008000,
  0x00008080,
  0x00800000,
  0x00800080,
  0x00808000,
  0x00808080,
  0x00000000,
  0x000000FF,
  0x0000FF00,
  0x0000FFFF,
  0x00FF0000,
  0x00FF00FF,
  0x00FFFF00,
  0x00FFFFFF,
  };
BYTE x=0,y=0,m=0;        // Kaleidoscope state
void Kaleidoscope()
  {
  const int xc=VRAM_xs>>1,yc=VRAM_ys>>1;  // center of screen for mirroring
  BYTE c,xx,yy,cc;
  // render
  for (c=0;c<32;c++)
    {
    // update position
    y+=(x>>2)&m;
    x-=(y>>2)&m;
    // render 4x mirrored pixels
    xx=x>>3;
    yy=y>>3;
    if (c&1) cc=c>>1; else cc=0;
    VRAM[yc-yy][xc-xx]=cc;
    VRAM[yc-yy][xc+xx]=cc;
    VRAM[yc+yy][xc-xx]=cc;
    VRAM[yc+yy][xc+xx]=cc;
    }
  x++; y++; m++;
  }
//---------------------------------------------------------------------------
````

You just call the `Kaleidoscope()` on each frame and then just visualize the content of `VRAM[][]` in gfx api used... In VCL I did it like this:

````cpp
void TMain::draw()
  {
  if (!_redraw) return;

  // clear buffer
  bmp->Canvas->Brush->Color=clBlack;
  bmp->Canvas->FillRect(TRect(0,0,xs,ys));

  Kaleidoscope();

  int x,y,xx,yy,xxx,yyy;
  DWORD c;
  for (yy=0,y=0;y<VRAM_ys;y++,yy+=pixel_sz)
   for (xx=0,x=0;x<VRAM_xs;x++,xx+=pixel_sz)
    {
    c=pal[VRAM[y][x]&15];
    for (yyy=yy;yyy<yy+pixel_sz;yyy++)
     for (xxx=xx;xxx<xx+pixel_sz;xxx++)
      pyx[yyy][xxx]=c;
    }

  // render backbuffer
  Main->Canvas->Draw(0,0,bmp);
  _redraw=false;
  }
````
Where `Main` is app window and `pyx[ys][xs]` is direct pixel access to backbuffer bitmap `bmp`... Also `BYTE,DWORD` types are unsigned 8 and 32 bit integers so use whatever you have at disposal in case you do not have them or typedef them ...

Here preview:

 ![Animated output](Kaleidoscope_CPP.gif)

PS I am not familiar with the Dazzler so the palette I created might be wrong and also I changed the iteration a bit (count also 0 as there where not as many black pixels as colored ones and the image tends to grow too much to my taste)...

