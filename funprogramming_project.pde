import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
FFT         fft;

void setup()
{
  size(512, 400);
  
  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);
  player = minim.loadFile("song.mp3");
  
  player.setGain(-18);
  //player.loop();
  fft = new FFT( player.bufferSize(), player.sampleRate() );
}

void draw()
{
  background(0);
  if ( player.isPlaying() )
  {
    text("Press any key to pause playback.", width-181, height-19 );
  }
  else
  {
    text("Press any key to start playback.", width-172, height-19 );
  }
  
  stroke( 255, 0, 0 );
  float position = map( player.position(), 0, player.length(), 0, width );
  line( position, 0, position, height );
  
  text("Click anywhere to jump to a position in the song.", width-259, height-5);
  
}

void keyPressed()
{
  if ( player.isPlaying() )
  {
    player.pause();
  }
  // if the player is at the end of the file,
  // we have to rewind it before telling it to play again
  else if ( player.position() == player.length() )
  {
    player.rewind();
    player.play();
  }
  else
  {
    player.play();
  }
}
void mousePressed()
{
  // choose a position to cue to based on where the user clicked.
  // the length() method returns the length of recording in milliseconds.
  int position = int( map( mouseX, 0, width, 0, player.length() ) );
  player.cue( position );
}