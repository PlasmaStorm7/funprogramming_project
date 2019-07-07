import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
FFT         fft;

void setup()
{
  size(512, 200, P3D);
  
  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);
  // loadFile will look in all the same places as loadImage does.
  // this means you can find files that are in the data folder and the 
  // sketch folder. you can also pass an absolute path, or a URL.
  player = minim.loadFile("song.mp3");
  
  player.setGain(-15.0);
  fft = new FFT( player.bufferSize(), player.sampleRate() );
}

void draw()
{
  background(0);
  
  
  if ( player.isPlaying() )
  {
    text("Press any key to pause playback.", 10, 20 );
  }
  else
  {
    text("Press any key to start playback.", 10, 20 );
  }
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