import ddf.minim.*; //<>// //<>// //<>//
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
FFT         fft;
int songLength;
float multiplication =5;
float band;
int bandResolution=4096;
int bandsSkipped=2;
float gain=-16;
float gainPosition=gain;
int k=0;
float gainCue=gain;
float playerRotation=0;
float v[]=new float[bandResolution/2+1];
float vv[]=new float[bandResolution/2+1];
float lerpAmt=0.04f;
float j=PI;
float bandMax=0;
float circle=200;
int change = 1;
boolean changeRequired = false;
float rotationChangeThreshold = 2;
float bandMedian=0;
int bands=0;
String fileName=null;
float rotateDivider=1000;
float bandsPercentage=0.4;

void setup()
{
  //size(1024, 700);
  frameRate(60);
  fullScreen();
  initializeSong();
  println(fft.specSize());

  for (int i=0; i < fft.specSize(); i++) {
    v[i]=0;
    vv[i]=0;
  }
  pushMatrix();
  rectMode(CORNERS);
}

void draw()
{
  background(0);
  fft.forward(player.mix);
  if (gain!=gainCue)
  {
    gain=lerp(gain, gainCue, 0.05);
  }
  
        downLines();
        //circleSpectrum();
  
    //sidebars();
   // helpcommands();

}

void downLines(){ 
  k=0;
  for (int i=0; i < bands; i+=bandsSkipped) {
    band=mapBand(fft.getBand(i))*2;
    if (band<vv[i])
    {        
      band=lerp(vv[i], band, lerpAmt);
    } 
    vv[i]=band;
    fill(map(band, 0, 0.4*height, 60, 200), 0, map(band, 0, 0.4*height, 200, 60), 255);
    stroke(map(band, 0, 0.4*height, 60, 200), 0, map(band, 0, 0.4*height, 200, 60), 255);
    rect(((width-30)/bands)*(bandsSkipped*k*2), height/2, ((width-30)/bands)*(bandsSkipped*k*2)+1, height/2-band);
    rect(((width-30)/bands)*(bandsSkipped*k*2), height/2, ((width-30)/bands)*(bandsSkipped*k*2)+1, height/2+band);
    k++;
  }
}

void helpcommands()
{
    fill(255);
  if ( player.isPlaying() )
  {
    text("Press the P key to pause playback.", 0, 40 );
  } else
  {
    text("Press the P key to start playback.", 0, 40 );
  }
  text("Click on the low side bar to jump to a position in the song.", 0, 25);
  text("Press the M key to choose another song.", 0, 55);
  text("Click on the right side bar to change the volume.", 0, 70);
}

void spikerotation(){
  bandMedian=0;
  for (int i=0; i < bands; i++) {
    bandMedian+=v[i];
  }
  bandMedian=bandMedian/bands;
  if (player.isPlaying())
    rotateDivider=lerp(rotateDivider, bandMax*50, 0.01);
    j+=bandMax/rotateDivider;
    
  //  j+=(bandMedian*change)/20000;
  //if (bandMedian > rotationChangeThreshold)
  //  changeRequired = true;
  //if (changeRequired && bandMedian < rotationChangeThreshold)
  //{
  //  change *= -1;
  //  changeRequired = false;
  //}
  
  bandMax=0;
  }
  
  void circleSpectrum()
  {
     pushMatrix();
  translate(width/2, height/2-20);
  fill(0, 0, 0);
  noStroke();
  circle(0, 0, circle*2);
  stroke(100, 0, 100);
  fill(100, 0, 100);
  rotate(j);
  
        //spikerotation();
  

  for (int i=0; i < bands; i+=bandsSkipped)
  {

    if (bandMax<fft.getBand(i)){
      bandMax=fft.getBand(i);
      band=bandMax;
    }
    else{
    band=mapBand(fft.getBand(i));
    }
    if (band<v[i])
    {        
      band=lerp(v[i], band, lerpAmt);
    }
    stroke(map(band, 0, 200, 70,255), 0, map(band, 0, 200, 150,0),200);
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
    stroke(map(band, 0, 200, 70,255), 0, map(band, 0, 200, 150,0),200);
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
  }
  
  void sidebars(){
    fill(0);
  stroke(255);
  rect(1, height-20, width-30, height);
  noStroke();
  rectMode(CORNERS);
  rect(width-30, 0, width, height);
  fill(255, 0, 0);
  float position = map( player.position(), 0, songLength, 0, width-30 );
  rect(1, height-19, position, height);
  
  rect(width-30, height, width, map(gain, -18, 0, height, 0));
  }
  
  

void mousePressed()
{
  // choose a position to cue to based on where the user clicked.
  if (mouseX<width-30 && mouseY>height-20)
  {
    int positionCue = int( map( mouseX, 0, width-30, 0, songLength ) );
    player.cue( positionCue );
  } else
    if (mouseX>width-30)
    {
      gainCue = int(map(mouseY, height, 0, -18, 0));
      player.shiftGain(gain, gainCue, 1000);
    }
}
