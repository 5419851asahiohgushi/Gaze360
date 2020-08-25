import ddf.minim.*;
Minim minim;
AudioPlayer kettei;
AudioPlayer Explosion;
AudioPlayer OpBGM;
AudioPlayer MainBGM;
AudioPlayer Good;
AudioPlayer Bad;

PImage cosmos;
PImage earth;
PImage explosion;
PImage meteor;
int scene=0;

class Player {
  int size = 40;
  int limitSize = 600;
  float playerX, playerY;
  boolean limit=true;
  void playerMove() {
    stroke(255);
    noFill();
    ellipse(width/2, height/2, limitSize, limitSize);
    if (limit==true) { 
      if (dist(mouseX, mouseY, width/2, height/2)<limitSize/2-size) {
        playerX=mouseX;
        playerY=mouseY;
      }
      ellipse(playerX, playerY, size, size);  
      image( earth, playerX-50, playerY-50 );
    }
  }
  void moveLimit() {
    if (dist(playerX, playerY, width/2, height/2)<=limitSize/2) {
      limit=true;
    } else {
      limit=false;
    }
  }
}
class Screen {
  int x=width/2, y=height/2;
  int size=300;
  //boolean start=true;
  int score ;
  int time = millis();
  int startTime;
  void startScreen() {
    MainBGM.loop();
    fill(255);
    text("YOKERUNDESU", width/2, height/3);
    text("GameStart", width/2, height*3/4);
    noFill();
    rect(width/2, height*3/4, size, 80);

    if ((width/2-size/2<=mouseX&&mouseX<=width/2+size/2)&&(height*3/4-40<=mouseY&&mouseY<=height*3/4+40)) {         
      if (mousePressed) {
        kettei.play();
        kettei.rewind(); 
        scene=1;
        c.clean();
        startTime = millis();
      }
    }
  }
  void gemeScreen() { 
    OpBGM.rewind();
    int nowTime = millis();
    int continueTime;
    continueTime = nowTime - startTime;
    score=0;
    score += (continueTime / 100);   
    fill(255);
    text("score: "+score, 150, 50);
    println(score);
  }
  void endScreen() {  
    OpBGM.rewind();
    background(explosion);
    text("GameOver", width/2, height*1/4);
    text("score:"+score, width/2, height/2);

    if (mousePressed) {
      kettei.play();
      kettei.rewind(); 
      scene=0;
      score=0;
    }
  }
}
class Meteor {
  int meteorNum = 30; 
  float[] meteorXs = new float [meteorNum];
  float[] meteorYs = new float [meteorNum];
  float[] xSteps = new float [meteorNum];
  float[] ySteps = new float [meteorNum];
  float[] slope = new float [meteorNum];
  float[] intercept = new float [meteorNum];
  boolean[] isExisting = new boolean[meteorNum];
  boolean isGameOver = false;
  float rad = 20;
  void clean() {
    for (int i = 0; i < meteorNum; i++) {
      isExisting[i] = false;
    }
  }
  boolean moveMeteor() {
    float meteorX, meteorY;
    for (int i = 0; i < meteorNum; i++) {
      if (isExisting[i]) {
        if (meteorXs[i] == width / 2) {
          meteorX = width / 2;
          meteorY = meteorYs[i];
        } else if (meteorYs[i] == height / 2) {
          meteorX = meteorXs[i];
          meteorY = height / 2;
        } else {
          meteorX = (meteorYs[i] - intercept[i]) / slope[i];
          meteorY = slope[i] * meteorXs[i] + intercept[i];
        }
        ellipse(meteorX, meteorY, rad * 2, rad * 2);
        pushMatrix();
        translate(meteorX, meteorY);
        imageMode(CENTER);
        image(meteor, 0, 0);
        imageMode(CORNER);
        popMatrix();
        meteorXs[i] += xSteps[i];
        meteorYs[i] += ySteps[i];
        if (meteorXs[i] < -(rad) || width + (rad) < meteorXs[i]) {
          isExisting[i] = false;
        }
        if (dist(mouseX, mouseY, meteorX, meteorY) < rad * 2) {
          return true;
        }
      } else {
        makeMeteor(i);
      }
    }
    return false;
  }
  void makeMeteor(int num) {
    meteorXs[num] = 0;
    meteorYs[num] = 0;
    if (isExisting[num] == false) {
      switch(int(random(0, 1000))) {
      case 1:
        while (isExisting[num] == false) {
          switch(int(random(0, 5))) {
          case 1:
            meteorXs[num] = -rad;
            meteorYs[num] = random(-rad, height + rad + 1);
            isExisting[num] = true;
            break;
          case 2:
            meteorXs[num]= width + rad;
            meteorYs[num] = random(-rad, height + rad + 1);
            isExisting[num] = true;
            break;
          case 3:
            meteorXs[num] = random(-rad, width + rad + 1);
            meteorYs[num] = -rad;
            isExisting[num] = true;
            break;
          case 4:
            meteorXs[num] = random(-rad, width + rad + 1);
            meteorYs[num] = height + rad;
            isExisting[num] = true;
            break;
          default:
            meteorXs[num] = 0;
            meteorYs[num] = 0;
            break;
          }
        }
        float len = dist(meteorXs[num], meteorYs[num], width / 2, height / 2);
        xSteps[num] = dist(meteorXs[num], 0, width / 2, 0) / (len / 3);
        ySteps[num] = -dist(0, meteorYs[num], 0, height / 2) / (len / 3);
        if (meteorXs[num] == width / 2) {
          if (meteorYs[num] <= 0) {
            ySteps[num] *= -1;
          }
        } else if (meteorYs[num] == height / 2) {
          if (meteorXs[num] >= width) {
            xSteps[num] *= -1;
            ;
          }
        } else if ((meteorXs[num] <= 0 && meteorYs[num] < height / 2) || (meteorXs[num] < width / 2 && meteorYs[num] <= 0)) {
          ySteps[num] *= -1;
        } else if (meteorXs[num] >= width / 2 && (meteorYs[num] >= height || meteorYs[num] >= height / 2)) {
          xSteps[num] *= -1;
        } else if (meteorXs[num] >= width / 2 && (meteorYs[num] <= 0 || meteorYs[num] <= height / 2)) {
          xSteps[num] *= -1;
          ySteps[num] *= -1;
        } 
        slope[num] = (meteorYs[num] - (height / 2)) / (meteorXs[num] - (width / 2));
        intercept[num] = meteorYs[num] - slope[num] * meteorXs[num];
        break;
      default:
        isExisting[num] = false;
        break;
      }
    }
  }
}
Screen a;
Player b;
Meteor c;

void setup() {
  textAlign(CENTER, CENTER);
  rectMode(CENTER);
  size(1000, 1000);
  textSize(50);

  minim = new Minim(this);
  kettei = minim.loadFile("kettei.wav");
  Explosion = minim.loadFile("Explosion.wav");
  MainBGM = minim.loadFile("opening.mp3");
  OpBGM = minim.loadFile("main.mp3");
  Good = minim.loadFile("good.wav");
  Bad = minim.loadFile("bad.wav");

  cosmos = loadImage( "cosmos.jpeg" );
  cosmos.resize(1000, 1000);  
  earth = loadImage( "earth.png" );
  earth.resize(100, 100);
  explosion = loadImage( "explosion.jpg" );
  explosion.resize(1000, 1000);
  meteor = loadImage("meteor.png");
  meteor.resize(50, 50);
  OpBGM.loop();

  //starttm = millis();
  a=new Screen();
  b = new Player();
  c = new Meteor();
}
void draw() {

  background(cosmos);
  if (scene==0) {
    a.startScreen();
  } else if (scene==1) {
    OpBGM.rewind();
    a.gemeScreen();
    b.playerMove();
    if (c.moveMeteor()) {
      scene = 2;
      MainBGM.pause();
      Explosion.play();
      Explosion.rewind();
    }
    //b.moveLimit();
  } else {  
    a.endScreen();
  }
}