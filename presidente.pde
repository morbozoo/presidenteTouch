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
PImage splash;

Button[] organicos  = new Button[4];
Button[] triangulos = new Button[4];
Button onOff        = new Button();

Slider sliderBright = new Slider();
Slider sliderSpeed  = new Slider();

boolean jetsonIsOn  = false;
boolean isLoading   = false;
int startTime     = 0;
int endTime       = 0;

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
  splash        = loadImage("loading.png");

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

  sliderBright.setup(new PVector(450, 80), 300, 38, "brightness.png");
  sliderSpeed.setup(new PVector(450, 180), 300, 30, "speed.png");

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
    if (isLoading) {
      image(splash, 0, 0);
      stroke(255);
      fill(0);
      rect(200, 380, 400, 25);
      fill(255);
      rect(205, 385, ((millis() - startTime) * (390.0f/30000.0f)), 15);
      if (millis() >= endTime) {
        isLoading = false;
        onOff.on = !onOff.on;
        OscMessage myMessage = new OscMessage("on");
        oscP5.send(myMessage, myRemoteLocation);
      }
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
  println("bright = " + sliderBright.getValor());
  println("speed = " + sliderSpeed.getValor());  
}


void select(int deCual, int selected){
  if (deCual == 0) {
    for (int i = 0; i < organicos.length; i++) {
      if (i == selected) {
        sendMessage(0,i);
        organicos[i].select();
        sliderSpeed.isTri = false;
        sliderBright.isTri = true;
        if (i == 1) {sliderSpeed.isTri = true;}
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
        sliderSpeed.isTri = true;
        sliderBright.isTri = true;
        sendMessage(3, triangulos[i].getBright());
        sliderBright.setValor(triangulos[i].getBright());
        sendMessage(4, triangulos[i].getSpeed());
        sliderSpeed.setValor(triangulos[i].getSpeed());
        organicos[i].deselect();
  switch(i) {
  case 0: 
    sliderSpeed.setValor(28.0f);
    break;
  case 1: 
    sliderSpeed.setValor(66.0f);
    break;
  case 2: 
    sliderSpeed.setValor(68.0f);
    break;
  case 3: 
    sliderSpeed.setValor(10.0f);
    break;
  }
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
      loading();
      if (jetsonIsOn && !isLoading) {
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

void loading(){
  isLoading = true;
  startTime = millis();
  //endTime   = startTime + 30000;
  endTime   = startTime + 30;
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
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}

void projector(String commandToRun){
    try {
    Process p = Runtime.getRuntime().exec(commandToRun, null, workingDir);
    int i = p.waitFor();
    if (i == 0) {
      BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
      while ( (returnedValues = stdInput.readLine ()) != null) {
        println(returnedValues);
      }
    }
    else {
      BufferedReader stdErr = new BufferedReader(new InputStreamReader(p.getErrorStream()));
      while ( (returnedValues = stdErr.readLine ()) != null) {
        println(returnedValues);
      }
    }
  }
  catch (Exception e) {
    println("Error running command!");  
    println(e);
  }
}