//Simulate an arduino connected to the server.
//Moving the mouse inside the box will generate data

import processing.net.*;

Client c;
float y = 0;
int mod = 1;

void setup()
{
  size(50,50);
  //background(0);
  //stroke(255);
  c = new Client(this, "localhost", 8000);
  delay(500);
  c.write("9\n");
  yvalues = new float[10];
}

void draw()
{
  try
  {
    calcWave();
    float b = map(mouseY,height,0,15,650);
    //float b = map(yvalues[0],-100,100,10,700);
    //println(b);
    
    try{
      c.write(int(b)+"\n");
    }
    catch(Exception e)
    {
      return;
    }
    y = y+mod;
    if(y>100 || y < 0)
    {
      mod = mod*-1;
      y = y+mod;
    }
  }
  catch(Exception e)
  {
    println("Disconnected from server");
    exit();
  }
}

float yoff = 0.0f;        // 2nd dimension of perlin noise
float[] yvalues;          // Using an array to store height values for the wave (not entirely necessary)
void calcWave() {
  float dx = 0.05f;
  float dy = 0.01f;
  float amplitude = 100.0f;

  // Increment y ('time')
  yoff += dy;

  //float xoff = 0.0;  // Option #1
  float xoff = yoff; // Option #2

  for (int i = 0; i < yvalues.length; i++) {
    // Using 2D noise function
    //yvalues[i] = (2*noise(xoff,yoff)-1)*amplitude; // Option #1
    // Using 1D noise function
    yvalues[i] = (2*noise(xoff)-1)*amplitude;    // Option #2
    xoff+=dx;
  }
}
