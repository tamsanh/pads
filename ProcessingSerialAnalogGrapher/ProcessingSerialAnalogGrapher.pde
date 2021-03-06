// This will graph arduino analog values from 0 to 1023

//+ and - to zoom in and zoom out
//spacebar to toggle ghost trace.

//Scale refers to the time it takes for the trace to cross the entire graphing screen.
//Sample rate refers to the frequency of data sampling the system is currently doing.

import processing.serial.*;

// This program only accepts one serial connection.
Serial port;
Graph g;

void setup()
{
  // Size of the plot
  size(900,600);
  
  // The port of the Serial Data we want.
    // Serial.list()[0] is almost always the most recently connected device.
  try
  {
    port = new Serial(this, Serial.list()[0], 38400);
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
  float zoomScale = 1;
  
  //Sample rate in miliseconds
  float samplingRate=1;
  int lastRead;
  
  //Serial port which this graph gets its data from
  Serial port;
  
  //Current array index
  
  int ax = 0;
  
  //Array of all the points that this graph holds
  float pnts[];
  float ghostpnts[][];
  
  int maxGhost = 2;
  int currGhost = 0;
  boolean ghostVisible = false;
  
  int delayRate = 100;
  
  Graph(Serial pp)
  {
    pnts = new float[width];
    ghostpnts = new float[maxGhost][width];
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
    if (gwidth <= 10)
    {
      gwidth = width/150;
      textAlign(CENTER);
      text("Maximum Zoom",width/2,height/2);
      textAlign(LEFT);
    }
    else
    {
      gwidth-=zoomScale;
    }
    zoomScale = (float(gwidth)/float(width))*5+1;
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
      textAlign(CENTER);
      text("Minimum Zoom",width/2,height/2);
      textAlign(LEFT);
    }
    zoomScale = float(gwidth)/float(width)*5+1;
  }
  
  void update()
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
      
      delay(delayRate);
      
      while(port.available()<0)
      {
      }
        // port.readStringUntil(10) means "Read the serial data until a newline character is encountered (which means it's the end of the line.)"
      String buff = port.readStringUntil(10);
      if(buff!=null)
      {
        // Add the new value to our list of values
        // at the point which we last left off.
        float in = new Float(buff);
        pnts[ax] = in;
        if(ghostVisible)
          ghostpnts[currGhost][ax] = in;
        
        if(in > smax)
          smax = in;
        else if(in < smin)
          smin = in;
        
        // If our graph goes over the width limit, start from the beginning
        ax++;
        if(ax>=gwidth)
        {
          ax = 0;
          if(ghostVisible)
          {
            currGhost++;
            if(currGhost>=maxGhost)
              currGhost=0;
          }
          
        }
        samplingRate = round(samplingRate+(samplingRate-(millis()-lastRead))*-0.3);
        lastRead = millis();
        
        // println(in);
        // Uncomment the following line to show the values being read.
        //println(buff);
      }
      
    }
    catch(Exception e)
    {
      e.printStackTrace();
    }
  }
  
  void display()
  {
    // Map the x and map the y values
    float lastyghost[] = new float[maxGhost];
    float ymapghost[] = new float[maxGhost];
    if(ghostVisible)
    {
      for(int i = 0; i < maxGhost; i++)
      {
        lastyghost[i] = map(ghostpnts[i][0], smin, smax, gmin, gmax);
      }
    }
    float lasty = map(pnts[0], smin, smax, gmin, gmax);
    float lastx = map(0, 0, gwidth, 0, width);
    float xmap;
    float ymap;
    
    // Draw the line
    stroke(c);
    rectMode(RADIUS);
    for(int i = 1; i<gwidth; i++)
    {
      xmap = map(i,0,gwidth,0,width);
      if(ghostVisible)
      {
        for(int j = 0; j < maxGhost; j++)
        {
          if(j==currGhost)
          {
            continue;
          }
          ymapghost[j] = map(ghostpnts[j][i], smin, smax, gmin, gmax);
          stroke(255,100,100);
          line(lastx,lastyghost[j],xmap, ymapghost[j]);
          lastyghost[j] = ymapghost[j];
        }
      }
      
      ymap = map(pnts[i], smin, smax, gmin, gmax);
      stroke(255);
      line(lastx,lasty, xmap, ymap);
      lasty = ymap;
      
      lastx = xmap;
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
    text("Sampling Rate: ~"+round(1/(samplingRate/1000))+" Hz", 10, 80);
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
  else if(key==' ')
  {
    g.ghostVisible = !g.ghostVisible;
  }
  else if(key==CODED)
  {
    if(keyCode == UP && g.delayRate>0)
    {
      //Increase clock speed
      //Decrease delay
      g.delayRate = g.delayRate - 2;
    }
    else if(keyCode == DOWN)
    {
      g.delayRate = g.delayRate + 2;
    }
  }
}

