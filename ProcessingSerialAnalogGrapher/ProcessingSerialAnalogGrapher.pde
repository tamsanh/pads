// This will graph arduino analog values from 0 to 1023

import processing.serial.*;

// Min and Max of the values the arduino sends over serial
 static float maximum = 1023;
 static float minimum = 0;

Serial port;
Graph graph;
Measure meas;
MouseDisplay mouseDisp;

void setup()
{
  size(1000,700);
  port = new Serial(this, Serial.list()[0], 9600);
  graph = new Graph();
  meas = new Measure();
  mouseDisp = new MouseDisplay();
}

void draw()
{
  background(0);
  graph.update();
  graph.display();
  meas.display();
  mouseDisp.display();
}

class MouseDisplay
{
  // Display the value at the position which the mouse has highlighted
  color c = color(255);
  float value = 0;
  void display()
  {
    value = map(mouseY, height-1, 0, minimum, maximum);
    
    fill(c);   
    stroke(c);
    line(mouseX,mouseY+15,mouseX,mouseY-15);
    line(mouseX+15,mouseY,mouseX-15,mouseY);
    
    if(mouseX > width - 100)
      textAlign(RIGHT);
    else
      textAlign(LEFT);
      
    if(mouseY < 30)
      text(value,mouseX,mouseY+30);
    else
      text(value,mouseX,mouseY-5);
  }
}

class Measure
{
  color halfColor = color(255,100,100,200);
  color quarterColor = color(255,100,100,100);
  // This shows lines with which to measure the data.
  void display()
  {
    stroke(halfColor);
    line(0,(height-1)/2,width,(height-1)/2);
    
    stroke(quarterColor);
    line(0,(height-1)/4,width,(height-1)/4);
    line(0,(height-1)/4*3,width,(height-1)/4*3);
  }
}

class Graph
{
  // Max and Min of the input
  
  // size of the grpah
  int gWidth;
  int gHeight;
  int gx;
  
  // sets the graph color.
  //color c = color(random(100,255),random(100,255),random(100,255));
  color c = color(255);
  
  //Points to b displayed
  float []  pnts;
  
  Graph()
  {
    gWidth = width;
    gHeight = height;
    pnts = new float[width];
    
    // Populate all the points
    for(int i = 0; i < width; i++)
      pnts[i] = height-1;
  }
  
  // update gets a new value from the serial port to add to the graph
  void update()
  {
    if (port.available() > 0)
    {
      try
      {
        String buff = port.readStringUntil(10);
        if(buff!=null)
        {
          float in = new Float(buff);
          in = map(in, minimum, maximum, height-1, 0);
          
          float tmp2 = in;  
          // Add in the new point, propagate down
          for(int i = width-1; i >= 0; i--)
          {
            float tmp = pnts[i];
            pnts[i] = tmp2;
            tmp2 = tmp;
          }
        }
      }
      catch (Exception e)
      {}
    }
  }
  
  // display displays the graph
  // two display modes. 
    // One to that scrolls left, another that doesn't scroll.
  void display()
  {
    float lasty = pnts[width-1];
    float curr;
    stroke(c);
    for(int i = width-2; i>0; i--)
    {
      curr = pnts[i];
      line(i+1, lasty, i,curr);
      lasty = curr;
    }
  }
  
}
