void keyPressed()
{ 

  if (key=='m'||key=='M')
  {
    player.pause();
    fileName=null;
    close();
    initializeSong();
  } else

  if ( player.isPlaying() &&(key=='p'||key=='P'))
  {
    player.pause();
  } else 
  if ( player.position() >= songLength-20 )
  { 
    player.rewind();
    player.play();
  }
  // if the player is at the end of the file,
  // we have to rewind it before telling it to play again
  else if (key=='p'||key=='P' )
  {
    player.play();
  }
}
