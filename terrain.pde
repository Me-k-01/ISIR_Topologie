
//Variable globales
int rows, columns;
int scale; 

int w = 600; 
int h = 600;

float flying = 0;

//######################
//Declaration de classes
//######################

class Brin {
// La classe Brin represente un brin par un sommet et ses relations alpha avec d'autres Brins

  public PVector point;
  public Brin[] alpha = new Brin[3];
   
  public Brin(PVector p){
    point = p;
  }
  
  // Cette methode permet de mettre en relation alpha un brin avec un autre
  public void connect(int alph, Brin b){
    this.alpha[alph] = b;
    b.alpha[alph]    = this;
  }
  // Cette methode sert à afficher un brin par le segment crée par lui meme et le brin avec le lequel il partage une relation alpha 0
  public void renderLines(){
    beginShape(LINES);
    vertex(point.x, point.y, point.z);
    vertex(alpha[0].point.x, alpha[0].point.y, alpha[0].point.z);
    endShape();
  }
  
  //Affiche un triangle plein partir d'un brin et ses relations
  public void render(){
    beginShape(TRIANGLE);
    vertex(point.x, point.y, point.z);
    vertex(alpha[0].point.x, alpha[0].point.y, alpha[0].point.z); 
    vertex(alpha[1].alpha[0].point.x, alpha[1].alpha[0].point.y, alpha[1].alpha[0].point.z); 
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
    b1 = a;
    b2 = b;

    b1.connect(1,b2); // le brin b1 et b2 partage une relation aplha 1 
  }
  
  // Affiche les 2 brins
  public void render(){
    b1.render();
    b2.render();
  }

  // Calcul de  la normale de la face
  public PVector normals(){
    
    PVector p = b1.point; // on recupere le point partagé par b1 et b2

    PVector b1vec = PVector.sub(b1.alpha[0].point, p); //on prend le segment auquel appartient b1
    PVector b2vec = PVector.sub(b2.alpha[0].point, p); //on prend le segment auquel appartient b2

    PVector result = new PVector();
    PVector.cross(b1vec, b2vec, result); // puis on realise un produit vectoriel pour obtenir la normal de la Face
    result.normalize();

    return result;
  }
}

//######################
// La classe Point represente un point du triangle strip (c'est un point dans l'espace)
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
  // Il y'a un maximum de 6 faces rattacher à ce point ( dans le cas d'un triangle strip)
  // en effet a un point de l'espace j'usqu'a six triangle peuvent partager un point commmun
  // Le but de cette classe est de rassembler les brins partageant ce point pour facilement les mettres en relation 

  // chacune de ces variable permet de définir les brins auquels il peut etre rattaché
  // Cette representation des point permet  realiser facilement les coutures entre brin adajacents (on deduit le troisième segment a partir des deux brins contenu dans la classe Face)
  public Face[] faces = new Face[6]; // [upLeft, downLeft1, downLeft2, downRight, upRight1, upRight2]
  
  public PVector point;

  Point(PVector p){
    point = p;

    for(int i =0 ; i<6 ; i++){
      faces[i] = null;
    }
  } 

  public Face getFace(Relation r) {
    return faces[r.ordinal()];
  }

  public void connect(int alpha, Relation a, Relation b) { // Connection de b1 vers b2
     faces[a.ordinal()].b1.connect(alpha, faces[b.ordinal()].b2);
  }
  // Fonction qui permet d'ajouter une relation avec le vertex.
  public void add(Relation r) { 
    // Point sans couture
    faces[r.ordinal()] = new Face(new Brin(point), new Brin(point));
  }
  
  public void add(Relation a, Relation b) {
    // Point avec 1 couture    
    faces[a.ordinal()] = new Face(new Brin(point), new Brin(point));
    faces[b.ordinal()] = new Face(new Brin(point), new Brin(point));
    // couture sur des faces
    faces[b.ordinal()].b1.connect(2, faces[a.ordinal()].b2);
  }
  
  public void add(Relation a, Relation middle, Relation b) {
     // Point avec 2 coutures
    faces[a.ordinal()] = new Face(new Brin(point), new Brin(point));
    faces[middle.ordinal()] = new Face(new Brin(point), new Brin(point));
    faces[b.ordinal()] = new Face(new Brin(point), new Brin(point));
    // couture sur des faces
    faces[middle.ordinal()].b1.connect(2, faces[a.ordinal()].b2);
    faces[b.ordinal()].b1.connect(2, faces[middle.ordinal()].b2);
  } 
   
  // Fonction qui permet de plonger le brin pour des déformations du terrain.
  public void setZ(float z){  
    point.z = z;

  }
  // Affichage de la face
  public void render(){
    // Si il y'a une face du type, alors je l'affiche
    for (var f : faces) {
      if (f != null) { 
        f.b1.render();
        // On a pas besoin de dessiner le second, car il y a redondance d'information.
        // f.b2.render();
      }
    }
  } 
  //Affichage des segments
  public void renderLines(){
    // Si il y'a une face du type, alors je l'affiche
    for (var f : faces) {
      if (f != null) {   
        f.b1.renderLines();
        // On a pas besoin de dessiner le second, car il y a redondance d'information.
        // f.b2.renderLines(); 
      }
    }
  } 
  
  // L'affichage des normales
  public void drawNormals(){

    PVector norm = new PVector(0,0,0); // On va d'abord effectuer une moyenne sur les normales des faces
    int n = 0;
    
    for (var f : faces) {
      if (f != null) {
        norm.add(f.normals());
        n++;
      }
    } 
    norm.div(n);

    //puis on "aggrandi" et on retourne la normale 
    norm.mult(-10);
    
    //puis on l'affiche vert sous forme d'un petit segment
    stroke(25, 180, 25);
    beginShape(LINES);
      vertex(point.x,point.y,point.z);
      vertex(point.x+norm.x,point.y+norm.y,point.z+norm.z);
    endShape();
    stroke(255);
  }
};

//######################
// La classe permettant de represnter une 2g map
// sous forme d'une matrice de Point
public class Map2g {

  // Nombre de colonnes et de ligne de la 2g map
  public int column;
  public int row;
  public float scaling=scale;

  // L'ensembles des point de l'espace
  public Point[][] mapPoint;
  // Les profondeur z attaché aux points
  public float[][] terrain;

  public Map2g(int nbCol , int nbRow) {
    column = nbCol;
    row    = nbRow;
    mapPoint=new Point[column][row];
    terrain= new float [column][row];
    
    // On genere la 2g map
    for (int y = 0; y < row; y++){ 
      for (int x = 0; x < column; x++){ 
          terrain[x][y]=0;
          Point p=createPoint(x,y);//d'abord on creer les point
          mapPoint[x][y]=p;
      }
    }
    // Puis on relie les segments avec des relations alpha 0
    linkAlpha0();
  }

  // Méthode permettant de creer un points dans la 2g map
  public Point createPoint(int x ,int y ){
    // On créer les points et on définies leurs relations avec les autres points
     Point p = new Point(new PVector(x*scaling, y*scaling, terrain[x][y])); 
    
    // Les relations entres les points sont définis selon 9 cas different
    // Les coins superieur gauche
    if(x==0 && y==0){   
      p.add(Relation.upLeft);
    } 
    
    // Les points le long du bord supérieur
    else if(x<(column-1) && y==0){ 
      p.add(Relation.upLeft, Relation.upRight2, Relation.upRight1);
    } 
    
    // Le coins supérieur droit
    else if(x==(column-1) && y==0){ 
      p.add(Relation.upRight1, Relation.upRight2);
    } 
    
    // Les points le long du bord gauche
    else if (x==0 && y<(row-1) ){ 
      p.add(Relation.upLeft, Relation.downLeft1, Relation.downLeft2);
    }
    
    // Les points le long du bord droit
    else if (x==(column-1) && y<(row-1)) { 
      p.add(Relation.downRight, Relation.upRight1, Relation.upRight2);
    }
    
    // Le coin inferieur gauche
    else if (x==0 && y==(row-1)) { 
      p.add(Relation.downLeft1, Relation.downLeft2);
    }
    
    // Le point le long du bord inférieur
    else if(x<(column-1) && y==(row-1)){  
      p.add(Relation.downLeft1, Relation.downLeft2, Relation.downRight);
    }
    
    // Le coins inferieur droit
    else if(x==(column-1) && y==(row-1)){
      p.add(Relation.downRight); 
    }
    
    // Le cas général (dans le milieu )==> 6 faces
    else{
      p.add(Relation.downRight, Relation.downLeft2, Relation.downLeft1);
      p.add(Relation.downRight, Relation.upRight1, Relation.upRight2);
      p.add(Relation.upRight2, Relation.upLeft, Relation.downLeft1);
    } 
    return p;
  }
  
  // La fonction permettant de relier les point par des segment(via les brins)
  // grace a notre representation toute les relation alpha 1 et alpha 2 sont faite a la construction
  //il ne reste donc qu'a faire les relation alpha 0
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
        
        // Le coins inferieur droit
        else if(x==(column-1) &&y==(row-1)){ 
          mapPoint[x-1][y].getFace(Relation.downLeft1).b1.connect(0,p.getFace(Relation.downRight).b2);
          mapPoint[x][y-1].getFace(Relation.upRight2).b2.connect(0,p.getFace(Relation.downRight).b1);
        }
        
        // Cas général
        else { 
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
  
  // Rendu de la 2g map
  public void render(){
    for (int y = 0; y < row; y++) { 
      for (int x = 0; x <column; x++) { 
        float z = (this.terrain[x][y] + 50); // Entre 0 et 100
        fill((100-z), z, z * 2 ); 
        mapPoint[x][y].setZ(this.terrain[x][y]);
        mapPoint[x][y].render(); 
         
      }  
    }
    stroke(0);
    noFill();
    for (int y = 0; y < row; y++) { 
      for (int x = 0; x <column; x++) {  
        mapPoint[x][y].setZ(this.terrain[x][y] + 0.5);
        mapPoint[x][y].renderLines(); 
        mapPoint[x][y].setZ(this.terrain[x][y] - 0.5);
      }  
    } 
    stroke(255);
  }

  // Fonction de raffinage
  // Notre represenetation sous forme de faces nous permet de realiser le raffinage tres facilement
  // Nous venir intercaler des point suplementaire entre les point deja existant
  // De ce point de depart les ralation alpha 1 et alpha 2 sont conservées
  //il faudra juste reconecter les point par des segment (alpah 0)
  public void split(){
    this.column = column+floor(column/2);  //+50% de points
    this.row    = row+floor(row/2); //+50% de points
    scaling /= 2; // La distance entre les points est 2 fois plus petite.

    // On créer les nouveaux tableaux
    float[][] newTerrain = new float[column][row]; 
    Point[][] newMapPoint=new Point[column][row];

    // On réinitialise le terrain
    for(int y = 0 ;y<row ; y++){
      for(int x = 0; x<column; x++){
        newTerrain[x][y]=0;
      }
    }
    
    this.terrain = newTerrain;

    // On genere le nouveau tableau de points
    for(int y = 0 ;y<row ; y++){
      for(int x = 0; x<column ; x++){
        if(x%2==0 && y%2==0 && x!=(column-1)  && y!=(row-1) ){ // si ce point existait auparavent alors on le conserve
          //car seule les realtion alpha 0 sont modifier les relation alpha 1 et alpha 2 sont conserver
          newMapPoint[x][y] = mapPoint[x/2][y/2];
          
        } else {
          newMapPoint[x][y] = createPoint(x,y); // sinon on creer un nouveau point
        }
      }
    }
    
    mapPoint = newMapPoint;
    // On lie tous les point entre eux par des segments (alpha 0 )
    this.linkAlpha0();
  }
  
  // Afficher les normales
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
  
  map = new Map2g(columns,rows);   
  map.split();
}

void draw() {
  flying -= 0.01;
  float yoff=flying;
  for (int y = 0; y < map.row; y++) { 
    float xoff = 0;
    for (int x = 0; x < map.column; x++) { 
      map.terrain[x][y] = map(noise(xoff, yoff), 0, 1, -50, 50); //on genere la hauteur du terrain
      xoff += 0.2; 
    }  
    yoff += 0.2; 
  }
 
  background(54,54,127);
  stroke(255);
  //noFill();
  
  //transformation geomtrique;
  translate(width/2, height/2);
  rotateX(PI/3);
  translate(-map.column*map.scaling /2 , -map.row*map.scaling /2);
  
  // Rendu du terrain
  map.render();
  map.drawNormals();
}
