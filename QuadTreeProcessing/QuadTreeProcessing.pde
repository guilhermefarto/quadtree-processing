
import java.awt.event.KeyEvent;

final int DEFAULT_SCALE = 4;
final int MAX_OBJECTS = 4;

int MAX_LEVELS;
int RANDOM_OBJECTS;

int rows, cols;
int[][] data;

QuadTree root = null;

boolean simulateQuadTrees = false;

void init() {
  clear();
  smooth();
  background(50);

  rows = height / DEFAULT_SCALE;
  cols = width / DEFAULT_SCALE;

  MAX_LEVELS = int((log(width / DEFAULT_SCALE) / log(2)));
  RANDOM_OBJECTS = int(pow(MAX_LEVELS, 2) * MAX_OBJECTS) * 2;

  data = new int[rows][cols];

  if (root == null) {
    root = new QuadTree(1, 0, 0, cols, rows, MAX_OBJECTS, MAX_LEVELS, true);
  } else {
    root.clear();
  }

  println("Logging for Grid [rows, cols] = " + rows + " , " + cols);
  println("Min. Level QuadTree: " + (rows / int(pow(2, MAX_LEVELS - 1))));
}

void setup() {
  size(512, 512);

  init();
}

void draw() {
  drawGrid();

  if (simulateQuadTrees) {
    root.simulate(root, DEFAULT_SCALE, MAX_LEVELS);
  } else {
    root.draw();
  }
}

void drawGrid() {
  noFill();
  stroke(70);

  for (int rowId=0; rowId<data.length; rowId++) {
    for (int colId=0; colId<data[0].length; colId++) {
      rect(colId * DEFAULT_SCALE, rowId * DEFAULT_SCALE, DEFAULT_SCALE, DEFAULT_SCALE);
    }
  }
}

void generateRandomObjects() {
  for (int i = 0; i < RANDOM_OBJECTS; i++) {
    data[int(random(0, rows))][int(random(0, cols))] = 1;
  }

  root.loadData(data);
}

void keyPressed() {
  String keyAsString = str(key).toUpperCase();

  if (keyAsString.equalsIgnoreCase("C")) { // Clear
    init();
  } else if (keyAsString.equalsIgnoreCase("R")) { // Generate random objects
    init();
    generateRandomObjects();
  } else if (key == CODED && keyCode == KeyEvent.VK_F2) { // Show or hide (simulate) QuadTrees
    simulateQuadTrees = !simulateQuadTrees;
  }
}

void mousePressed() {
  int colId = getSelectedCol(mouseX);
  int rowId = getSelectedRow(mouseY);

  if (colId == -1 || rowId == -1) {
    return;
  }

  data[rowId][colId] = 1;

  root.addObject(new Object(1, colId, rowId));
}

void mouseDragged() {
  int colId = getSelectedCol(mouseX);
  int rowId = getSelectedRow(mouseY);

  if (colId == -1 || rowId == -1) {
    return;
  }

  data[rowId][colId] = 1;

  root.addObject(new Object(1, colId, rowId));
}

boolean hasObject(int rowId, int colId) {
  return data[rowId][colId] == 1;
}

int getSelectedRow(int mouseY) {
  return mouseY >=0 && mouseY < height ? mouseY / DEFAULT_SCALE : -1;
}

int getSelectedCol(int mouseX) {
  return mouseX >=0 && mouseX < width ? mouseX / DEFAULT_SCALE : -1;
}