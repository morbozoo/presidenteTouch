/**
 * oscP5sendreceive by andreas schlegel
 * example shows how to send and receive osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 
import oscP5.*;
import netP5.*;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import processing.simpletouch.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

SimpleTouch touchscreen;

PImage escultura;
PImage signature;
PImage brightness;
PImage speed;

Button[] organicos  = new Button[4];
Button[] triangulos = new Button[4];
Button onOff        = new Button();

Slider sliderBright = new Slider();
Slider sliderSpeed  = new Slider();

boolean jetsonIsOn  = false;

String projectorOn  = "python on.py";
String projectorOff = "python off.py";
String returnedValues;
File workingDir = new File("/usr/local/lib/processing-3.0.1/modes/java/examples/Topics/GUI/presidente/data");

void setup() {
  fullScreen();
  frameRate(30);

  println("Available input devices:");
  String[] devs = SimpleTouch.list();
  printArray(devs);
  if (devs.length == 0) {
    println("No input devices available");
    exit();
  }
  touchscreen = new SimpleTouch(this, devs[2]);
  println("Opened device: " + touchscreen.name());

  escultura     = loadImage("Escultura_on.png");
  signature     = loadImage("signature.png");
  brightness    = loadImage("brightness.png");
  speed         = loadImage("speed.png");

  onOff.setImg("On-off.png");
  onOff.setPos(new PVector(40, 40));
  onOff.isOnOff = true;
  for (int i = 0; i < organicos.length; i++) {
    organicos[i] = new Button();
    organicos[i].setImg("mood_" + (i+5) + ".png");
    organicos[i].setPos(new PVector(420 + i * (organicos[i].sizeW + 35), 350));

    triangulos[i] = new Button();
    triangulos[i].setImg("mood_" + (i+1) + ".png");
    triangulos[i].setPos(new PVector(420 + i * (triangulos[i].sizeW + 35), 240));
  }

  sliderBright.setup(new PVector(450, 80), 300, 38);
  sliderSpeed.setup(new PVector(450, 180), 300, 30);

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12345);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("192.168.1.103",12345);
}


void draw() {
  noCursor();
  background(0);  

  if (onOff.on) {
    image(escultura, 90, 10, 280, 460);
    image(signature, 490, 440);
    image(brightness, 600, 30);
    image(speed, 600, 130);

    SimpleTouchEvt touches[] = touchscreen.touches();
    for (SimpleTouchEvt touch : touches) {
    // the id value is used to track each touch
    // we use it to assign a unique color
    //fill((touch.id * 100) % 360, 100, 100);
    // x and y are values from 0.0 to 1.0
    //ellipse(width * touch.x, height * touch.y, 100, 100);
      for (int i = 0; i < organicos.length; i++) {
        if (organicos[i].over(new PVector(width * touch.x, height * touch.y))) {
          select(0, i);
        }else if(triangulos[i].over(new PVector(width * touch.x, height * touch.y))){
          select(1, i);
        }
      }
      if (onOff.over(new PVector(width * touch.x, height * touch.y)) && !onOff.locked) {
        onOff.lock();
        sendMessage(2, 1);
      }
      if (sliderBright.over(new PVector(width * touch.x, height * touch.y))) {
        sendMessage(3, sliderBright.getValor());
      }
      if (sliderSpeed.over(new PVector(width * touch.x, height * touch.y))) {
        sendMessage(4, sliderSpeed.getValor());
      }
    }
    onOff.update();
    onOff.draw();
    for (int i = 0; i < organicos.length; i++) {
      organicos[i].draw();
      triangulos[i].draw();
    }
    sliderBright.draw();
    sliderSpeed.draw();  
  } else{
    SimpleTouchEvt touches[] = touchscreen.touches();
    for (SimpleTouchEvt touch : touches) {
      if (onOff.over(new PVector(width * touch.x, height * touch.y)) && !onOff.locked) {
        onOff.lock();
        sendMessage(2, 2);
      }
    }
    onOff.update();
    onOff.draw();
  }
}


void select(int deCual, int selected){
  if (deCual == 0) {
    for (int i = 0; i < organicos.length; i++) {
      if (i == selected) {
        sendMessage(0,i);
        organicos[i].select();
        sendMessage(3, organicos[i].getBright());
        sliderBright.setValor(organicos[i].getBright());
        sendMessage(4, organicos[i].getSpeed());
        sliderSpeed.setValor(organicos[i].getSpeed());
        triangulos[i].deselect();
      }else{
        organicos[i].deselect();
        triangulos[i].deselect();
      }
    }
  }else {
    for (int i = 0; i < triangulos.length; i++) {
      if (i == selected) {
        sendMessage(1,i);
        triangulos[i].select();
        sendMessage(3, triangulos[i].getBright());
        sliderBright.setValor(triangulos[i].getBright());
        sendMessage(4, triangulos[i].getSpeed());
        sliderSpeed.setValor(triangulos[i].getSpeed());
        organicos[i].deselect();
      }else{
        triangulos[i].deselect();
        organicos[i].deselect();
      }
    }
  }
}

void sendMessage(int deCual, float cual){
  OscMessage myMessage;
  if (deCual == 0) {
    myMessage = new OscMessage("mood");
    myMessage.add(cual);
    oscP5.send(myMessage, myRemoteLocation);
  }else if (deCual == 1) {
    myMessage = new OscMessage("mood");
    myMessage.add(cual + 4);
    oscP5.send(myMessage, myRemoteLocation);
  }else if (deCual == 2) {
    if (cual == 2) {
      myMessage = new OscMessage("on");
      oscP5.send(myMessage, myRemoteLocation);
      if (jetsonIsOn) {
        onOff.on = !onOff.on;
        for (int i = 0; i < organicos.length; i++) {
          organicos[i].deselect();
          triangulos[i].deselect();
        }
      }
      
    }else{
      myMessage = new OscMessage("off");
      oscP5.send(myMessage, myRemoteLocation);
      onOff.on = !onOff.on;
      projector(projectorOff);
    }
  }else if (deCual == 3) {
    myMessage = new OscMessage("slider1");
    myMessage.add(cual);
    oscP5.send(myMessage, myRemoteLocation);
  }else if (deCual == 4) {
    myMessage = new OscMessage("slider2");
    myMessage.add(cual);
    oscP5.send(myMessage, myRemoteLocation);
  }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  if (theOscMessage.checkAddrPattern("imOn")==true) {
    print("### true");
    jetsonIsOn = true;
  }else if (theOscMessage.checkAddrPattern("imOff")==true) {
    jetsonIsOn = false;
  }
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}

void projector(String commandToRun){
    try {

    // complicated!  basically, we have to load the exec command within Java's Runtime
    // exec asks for 1. command to run, 2. null which essentially tells Processing to 
    // inherit the environment settings from the current setup (I am a bit confused on
    // this so it seems best to leave it), and 3. location to work (full path is best)
    Process p = Runtime.getRuntime().exec(commandToRun, null, workingDir);

    // variable to check if we've received confirmation of the command
    int i = p.waitFor();

    // if we have an output, print to screen
    if (i == 0) {

      // BufferedReader used to get values back from the command
      BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));

      // read the output from the command
      while ( (returnedValues = stdInput.readLine ()) != null) {
        println(returnedValues);
      }
    }

    // if there are any error messages but we can still get an output, they print here
    else {
      BufferedReader stdErr = new BufferedReader(new InputStreamReader(p.getErrorStream()));

      // if something is returned (ie: not null) print the result
      while ( (returnedValues = stdErr.readLine ()) != null) {
        println(returnedValues);
      }
    }
  }

  // if there is an error, let us know
  catch (Exception e) {
    println("Error running command!");  
    println(e);
  }
}