import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
FFT         fft;
int songLength;
void setup()
{
  size(1024, 400);
  
  
  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);
  player = minim.loadFile("song.mp3");
  frameRate(60);
  player.setGain(-18);
  //player.play();
  fft = new FFT( player.bufferSize(), player.sampleRate() );
  
  player.cue(player.length());
  println(player.position());
  songLength=player.position();
  player.cue(0);
  println("length is "+songLength+"/"+player.length());
}

void draw()
{
  background(0);
  fft.forward(player.mix);
  //println("position is "+player.position()+"/"+songLength);
  line(0,height-20,width,height-20);
  
  stroke( 255, 0, 0 );
  fill(255, 0, 0);
  float position = map( player.position(), 0, songLength, 0, width );
  rect(1,height-19,position,height);
  
  
  
  
  
  
  fill(255);
  if ( player.isPlaying() )
  {
    text("Press any key to pause playback.", width-181, height-40 );
  }
  else
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

  }
  else if ( player.position() == songLength )
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
  // the length() method returns the length of recording in milliseconds.
  int positionCue = int( map( mouseX, 0, width, 0, songLength ) );
  player.cue( positionCue );
}