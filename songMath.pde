float mapBand(float band)
{
  return constrain(log(band)* 30, 0, width) ;
  //return constrain (map(band*15,0,300,0,200),0,500);
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    fileName=selection.getAbsolutePath();
  }
}

public void close()
{
  Minim.debug( "Closing " + this.toString() );
  player.close();
}
void initializeSong()
{
  selectInput("Select a file to process:", "fileSelected");
  while (fileName==null)
  {
    println("waiting");
  }
  println(fileName);
  minim = new Minim(this);
  player=minim.loadFile(fileName, bandResolution);
  println("loaded "+ fileName);
  println("player.bufferSize()="+player.bufferSize());
  println("player.sampleRate()="+player.sampleRate());
  fft = new FFT( player.bufferSize(), player.sampleRate() );
  player.play(); //<>//
  bands=int(fft.specSize()*bandsPercentage);
  player.setGain(gain);
  player.cue(player.length());
  println("player.position()="+player.position() );
  songLength=player.position();
  player.cue(0);
}
