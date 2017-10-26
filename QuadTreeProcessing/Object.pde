
final int DEFAULT_SIZE = DEFAULT_SCALE;

class Object {

  int value;
  int x;
  int y;

  Object(int value, int x, int y) {
    this.value = value;
    this.x = x;
    this.y = y;
  }

  void draw(color colorForQuad) {
    fill(colorForQuad);
    stroke(255);

    rect(this.x * DEFAULT_SCALE, this.y * DEFAULT_SCALE, DEFAULT_SIZE, DEFAULT_SIZE);
  }

  void log() {
    println("Logging Object for [value, x, y] = " + value + " , " + x + " , " + y);
  }
}