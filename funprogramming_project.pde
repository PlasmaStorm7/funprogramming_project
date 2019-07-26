import ddf.minim.*; //<>// //<>// //<>//
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
FFT         fft;
int songLength;
float multiplication =5;
float band;
float playerRotation=0;
float v[]=new float[1027];
float vv[]=new float[1027];
float lerpAmt=0.04f;
float j=PI;
float bandMax=0;
float circle=200;
int change = 1;
boolean changeRequired = false;
float rotationChangeThreshold = 10;
float bandMedian=0;
int bands=0;
String fileName=null;
float rotateDivider=1000;
float bandsPercentage=0.8;
int bandResolution=2048;
int bandsSkipped=8;
int gain=-16;
int gainPosition=gain;
int k=0;
void setup()
{
  //size(1024, 700);
  frameRate(60);
  fullScreen();
  initializeSong();
  
  for (int i=0; i < fft.specSize(); i++) {
    v[i]=0;
    vv[i]=0;
  }
  pushMatrix();
}

void draw()
{
  background(0);
  fft.forward(player.mix);



  stroke(60, 0, 60);
  fill(60, 0, 60);
   k=0;
  for(int i=0; i < bands; i+=bandsSkipped){
    band=mapBand(fft.getBand(i))*3;
    if (band<vv[i])
      {        
       band=lerp(vv[i],band,lerpAmt);             
      } 
    vv[i]=band;
    stroke(map(band,0,0.8*height,0,255),0,map(band,0,0.8*height,255,0),40);
     rect(((width-30)/bands)*(bandsSkipped*k*2),height-21,((width-30)/bands)*(bandsSkipped*k*2)+1,height-21-band);
     k++;
     
     
  }
  bandMedian=0;
  for (int i=0; i < bands; i++) {
    bandMedian+=v[i];
  }
  bandMedian=bandMedian/bands;
  pushMatrix();
  translate(width/2, height/2-20);
  fill(0,0,0);
  noStroke();
  circle(0,0,circle*2);
  stroke(100, 0, 100);
  fill(100, 0, 100);
  rotate(j);
  if (player.isPlaying())
    rotateDivider=lerp(rotateDivider, bandMax*50, 0.01);
  j+=bandMax/rotateDivider;

  //j+=(bandMedian*change)/20000;
  //if (bandMedian > rotationChangeThreshold)
  //  changeRequired = true;
  //if (changeRequired && bandMedian < rotationChangeThreshold)
  //{
  //  change *= -1;
  //  changeRequired = false;
  //}
  bandMax=0;

  for (int i=0; i < bands; i+=bandsSkipped)
  {

    if (bandMax<fft.getBand(i))
    {
      bandMax=fft.getBand(i);
    }
    band=mapBand(fft.getBand(i));
    if (band<v[i])
    {        
      band=lerp(v[i], band, lerpAmt);
    }
    stroke(90+map(band, 0, 200, 0, 165), 0, map(i, bands, 0, 0, 255));
    rotate(playerRotation);
    rectMode(CORNERS);
    rect(0, circle, 1, circle+band);
    playerRotation=(PI/bands)*bandsSkipped;
    v[i]=band;
  }

  for (int i=bands; i>=0; i-=bandsSkipped)
  {
    band=mapBand(fft.getBand(i));
    if (band<v[i])
    {        
      band=lerp(v[i], band, lerpAmt);
    } 
    stroke(90+map(band, 0, 200, 0, 165), 0, map(i, bands, 0, 0, 255));
    rotate(playerRotation);
    rectMode(CORNERS);
    rect(0, circle, 1, circle+band);
    playerRotation=(PI/bands)*bandsSkipped;
    v[i]=band;
  }

  //noFill();
  //stroke(200, 0, 0);
  //ellipse(0, 0, (circle + rotationChangeThreshold)*2, (circle + rotationChangeThreshold)*2);
  //rotationChangeThreshold = lerp(rotationChangeThreshold, bandMedian*2, 0.0001);
  popMatrix();

  fill(0);
  stroke(255);
  rect(1, height-20, width-30, height);
  noStroke();
  rectMode(CORNERS);
  rect(width-30, 0, width, height);
  fill(255, 0, 0);
  float position = map( player.position(), 0, songLength, 0, width-30 );
  rect(1, height-19, position, height);
  
  gainPosition=int(map(gain,-18,0,height,0));
  rect(width-30,height,width,gainPosition);
  

  fill(255);
  if ( player.isPlaying() )
  {
    text("Press the P key to pause playback.", 0, 40 );
  } else
  {
    text("Press the P key to start playback.", 0, 40 );
  }
  text("Click anywhere to jump to a position in the song.", 0, 25);
  text("Press the M key to choose another song.", 0, 55);
}



void mousePressed()
{
  // choose a position to cue to based on where the user clicked.
  if(mouseX<width-30 && mouseY>height-20)
  {
    int positionCue = int( map( mouseX, 0, width-30, 0, songLength ) );
  player.cue( positionCue );
  }
  else
  if(mouseX>width-30)
  {
    int gainCue = int(map(mouseY,height,0,-18,0));
    player.shiftGain(gain,gainCue,1000);
    gain=gainCue;
  }
}
