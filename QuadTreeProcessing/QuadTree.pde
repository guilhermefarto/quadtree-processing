
import java.util.Iterator;
import java.util.Map;

final boolean LOCK_INSERTION_BY_MAX_OBJECTS = false;
final boolean ENABLE_RANDOM_COLOR_PER_QUAD = false;

class QuadTree {

  ArrayList<Object> objects = new ArrayList<Object>();

  int x;
  int y;
  int width;
  int height;

  int level; 
  int maxObjects;
  int maxLevels;

  color randomColorForObjects;

  QuadTree nw, ne, sw, se;
  HashMap<Integer, QuadTree> quads = new HashMap<Integer, QuadTree>();

  boolean isRoot = false;

  QuadTree(int level, int x, int y, int width, int height, int maxObjects, int maxLevels) {
    this(level, x, y, width, height, maxObjects, maxLevels, false);
  }

  QuadTree(int level, int x, int y, int width, int height, int maxObjects, int maxLevels, boolean isRoot) {
    this.level = level;

    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;

    this.maxObjects = maxObjects;
    this.maxLevels = maxLevels;

    this.isRoot = isRoot;

    if (ENABLE_RANDOM_COLOR_PER_QUAD) {
      this.randomColorForObjects = color(int(random(0, 255)), int(random(0, 255)), int(random(0, 255)));
    } else {
      this.randomColorForObjects = color(150);
    }
  }

  boolean addObject(Object object) {
    if (!this.quads.isEmpty()) {
      int quadIndex = getQuadIndex(object);

      if (quadIndex != -1) {
        this.quads.get(quadIndex).addObject(object);

        return true;
      }
    }

    this.objects.add(object);

    if (this.objects.size() > this.maxObjects) {
      if (this.level < this.maxLevels) {
        if (this.quads.isEmpty()) {
          this.split();
        }

        exchangeObjectsToQuads();
      } else {
        if (LOCK_INSERTION_BY_MAX_OBJECTS) {
          this.removeObject(object);
        }
      }
    }

    return true;
  }

  boolean exchangeObjectsToQuads() {
    Iterator<Object> iObject = this.objects.iterator();

    while (iObject.hasNext()) { 
      Object object = iObject.next();

      int quadIndex = this.getQuadIndex(object);

      if (quadIndex != -1) {
        this.quads.get(quadIndex).addObject(object);

        iObject.remove();
      }
    }

    return true;
  }

  boolean removeObject(Object object) {
    this.objects.remove(object);

    return true;
  }

  boolean clear() {
    this.objects.clear();

    for (Map.Entry entry : this.quads.entrySet()) {
      ((QuadTree) entry.getValue()).clear();
    }

    this.quads.clear();

    return true;
  }

  int getQuadIndex(Object object) {
    int xForObject = object.x;
    int yForObject = object.y;

    boolean isLeftQuad = xForObject >= this.x && xForObject < (this.x + this.width / 2);
    boolean isTopQuad = yForObject >= this.y && yForObject < (this.y + this.height / 2);

    if (isLeftQuad && isTopQuad) { // nw quad
      return 1;
    } else if (!isLeftQuad && isTopQuad) { // ne quad
      return 2;
    } else if (isLeftQuad && !isTopQuad) { // sw quad
      return 3;
    } else if (!isLeftQuad && !isTopQuad) { // se quad
      return 4;
    }

    return -1;
  }

  boolean split() {
    if (!this.quads.isEmpty()) {
      throw new java.lang.IllegalStateException("QuadTree already splitted...");
    }

    int halfWidth = this.width / 2;
    int halfHeight = this.height / 2;

    nw = new QuadTree(this.level + 1, this.x, this.y, halfWidth, halfHeight, maxObjects, maxLevels);
    ne = new QuadTree(this.level + 1, this.x + halfWidth, this.y, halfWidth, halfHeight, maxObjects, maxLevels);
    sw = new QuadTree(this.level + 1, this.x, this.y + halfHeight, halfWidth, halfHeight, maxObjects, maxLevels);
    se = new QuadTree(this.level + 1, this.x + halfWidth, this.y + halfHeight, halfWidth, halfHeight, maxObjects, maxLevels);

    this.quads.put(1, nw);
    this.quads.put(2, ne);
    this.quads.put(3, sw);
    this.quads.put(4, se);

    return true;
  }

  void draw() {
    if (!this.quads.isEmpty()) {
      nw.draw();
      ne.draw();
      sw.draw();
      se.draw();
    }

    drawObjects();

    noFill();
    stroke(220, 220, 0);

    rect(x * DEFAULT_SCALE, y * DEFAULT_SCALE, width * DEFAULT_SCALE, height * DEFAULT_SCALE);
  }

  void drawObjects() {
    for (Object object : this.objects) {
      object.draw(this.randomColorForObjects);
    }
  }

  void simulate(QuadTree root, int scale, int maxLevels) {
    noFill();
    stroke(200, 200, 0);

    rect(root.x * scale, root.y * scale, root.width * scale, root.height * scale);

    if (root.level < maxLevels) {
      int halfWidth = root.width / 2;
      int halfHeight = root.height / 2;

      simulate(new QuadTree(root.level + 1, root.x, root.y, halfWidth, halfHeight, maxObjects, maxLevels), scale, maxLevels);
      simulate(new QuadTree(root.level + 1, root.x + halfWidth, root.y, halfWidth, halfHeight, maxObjects, maxLevels), scale, maxLevels);
      simulate(new QuadTree(root.level + 1, root.x, root.y + halfHeight, halfWidth, halfHeight, maxObjects, maxLevels), scale, maxLevels);
      simulate(new QuadTree(root.level + 1, root.x + halfWidth, root.y + halfHeight, halfWidth, halfHeight, maxObjects, maxLevels), scale, maxLevels);
    }
  }

  void loadData(int[][] data) {
    this.clear();

    if (data != null) {
      for (int rowId = 0; rowId < data.length; rowId++) {
        for (int colId = 0; colId < data[0].length; colId++) {
          if (data[rowId][colId] == 1) {
            this.addObject(new Object(1, colId, rowId));
          }
        }
      }
    }
  }

  void log() {
    println("Logging QuadTree for [x, y, width, height] = " + this.x + " , " + this.y + " , " + this.width + " , " + this.height);
  }
}