import com.shigeodayo.ardrone.processing.*;
import intel.pcsdk.*;

ARDroneForP5 ardrone;

PImage rgbImage;
int[] rgb_size = new int[2];
PXCUPipeline session;

void setup() {
  size(960, 480);

  //AR.Drone Setup
  ardrone=new ARDroneForP5("192.168.1.1");
  ardrone.connect();
  ardrone.connectNav();
  ardrone.connectVideo();
  ardrone.start();
  
  //PerC Setup
  session = new PXCUPipeline(this);
  if (!session.Init(PXCUPipeline.COLOR_VGA|PXCUPipeline.GESTURE))
    exit();

  if(session.QueryRGBSize(rgb_size))
    rgbImage=createImage(rgb_size[0], rgb_size[1], RGB);
}

void draw() {
  background(204);  

  // getting image from AR.Drone
  // true: resizeing image automatically
  // false: not resizing
  PImage img = ardrone.getVideoImage(false);
  if (img == null)
    return;
  image(img, 0, 0,640,480);

  // print out AR.Drone information
  //ardrone.printARDroneInfo();

  // getting sensor information of AR.Drone
  float pitch = ardrone.getPitch();
  float roll = ardrone.getRoll();
  float yaw = ardrone.getYaw();
  float altitude = ardrone.getAltitude();
  float[] velocity = ardrone.getVelocity();
  int battery = ardrone.getBatteryPercentage();

  String attitude = "pitch:" + pitch + "\nroll:" + roll + "\nyaw:" + yaw + "\naltitude:" + altitude;
  text(attitude, 20, 85);
  String vel = "vx:" + velocity[0] + "\nvy:" + velocity[1];
  text(vel, 20, 140);
  String bat = "battery:" + battery + " %";
  text(bat, 20, 170);
  
  if (session.AcquireFrame(false))
  {
    session.QueryRGB(rgbImage);
    if(session.QueryGesture(PXCMGesture.GeoNode.LABEL_ANY, gest))
    {
      ParseGesture(gest) ;
    }
    session.ReleaseFrame();
  }
  
  image(rgbImage, 640, 0, 320, 240);
  
}

PXCMGesture.Gesture gest = new PXCMGesture.Gesture();
void ParseGesture(PXCMGesture.Gesture gest)
{
  if (!gest.active)
    return ;
    
  if (gest.label == PXCMGesture.Gesture.LABEL_NAV_SWIPE_LEFT)
  {
    println("Swipe left");
    ardrone.spinLeft(); 
  }
  else if (gest.label == PXCMGesture.Gesture.LABEL_NAV_SWIPE_RIGHT)
  {
    println("Swipe right");
    ardrone.spinRight(); 
  }
  else if (gest.label == PXCMGesture.Gesture.LABEL_NAV_SWIPE_UP)
  {
    println("Swipe up");
    ardrone.up();  
  }
  else if (gest.label == PXCMGesture.Gesture.LABEL_NAV_SWIPE_DOWN)
  {
    println("Swipe down");
    ardrone.down();     
  }
  else if (gest.label == PXCMGesture.Gesture.LABEL_HAND_CIRCLE)
  {
    println("Gesture : Circle , Meaning: Take off");
    ardrone.takeOff();
  }else if (gest.label == PXCMGesture.Gesture.LABEL_POSE_PEACE)
  {
    println("Gesture : Peace , Meaning : Landing");
    ardrone.landing();
  }
}

// controlling AR.Drone through key input
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      ardrone.forward(); // go forward
    } 
    else if (keyCode == DOWN) {
      ardrone.backward(); // go backward
    } 
    else if (keyCode == LEFT) {
      ardrone.goLeft(); // go left
    } 
    else if (keyCode == RIGHT) {
      ardrone.goRight(); // go right
    } 
    else if (keyCode == SHIFT) {
      ardrone.takeOff(); // take off, AR.Drone cannot move while landing
    } 
    else if (keyCode == CONTROL) {
      ardrone.landing();
      // landing
    }
  } 
  else {
    if (key == 's') {
      ardrone.stop(); // hovering
    } 
    else if (key == 'r') {
      ardrone.spinRight(); // spin right
    } 
    else if (key == 'l') {
      ardrone.spinLeft(); // spin left
    } 
    else if (key == 'u') {
      ardrone.up(); // go up
    }
    else if (key == 'd') {
      ardrone.down(); // go down
    }
    else if (key == '1') {
      ardrone.setHorizontalCamera(); // set front camera
    }
    else if (key == '2') {
      ardrone.setHorizontalCameraWithVertical(); // set front camera with second camera (upper left)
    }
    else if (key == '3') {
      ardrone.setVerticalCamera(); // set second camera
    }
    else if (key == '4') {
      ardrone.setVerticalCameraWithHorizontal(); //set second camera with front camera (upper left)
    }
    else if (key == '5') {
      ardrone.toggleCamera(); // set next camera setting
    }
  }
}

void exit()
{
  session.Close(); 
  super.exit();
}
