/**
 * oscP5sendreceive by andreas schlegel
 * example shows how to send and receive osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 
import oscP5.*;
import netP5.*;
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
    organicos[i].setPos(new PVector(420 + i * (organicos[i].sizeW + 35), 240));

    triangulos[i] = new Button();
    triangulos[i].setImg("mood_" + (i+1) + ".png");
    triangulos[i].setPos(new PVector(420 + i * (triangulos[i].sizeW + 35), 350));
  }

  sliderBright.setup(new PVector(450, 80), 300, 38);
  sliderSpeed.setup(new PVector(450, 180), 300, 30);

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("192.168.0.13",12345);
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
    onOff.on = !onOff.on;
    if (cual == 2) {
      myMessage = new OscMessage("on");
      oscP5.send(myMessage, myRemoteLocation);
      for (int i = 0; i < organicos.length; i++) {
        organicos[i].deselect();
        triangulos[i].deselect();
      }
    }else{
      myMessage = new OscMessage("off");
      oscP5.send(myMessage, myRemoteLocation);
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
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}