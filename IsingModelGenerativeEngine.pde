//Thomas Power - 22/5/16

import themidibus.*; //Import the library

MidiBus myBus; // The MidiBus


//Cell Parameters
int cellsize = 100;
int cellnum = 5;
boolean isRunning = false;

//Set up 2D array to store spin states -1 or 1
int[][] spin = new int[cellnum][cellnum];

int channel = 0;
int pitch1 = 64;
int pitch2 = 76;
int velocity = 60;
int random;

float beta = 0.44; //critical point = 0.44
float p, E;
float J = 1.0;

void setup() {
  size(cellsize*cellnum, cellsize*cellnum);
  
  frameRate(4);
  noStroke();
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(this, -1, "cloud"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.

  for (int i = 0; i < cellnum; i++) {
    for (int j = 0; j < cellnum; j++) {
      //Assign each cell a random spin
      spin[i][j] = 2*int(random(2))-1;
    }
  }
}

void draw() {

  if (isRunning) {
   // random = int(random(4));
    pitch2 = int(random(30,110));

 

    velocity = int(random(10, 70));

    for (int i = 0; i < cellnum; i++) {
      for (int j = i%2; j < cellnum; j += 2) {
        p = random(1);
        E = J*spin[i][nextcell(j)]+spin[i][previouscell(j)]+spin[nextcell(i)][j]+spin[previouscell(i)][j];
        if (p < exp(beta*E)/(exp(beta*E)+exp(-beta*E))) {
          spin[i][j] = 1;
          myBus.sendNoteOn(channel, pitch2, velocity);
        } else {
          spin[i][j] = -1;
          myBus.sendNoteOff(channel, pitch2, velocity); // Send a Midi noteOn
        }
      }
    }
    for (int i = 0; i < cellnum; i++) {
      for (int j = (i+1)%2; j < cellnum; j += 2) {
        p = random(1);
        E = J* spin[i][nextcell(j)]+spin[i][previouscell(j)]+spin[nextcell(i)][j]+spin[previouscell(i)][j];
        if (p < exp(beta*E)/(exp(beta*E)+exp(-beta*E))) {
          spin[i][j] = 1;
          myBus.sendNoteOn(channel, pitch2, velocity); // Send a Midi noteOn
        } else {
          spin[i][j] = -1;

          myBus.sendNoteOff(channel, pitch2, velocity); // Send a Midi noteOn
        }
      }
    }

    for (int i = 0; i < cellnum; i++) {
      for (int j = 0; j < cellnum; j++) {
        if (spin[i][j] == 1) {
          fill(255, 200);
        } else {
          fill(0, 200);
        }
        //ellipseMode(CORNER);
        rect(cellsize*i, cellsize*j, cellsize, cellsize);
      }
    }

    int sum = 0;
    for (int i = 0; i < cellnum; i++) {
      for (int j = 0; j < cellnum; j++) {
        sum += spin[i][j];
      }
    }

    // println(sum/pow(cellnum,2));
  }
}

int nextcell(int i) {
  if (i+1 >= cellnum) {
    return 0;
  } else {
    return i+1;
  }
}

int previouscell(int i) {
  if (i <= 0) {
    return cellnum-1;
  } else {
    return i-1;
  }
}

void keyPressed() {

  if (keyCode == UP) {
    beta += 0.01; 
    J+=0.1;
    println("J: " + J + "beta: " + beta);
  }

  if (keyCode == DOWN) {
    beta -= 0.01; 
    J-=0.1;
  }


  if (keyCode == RIGHT) {
    isRunning = !isRunning;
  }
}

void mousePressed() {
  for (int i = 0; i < cellnum; i++) {
    for (int j = 0; j < cellnum; j++) {
      //Assign each cell a random spin
      spin[i][j] = 2*int(random(2))-1;
    }
  }
}

