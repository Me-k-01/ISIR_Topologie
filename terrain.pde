
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
//La classe Brin represente un brin par un poit et ses relation alpha avec d'autres Brins

public PVector point;
public Brin[] alpha = new Brin[3];
 
public Brin(PVector p){
  point = p;

}

//cette methode permet de mettre alpha un brin avec un autre
public void connect(int alph,Brin b){
  alpha[alph]=b;
  b.alpha[alph]=this;

}
//cette methode sers à afficher un brin par le segment crée par lui meme et le brin avec le lequel il partage une relation alpha 0
public void render(){

  beginShape(LINES);
  vertex(point.x,point.y,point.z);
  vertex(alpha[0].point.x, alpha[0].point.y, alpha[0].point.z);
  endShape();


}



};
//######################

//la classe Face permet de representé une face(triangle) à l'aide de seulement 2 brins
//cette classe permet surtout de mettre en ordre les données
//c'est pourquoi un seul et meme triangle peut etre reprenté par plusieur instance de Face
public class Face{

  Brin b1;
  Brin b2;

  public Face(Brin a,Brin b){
    b1=a;
    b2=b;

    b1.connect(1,b2); // le brin b1 et b2 partage une relation aplha 1 

  }
  
  //affiche les 2 brins
  public void render(){
    b1.render();
    b2.render();
  }

  //calcul de  la normal de la face
  public PVector normals(){
    
    PVector p = b1.point; // on recupere le point partagé par b1 et b2

    PVector b1vec= PVector.sub(b1.alpha[0].point,p); //on prend le segement auquel appartient b1
    PVector b2vec= PVector.sub(b2.alpha[0].point,p); //on prend le segement auquel appartient b2

    PVector result=new PVector();
    PVector.cross(b1vec,b2vec,result); // puis on realise un produit vectoriel pour obtenir la normal de la Face
    result.normalize();

    return result;


  }
  

};
//######################
//la classe point represente un point de l'espace
//Ce point appartient a un certain nombre de faces


public class Point {

  //il y'a un maximum de 6 faces rattacher à ce point
  //chacune de ces variable correspond a une face bien definie
  //cf schema
  public Face upLeft; //0
  public Face downLeft1; //1
  public Face downLeft2; //2
  public Face downRight; //3
  public Face upRight1; //4
  public Face upRight2; //5

  //cette reprensation des point permet  realiser facilemnt les coutures entre brin adajacents
  public boolean[] exist = new boolean[6];
  public PVector point;

  Point(PVector p){
    point = p;

    for(int i =0 ; i<6 ; i++){
      exist[i]=false;
    }
  }

  public void render(){

    if(exist[0]) //si il y'a une face du type ... alors je l'affiche
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

  public void setZ(float z){//permet de modifier la profondeur z du point
    point.z=z;

  }

  //l'affichage des normales
  public void drawNormals(){

    PVector norm = new PVector(0,0,0);//on va d'abors effectuer une moyenne sur les normales des faces
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

    //puis on "aggrandi" et on retourne la normale 
    norm.mult(-10);
    
    //puis on l'affiche en rouge sous forme d'un petit segment
    stroke(255,0,0);
    beginShape(LINES);
      vertex(point.x,point.y,point.z);
      vertex(point.x+norm.x,point.y+norm.y,point.z+norm.z);
    endShape();
    stroke(255);

  }


};
//######################

//La classe permettant de represnter une 2g map

public class Map2g{

//nombre de collonnes et de ligne de la 2g map
  public int column;
  public int row;
  public float scaling=scale;

//l'ensembles des point de l'espace
  public Point[][] mapPoint;
//les profondeur z attaché aux points
  public float[][] terrain;

  public Map2g(int cols , int rows){
    column=cols;
    row=rows;
    mapPoint=new Point[column][row];
    terrain= new float [column][row];
    

    //on genere la 2g map
    for (int y = 0; y < row; y++){ 
      for (int x = 0; x <column; x++){ 
          terrain[x][y]=0;
          Point p=createPoint(x,y);//d'abord on creer les point
          mapPoint[x][y]=p;
      }
    }
    //puis on les relie par des segments (alpha 0)
    linkAlpha0();

  }

  //methode permettant de creer un points dans la 2g map
  public Point createPoint(int x ,int y ){
       Point p =new Point(new PVector(x*scaling,y*scaling,terrain[x][y]));//on creer une instance de Point


        //puis on l'initialiser selon les cas
        //il y'a un total de 9 cas different
        
        if(x==0 && y==0){ // coins superieur gauche
          p.exist[0]=true;
          p.upLeft=new Face(new Brin(p.point),new Brin(p.point)); 
        }
        else if(x<(column-1) && y==0){ // les points le long du bord supérieur

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
        else if(x==(column-1) && y==0){//le coins supérieur droit
          
          p.exist[4]=true;
          p.upRight1=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[5]=true;
          p.upRight2=new Face(new Brin(p.point),new Brin(p.point));

          //couture sur les faces
          p.upRight2.b1.connect(2,p.upRight1.b2);
        
        }
        else if (x==0 && y<(row-1) ){ // les points le long du bord gauche
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

        else if (x==(column-1) &&y<(row-1)) { //// les points le long du bord droit
            
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
        else if (x==0 &&y==(row-1)) { // le coin inferieur gauche

          p.exist[1]=true;
          p.downLeft1=new Face(new Brin(p.point),new Brin(p.point));

          p.exist[2]=true;
          p.downLeft2=new Face(new Brin(p.point),new Brin(p.point));

          //coutures
          p.downLeft1.b2.connect(2,p.downLeft2.b1);
        
        }
        else if(x<(column-1) &&y==(row-1)){ //le point le long du bord inférieur

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
        else if(x==(column-1) &&y==(row-1)){//le coins inferieur droit

          p.exist[3]=true;
          p.downRight= new Face(new Brin(p.point),new Brin(p.point));

        }
        else{ // le cas général (dans le milieu )

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
  
  //la fonction permettant de relier les point par des segment(via les brins)
  public void linkAlpha0(){

    for (int y = 0; y < row; y++){ 
      for (int x = 0; x <column; x++){ 

        Point p = mapPoint[x][y];
        if(x==0 && y==0){
              
        }
        else if(x<(column-1) && y==0){// les points le long du bord supérieur
          mapPoint[x-1][y].upLeft.b2.connect(0,p.upRight1.b1);
          
        }
        else if(x==(column-1) && y==0){//le coins supérieur droit
          print(x,"-",y);
          
          mapPoint[x-1][y].upLeft.b2.connect(0,p.upRight1.b1);
        }
        else if (x==0 && y<(row-1) ){// les points le long du bord gauche
        
          mapPoint[x][y-1].upLeft.b1.connect(0,p.downLeft2.b2);

          mapPoint[x+1][y-1].upRight1.b2.connect(0,p.downLeft2.b1);
        
          mapPoint[x+1][y-1].upRight2.b1.connect(0,p.downLeft1.b2);


        }

        else if (x==(column-1) &&y<(row-1)) { //// les points le long du bord droit
            

          mapPoint[x-1][y].downLeft1.b1.connect(0,p.downRight.b2);
          mapPoint[x-1][y].upLeft.b2.connect(0,p.upRight1.b1);

          mapPoint[x][y-1].upRight2.b2.connect(0,p.downRight.b1);


        }
        else if (x==0 &&y==(row-1)) {// le coin inferieur gauche


          mapPoint[x][y-1].upLeft.b1.connect(0,p.downLeft2.b2);

          mapPoint[x+1][y-1].upRight1.b2.connect(0,p.downLeft2.b1);
          mapPoint[x+1][y-1].upRight2.b1.connect(0,p.downLeft1.b2);

        }
        else if(x<(column-1) &&y==(row-1)){//le point le long du bord inférieur

        
          mapPoint[x][y-1].upLeft.b1.connect(0,p.downLeft2.b2);
          mapPoint[x][y-1].upRight2.b2.connect(0,p.downRight.b1);

          mapPoint[x-1][y].downLeft1.b1.connect(0,p.downRight.b2);

          mapPoint[x+1][y-1].upRight1.b2.connect(0,p.downLeft2.b1);
          mapPoint[x+1][y-1].upRight2.b1.connect(0,p.downLeft1.b2);



        }
        else if(x==(column-1) &&y==(row-1)){//le coins inferieur droit

        
          mapPoint[x-1][y].downLeft1.b1.connect(0,p.downRight.b2);
          mapPoint[x][y-1].upRight2.b2.connect(0,p.downRight.b1);

        }
        else{//cas général

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
  //rendu de la 2g map
  public void render(){

    for (int y = 0; y < row; y++) { 
      for (int x = 0; x <column; x++) { 
        mapPoint[x][y].setZ(this.terrain[x][y]);
        mapPoint[x][y].render();
      }  
    }
  }



  //fonction de raffinage
  public void split(){


    this.column=column+floor(column/2);  //+50% de points
    this.row=row+floor(row/2); //+50% de points

    scaling = scaling/2; //distance entre les point est 2 fois plus petite

    //on creer les nouveaux tableaux
    float[][] newTerrain = new float[column][row]; 
    Point[][] newMapPoint=new Point[column][row];

  //on réinitialise le terrain
    for(int y = 0 ;y<row ; y++){
      for(int x = 0; x<column; x++){
        newTerrain[x][y]=0;
      }
    }
    this.terrain=newTerrain;

  //on genere le nouveau tableau de points
    for(int y = 0 ;y<row ; y++){
      for(int x = 0; x<column ; x++){
        
      
        if(x%2==0 && y%2==0 && x!=(column-1)  && y!=(row-1) ){ // si ce point existait auparavent alors on le conserve
          //car seule les realtion alpha 0 sont modifier les relation alpha 1 et alpha 2 sont conserver
          newMapPoint[x][y]=mapPoint[x/2][y/2];
          
        }
        else{
          newMapPoint[x][y]=createPoint(x,y); // sinon on creer un nouveau point
        }
     
    
      }
    }
    
    mapPoint=newMapPoint;
    
    //on lie tous les poit entre eux par des segments
    this.linkAlpha0();

  }
  //afficher les normales
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
  w = 600;
  h = 600;
  scale = 20;
  rows = w / scale;
  columns = h / scale; 


  map=new Map2g(columns,rows);   

  map.split();
  //map.split();

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
 
  
  background(54,54,127);
  stroke(255);
  noFill();
  
  //transformation geomtrique;
  translate(width/2, height/2);
  rotateX(PI/3);
  translate(-map.column*map.scaling /2 , -map.row*map.scaling /2);

  map.render();
  map.drawNormals();

 


}
