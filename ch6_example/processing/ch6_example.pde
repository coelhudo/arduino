import processing.serial.*;
import java.net.*;
import java.io.*;
import java.util.*;

String feed = "http://blog.makezine.com/index.html";

int interval = 10; // retrieve feed every 60 seconds
int lastTime; // the last time we fetched the content

int love = 0;
int peace = 0;
int arduino = 0;

int light = 0; // light level measured by the lamp

Serial port;
color c;
String cs;

String buffer = ""; // Accumulates characters comming from Arduino

PFont font;

void setup() {
  size(640, 480);
  frameRate(10); // we dont need fast updates
  
  font = loadFont("Arial-BoldMT-32.vlw");
  fill(255);
  textFont(font, 32);
  
  // IMPORNTANT
  // The first serial port retrieve by Serial.list() should be your Arduino.
  // If not, uncomment the next line by deleting the // before it, and re-run the sketch to see a list of serial ports
  // Then, change the 0 between [ and ] to the numer of the port that your Arduino is connected to.
  // println(Serial.list())
  
  String arduinoPort = Serial.list()[0];
  port = new Serial(this, arduinoPort, 9600);
  
  lastTime = 0;
  fetchData();
}

void draw() {
  background(c);
  int n = (interval - ((millis()-lastTime)/1000));
  
  // Build a colour based on the 3 values
  c = color(peace, love, arduino);
  cs = "#"+ hex(c,6);
  
  text("Arduino Networked Lamp", 10, 40);
  text("Reading feed: ", 10, 100);
  text(feed, 10, 140);
  
  text("Next update in " + n + "seconds", 10, 450);
  text("peace", 10, 20);
  text(" " + peace, 130, 240);
  rect(200, 252, arduino, 28);
  
  // write the color string to the screen
  text("sending", 10, 340);
  text(cs, 200, 340);
  
  text("light level", 10, 380);
  rect(200, 352, light/10.23, 28); // this turns 1-23 into 100
  
  if(n <= 0) {
    fetchData();
    lastTime = millis();
  }
  
  port.write(cs); // send data to Arduino
  
  if(port.available() > 0) { // check if there is data waiting
    int inByte = port.read(); // read one byte
    if(inByte != 10) { // if byte is not newline
      buffer = buffer + char(inByte); // append
    } else {
      
      //newline reached, lets process the data
      if (buffer.length() > 1) { // make sure there is enought data
        //chop off the last character, it is a carriage return
        buffer = buffer.substring(0,buffer.length() -1);
        
        //turn the buffer from string into an integer number
        light = int(buffer);
        
        //clean the buffer for the next read cycle
        
        buffer = "";
        
        port.clear();
      }
    }
  }
}

void fetchData() {
  // we use these strings to parse the feed
  String data;
  String chunk;
  
  // zero the counters
  love = 0;
  peace = 0;
  arduino = 0;
  
  try {
    URL url = new URL(feed); // an object to represent the url 
    //prepare a connection
    URLConnection conn = url.openConnection();
    conn.connect();
    
    BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
    
    // read each line from the feed
    while ((data = in.readLine()) != null) {
      
      StringTokenizer st = new StringTokenizer(data, "\"<>,.()[] "); //break it down
      
      while(st.hasMoreTokens()) {
        //each chunk of data is made lowercase
        chunk = st.nextToken().toLowerCase();
        
        if(chunk.indexOf("love") >= 0)
          love++;
        if(chunk.indexOf("peace") >= 0)
          peace++;
        if(chunk.indexOf("arduino") >= 0)
          arduino++;
      }
    }
    
    // Set 64 to be the maximum number of references we care about
    if (peace > 64) peace = 64;
    if (love > 64) love = 64;
    if (arduino > 64) arduino = 64;
    peace *= 4;
    love *= 4;
    arduino *= 4;
  } catch (Exception ex) {
    ex.printStackTrace();
    System.out.println("ERROR: " + ex.getMessage());
  }
}
