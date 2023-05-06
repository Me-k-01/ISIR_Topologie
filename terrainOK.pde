
//Variable globales
int rows, columns;
int scale;

int w = 600;
int h = 600;

float flying = 0;
//######################
//Declaration de classes
//######################
class Brin{

public PVector point;
public Brin[] alpha = new Brin[3];

public Brin(PVector p){
  point = p;

}

public void connect(int alph,Brin b){
  alpha[alph]=b;
  b.alpha[alph]=this;

}
//######################
public void render(){

  beginShape(LINES);
  vertex(point.x,point.y,point.z);
  vertex(alpha[0].point.x, alpha[0].point.y, alpha[0].point.z);
  endShape();


}



};
//######################
public class Face{

  Brin b1;
  Brin b2;

  public Face(Brin a,Brin b){
    b1=a;
    b2=b;

    b1.connect(1,b2);

  }

  public void render(){
    b1.render();
    b2.render();
  }

  public PVector normals(){
    
    PVector p = b1.point;

    PVector b1vec= PVector.sub(b1.alpha[0].point,p);
    PVector b2vec= PVector.sub(b2.alpha[0].point,p);

    PVector result=new PVector();
    PVector.cross(b1vec,b2vec,result);
    result.normalize();

    return result;


  }
  

};
//######################
public class Point {

  public Face upLeft; //0
  public Face downLeft1; //1
  public Face downLeft2; //2
  public Face downRight; //3
  public Face upRight1; //4
  public Face upRight2; //5

  public boolean[] exist = new boolean[6];
  public PVector point;

  Point(PVector p){
    point = p;

    for(int i =0 ; i<6 ; i++){
      exist[i]=false;
    }
  }

  public void render(){

    if(exist[0])
      upLeft.render();
    if(exist[1])
      downLeft1.render();
    if(exist[2])
      downLeft2.render();
    if(exist[3])
      downRight.render();
    if(exist[4])
      upRight1.render();
    if(exist[5])
      upRight2.render();
  }
  public void setZ(float z){

    point.z=z;

  }

  public void drawNormals(){

    PVector norm = new PVector(0,0,0);
    int n =0;
    if(exist[0]){
      norm.add(upLeft.normals());
      n++;
    }
    if(exist[1]){
      norm.add(downLeft1.normals());
      n++;
    }
    if(exist[2]){
      norm.add( downLeft2.normals());
      n++;
    }
    if(exist[3]){
      norm.add(downRight.normals());
      n++;
    }
    if(exist[4]){
      norm.add(upRight1.normals());
      n++;
    }
    if(exist[5]){
      norm.add(upRight2.normals());
      n++;
    }
    norm.div(n);
    norm.mult(-10);
    
    stroke(255,0,0);
    beginShape(LINES);
      vertex(point.x,point.y,point.z);
      vertex(point.x+norm.x,point.y+norm.y,point.z+norm.z);
    endShape();
    stroke(255);

  }


};
//######################
public class Map2g{
  public int column;
  public int row;
  public Point[][] mapPoint;
  public float[][] terrain;
  public float scaling=scale;
  public Map2g(int cols , int rows){
    column=cols;
    row=rows;
    mapPoint=new Point[column][row];
    terrain= new float [column][row];
    

    //this.generateMap();
    for (int y = 0; y < row; y++){ 
      for (int x = 0; x <column; x++){ 
          terrain[x][y]=0;
          Point p=createPoint(x,y);
          mapPoint[x][y]=p;
      }
    }
    linkAlpha0();

  }

  public Point createPoint(int x ,int y ){
       Point p =new Point(new PVector(x*scaling,y*scaling,terrain[x][y]));

        if(x==0 && y==0){
          p.exist[0]=true;
          p.upLeft=new Face(new Brin(p.point),new Brin(p.point)); 
        }
        else if(x<(column-1) && y==0){

          p.exist[0]=true;
          p.upLeft=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[4]=true;
          p.upRight1=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[5]=true;
          p.upRight2=new Face(new Brin(p.point),new Brin(p.point));

          //couture sur les faces
          p.upRight2.b1.connect(2,p.upRight1.b2);
          p.upLeft.b1.connect(2,p.upRight2.b2);
          
        }
        else if(x==(column-1) && y==0){
          
          p.exist[4]=true;
          p.upRight1=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[5]=true;
          p.upRight2=new Face(new Brin(p.point),new Brin(p.point));

          //couture sur les faces
          p.upRight2.b1.connect(2,p.upRight1.b2);
        
        }
        else if (x==0 && y<(row-1) ){
          p.exist[0]=true;
          p.upLeft=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[1]=true;
          p.downLeft1=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[2]=true;
          p.downLeft2=new Face(new Brin(p.point),new Brin(p.point));

          //couture sur les faces
          p.downLeft1.b2.connect(2,p.downLeft2.b1);
          p.downLeft1.b1.connect(2,p.upLeft.b2);

        }

        else if (x==(column-1) &&y<(row-1)) {
            
          p.exist[3]=true;
          p.downRight=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[4]=true;
          p.upRight1=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[5]=true;
          p.upRight2=new Face(new Brin(p.point),new Brin(p.point));

          //coutures
          p.downRight.b2.connect(2,p.upRight1.b1);
          p.upRight1.b2.connect(2,p.upRight2.b1);

        }
        else if (x==0 &&y==(row-1)) {

          p.exist[1]=true;
          p.downLeft1=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[2]=true;
          p.downLeft2=new Face(new Brin(p.point),new Brin(p.point));

          //coutures
          p.downLeft1.b2.connect(2,p.downLeft2.b1);
        
        }
        else if(x<(column-1) &&y==(row-1)){

          p.exist[1]=true;
          p.downLeft1=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[2]=true;
          p.downLeft2=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[3]=true;
          p.downRight= new Face(new Brin(p.point),new Brin(p.point));

          //COUTURES
          p.downRight.b1.connect(2,p.downLeft2.b2);
          p.downLeft1.b2.connect(2,p.downLeft2.b1);

        }
        else if(x==(column-1) &&y==(row-1)){

          p.exist[3]=true;
          p.downRight= new Face(new Brin(p.point),new Brin(p.point));

        }
        else{

          p.exist[0]=true;
          p.upLeft=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[1]=true;
          p.downLeft1=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[2]=true;
          p.downLeft2=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[3]=true;
          p.downRight= new Face(new Brin(p.point),new Brin(p.point));

          p.exist[4]=true;
          p.upRight1=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[5]=true;
          p.upRight2=new Face(new Brin(p.point),new Brin(p.point));

          //coutures

          p.downRight.b1.connect(2,p.downLeft2.b2);
          p.downLeft1.b2.connect(2,p.downLeft2.b1);

          p.downRight.b2.connect(2,p.upRight1.b1);
          p.upRight1.b2.connect(2,p.upRight2.b1);

          p.upLeft.b1.connect(2,p.upRight2.b2);
          p.upLeft.b2.connect(2,p.downLeft1.b1);


        }
      return p;
  }
  
  
  public void linkAlpha0(){

    for (int y = 0; y < row; y++){ 
      for (int x = 0; x <column; x++){ 

        Point p = mapPoint[x][y];
        if(x==0 && y==0){
              
        }
        else if(x<(column-1) && y==0){
          mapPoint[x-1][y].upLeft.b2.connect(0,p.upRight1.b1);
          
        }
        else if(x==(column-1) && y==0){
          print(x,"-",y);
          
          mapPoint[x-1][y].upLeft.b2.connect(0,p.upRight1.b1);
        }
        else if (x==0 && y<(row-1) ){
        
          mapPoint[x][y-1].upLeft.b1.connect(0,p.downLeft2.b2);

          mapPoint[x+1][y-1].upRight1.b2.connect(0,p.downLeft2.b1);
        
          mapPoint[x+1][y-1].upRight2.b1.connect(0,p.downLeft1.b2);


        }

        else if (x==(column-1) &&y<(row-1)) {
            

          mapPoint[x-1][y].downLeft1.b1.connect(0,p.downRight.b2);
          mapPoint[x-1][y].upLeft.b2.connect(0,p.upRight1.b1);

          mapPoint[x][y-1].upRight2.b2.connect(0,p.downRight.b1);


        }
        else if (x==0 &&y==(row-1)) {


          mapPoint[x][y-1].upLeft.b1.connect(0,p.downLeft2.b2);

          mapPoint[x+1][y-1].upRight1.b2.connect(0,p.downLeft2.b1);
          mapPoint[x+1][y-1].upRight2.b1.connect(0,p.downLeft1.b2);

        }
        else if(x<(column-1) &&y==(row-1)){

        
          mapPoint[x][y-1].upLeft.b1.connect(0,p.downLeft2.b2);
          mapPoint[x][y-1].upRight2.b2.connect(0,p.downRight.b1);

          mapPoint[x-1][y].downLeft1.b1.connect(0,p.downRight.b2);

          mapPoint[x+1][y-1].upRight1.b2.connect(0,p.downLeft2.b1);
          mapPoint[x+1][y-1].upRight2.b1.connect(0,p.downLeft1.b2);



        }
        else if(x==(column-1) &&y==(row-1)){

        
          mapPoint[x-1][y].downLeft1.b1.connect(0,p.downRight.b2);
          mapPoint[x][y-1].upRight2.b2.connect(0,p.downRight.b1);

        }
        else{

          mapPoint[x-1][y].downLeft1.b1.connect(0,p.downRight.b2);
          mapPoint[x-1][y].upLeft.b2.connect(0,p.upRight1.b1);

          mapPoint[x][y-1].upRight2.b2.connect(0,p.downRight.b1);
          mapPoint[x][y-1].upLeft.b1.connect(0,p.downLeft2.b2);

          mapPoint[x+1][y-1].upRight1.b2.connect(0,p.downLeft2.b1);
          mapPoint[x+1][y-1].upRight2.b1.connect(0,p.downLeft1.b2);


        }
        mapPoint[x][y]=p;
      }
      
    }
   
  }
  public void render(){

    for (int y = 0; y < row; y++) { 
      for (int x = 0; x <column; x++) { 
        mapPoint[x][y].setZ(this.terrain[x][y]);
        mapPoint[x][y].render();
      }  
    }
  }




  public void split(){
    this.column=column+floor(column/2);
    this.row=row+floor(row/2);
    scaling = scaling/2;
    float[][] newTerrain = new float[column][row];
    Point[][] newMapPoint=new Point[column][row];

    for(int y = 0 ;y<row ; y++){
      for(int x = 0; x<column; x++){
        newTerrain[x][y]=0;
      }
    }
    this.terrain=newTerrain;

    for(int y = 0 ;y<row ; y++){
      for(int x = 0; x<column ; x++){
        
       

        if(x%2==0 && y%2==0 && x!=(column-1)  && y!=(row-1) ){
          newMapPoint[x][y]=mapPoint[x/2][y/2];
          
        }
        else{
          newMapPoint[x][y]=createPoint(x,y);
        }
     
        
        
        
      }
    }
    
    mapPoint=newMapPoint;
    
    this.linkAlpha0();

  }
  public void drawNormals(){
    for(int y = 0 ;y<row ; y++){
      for(int x = 0; x<column ; x++){
      
        mapPoint[x][y].drawNormals();
     
      }
    }


  }

};


Map2g map;
void setup() { 
  size(600, 600, P3D);
  //w = 1200;
  //h = 720;
  w = 600;
  h = 600;
  scale = 20;
  rows = w / scale;
  columns = h / scale; 


  map=new Map2g(columns,rows);   

  map.split();

}








void draw() {
  flying -= 0.01;
  float yoff=flying;
  for (int y = 0; y < map.row; y++) { 
    float xoff = 0;
    for (int x = 0; x < map.column; x++) { 
     map.terrain[x][y] = map(noise(xoff, yoff), 0, 1, -50, 50);


      xoff += 0.2; 
    }  
    yoff += 0.2; 
  }
 
  
  background(0);
  stroke(255);
  noFill();
  
  translate(width/2, height/2);
  rotateX(PI/3);
  translate(-map.column*map.scaling /2 , -map.row*map.scaling /2);

  map.render();
  map.drawNormals();

 


}
