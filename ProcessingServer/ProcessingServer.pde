//If there is a "Caught exception in serverEvent" error,
//simply try connecting the arduino again

//import fullscreen.*;
//import japplemenubar.*;
import processing.net.*;
import java.net.InetAddress;


//FullScreen fs; 
PImage topPlate;
PImage botPlate;
PImage allMap;
PImage rest;

//Getting the IP address
InetAddress inet;
String myIP;

static int port = 8000;
boolean serverOn = true;
int xPos=0;

static byte lineRet = 10;
static int timeOutMax = 200;
static float thresh = 5;

Server arduinoServer;
ArrayList arduinos = new ArrayList();
color oceanColor = color(198,236,255);

void setup()
{

  try {
    inet = InetAddress.getLocalHost();
    myIP = inet.getHostAddress();
  }
  catch (Exception e) {
    e.printStackTrace();
    myIP = "couldnt get IP"; 
  }
  
  topPlate = loadImage("top.gif");
  botPlate = loadImage("bot.gif");
  allMap = loadImage("all2.gif");
  //fs = new FullScreen(this); 
  size(800, 600);
  textFont(createFont("Menlo", 16));
  arduinoServer = new Server(this, port); 
  // Starts a myServer on port 10002
  background(oceanColor);
  //fs.enter();
}

int tx = 0;
int ty = 1;
//First arduino to connect will be with the top plate
//Second arduino will be with the bot plate.
Arduino ilocos = null;
Arduino tarlac = null;
int tecMax = 15;
int gPos = 130;

int bigmap = 0;
boolean transitioned = false;
int fadeAplha = 0;

void plot(Arduino a,int i)
{
  //Plot a given arduino's data graph
  int index = i;
  
  fill(a.c);
  stroke(a.c);
  text("Arduino "+index, 20, height/4+(index*height*2/4));
  float pnt = map(a.data, 10, 700, 0, height/2);
  if(a.lastPnt==-1)
    a.lastPnt=pnt;
  stroke(a.c);
  float graphBot = height/2*index;
  line(gPos-1,graphBot+a.lastPnt,gPos,graphBot+pnt);
  a.lastPnt=pnt;
}

void draw()
{
  //bigmap is the currently displayed map
  if(bigmap==1)
  {
    //Display the tectonic plates
    textFont(createFont("Menlo", 16));
    background(oceanColor);
    if(ilocos==null && tarlac==null)
    {
      image(topPlate,0,0,width,height);
      image(botPlate,0,0,width,height); 
    }
    else if(tarlac == null)
    {
      drawIlocos();
      image(botPlate,0,0,width,height); 
    }
    else if(ilocos==null)
    {
      image(topPlate,0,0,width,height);
      drawTarlac();
    }
    else
    {
      drawTarlac();
      drawIlocos();
    }
  }
  else if (bigmap==0)
  {
    //Display only the graphs
    textFont(createFont("Menlo", 16));
    if(gPos==130)
      background(0);
    if(ilocos==null && tarlac==null)
    {
    }
    else if(tarlac == null)
    {
      ilocos.update();
      plot(ilocos,0);
    }
    else if(ilocos==null)
    {
      tarlac.update();
      plot(tarlac,1);
    }
    else
    {
      ilocos.update();
      tarlac.update();
      plot(ilocos,0);
      plot(tarlac,1);
    }
    gPos++;
    if(gPos>=width)
      gPos=130;
  }
  else if(bigmap==2)
  {
    //Display all the simulated arduinos
    textFont(createFont("Menlo", 10));
    background(oceanColor);
    image(allMap,0,0,width,height);
    //Draw lots of arduinos.
    //33 50
    if(ilocos!=null)
      ilocos.update();
    if(tarlac!=null)
      tarlac.update();
      
    int xLoc = 33;
    for(int i = 0; i < extraGraphs; i++)
    {
      if(noises[i]==null)
        noises[i]=new Noisey(i);
      noises[i].update();
      if(graphs[i]==null)
      {
        fill(0);
        if(i>=10&&i<20)
          graphs[i] = new Graph (85,148,50+((i-10)*50),color(random(50,255),random(50,255),random(50,255)));
        else if(i>=20)
          graphs[i] = new Graph (85,263,50+((i-20)*50),color(random(50,255),random(50,255),random(50,255)));
        else
        {
          if(i==0)     
            graphs[i] = new Graph (85,33,50+(i*50),color(230,100,100)); 
          else if(i==1)
            graphs[i] = new Graph (85,33,50+(i*50),color(100,200,100));
          else
            graphs[i] = new Graph (85,33,50+(i*50),color(random(50,255),random(50,255),random(50,255)));
        }
      }
      if(i==0 && ilocos!=null)
      {
        graphs[i].update(ilocos.data);
        graphs[i].display();
      }
      else if(i==1 && tarlac!=null)
      {
        graphs[i].update(tarlac.data);
        graphs[i].display();
      }
      else
      {
        graphs[i].update(noises[i].val);
        graphs[i].display();
      }
      fill(0);
      if(i>=11&&i<21)
        text("Sensor "+i,148,50+((i-11)*50));
      else if(i>=21)
        text("Sensor "+i,263,50+((i-21)*50));
      else
        text("Sensor "+i,33,i*50);
    }
    
  }
  fill(255);
  textAlign(RIGHT);
  text("Server IP: "+myIP,width,30);
  textAlign(LEFT);
}

int extraGraphs = 31;

class Noisey
{
  //This class generates the noise for the simulated arduinos in the 3rd map
float [] yvalues = new float[10];
float val;

float yoff = 0.0f;        // 2nd dimension of perlin noise

Noisey(int i){
  yoff += i;
  }
void update() {
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
  val = map(yvalues[0],-100,100,10,700);
}
}

Noisey[] noises = new Noisey[extraGraphs];
Graph [] graphs = new Graph[extraGraphs];

class Graph
{
  //This is the graph that is used to display the data
  int maxWidth;
  int maxHeight = 20;
  int xPos;
  int yPos;
  color c;
  GraphPoint[] pnts;
  Graph(int w,int x,int y,color col)
  {
    pnts = new GraphPoint[w];
    maxWidth = w;
    xPos = x;
    yPos = y;
    c = col;
  }
  void update(float d)
  {
    //Update the graph with new data and draw
    GraphPoint next = new GraphPoint(d);
    GraphPoint tmp = null;
    tmp = pnts[maxWidth-1];
    pnts[maxWidth-1] = next;
    for(int i = maxWidth-2; i>=0; i--)
    {
      next = pnts[i];
      pnts[i]=tmp;
      tmp = next;
    }
  }
  
  void display()
  {
    //Display the graph
    GraphPoint gp;
    GraphPoint lastgp;
    lastgp = pnts[maxWidth-1];
    for(int i = maxWidth-2; i>=0; i--)
    {
      //Create the locations
      stroke(c);
      gp = pnts[i];
      if(gp==null||lastgp==null)
        break;
      //Map makes sure that the data points are put into the proper places
      float posi = map(gp.y, 20,700, 0, maxHeight);
      float lastposi = map(lastgp.y, 20,700, 0, maxHeight);
      line(xPos+i+1,yPos+lastposi,xPos+i,yPos+posi);
      lastgp = gp;
    }
  }
}

class GraphPoint
{
  //Raw arduino data
  //A point on the graph
  float y;
  GraphPoint(float iny)
  {
    y=iny;
  }
}

Graph ilocosGraph = new Graph(85, 61, 63,color(200,100,100));
void drawIlocosGraph()
{
  //61, 52
  ilocosGraph.update(ilocos.data);
  ilocosGraph.display();
}

void drawIlocos()
{
  if(ilocos==null||!ilocos.active)
  {
    println("Arduino Ilocos timed out.");
    ilocos=null;
    return;
  }
  fill(255);
  text("Ilocos Norte",61,52);
  ilocos.update();
  fill(ilocos.c);
  stroke(ilocos.c);
  ellipse(192,46,10,10);
  drawIlocosMap();
  drawIlocosGraph();
}

void drawIlocosMap()
{
  float mapx = map(ilocos.data,20, 700,0,(tecMax/3)*-1);
  float mapy = map(ilocos.data,20, 700,0,tecMax*-1);
  image(topPlate,mapx,mapy,width,height);
  //fill(ilocos.c);
  ellipse(mapx+441,mapy+49,10,10);
}

void drawTarlacMap()
{ 
  //Dot at X: 394 Y: 556
  float mapx = map(tarlac.data,20, 700,0,(tecMax/3));
  float mapy = map(tarlac.data,20, 700,0,tecMax);
  image(botPlate,mapx,mapy,width,height);
  //fill(tarlac.c);
  ellipse(mapx+394,mapy+556,10,10);
}

Graph tarlacGraph = new Graph(85, 61, 160,color(10,120,50));
void drawTarlacGraph()
{
  //61, 52
  tarlacGraph.update(tarlac.data);
  tarlacGraph.display();
}

void drawTarlac()
{
  if(tarlac==null||!tarlac.active)
  {
    tarlac=null;
    println("Arduino Tarlac timed out.");
    return;
  }
  //text dot X: 129 Y: 137
  fill(255);
  text("Tarlac",61,140);
  tarlac.update();
  fill(tarlac.c);
  stroke(tarlac.c);
  ellipse(129,135,10,10);
  drawTarlacMap();
  drawTarlacGraph();
}

void serverEvent(Server thisServer, Client arduinoClient)
{
  //This gets called when a client connects to the server.
  //The first one that connects is ilocos, the second one is tarlac
  try
  {
    Arduino a = new Arduino(arduinoClient);
    if(ilocos==null)
    {
      ilocos = a;
      ilocos.c = color(230,100,100);
      println("Arduino Ilocos connected with IP "+a.client.ip());
    }
    else if(tarlac == null)
    {
      tarlac = a;
      tarlac.c = color(100,200,100);
      println("Arduino Tarlac connected with IP "+a.client.ip());
    }
    else
    {
      println("Extra connection ignored.");
    }
  }
  catch (Exception e)
  {
    println("Caught exception in serverEvent");
  }
}

class Arduino 
{
  //The arduino class
  int id;
  float data;
  float lastData;
  float lastPnt = -1;
  Client client;
  color c;
  boolean active=false;
  int timeOut;
  Arduino(Client c)
  {
    timeOut=0;
    this.c = color(random(50,255),random(50,255),random(50,255));
    this.client = c;
    while (c.available () == 0) {} //Wait for the client
    id = int(trim(c.readStringUntil(lineRet)));
    while (c.available () == 0) {} //Wait for the client to give us initial data
    data = float(trim(c.readStringUntil(lineRet)));
    lastData=data;
    c.clear();
    active = true;
  }

  void update()
  {
    //Grabs another portion of data from the arduino
    if (client.available()>0)
    {
      String in = client.readStringUntil(lineRet);
      if (in!=null)
      {
        float dataIn = float(trim(in));
        if(abs(dataIn-lastData)>=thresh && dataIn>15)
        {
          lastData=data;
          data = dataIn;
        }
        println(data);
        client.clear();
        timeOut=0;
      }
    }
    else
    {
      timeOut++;
      if(timeOut>=timeOutMax)
      {
        active = false;
      }
    }
  }
}

void keyPressed() {
  //Space is pressed, go to the next map.
  if (key == ' ') {
    bigmap++;
    if(bigmap>2)
      bigmap=0;
    if(bigmap==0)
      background(0);
    else
      background(oceanColor);
  }
}
