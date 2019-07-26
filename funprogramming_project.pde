import ddf.minim.*; //<>// //<>//
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
FFT         fft;
int songLength;
float multiplication =5;
float band;
float playerRotation=0;
float v[]=new float[1027];
float lerpAmt=0.04f;
float j=PI;
float bandMax=0;
float circle=200;
int change = 1;
boolean changeRequired = false;
float rotationChangeThreshold = 10;
float bandMedian=0;
int bands=0;
String fileName;
float rotateDivider=1000;
float bandsPercentage=0.75;
int bandResolution=1024;
int bandsSkipped=4;
float gain= -10;
void setup()
{
  size(1024, 700);
  //fullScreen();
  selectInput("Select a file to process:", "fileSelected");
  minim = new Minim(this);
  frameRate(60);
  
  while(fileName==null)
  {
    println("waiting");
  }
  println(fileName);
  player=minim.loadFile(fileName,bandResolution);
  player.play();
  fft = new FFT( player.bufferSize(), player.sampleRate() );
  bands=int(fft.specSize()*bandsPercentage);
player.setGain(gain);
  player.cue(player.length()); //<>//
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
  for(int i=0; i < bands; i++){
     bandMedian+=v[i];
  }
  bandMedian=bandMedian/bands;
  pushMatrix();
  translate(width/2, height/2-20);
  stroke(100, 0, 100);
  fill(100, 0, 100);
  rotate(j);
  if(player.isPlaying())
  rotateDivider=lerp(rotateDivider,bandMax*50,0.01); //<>//
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
    stroke(90+map(band,0,200,0,165),0,map(i,bands,0,0,255));
    rotate(playerRotation);
    rectMode(CORNERS);
    rect(0, circle, 1, circle+band);
    playerRotation=(PI/bands)*bandsSkipped;
    v[i]=band;
  }

  for (int i=bands; i>0; i-=bandsSkipped)
  {
    band=mapBand(fft.getBand(i));
    if (band<v[i])
    {        
      band=lerp(v[i], band, lerpAmt);
    } 
    stroke(90+map(band,0,200,0,165),0,map(i,bands,0,0,255));
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
  rect(1, height-20,width, height);
  noStroke();
  rectMode(CORNERS);
  //line(0, height-20, width, height-20);
  fill(255, 0, 0);
  float position = map( player.position(), 0, songLength, 0, width );
  rect(1, height-19, position, height);




  fill(255);
  if ( player.isPlaying() )
  {
    text("Press the P key to pause playback.", width-191, height-40 );
  } else
  {
    text("Press the P key to start playback.", width-182, height-40 );
  }
  text("Click anywhere to jump to a position in the song.", width-259, height-25);
  text("Press the M key to choose another song.",width-220,height-55);
}

void keyPressed()
{ 
  if (key=='m'||key=='M')
    {
      player.pause();
      fileName=null;
      close();
      selectInput("Select a file to process:", "fileSelected");
      while(fileName==null)
      {
        println("waiting");
      }
      player=minim.loadFile(fileName,bandResolution);
      fft = new FFT( player.bufferSize(), player.sampleRate() );
      player.setGain(gain);
      player.cue(player.length());
    println(player.position());
    songLength=player.position();
    player.cue(0);
    player.play();
    }
    else
  if ( player.isPlaying() &&(key=='p'||key=='P'))
    {
      player.pause();
    } 
    else 
      if ( player.position() >= songLength-20 )
        { 
        player.rewind();
        player.play();
        }
  // if the player is at the end of the file,
  // we have to rewind it before telling it to play again
        else if(key=='p'||key=='P' )
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
  return constrain((log(band)*1.5) / log(2), 0, width) * 15;
  //return constrain (map(band*15,0,300,0,200),0,500);
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    fileName=selection.getAbsolutePath();
    
    
  } //<>//
}

public void close()
{
    Minim.debug( "Closing " + this.toString() );
 
    player.close();
    
}
