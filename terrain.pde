
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
// La classe Brin represente un brin par un point et ses relations alpha avec d'autres Brins

  public PVector point;
  public Brin[] alpha = new Brin[3];
   
  public Brin(PVector p){
    point = p;
  }
  
  // Cette methode permet de mettre alpha un brin avec un autre
  public void connect(int alph, Brin b){
    this.alpha[alph] = b;
    b.alpha[alph]    = this;
  }
  // Cette methode sers à afficher un brin par le segment crée par lui meme et le brin avec le lequel il partage une relation alpha 0
  public void render(){
  
    beginShape(LINES);
    vertex(point.x,point.y,point.z);
    vertex(alpha[0].point.x, alpha[0].point.y, alpha[0].point.z);
    endShape();
  }

}

//######################
// La classe Face permet de representé une face(triangle) à l'aide de seulement 2 brins
// Cette classe permet surtout de mettre en ordre les données
// C'est pourquoi un seul et même triangle peut être reprenté par plusieurs instances de Face

public class Face{

  Brin b1;
  Brin b2;
  
  public Face(Brin a, Brin b){
    b1=a;
    b2=b;

    b1.connect(1,b2); // le brin b1 et b2 partage une relation aplha 1 
  }
  
  // Affiche les 2 brins
  public void render(){
    b1.render();
    b2.render();
  }

  // Calcul de  la normal de la face
  public PVector normals(){
    
    PVector p = b1.point; // on recupere le point partagé par b1 et b2

    PVector b1vec= PVector.sub(b1.alpha[0].point,p); //on prend le segement auquel appartient b1
    PVector b2vec= PVector.sub(b2.alpha[0].point,p); //on prend le segement auquel appartient b2

    PVector result=new PVector();
    PVector.cross(b1vec,b2vec,result); // puis on realise un produit vectoriel pour obtenir la normal de la Face
    result.normalize();

    return result;
  }
}

//######################
// La classe Point represente un point de l'espace
// Ce point appartient à un certain nombre de faces
enum Relation {
  upLeft,    // 0
  downLeft1, // 1
  downLeft2, // 2
  downRight, // 3
  upRight1,  // 4
  upRight2   // 5
}

public class Point {  
  //il y'a un maximum de 6 faces rattacher à ce point
  //chacune de ces variable permet de définir le brin auquel il peut etre rattaché
  //cf schema
  // cette reprensation des point permet  realiser facilement les coutures entre brin adajacents
  /*
  public Face upLeft = null; //0
  public Face downLeft1 = null; //1
  public Face downLeft2 = null; //2
  public Face downRight = null; //3
  public Face upRight1 = null; //4
  public Face upRight2 = null; //5*/
  
  // Nouvelle représentation  
  public Face[] faces = new Face[6]; // [upLeft, downLeft1, downLeft2, downRight, upRight1, upRight2]
  
  public PVector point;

  Point(PVector p){
    point = p;

    for(int i =0 ; i<6 ; i++){
      faces[i] = null;
    }
  }
  /*
  public void setFaces() {
    faces = new Face[]{upLeft, downLeft1, downLeft2, downRight, upRight1, upRight2};
  }
  public void setVar() {
    upLeft = faces[0];
    downLeft1 = faces[1];
    downLeft2 = faces[2];
    downRight = faces[3];
    upRight1 = faces[4];
    upRight2 = faces[5];
  }*/

  public Face getFace(Relation r) {
    return faces[r.ordinal()];
  }

  public void connect(int alpha, Relation a, Relation b) { // Connection de b1 vers b2
     faces[a.ordinal()].b1.connect(alpha, faces[b.ordinal()].b2);
  }

  public void add(Relation r) { 
    // Point sans couture
    faces[r.ordinal()] = new Face(new Brin(point), new Brin(point));
  }
  
  public void add(Relation a, Relation b) {
    // Point avec 1 couture    
    faces[a.ordinal()] = new Face(new Brin(point), new Brin(point));
    faces[b.ordinal()] = new Face(new Brin(point), new Brin(point));

    //couture sur les faces
    faces[b.ordinal()].b1.connect(2, faces[a.ordinal()].b2);
  }
  
  public void add(Relation a, Relation middle, Relation b) {
     // Point avec 2 coutures
    faces[a.ordinal()] = new Face(new Brin(point), new Brin(point));
    faces[middle.ordinal()] = new Face(new Brin(point), new Brin(point));
    faces[b.ordinal()] = new Face(new Brin(point), new Brin(point));
     
    //couture sur les faces
    /*
    faces[b.ordinal()].b1.connect(2, faces[middle.ordinal()].b2);
    faces[middle.ordinal()].b1.connect(2, faces[a.ordinal()].b2);*/
          
    faces[middle.ordinal()].b1.connect(2, faces[a.ordinal()].b2);
    faces[b.ordinal()].b1.connect(2, faces[middle.ordinal()].b2);
  } 
  
  public void render(){
    //si il y'a une face du type ... alors je l'affiche
    for (var f : faces) {
      if (f != null)
        f.render();
    }
  }
  
  /* public void render2(){
    if (upLeft != null) //si il y'a une face du type ... alors je l'affiche
      upLeft.render();
    if (downLeft1 != null)
      downLeft1.render();
    if (downLeft2 != null)
      downLeft2.render();
    if (downRight != null)
      downRight.render();
    if (upRight1 != null)
      upRight1.render();
    if (upRight2 != null)
      upRight2.render();
  }*/

  public void setZ(float z){//permet de modifier la profondeur z du point
    point.z=z;

  }

  //l'affichage des normales
  public void drawNormals(){

    PVector norm = new PVector(0,0,0);//on va d'abors effectuer une moyenne sur les normales des faces
    int n =0;
    
    for (var f : faces) {
      if (f != null) {
        norm.add(f.normals());
        n++;
      }
    }
    /*if (upLeft != null) {
      norm.add(upLeft.normals());
      n++;
    }
    if (downLeft1 != null){
      norm.add(downLeft1.normals());
      n++;
    }
    if (downLeft2 != null){
      norm.add( downLeft2.normals());
      n++;
    }
    if (downRight != null){
      norm.add(downRight.normals());
      n++;
    }
    if (upRight1 != null){
      norm.add(upRight1.normals());
      n++;
    }
    if (upRight2 != null){
      norm.add(upRight2.normals());
      n++;
    }*/
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

public class Map2g {
  
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
      // On créer les points et on définies leurs relations avec les autres points
       Point p = new Point(new PVector(x*scaling, y*scaling, terrain[x][y])); 

        // Les relations entres les points sont définis selon 9 cas different
        
        // Les coins superieur gauche
        if(x==0 && y==0){   
          p.add(Relation.upLeft);
          /*
          p.upLeft = new Face(new Brin(p.point), new Brin(p.point));  */
        } 
        // Les points le long du bord supérieur
        else if(x<(column-1) && y==0){ 
          p.add(Relation.upLeft, Relation.upRight2, Relation.upRight1);
          /*
          p.upLeft = new Face(new Brin(p.point), new Brin(p.point));
          p.upRight1=new Face(new Brin(p.point), new Brin(p.point));
          p.upRight2=new Face(new Brin(p.point), new Brin(p.point));

          //couture sur les faces
          p.upRight2.b1.connect(2, p.upRight1.b2);
          p.upLeft.b1.connect(2, p.upRight2.b2);
          */
        } 
        // Le coins supérieur droit
        else if(x==(column-1) && y==0){ 
          p.add(Relation.upRight1, Relation.upRight2);
          /*
          p.upRight1=new Face(new Brin(p.point), new Brin(p.point));
          p.upRight2=new Face(new Brin(p.point), new Brin(p.point));

          //couture sur les faces
          p.upRight2.b1.connect(2,p.upRight1.b2);
          */
        } 
        // Les points le long du bord gauche
        else if (x==0 && y<(row-1) ){ 
          p.add(Relation.upLeft, Relation.downLeft1, Relation.downLeft2);
          /*
          p.upLeft=new Face(new Brin(p.point), new Brin(p.point));
          p.downLeft1=new Face(new Brin(p.point), new Brin(p.point));
          p.downLeft2=new Face(new Brin(p.point), new Brin(p.point));

          //couture sur les faces
          p.downLeft1.b2.connect(2,p.downLeft2.b1);
          p.downLeft1.b1.connect(2,p.upLeft.b2);
          */
        }
        // Les points le long du bord droit
        else if (x==(column-1) && y<(row-1)) { 
          p.add(Relation.downRight, Relation.upRight1, Relation.upRight2);
          /*
          p.downRight=new Face(new Brin(p.point), new Brin(p.point));
          p.upRight1=new Face(new Brin(p.point), new Brin(p.point));
          p.upRight2=new Face(new Brin(p.point), new Brin(p.point));

          //coutures
          p.downRight.b2.connect(2,p.upRight1.b1);
          p.upRight1.b2.connect(2,p.upRight2.b1);
          */
        }
         // Le coin inferieur gauche
        else if (x==0 && y==(row-1)) { 
          p.add(Relation.downLeft1, Relation.downLeft2);
          /*
          p.downLeft1=new Face(new Brin(p.point), new Brin(p.point));

          p.downLeft2=new Face(new Brin(p.point), new Brin(p.point));

          //coutures
          p.downLeft1.b2.connect(2,p.downLeft2.b1);
          */
        }
        // Le point le long du bord inférieur
        else if(x<(column-1) && y==(row-1)){  
          p.add(Relation.downLeft1, Relation.downLeft2, Relation.downRight);
          /*
          p.downLeft1 = new Face(new Brin(p.point), new Brin(p.point));
          p.downLeft2 = new Face(new Brin(p.point), new Brin(p.point));
          p.downRight = new Face(new Brin(p.point), new Brin(p.point));

          //COUTURES
          p.downRight.b1.connect(2, p.downLeft2.b2);
          p.downLeft1.b2.connect(2, p.downLeft2.b1);
          */
        }
        // Le coins inferieur droit
        else if(x==(column-1) && y==(row-1)){
          p.add(Relation.downRight);
          /*
          p.downRight= new Face(new Brin(p.point), new Brin(p.point));*/
        }
         // Le cas général (dans le milieu )
        else{
          p.add(Relation.downRight, Relation.downLeft2, Relation.downLeft1);
          p.add(Relation.downRight, Relation.upRight1, Relation.upRight2);
          p.add(Relation.upRight2, Relation.upLeft, Relation.downLeft1);
  
        /*
          p.upLeft   =new Face(new Brin(p.point), new Brin(p.point));
          p.downLeft1 =new Face(new Brin(p.point), new Brin(p.point));
          p.downLeft2 =new Face(new Brin(p.point), new Brin(p.point));
          p.downRight = new Face(new Brin(p.point), new Brin(p.point));
          p.upRight1=new Face(new Brin(p.point), new Brin(p.point));
          p.upRight2=new Face(new Brin(p.point), new Brin(p.point));

          //coutures
          p.downRight.b1.connect(2,p.downLeft2.b2);
          p.downLeft1.b2.connect(2,p.downLeft2.b1);

          p.downRight.b2.connect(2,p.upRight1.b1);
          p.upRight1.b2.connect(2,p.upRight2.b1);

          p.upLeft.b1.connect(2,p.upRight2.b2);
          p.upLeft.b2.connect(2,p.downLeft1.b1);*/
        } 
      return p;
  }
  
  //la fonction permettant de relier les point par des segment(via les brins)
  public void linkAlpha0(){

    for (int y = 0; y < row; y++){ 
      for (int x = 0; x <column; x++){ 

        Point p = mapPoint[x][y];
        if(x==0 && y==0) {} 
        // Les points le long du bord supérieur
        else if(x<=(column-1) && y==0){  
          mapPoint[x-1][y].getFace(Relation.upLeft).b2.connect(0,p.getFace(Relation.upRight1).b1);
          //mapPoint[x-1][y].upLeft.b2.connect(0,p.upRight1.b1);
        }  
        // Les points le long du bord gauche
        else if (x==0 && y<(row-1) ){ 
          mapPoint[x][y-1].getFace(Relation.upLeft).b1.connect(0, p.getFace(Relation.downLeft2).b2);
          mapPoint[x+1][y-1].getFace(Relation.upRight1).b2.connect(0, p.getFace(Relation.downLeft2).b1);
          mapPoint[x+1][y-1].getFace(Relation.upRight2).b1.connect(0,p.getFace(Relation.downLeft1).b2);
        }
        // Les points le long du bord droit
        else if (x==(column-1) &&y<(row-1)) {   
          mapPoint[x-1][y].getFace(Relation.downLeft1).b1.connect(0, p.getFace(Relation.downRight).b2);
          mapPoint[x-1][y].getFace(Relation.upLeft).b2.connect(0, p.getFace(Relation.upRight1).b1);
          mapPoint[ x ][y-1].getFace(Relation.upRight2).b2.connect(0, p.getFace(Relation.downRight).b1);
          
        }
        // Le coin inferieur gauche
        else if (x==0 &&y==(row-1)) {  
          
          mapPoint[x][y-1].getFace(Relation.upLeft).b1.connect(0,p.getFace(Relation.downLeft2).b2);
          mapPoint[x+1][y-1].getFace(Relation.upRight1).b2.connect(0,p.getFace(Relation.downLeft2).b1);
          mapPoint[x+1][y-1].getFace(Relation.upRight2).b1.connect(0,p.getFace(Relation.downLeft1).b2);

        }
        // Le point le long du bord inférieur
        else if(x<(column-1) && y==(row-1)){   
          
          mapPoint[x][y-1].getFace(Relation.upLeft).b1.connect(0, p.getFace(Relation.downLeft2).b2);
          mapPoint[x][y-1].getFace(Relation.upRight2).b2.connect(0, p.getFace(Relation.downRight).b1);
 
          mapPoint[x-1][y].getFace(Relation.downLeft1).b1.connect(0,p.getFace(Relation.downRight).b2);
          
          mapPoint[x+1][y-1].getFace(Relation.upRight1).b2.connect(0,p.getFace(Relation.downLeft2).b1);
          mapPoint[x+1][y-1].getFace(Relation.upRight2).b1.connect(0,p.getFace(Relation.downLeft1).b2);
          
        }
        else if(x==(column-1) &&y==(row-1)){//le coins inferieur droit
         
          
          mapPoint[x-1][y].getFace(Relation.downLeft1).b1.connect(0,p.getFace(Relation.downRight).b2);
          mapPoint[x][y-1].getFace(Relation.upRight2).b2.connect(0,p.getFace(Relation.downRight).b1);
          
        }
        else{//cas général
          mapPoint[x-1][y].getFace(Relation.downLeft1).b1.connect(0, p.getFace(Relation.downRight).b2);
          mapPoint[x-1][y].getFace(Relation.upLeft).b2.connect(0,p.getFace(Relation.upRight1).b1);

          mapPoint[x][y-1].getFace(Relation.upRight2).b2.connect(0, p.getFace(Relation.downRight).b1);
          mapPoint[x][y-1].getFace(Relation.upLeft).b1.connect(0, p.getFace(Relation.downLeft2).b2);
          
          mapPoint[x+1][y-1].getFace(Relation.upRight1).b2.connect(0, p.getFace(Relation.downLeft2).b1);
          mapPoint[x+1][y-1].getFace(Relation.upRight2).b1.connect(0, p.getFace(Relation.downLeft1).b2);
          
        }
        mapPoint[x][y] = p;
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
