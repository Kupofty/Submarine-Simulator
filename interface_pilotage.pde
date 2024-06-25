//-----------------------------------------------
import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;
//-----------------------------------------------

//Définie les variables
int W=1920;
int H=1080; 
float Pitch; 
float Bank; 
float Azimuth; 
float ArtificialHoizonMagnificationFactor=0.6; 
float CompassMagnificationFactor=0.85; 
float SpanAngle=120; 
int NumberOfScaleMajorDivisions; 
int NumberOfScaleMinorDivisions; 
float roll_axis, pitch_axis, yaw_axis,speed_cursor,Depth,Speed, Pression, ballast;
PVector pos;
PVector vel;
ArrayList<PVector>hist;
int moveX=0;
int moveY=0;
float volumeballast=0;
float QuantiteOxygene= 100;
float xn=0;
float yn=0;

//-----------------------------------------------

//Active le contrôle par manette/stick
ControlIO control;
ControlDevice stick;

//-----------------------------------------------

//Ajuste l'écran et repère les entrées utilisables pour piloter 
public void setup() {
  fullScreen();
  rectMode(CENTER); 
  smooth(8); 
  strokeCap(SQUARE);
  surface.setTitle("Interface Homme Machine Sous-Marin"); 
  control = ControlIO.getInstance(this);   
  stick = control.filter(GCP.STICK).getMatchedDevice("IHM_sous_marin"); }

//-----------------------------------------------

//Fait correspondre des variables aux boutons de la manette
public void getUserInput() {
  roll_axis = map(stick.getSlider("X").getValue(), 0, 1, 0, width)*0.26;
  pitch_axis = map(stick.getSlider("Y").getValue(), 0, 1, -1, height)*0.21;
  yaw_axis = map (stick.getSlider("Z").getValue(), 1, -1, 0, height);
  speed_cursor = 0.015*map(stick.getSlider("S").getValue(), 1, 0, 0, width)-1920*0.015; 
  ballast=map(stick.getHat("BALLAST").getValue(), 0, 1, 0, width);}
  
//-----------------------------------------------

//Met à jour les positions
void Update() {
  hist.add(pos.copy());
  pos.x += vel.x*Bank;
  pos.y += vel.y*Pitch;
  moveX = int(vel.x);
  moveY = int(vel.y);
  pos.x = (pos.x + width) % width;
  pos.y = (pos.y + height) % height;}
  
//-----------------------------------------------
//-----------------------------------------------

//Fonction principale d'affichage (boucle)
void draw() { 
  getUserInput();
  background(255); 
  translate(W/4, H/2.1);  
  AnglesJoystick(); 
  Horizon(); 
  rotate(-Bank); 
  GraduationHorizon(); 
  AxesHorizon(); 
  rotate(Bank); 
  FondNoir(); 
  
  AnglesHorizon(); 
  
  CompteurBallast();
  CompteurVitesse();
  CompteurPression();
  
  Compas(); 
  Azimuth();
  
  Vitesse();
  AfficheVitesse();
  
  Profondeur();
  AfficheProfondeur();
  
  Ballast();
  AfficheBallast();
  
  Oxygene();
  AfficheOxygene(); 
  
  AfficheDate();
  
  DangerOxygene();
  DangerProfondeur();
  DangerVitesse();
  
  Position();
  AffichePosition();
  AfficheNom();}
  
//-----------------------------------------------

//Affiche l'horizon
void Horizon() { 
  scale(ArtificialHoizonMagnificationFactor); 
  noStroke(); 
  smooth(8);

  /// Ciel ////
  fill(0, 180, 255); 
  rotate(-Bank);
  rect(0, -1200+Pitch, 3000, 2500); 
  rotate(Bank);
  
  //// Entre ciel et terre ////
  fill(10,10,10,150);
  rotate(-Bank);
  rect(0,0+Pitch,2000,10);
  rotate(Bank);
 
  /// Terre ////
  fill(95, 55, 40); 
  rotate(-Bank); 
  rect(0,1250 +Pitch, 3000, 2500); 
  rotate(Bank); 
  
  //// Cercle horizon ////
  rotate(-PI-PI/6); 
  SpanAngle=120; 
  NumberOfScaleMajorDivisions=12; 
  NumberOfScaleMinorDivisions=24;  
  GraduationCirculaire(); 
  rotate(PI+PI/6); 
  rotate(-PI/6);  
  GraduationCirculaire(); 
  rotate(PI/6); }

//-----------------------------------------------

void GraduationHorizon() {  
  stroke(255); 
  fill(255); 
  strokeWeight(3); 
  textSize(24); 
  textAlign(CENTER); 
  
  for (int i=-4;i<5;i++) {  
    if ((i==0)==false) { 
      line(110, 50*i, -110, 50*i);  }  
      
    text(""+i*10, 140, 50*i, 100, 30); 
    text(""+i*10, -140, 50*i, 100, 30); } 
    
  textAlign(CORNER); 
  strokeWeight(2); 
  for (int i=-9;i<10;i++) {  
    if ((i==0)==false) {    
      line(25, 25*i, -25, 25*i); } } }

//-----------------------------------------------

//Affiches les axes de l'horizon
void AxesHorizon() { 
  stroke(255, 0, 0); 
  strokeWeight(3); 
  line(-115, 0, 115, 0); 
  line(0, 280, 0, -280); 
  fill(100, 255, 100); 
  stroke(0); 
  triangle(0, -285, -10, -255, 10, -255); 
  triangle(0, 285, -10, 255, 10, 255); }

//-----------------------------------------------

//Rectangle noir à droite
  void FondNoir() { 
  fill(0); 
  rect(1810,0,2000,5000);
  rect(-500,-900,2700,550);
  rect(500,+900,2700,400);
  rect(-950,0,450,5000);
  
  fill(135);
  rect(-500,-900,6000,120);
  rect(500,+985,6000,120);
  rect(-950,0,335,5000);
  rect(+2550,0,335,5000);}

//-----------------------------------------------

//Affiche le cap suivi (azimuth)
void Azimuth() { 
  fill(50); 
  noStroke(); 
  rect(20, 470, 440, 50); 
  int Azimuth1=round(Azimuth); 
  textAlign(CORNER); 
  textSize(35); 
  fill(255); 
  text("Angle:  "+Azimuth1+" Deg", 140, 477, 500, 60); }
  
//-----------------------------------------------

//Affiche le compteur des ballasts
void CompteurBallast() { 
  translate(1250,-450); 
  scale(CompassMagnificationFactor); 
  noFill(); 
  stroke(100); 
  strokeWeight(80); 
  ellipse(0, 0, 750, 750); 
  strokeWeight(50); 
  stroke(50); 
  fill(0, 0, 40); 
  ellipse(0, 0, 610, 610); 
  
  for (int k=255;k>0;k=k-5) { 
    noStroke(); 
    fill(0, 0, 255-k); 
    ellipse(0, 0, 2*k, 2*k);  } 
    
  strokeWeight(20); 
  NumberOfScaleMajorDivisions=18; 
  NumberOfScaleMinorDivisions=36;  
  SpanAngle=270; 
  GraduationCirculaire(); 

  fill(255); 
  textSize(40); 
  textAlign(CENTER); 
  text("15%", -375, 0, 100, 80); 
  text("85%", 370, 0, 100, 80); 
  text("50%", 0, -365, 100, 80); 

  textSize(23); 
  text("BALLASTS", 0, -130, 500, 80); 
  text("(remplissage %)", 0, -80, 500, 80); 
  rotate(PI/4); 
  textSize(40); 
  text("35%", -370, 0, 100, 50); 
  text("70%", 0, -355, 100, 50); 
  text("0%", 0, 365, 100, 50); 
  textSize(30); 
  text("100%", 375, 0, 100, 50); 
  rotate(-PI/4); 
  AiguilleBallast();}
  
//-----------------------------------------------

//Affiche le compteur de vitesse
void CompteurVitesse(){
  translate(900,0); 
  scale(CompassMagnificationFactor*1.17); 
  noFill(); 
  stroke(100); 
  strokeWeight(80); 
  ellipse(0, 0, 750, 750); 
  strokeWeight(50); 
  stroke(50); 
  fill(0, 0, 40); 
  ellipse(0, 0, 610, 610); 
  
  for (int k=255;k>0;k=k-5) { 
    noStroke(); 
    fill(0, 0, 255-k); 
    ellipse(0, 0, 2*k, 2*k);  } 
    
  strokeWeight(20); 
  NumberOfScaleMajorDivisions=18; 
  NumberOfScaleMinorDivisions=36;  
  SpanAngle=270; 
  GraduationCirculaire(); 
  fill(255); 
  textSize(60); 
  textAlign(CENTER); 
  text("5", -375, 0, 100, 80); 
  text("25", 370, 0, 100, 80); 
  text("15", 0, -365, 100, 80);  
  textSize(25); 
  text("VITESSE", 0, -130, 500, 80); 
  text("(noeuds)", 0, -80, 500, 80); 
  rotate(PI/4); 
  textSize(40); 
  text("10", -370, 0, 100, 50); 
  text("30", 365, 0, 100, 50); 
  text("20", 0, -355, 100, 50); 
  text("0", 0, 365, 100, 50); 
  rotate(-PI/4); 
  
  AiguilleVitesse();}

//-----------------------------------------------

  //Affiche le compteur de pression
  void CompteurPression() { 
  translate(0,1100); 
  scale(CompassMagnificationFactor*1.17); 
  noFill(); 
  stroke(100); 
  strokeWeight(80); 
  ellipse(0, 0, 750, 750); 
  strokeWeight(50); 
  stroke(50); 
  fill(0, 0, 40); 
  ellipse(0, 0, 610, 610); 
  
  for (int k=255;k>0;k=k-5) { 
    noStroke(); 
    fill(0, 0, 255-k); 
    ellipse(0, 0, 2*k, 2*k);  } 
    
  strokeWeight(20); 
  NumberOfScaleMajorDivisions=18; 
  NumberOfScaleMinorDivisions=36;  
  SpanAngle=270; 
  GraduationCirculaire(); 
  
  fill(255); 
  textSize(60); 
  textAlign(CENTER); 
  text("5", -375, 0, 100, 80); 
  text("25", 370, 0, 100, 80); 
  text("15", 0, -365, 100, 80);  
  textSize(25); 
  text("PRESSION", 0, -130, 500, 80);
  text("(bar)", 0, -80, 500, 80); 
  rotate(PI/4); 
  textSize(40); 
  text("10", -370, 0, 100, 50); 
  text("30", 365, 0, 100, 50); 
  text("20", 0, -355, 100, 50); 
  text("0", 0, 365, 100, 50); 
  rotate(-PI/4); 
  
  AiguillePression();}
  
//-----------------------------------------------

//Affiche le compas
void Compas() { 
  translate(-900,0); 
  scale(CompassMagnificationFactor*1.19); 
  noFill(); 
  stroke(100); 
  strokeWeight(80); 
  ellipse(0, 0, 750, 750); 
  strokeWeight(50); 
  stroke(50); 
  fill(0, 0, 40); 
  ellipse(0, 0, 610, 610); 
  
  for (int k=255;k>0;k=k-5) { 
    noStroke(); 
    fill(0, 0, 255-k); 
    ellipse(0, 0, 2*k, 2*k);  } 
    
  strokeWeight(20); 
  NumberOfScaleMajorDivisions=18; 
  NumberOfScaleMinorDivisions=36;  
  SpanAngle=180; 
  GraduationCirculaire(); 
  rotate(PI); 
  SpanAngle=180; 
  GraduationCirculaire(); 
  rotate(-PI); 
  
  fill(255); 
  textSize(60); 
  textAlign(CENTER); 
  text("O", -375, 0, 100, 80); 
  text("E", 370, 0, 100, 80); 
  text("N", 0, -365, 100, 80); 
  text("S", 0, 375, 100, 80); 
  textSize(25); 
  text("Cap", 0, -130, 500, 80); 
  text("(degrés)", 0, -80, 500, 80); 
  rotate(PI/4); 
  textSize(40); 
  text("NO", -370, 0, 100, 50); 
  text("SE", 365, 0, 100, 50); 
  text("NE", 0, -355, 100, 50); 
  text("SO", 0, 365, 100, 50); 
  rotate(-PI/4); 
  
  AiguilleCompas();}

//-----------------------------------------------

//Affiche l'aiguille du compteur d'oxygène
void AiguilleBallast() { 
  rotate(PI-7*volumeballast);  
  stroke(0); 
  strokeWeight(4); 
  fill(240, 195, 0); 
  triangle(-20, -210, 20, -210, 0, 270); 
  triangle(-15, 210, 15, 210, 0, 270); 
  ellipse(0, 0, 45, 45);   
  fill(0, 0, 50); 
  noStroke(); 
  ellipse(0, 0, 10, 10); 
  triangle(-20, -213, 20, -213, 0, -190); 
  triangle(-15, -215, 15, -215, 0, -200); 
  rotate(-PI+7*volumeballast);   }

//-----------------------------------------------

//Affiche l'aiguille du compteur de vitesse
void AiguilleVitesse() { 
  rotate((PI/4)+Speed/6.3);  
  stroke(0); 
  strokeWeight(4); 
  fill(250, 0, 0); 
  triangle(-20, -210, 20, -210, 0, 270); 
  triangle(-15, 210, 15, 210, 0, 270); 
  ellipse(0, 0, 45, 45);   
  fill(0, 0, 0); 
  noStroke(); 
  ellipse(0, 0, 10, 10); 
  triangle(-20, -213, 20, -213, 0, -190); 
  triangle(-15, -215, 15, -215, 0, -200); 
  rotate(-PI/4-Speed/6.3); }
  
//-----------------------------------------------

  //Affiche l'aiguille du compteur de pression
  void AiguillePression() { 
  rotate(PI/4-Pression/6.15);  
  stroke(0); 
  strokeWeight(4); 
  fill(255,255,255); 
  triangle(-20, -210, 20, -210, 0, 270); 
  triangle(-15, 210, 15, 210, 0, 270); 
  ellipse(0, 0, 45, 45);   
  fill(0, 0, 50); 
  noStroke(); 
  ellipse(0, 0, 10, 10); 
  triangle(-20, -213, 20, -213, 0, -190); 
  triangle(-15, -215, 15, -215, 0, -200); 
  rotate(-PI/4+Pression/6.15); }
  
//-----------------------------------------------

  //Affiche l'aiguille du compas
  void AiguilleCompas() { 
  rotate(PI+radians(Azimuth));  
  stroke(0); 
  strokeWeight(4); 
  fill(100, 255, 100); 
  triangle(-20, -210, 20, -210, 0, 270); 
  triangle(-15, 210, 15, 210, 0, 270); 
  ellipse(0, 0, 45, 45);   
  fill(0, 0, 50); 
  noStroke(); 
  ellipse(0, 0, 10, 10); 
  triangle(-20, -213, 20, -213, 0, -190); 
  triangle(-15, -215, 15, -215, 0, -200); 
  rotate(-PI-radians(Azimuth)); }
  
//-----------------------------------------------

void GraduationCirculaire() { 
  float GaugeWidth=800;  
  textSize(GaugeWidth/30); 
  float StrokeWidth=1; 
  float an; 
  float DivxPhasorCloser; 
  float DivxPhasorDistal; 
  float DivyPhasorCloser; 
  float DivyPhasorDistal; 
  strokeWeight(2*StrokeWidth); 
  stroke(255);
  float DivCloserPhasorLenght=GaugeWidth/2-GaugeWidth/9-StrokeWidth; 
  float DivDistalPhasorLenght=GaugeWidth/2-GaugeWidth/7.5-StrokeWidth;
  
  for (int i=0;i<NumberOfScaleMinorDivisions+1;i++) { 
    an=SpanAngle/2+i*SpanAngle/NumberOfScaleMinorDivisions;  
    DivxPhasorCloser=DivCloserPhasorLenght*cos(radians(an)); 
    DivxPhasorDistal=DivDistalPhasorLenght*cos(radians(an)); 
    DivyPhasorCloser=DivCloserPhasorLenght*sin(radians(an)); 
    DivyPhasorDistal=DivDistalPhasorLenght*sin(radians(an));   
    line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); }
    
  DivCloserPhasorLenght=GaugeWidth/2-GaugeWidth/10-StrokeWidth; 
  DivDistalPhasorLenght=GaugeWidth/2-GaugeWidth/7.4-StrokeWidth;
  
  for (int Division=0;Division<NumberOfScaleMajorDivisions+1;Division++) { 
    an=SpanAngle/2+Division*SpanAngle/NumberOfScaleMajorDivisions;  
    DivxPhasorCloser=DivCloserPhasorLenght*cos(radians(an)); 
    DivxPhasorDistal=DivDistalPhasorLenght*cos(radians(an)); 
    DivyPhasorCloser=DivCloserPhasorLenght*sin(radians(an)); 
    DivyPhasorDistal=DivDistalPhasorLenght*sin(radians(an)); 
    
    if (Division==NumberOfScaleMajorDivisions/2|Division==0|Division==NumberOfScaleMajorDivisions) { 
      strokeWeight(15); 
      stroke(0); 
      line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); 
      strokeWeight(8); 
      stroke(100, 255, 100); 
      line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); } 
      
    else { 
      strokeWeight(3); 
      stroke(255); 
      line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); } } }

//-----------------------------------------------

//Affiche informations sur l'horizon
void AnglesHorizon() {  
  textSize(30); 
  fill(50); 
  noStroke(); 
  rect(-150, 400, 280, 40); 
  rect(150, 400, 280, 40); 
  fill(255); 
  
  int Pitch1=round(Pitch/5); 
  int Bank1;
  
  if( abs(round(Bank*57)) >15){
    Bank1=15;}
  else {
    Bank1=abs(round(Bank*57));}
    
  text("Tangage: "+Pitch1+" Deg", -40, 411, 480, 60); 
  text("Roulis:  "+Bank1+" Deg", 280, 411, 500, 60); 
  //// Indicateur Haut & Bas ////
  textSize(30); 
  fill(50); 
  noStroke(); 
  rect(-150, 450, 280, 40); 
  
  if (Pitch<-5)
  {fill(255,0,0);
    text("BAS", -10,463,360,60);} 
  else if(Pitch>5)
  {fill(0,255,0);
    text("HAUT", -40,463,300,60); }
  else{
    fill(255);
    text("ZERO", -10,463,360,60);}
    
  //// Indicateur gauche & droite ///
   textSize(30); 
  fill(50); 
  noStroke(); 
  rect(150, 450, 280, 40); 
  
  if (Bank<-0.01){
    fill(255,0,0);
    text("GAUCHE", 160,463,-100,60);}  
  else if(Bank>0.01){
    fill(0,255,0);
    text("DROITE", 150,463,-100,60);}  
  else {
    fill(255);
    text("ZERO",170,463,-120,60);}}
  
//-----------------------------------------------

// Relie l'angle des joystick aux valeurs qui les représentent
void AnglesJoystick() { 
  Bank =roll_axis/1890; 
  Pitch=pitch_axis; 
  Azimuth=Azimuth + 0.001*(yaw_axis/3-180);
  if(Azimuth>=180){
      Azimuth=-180;}
  if(Azimuth<-180){
    Azimuth=180;}}

//-----------------------------------------------

//Définit la vitesse du sous-marin
void Vitesse(){
  Speed=Speed+round(speed_cursor)*0.001;
  if(Speed>=30){Speed=30;}
  if(Speed<=0){Speed=0;}}

//-----------------------------------------------

//Affiche la vitesse du sous marin
void AfficheVitesse() { 
  translate(2420,-1800);
  
  fill(50); 
  noStroke(); 
  rect(-1520,1180,350,60); 
  int Vitesse1=round(Speed);
  textAlign(CORNER); 
  textSize(35); 
  fill(255); 
  text("Vitesse:  "+Vitesse1+" nd", -1480, 1180, 330, 50);

  fill(50); 
  noStroke(); 
  rect(-3150,2120,400,60);
  textAlign(CORNER); 
  textSize(30); 
  fill(255); 
  text("Vitesse:  "+Vitesse1+" nd", -3090, 2125, 330, 50);}
  
//-----------------------------------------------

//Définit la profondeur 
void Profondeur(){
  Depth=Depth+sin(round(Pitch/5))*round(Speed)*0.004+volumeballast*0.2;
  if(Depth>=0){Depth=0;}
  if(Depth<=-300){Depth=-300;}
  Pression = (1000*9.81*Depth)/100000 ; }

//-----------------------------------------------

//Affiche la profondeur
void AfficheProfondeur(){
  translate(0,1000);
  fill(50); 
  noStroke(); 
  rect(-1520,1270,350,60); 
  int Profondeur=round(Depth); 
  textAlign(CORNER); 
  textSize(30); 
  fill(255); 
  text("Profondeur:  "+abs(Profondeur)+" m", -1490, 1270, 330, 50);
  
  fill(50); 
  noStroke(); 
  rect(-3850,1120,400,60); 
  textAlign(CORNER); 
  textSize(30); 
  fill(255); 
  text("Profondeur:  "+abs(Profondeur)+" m", -3800,1130,400,60);}
  
//-----------------------------------------------

  //Définit la quantité d'oxygène restante 
void Oxygene(){
  QuantiteOxygene=QuantiteOxygene-0.005;
  if (QuantiteOxygene<=0){
  QuantiteOxygene=0;}}
  
//-----------------------------------------------

//Affiche la quantité oxygene
void AfficheOxygene(){
  translate(-2080,150);
  fill(50); 
  noStroke(); 
  rect(-1520,1270,400,60); 
  int OxygenePourcentage=round(QuantiteOxygene); 
  textSize(30); 
  fill(255); 
  text("Oxygène restant:  "+OxygenePourcentage+"%", -1520, 1270, 350, 50);}

//-----------------------------------------------

//Calcule la valeur de remplissage des ballast
void Ballast(){
  if(ballast==3840.0){volumeballast=volumeballast-0.001;
  if (volumeballast<=-0.336){volumeballast=-0.336;}}
  if(ballast==11520){volumeballast=volumeballast+0.001;
  if (volumeballast>=0.336){volumeballast=0.336;}}}
  
//-----------------------------------------------

//Affiche le remplissage des ballasts en %
void AfficheBallast(){
  translate(-950,-300);
  fill(50); 
  noStroke(); 
  rect(-1480, 477, 330, 60); 
  int BallastPourcentage=round(50-volumeballast*50/0.336); 
  textAlign(CENTER); 
  textSize(35); 
  fill(255); 
  text("Ballasts: "+BallastPourcentage+" %", -1480, 485, 330, 60);}
  
//-----------------------------------------------

//Affiche la date et l'heure
void AfficheDate(){
  fill(50); 
  noStroke(); 
  translate(50,0);
  rect(-870,-490,400,100); 
  
  fill(255);
  translate(-800,300);
  text(day()+" / "+month()+" / "+year(),-75,-800);
  text(hour()+" h "+minute()+" m "+second()+" s ",-70,-760);
  translate(-50,0);}
 
//-----------------------------------------------

//Affiche l'indicateur de danger de quantité d'oxygene
void DangerOxygene(){
  translate(-720,+1050);
  
  if(QuantiteOxygene<=15){
  fill(255,0,0); 
  noStroke(); 
  rect(0,0,400,60);  
  textSize(27); 
  fill(255); 
  text("Quantite oxygène critique", 0, 5, 350, 50);}
  
  else{
  fill(52,201,36); 
  noStroke(); 
  rect(0,0,400,60);  
  textSize(27); 
  fill(255); 
  text("Quantite oxygène correcte", 0, 5, 350, 50);}}
  
//-----------------------------------------------

//Affiche l'indicateur de danger de pression
void DangerProfondeur(){
  translate(+700,0);
  
  if(Depth<=-275){
  fill(255,0,0); 
  noStroke(); 
  rect(0,0,400,60);  
  textSize(27); 
  fill(255); 
  text("Pression critique", 0, 5, 350, 50);}
  
  else{
  fill(52,201,36); 
  noStroke(); 
  rect(0,0,400,60);  
  textSize(27); 
  fill(255); 
  text("Pression correcte", 0, 5, 350, 50);}}
 
//-----------------------------------------------

 //Affiche l'indicateur de danger vitesse
void DangerVitesse(){
  translate(+700,0);
  
  if(Speed>=25){
  fill(255,0,0); 
  noStroke(); 
  rect(0,0,400,60);  
  textSize(27); 
  fill(255); 
  text("Régime moteur critique", 0, 5, 350, 50);}
  
  else{
  fill(52,201,36); 
  noStroke(); 
  rect(0,0,400,60);  
  textSize(27); 
  fill(255); 
  text("Régime moteur correct", 0, 5, 350, 50);}}
  
//-----------------------------------------------

//Calcule la position du sous marin
void Position(){
  yn=yn+0.005*Speed*cos(abs(Azimuth*PI/180))*abs(cos(pitch_axis*PI/180));
  if(yn>=300){yn=300;}
  if(yn<=-300){yn=-300;}
  if(xn>=300){xn=300;}
  if(xn<=-300){xn=-300;}
  xn=xn+0.005*Speed*sin(abs(Azimuth*PI/180))*abs(cos(pitch_axis*PI/180));}

//-----------------------------------------------

//Affiche les coordonnées du sous marin et le secteur de la carte sur lequel il se situe
void AffichePosition(){
  translate(-400,-1350);
  fill(50); 
  noStroke(); 
  rect(-900,-490,600,100); 
  fill(255);
  translate(-800,300);

  textSize(40); 
  text("Secteur carte : ", -230, -780);
  textSize(50); 
  translate(130,25);
  
  if (yn>=-300 && yn<-240){text("1",-105,-800);}
  else if (yn>=-240 && yn<-180){text("2",-105,-800);}
  else if (yn>=-180 && yn<-120){text("3",-105,-800);}
  else if (yn>=-120 && yn<-60){text("4",-105,-800);}
  else if (yn>=-60 && yn<0){text("5",-105,-800);}
  else if (yn>=0 && yn<60){text("6",-105,-800);}
  else if (yn>=60 && yn<120){text("7",-105,-800);}
  else if (yn>=120 && yn<180){text("8",-105,-800);}
  else if (yn>=180 && yn<240){text("9",-105,-800);}
  else if (yn>=240 && yn<=302){text("10",-105,-800);}
  translate(30,0);
  if (xn>=-300 && xn<-240){text("A",-75,-800);}
  else if (xn>=-240 && xn<-180){text("B",-75,-800);}
  else if (xn>=-180 && xn<-120){text("C",-75,-800);}
  else if (xn>=-120 && xn<-60){text("D",-75,-800);}
  else if (xn>=-60 && xn<0){text("E",-75,-800);}
  else if (xn>=0 && xn<60){text("F",-75,-800);}
  else if (xn>=60 && xn<120){text("G",-75,-800);}
  else if (xn>=120 && xn<180){text("H",-75,-800);}
  else if (xn>=180 && xn<240){text("I",-75,-800);}
  else if (xn>=240 && xn<=302){text("J",-75,-800);}
  
  translate(940,-810);
  noStroke(); 
  fill(50); 
  rect(0,0,600,100); 
  translate(+100,+770);
  fill(255);
  textSize(35); 
  text("Coordonnées : ", -250, -760);
  translate(30,0);
  text("X: "+round(xn), -80, -760);
  translate(30,0);
  text("Y: "+round(yn), +20, -760);}
  
//-----------------------------------------------

void AfficheNom(){
  fill(255);
  textSize(80);
  text("N.E.M.O",1125,150);}
