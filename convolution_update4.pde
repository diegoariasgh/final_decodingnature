//gracias Joaquin
boolean sharpen0, sharpen1, sharpen2, sharpen3, sharpen4, sharpen5, sharpen6, sharpen7, sharpen8 = false;
PImage img;
Flock flock;
float xPos0, xPos1, xPos2, xPos3, xPos4, xPos5, xPos6, xPos7, xPos8;

float sharpen[][] = {
  {-1, -1, -1}, 
  {-1, 9, -1}, 
  {-1, -1, -1}
};

float sobelX[][] = {
  {1, 0, -1}, 
  {2, 0, -2}, 
  {1, 0, -1}
};

float sobelY[][] = {
  {1, 2, 1}, 
  {0, 0, 0}, 
  {-1, -2, -1}
};

float scharrX[][] = {
  {3, 0, -3}, 
  {10, 0, -10}, 
  {3, 0, -3}
};

float scharrY[][] = {
  {3, 10, 3}, 
  {0, 0, 0}, 
  {-3, -10, -3}
};

int w = 100;

float matrix[][] = sharpen;
boolean convolve = true;
boolean reprocess = true;



void setup() {
  size(800, 600);
  img = loadImage("data/moon.jpg");
  flock = new Flock();
  for (int i = 0; i < 9; i++) {
    Boid b = new Boid(width/2, height/2);
    flock.addBoid(b);
  }
}

void draw() {
  flock.run();

  // so let's set the whole image as the background first
  if (reprocess) {//only process once
    image(img, 0, 0);
    if (convolve) {
      processImage(matrix);
    }
    // reprocess = false;
  }
  xPos0 = map(flock.boids.get(0).position.x, 0, 800, -10, 10);  
  println("xPos0: " + xPos0);
  xPos1 = map(flock.boids.get(1).position.x, 0, 800, -5, 5);
  println("xPos1: " + xPos1);
  xPos2 = map(flock.boids.get(2).position.x, 0, 800, -1, 1);
  println("xPos2: " + xPos2);
  xPos3 = map(flock.boids.get(3).position.x, 0, 800, -5, 5);
  println("xPos3: " + xPos3);
  xPos4 = map(flock.boids.get(4).position.x, 0, 800, -.01, .01);
  println("xPos4: " + xPos4);
  xPos5 = map(flock.boids.get(5).position.x, 0, 800, -.01, .01);
  println("xPos5: " + xPos5);
  xPos6 = map(flock.boids.get(6).position.x, 0, 800, -.01, .01);
  println("xPos6: " + xPos6);
  xPos7 = map(flock.boids.get(7).position.x, 0, 800, -.05, .05);
  println("xPos7: "+ xPos7);
  xPos8 = map(flock.boids.get(8).position.x, 0, 800, -.05, .05);
  println("xPos8: " + xPos8);

  if (sharpen0 == true) {
    sharpen[0][0] += xPos0*.1;
  }
  if (sharpen1 == true) {
    sharpen[0][1] += xPos1*(.001);
  }
  if (sharpen2 == true) {
    sharpen[0][2] += xPos2*(.001);
  }
  if (sharpen3 == true) {
    sharpen[1][0] -= xPos3*(.001);
  }
  if (sharpen4 == true) {
    sharpen[1][1] -= xPos4*(.001);
  }
  if (sharpen5 == true) {
    sharpen[1][2] = .5 + sharpen[1][2] % (xPos5 + .1);
  }
  if (sharpen6 == true) {
    sharpen[2][0] = .5 + sharpen[2][0] % (xPos6 - .8);
  }
  if (sharpen7 == true) {
    sharpen[2][1] = .5 + sharpen[2][1] % (4 - xPos7);
  }
  if (sharpen8 == true) {
    sharpen[2][2] = xPos8 + sharpen[2][2] % (8 - .9);
  }
}

void processImage(float matrix[][]) {
  // In this example we are only processing a section of the image
  int xstart = constrain(mouseX-w/2, 0, img.width);
  int ystart = constrain(mouseY-w/2, 0, img.height);
  int xend = constrain(mouseX + w/2, 0, img.width);
  int yend = constrain(mouseY + w/2, 0, img.height);
  int matrixsize = 3;

  loadPixels();
  img.loadPixels();
  for (int x = xstart; x < xend; x++) {
    for (int y = ystart; y < yend; y++) {
      // Each pixel location (x,y) gets passed into a function called convolution()
      // The convolution() function returns a new color to be displayed.
      color result = convolve(x, y, matrix, matrixsize, img);
      int loc = (x + y * img.width);
      pixels[loc] = result;
    }
  }
  updatePixels();
}

color convolve(int x, int y, float matrix[][], int matrixsize, PImage img) {
  float rtotal = 0.0;
  float gtotal = 0.0;
  float btotal = 0.0;
  int offset = floor(matrixsize / 2);

  // Loop through convolution matrix
  for (int i = 0; i < matrixsize; i++) {
    for (int j = 0; j < matrixsize; j++) {
      // What pixel are we testing
      int xloc = x + i - offset;
      int yloc = y + j - offset;
      int loc = xloc + img.width * yloc;

      // Make sure we haven't walked off the edge of the pixel array
      // It is often good when looking at neighboring pixels to make sure we have not gone off the edge of the pixel array by accident.
      loc = constrain(loc, 0, img.pixels.length - 1);
      // Calculate the convolution
      // We sum all the neighboring pixels multiplied by the values in the convolution matrix.
      rtotal += red(img.pixels[loc]) * matrix[i][j];
      gtotal += green(img.pixels[loc]) * matrix[i][j];
      btotal += blue(img.pixels[loc]) * matrix[i][j];
    }
  }


  //*WRAP*
  //Values that exceed the limits are wrapped around 
  //to the opposite limit with a modulo operation. 
  //(256 wraps to 0, 257 wraps to 1, 
  //and -1 wraps to 255, -2 wraps to 254, etc.)

  //rtotal
  if (rtotal > 255) {
    rtotal = rtotal % 255;
  } else if (rtotal < 0) {
    rtotal = (rtotal % 255) + 255;
  }
  //gtotal
  if (gtotal > 255) {
    gtotal = gtotal % 255;
  } else if (gtotal < 0) {
    gtotal = (gtotal % 255) + 255;
  }
  //btotal
  if (btotal > 255) {
    btotal = btotal % 255;
  } else if (btotal < 0) {
    btotal = (btotal % 255) + 255;
  }

  // Return an array with the three color values
  return color(rtotal, gtotal, btotal);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      w += 100;
    } else if (keyCode == DOWN) {
      w -= 100;
    }
  }
}

void keyTyped() {
  if (key == '0') {
    sharpen0 = !sharpen0;
  } else if (key == '1') {
    sharpen1 = !sharpen1;
  } else if (key == '2') {
    sharpen2 = !sharpen2;
  } else if (key == '3') {
    sharpen3 = !sharpen3;
  } else if (key == '4') {
    sharpen4 = !sharpen4;
  } else if (key == '5') {
    sharpen5 = !sharpen5;
  } else if (key == '6') {
    sharpen6 = !sharpen6;
  } else if (key == '7') {
    sharpen7 = !sharpen7;
  } else if (key == '8') {
    sharpen8 = !sharpen8;
  }
}