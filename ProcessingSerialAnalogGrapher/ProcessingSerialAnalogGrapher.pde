// This will graph arduino analog values from 0 to 1023

import processing.serial.*;

// This program only accepts one serial connection.
Serial port;
Graph g;
static boolean debug = true;
void setup()
{
  // Size of the plot
  size(800,600);
  
  // The port of the Serial Data we want.
    // Serial.list()[0] is almost always the most recently connected device.
  try
  {
    port = new Serial(this, Serial.list()[0], 9600);
  }
  catch (Exception e)
  {
    println("Is Arduino connected?");
  }
  g = new Graph(port);
  
}

void draw()
{
  background(0);
  g.update();
  g.display();
  
  fill(255);
  text("Serial Grapher",10,20);
}

class Graph
{
  // Graph color
  color c = color(255);
  //Location of the top left corner of the graph
  int gx;
  int gy;
  
  //Values of the max and min seen on the serial device
  float smax;
  float smin;
  
  //Values of the maximum and minimum values which the graph needs to map to
  int gmax;
  int gmin;
  
  //Width of the graph
  int gwidth;
  int zoomScale = 10;
  
  //Sample rate in miliseconds
  float samplingRate;
  int lastRead;
  
  //Serial port which this graph gets its data from
  Serial port;
  
  //Current array index
  
  int ax = 0;
  
  //Array of all the points that this graph holds
  float pnts[];
  Graph(Serial pp)
  {
    pnts = new float[width];
    port = pp;
    smax = 0;
    smin = 0;
    
    // This reversal makes 0 as the bottom
    gmax = 0;
    gmin = height-1;
    
    gwidth = 100;
  }
  
  void zoomIn()
  {
    if(gwidth>zoomScale)
    {
      gwidth-=zoomScale;
    }
    else if (gwidth <= zoomScale)
    {
      gwidth = zoomScale;
    }
  }
  
  void zoomOut()
  {
    if(gwidth<width-zoomScale)
    {
      gwidth+=zoomScale;
    }
    else if (gwidth >= width-zoomScale)
    {
      gwidth = width;
    }
  }
  
  void update()
  {
    if(!debug)
    {
      try
      {
        // This is a handshaking protocol.
        // The arduino waits for the character 'A' before it sends its analog data.
        // The delay is added so that the Arduino is not overburdened.
          // The data we get back is much cleaner and more reliable.
        try
        {
          port.write('A');
        }
        catch(Exception e)
        {
          fill(255);
          textAlign(CENTER);
          text("Could not connect to serial device.",width/2,height/2);
          textAlign(LEFT);
          return;
        }
          // port.readStringUntil(10) means "Read the serial data until a newline character is encountered (which means it's the end of the line.)"
        String buff = port.readStringUntil(10);
        if(buff!=null)
        {
          // Add the new value to our list of values
          // at the point which we last left off.
          float in = new Float(buff);
          pnts[ax] = in;
          
          if(in > smax)
            smax = in;
          else if(in < smin)
            smin = in;
          
          // If our graph goes over the width limit, start from the beginning
          ax++;
          if(ax>=gwidth)
          {
            ax = 0;
          }
          samplingRate = round(samplingRate+(samplingRate-(millis()-lastRead))*-0.3);
          lastRead = millis();
          
          
          // Uncomment the following line to show the values being read.
          //println(buff);
        }
        
      }
      catch(Exception e)
      {
        e.printStackTrace();
      }
    }
    else
    {
        float in = new Float("400");
        pnts[ax] = in;
        
        if(in > smax)
          smax = in;
        else if(in < smin)
          smin = in;
      
        ax++;
        if(ax>=gwidth)
        {
          ax = 0;
        }
        samplingRate = round(samplingRate+(samplingRate-(millis()-lastRead))*-.4);
        lastRead = millis();
    }
    delay(10);
  }
  
  void display()
  {
    // Map the x and map the y values
    float lasty = map(pnts[0], smin, smax, gmin, gmax);
    float lastx = map(0, 0, gwidth, 0, width);
    float xmap;
    float ymap;
    
    // Draw the line
    stroke(c);
    rectMode(RADIUS);
    for(int i = 1; i<gwidth; i++)
    {
      ymap = map(pnts[i], smin, smax, gmin, gmax);
      xmap = map(i,0,gwidth,0,width);
      line(lastx,lasty, xmap, ymap);
      lastx = xmap;
      lasty = ymap;
      // Display update marker
      if(i+1==ax)
      {
        rect(xmap,ymap,5,5);
        break;
      }
        
    }
    
    // Display currently high value
    fill(c);
    text("Max Value: "+int(smax),10,40);
    
    // Calculate/Display average value
    /*
    int avg = 0;
    for(int i = 0; i<gwidth; i++)
    {
      avg += int(pnts[i]);
    }
    avg = avg/width;
    text("Avg Value: "+avg,10,60);
    */
    // Scale will be computed as the total width of the screen, in seconds.
    // If it takes 0.017 seoncds per sample (per pixel), then that means that the width is 13.6 seconds.
    text("Scale: "+((float(gwidth)/float(width))*(samplingRate/1000)*width)+"s", 10, 60);
    text("Sampling Rate: "+round(1/(samplingRate/1000))+" Hz", 10, 80);
  }
}

void keyPressed()
{
  if(key=='='||key=='+')
  {
    g.zoomIn();
  }
  else if(key=='-'||key=='_')
  {
    g.zoomOut();
  }
}

