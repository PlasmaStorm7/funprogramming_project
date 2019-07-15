import ddf.minim.*; //<>// //<>//
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
FFT         fft;
int songLength;
float multiplication =5;
float band;
float playerRotation=0;
float v[]=new float[4096];
float lerpAmt=0.06f;
float j=PI;
float bandMax=0;
float circle=200;
int change = 1;
boolean changeRequired = false;
float rotationChangeThreshold = 10;
float bandMedian=0;
void setup()
{
  size(1024, 600);

  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);
  player = minim.loadFile("song3.mp3", 256);
  frameRate(60);
  player.setGain(-18);
  player.play();
  fft = new FFT( player.bufferSize(), player.sampleRate() );

  player.cue(player.length());
  println(player.position());
  songLength=player.position();
  player.cue(0);
  //println("length is "+songLength+"/"+player.length()+"metadata length is"+player.getMetaData().length());

  for (int i=0; i < fft.specSize(); i++) {
    v[i]=0;
  }
  pushMatrix();
}

void draw()
{
  background(0);
  fft.forward(player.mix);
  fill(0);
  stroke(255);
  rect(1, height-20,width, height);
  noStroke();
  rectMode(CORNERS);
  //line(0, height-20, width, height-20);
  fill(255, 0, 0);
  float position = map( player.position(), 0, songLength, 0, width );
  rect(1, height-19, position, height);

  stroke(60, 0, 60);
  fill(60, 0, 60);

  //for(int i=0; i < fft.specSize(); i++){
  //  band=fft.getBand(i)*multiplication;
  //  if (band<v[i])
  //    {        
  //     band=lerp(v[i],band,lerpAmt);             
  //    } 

  //   rect(i*3,height-21,i*3+1,height-21-band);
  //}
  bandMedian=0;
  for(int i=0; i < fft.specSize(); i++){
     bandMedian+=v[i];
  }
  bandMedian=bandMedian/fft.specSize();
  pushMatrix();
  translate(width/2, height/2-20);
  stroke(100, 0, 100);
  fill(100, 0, 100);
  rotate(j);
    j+=bandMax/2000;
  //j+=(bandMedian*change)/20000;
  //if (bandMedian > rotationChangeThreshold)
  //  changeRequired = true;
  //if (changeRequired && bandMedian < rotationChangeThreshold)
  //{
  //  change *= -1;
  //  changeRequired = false;
  //}
  bandMax=0;

  for (int i=0; i < fft.specSize(); i++)
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
    rotate(playerRotation);
    rectMode(CORNERS);
    rect(0, circle, 1, circle+band);
    playerRotation=PI/fft.specSize();
    v[i]=band;
  }

  for (int i=fft.specSize(); i>0; i--)
  {
    band=mapBand(fft.getBand(i));
    if (band<v[i])
    {        
      band=lerp(v[i], band, lerpAmt);
    } 
    rotate(playerRotation);
    rectMode(CORNERS);
    rect(0, circle, 1, circle+band);
    playerRotation=PI/fft.specSize();
  }
  
  //noFill();
  //stroke(200, 0, 0);
  //ellipse(0, 0, (circle + rotationChangeThreshold)*2, (circle + rotationChangeThreshold)*2);
  //rotationChangeThreshold = lerp(rotationChangeThreshold, bandMedian*2, 0.0001);
  popMatrix();





  fill(255);
  if ( player.isPlaying() )
  {
    text("Press any key to pause playback.", width-181, height-40 );
  } else
  {
    text("Press any key to start playback.", width-172, height-40 );
  }
  text("Click anywhere to jump to a position in the song.", width-259, height-25);
}

void keyPressed()
{
  if ( player.isPlaying() )
  {
    player.pause();
  } else if ( player.position() >= songLength-20 )
  { 
    player.rewind();
    player.play();
  }
  // if the player is at the end of the file,
  // we have to rewind it before telling it to play again
  else 
  {
    player.play();
  }
}

void mousePressed()
{
  // choose a position to cue to based on where the user clicked.
  int positionCue = int( map( mouseX, 0, width, 0, songLength ) );
  player.cue( positionCue );
}

float mapBand(float band)
{
  return constrain(log(band) / log(2), 0, width) * 15;
}
