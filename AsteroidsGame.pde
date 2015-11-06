import org.json.*;

SpaceShip spaceship;

private boolean upKey = false;
private boolean downKey = false;
private boolean leftKey = false;
private boolean rightKey = false;
private boolean ctrlKey = false;

Stars stars = new Stars();

public void setup() 
{
  size(500,500);

  stars.generate();
  
  spaceship = new SpaceShip();
}
public void draw() 
{
  if(upKey)
    spaceship.accelerate(0.02);
  if(leftKey)
    spaceship.rotate(-3);
  if(rightKey)
    spaceship.rotate(3);

  background(0);

  stars.showAll();

  spaceship.move();
  spaceship.show();
}
public void keyPressed()
{
  if(key == CODED)
  {
    if(keyCode == UP)
      upKey = true;
    else if(keyCode == DOWN)
      downKey = true;
    else if(keyCode == LEFT)
      leftKey = true;
    else if(keyCode == RIGHT)
      rightKey = true;
    else if(keyCode == CONTROL && !ctrlKey)
    {
      spaceship.hyperspace();
      ctrlKey = true;
    }
  }
}
public void keyReleased()
{
  if(key == CODED)
  {
    if(keyCode == UP)
      upKey = false;
    else if(keyCode == DOWN)
      downKey = false;
    else if(keyCode == LEFT)
      leftKey = false;
    else if(keyCode == RIGHT)
      rightKey = false;
    else if(keyCode == CONTROL)
      ctrlKey = false;
  }
}
class Stars
{
  public Star[] stars;

  public Stars()
  {
    //*sigh* Java
  }

  public void generate()
  {
    this.stars = new Star[(int)(Math.random() * 50) + 75];
    for(int i = 0; i < this.stars.length; i++)
    {
      this.stars[i] = new Star(Math.random() * width, Math.random() * height, (Math.random() * 10) + 5);
    }
  }

  public void showAll()
  {
    for(int i = 0; i < this.stars.length; i++)
    {
      this.stars[i].show();
    }
  }
}

class Star
{
  private double posX;
  private double posY;
  private double size;

  public Star(double x, double y, double s)
  {
    posX = x;
    posY = y;
    size = s;
  }
  public void show()
  {
    fill(0,0,0,0);
    strokeWeight(0.5);
    stroke(200);  

    arc((float)posX, (float)posY, (float)size, (float)size, 0, PI / 2.0);
    arc((float)(posX + size), (float)posY, (float)size, (float)size, PI / 2.0, PI);
    arc((float)(posX + size), (float)(posY + size), (float)size, (float)size, PI, PI * 1.5);
    arc((float)posX, (float)(posY + size), (float)size, (float)size, PI * 1.5, PI * 2.0);
  }
}

class SpaceShip extends Floater  
{   
  private boolean drawAcceleration = false;

  private double hyperspaceCooldown = 0;

  public SpaceShip()
  {
    myCenterX = 200;
    myCenterY = 200;

    JSON properties = JSON.load(dataPath("graphics.json")).getArray("spaceship");
    
    //Load color
    JSON c = ((JSON)properties.getObject(0)).getArray("color");
    this.myColor = color(((JSON)c.getObject(0)).getInt("r"), ((JSON)c.getObject(1)).getInt("g"), ((JSON)c.getObject(2)).getInt("b"));
    //This is why I hate java. ^

    //Load vertices
    JSON v = ((JSON)properties.getObject(1)).getArray("vertices");
    corners = ((JSON)v.getObject(0)).getInt("verticesNumber");
    xCorners = new int[corners];
    yCorners = new int[corners];

    for(int i = 0; i < corners; i++)
    {
      JSON vert = ((JSON)v.getObject(i + 1)).getArray("vertex");
      xCorners[i] = (int)(1.5 * ((JSON)vert.getObject(0)).getInt("x"));
      yCorners[i] = (int)(1.5 * ((JSON)vert.getObject(1)).getInt("y"));
    }
  }

  //I've given up on commenting so good luck
  public void setX(int x) {this.myCenterX = x;} 
  public int getX() {return (int)this.myCenterX;}
  public void setY(int y) {this.myCenterY = y;}
  public int getY() {return (int)this.myCenterY;}
  public void setDirectionX(double x) {this.myDirectionX = x;}
  public double getDirectionX() {return this.myDirectionX;}
  public void setDirectionY(double y) {this.myDirectionY = y;}
  public double getDirectionY() {return this.myDirectionY;}
  public void setPointDirection(int degrees) {this.myPointDirection = degrees;}
  public double getPointDirection() {return this.myPointDirection;}

  public void accelerate (double dAmount)   
  {   
    super.accelerate(dAmount);
    drawAcceleration = true;
  }

  public void hyperspace()
  {
    hyperspaceCooldown = 1.0;

    setX((int)(Math.random() * width));
    setY((int)(Math.random() * height));
    setDirectionX(0);
    setDirectionY(0);
    setPointDirection((int)(Math.random() * 360));

    stars.generate();
  }

  public void show ()  //Draws the floater at the current position and all around
  {
    fill(0,0,0,0);
    strokeWeight(1);
    stroke(myColor);   

    double dRadians = myPointDirection*(Math.PI/180);

    showAtRelPos(-width, -height, dRadians);
    showAtRelPos(-width, 0, dRadians);
    showAtRelPos(-width, height, dRadians);

    showAtRelPos(0, -height, dRadians);
    showAtRelPos(0, 0, dRadians);
    showAtRelPos(0, height, dRadians);

    showAtRelPos(width, -height, dRadians);
    showAtRelPos(width, 0, dRadians);
    showAtRelPos(width, height, dRadians);

    if(hyperspaceCooldown > 0)
    {
      strokeWeight(0);
      fill(255, 255, 255, (int)(255 * hyperspaceCooldown));
      rect(0, 0, width, height);

      hyperspaceCooldown -= 0.05;
    }

    drawAcceleration = false;
  } 

  private double getRotatedX(double x, double y, double dRadians)
  {
    return (x * Math.cos(dRadians)) - (y * Math.sin(dRadians));
  }

  private double getRotatedY(double x, double y, double dRadians)
  {
    return (x * Math.sin(dRadians)) + (y * Math.cos(dRadians));
  }

  private void showAtRelPos(int relX, int relY, double dRadians)
  {
    //convert degrees to radians for sin and cos         
                     
    float xRotatedTranslated, yRotatedTranslated;    
    beginShape();         
    for(int nI = 0; nI < corners; nI++)    
    {     
      //rotate and translate the coordinates of the floater using current direction 
      xRotatedTranslated = (float)(getRotatedX(xCorners[nI], yCorners[nI], dRadians)+(myCenterX + relX));     
      yRotatedTranslated = (float)(getRotatedY(xCorners[nI], yCorners[nI], dRadians)+(myCenterY + relY));      
      vertex(xRotatedTranslated,yRotatedTranslated);
    }   
    endShape(CLOSE);

    if(drawAcceleration && Math.random() < 0.6)
    {
      line((float)(getRotatedX(-8, 2, dRadians) + myCenterX + relX), (float)(getRotatedY(-8, 2, dRadians) + myCenterY + relY), (float)(getRotatedX(-12, 3, dRadians) + myCenterX + relX), (float)(getRotatedY(-12, 3, dRadians) + myCenterY + relY));
      line((float)(getRotatedX(-8, 0, dRadians) + myCenterX + relX), (float)(getRotatedY(-8, 0, dRadians) + myCenterY + relY), (float)(getRotatedX(-13, 0, dRadians) + myCenterX + relX), (float)(getRotatedY(-13, 0, dRadians) + myCenterY + relY));
      line((float)(getRotatedX(-8, -2, dRadians) + myCenterX + relX), (float)(getRotatedY(-8, -2, dRadians) + myCenterY + relY), (float)(getRotatedX(-12, -3, dRadians) + myCenterX + relX), (float)(getRotatedY(-12, -3, dRadians) + myCenterY + relY));
    }
  }  
}

abstract class Floater //Do NOT modify the Floater class! Make changes in the SpaceShip class 
{   
  protected int corners;  //the number of corners, a triangular floater has 3   
  protected int[] xCorners;   
  protected int[] yCorners;   
  protected int myColor;   
  protected double myCenterX, myCenterY; //holds center coordinates   
  protected double myDirectionX, myDirectionY; //holds x and y coordinates of the vector for direction of travel   
  protected double myPointDirection; //holds current direction the ship is pointing in degrees    
  abstract public void setX(int x);  
  abstract public int getX();   
  abstract public void setY(int y);   
  abstract public int getY();   
  abstract public void setDirectionX(double x);   
  abstract public double getDirectionX();   
  abstract public void setDirectionY(double y);   
  abstract public double getDirectionY();   
  abstract public void setPointDirection(int degrees);   
  abstract public double getPointDirection(); 

  //Accelerates the floater in the direction it is pointing (myPointDirection)   
  public void accelerate (double dAmount)   
  {          
    //convert the current direction the floater is pointing to radians    
    double dRadians =myPointDirection*(Math.PI/180);     
    //change coordinates of direction of travel    
    myDirectionX += ((dAmount) * Math.cos(dRadians));    
    myDirectionY += ((dAmount) * Math.sin(dRadians));       
  }   
  public void rotate (int nDegreesOfRotation)   
  {     
    //rotates the floater by a given number of degrees    
    myPointDirection+=nDegreesOfRotation;   
  }   
  public void move ()   //move the floater in the current direction of travel
  {      
    //change the x and y coordinates by myDirectionX and myDirectionY       
    myCenterX += myDirectionX;    
    myCenterY += myDirectionY;     

    //wrap around screen    
    if(myCenterX >width)
    {     
      myCenterX = 0;    
    }    
    else if (myCenterX<0)
    {     
      myCenterX = width;    
    }    
    if(myCenterY >height)
    {    
      myCenterY = 0;    
    }   
    else if (myCenterY < 0)
    {     
      myCenterY = height;    
    }   
  }   
  public void show ()  //Draws the floater at the current position  
  {             
    fill(myColor);   
    stroke(myColor);    
    //convert degrees to radians for sin and cos         
    double dRadians = myPointDirection*(Math.PI/180);                 
    int xRotatedTranslated, yRotatedTranslated;    
    beginShape();         
    for(int nI = 0; nI < corners; nI++)    
    {     
      //rotate and translate the coordinates of the floater using current direction 
      xRotatedTranslated = (int)((xCorners[nI]* Math.cos(dRadians)) - (yCorners[nI] * Math.sin(dRadians))+myCenterX);     
      yRotatedTranslated = (int)((xCorners[nI]* Math.sin(dRadians)) + (yCorners[nI] * Math.cos(dRadians))+myCenterY);      
      vertex(xRotatedTranslated,yRotatedTranslated);    
    }   
    endShape(CLOSE);  
  }   
} 