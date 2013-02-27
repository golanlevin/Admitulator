import processing.opengl.*;
import java.util.Arrays;
import controlP5.*;

int theYear = 2013;
String admissionsFileName                   =  "2013/20130227-ART.DATA.TOTAL.csv"; //official-start-ART.DATA.TOTAL.2.15.13.csv"; // Excel CSV from Jason Nevinger
String ratingReportFilename                 =  "2013/Ratings_20130217.tsv"; 
String slideroomApplicantSummaryFilename    =  "2013/ApplicantSummary_20130217.tsv";
String onCampusRatingReportFilename         =  "2013/OnCampus-2013-final-tsv.txt";
int admitTarget = 150; 

// Contains pie-chart weightings, bezier shapings, and RGB colors for each priority
String admissionsPrioritiesFileName = "admissionsPriorities.csv";

//---------------------------------------------------------------------------
Student            studentArray[];
SlideroomApplicant slideroomApplicants[];
AdmissionsPriority admissionsPriorities[];
ArrayList<Student> rawAdmissionsStudentVector;

int CURRENT_STUDENT_ID = 0; // in the studentArray
int CURRENT_STUDENT_ALPHAID = 0;

//---------------------------------------------------------------------------
int N_ADMISSIONS_STUDENTS_RAW = 0; // number of students in Admissions database
int N_SLIDEROOM_STUDENTS_RAW = 0;  // number of students in Slideroom 
int N_VALID_STUDENTS = 0;
int COMPARISON_METRIC = -1;
int N_ADMISSIONS_PRIORITIES = 0;
int BACKWARD = -1;
int FORWARD  =  1;
int SORT_DIRECTION = FORWARD;
int whichAdmissionPrioritySelected;
boolean bDORECALCULATION  = true;
boolean bAnonymizeByRot13 = false;
boolean bShowEnrollsOnly  = false;
long lastMousePressedTime = 0;
long lastMouseReleasedTime = 0; 


ControlP5 controlP5;
Evaluator EV;
Pie myPie; 
Stack myStack1;
Stack myStack2;
Stack myStack3;
PFont smallFont;
PFont arial14Font;
PFont arial24Font; 

ListBox applicantListbox;
RadioButton dataTypeRadiobutton;
CheckBox checkbox;
int FLAT_SHAPER_ID   = 1000;
int RELOAD_SHAPER_ID = 1001;
int SORT_BUTTON_ID   = 1002;
int ENROLLS_BUTTON_ID = 1003;
int FORMULA_TOGGLE_ID = 1004;

Toggle toggleMale; 
Toggle toggleFemale;
Toggle toggleFormula;
boolean bMaleOn   = true;
boolean bFemaleOn = true;
boolean bUseAltFormula = true;


int admissionsPriorityX =  20;
int admissionsPriorityY =  20;
int shaperX = admissionsPriorityX;
int shaperY = admissionsPriorityY;
int shaperW = 50;
int stackX  = shaperX + shaperW + 10;
int stackY  = shaperY;
int stackH  = shaperW;
float pieR  = 200; 
float pieX  = 250;
float pieY  = 450;

float mainStackX;
float mainStackH;
float mainStackY;
float mainStackW;
MainStack myMainStack;
boolean bInPie = false;

//====================================================================================
void setup() {

  size (1380, 820);
  controlP5 = new ControlP5(this);
  smallFont = loadFont("fonts/6px2bus24.vlw"); 
  arial14Font = loadFont("fonts/ArialNarrow-14.vlw"); 
  arial24Font = loadFont("fonts/ArialNarrow-24.vlw"); 

  createDataPieceIDs();  
  EV = new Evaluator();

  loadStudentAdmissionsData (); // in DataIO.pde
  loadSlideRoomData ();
  loadAdmissionsPriorities ();

  myStack1 = new Stack(stackX, stackY, width-stackX-30+10, stackH, 0);
  myStack2 = new Stack(stackX-10-stackH, stackY+10+stackH, stackH, stackH, 0);
  myStack3 = new Stack(stackX, stackY+10+stackH, width-stackX-30+10, stackH, 0);

  findMatchesBetweenSlideroomAndAdmissions();
  populateStudentsAdmissionsDataWithSlideroomData();
  compileStudentsWithPortfolioRatings();
  compileStudentTestScores();
  EV.calculateNormalizedStudentData(); // produces normalized but unshaped data 


    mainStackX = 50;
  mainStackH = 220;
  mainStackY = height - mainStackH - 25;
  mainStackW = width - 5 - mainStackX;
  myMainStack = new MainStack(mainStackX, mainStackY, mainStackW, mainStackH); 

  pieR  = ((mainStackY - ( myStack2.ry + myStack2.rh))/2.0) - 80;  //200
  pieY  =  ( myStack2.ry + myStack2.rh) + pieR + 35;
  pieX  = 190;//500;
  myPie = new Pie(); // do after loadAdmissionsPriorities
  selectAdmissionsPriority( myPie.priorityIDs[4]);


  createListBoxes();

  // printSlideRoomStudentsMissingAdmissionsData();
  // findAdmissionsStudentsMissingSlideroomData();

  //
  //printStudentAdmissionsData();
  //printStudentArrayRawData();
  //printStudentArrayNormalizedShapedData();
}

//====================================================================================
void createListBoxes() {

  int albY = (int)( myStack2.ry + myStack2.rh + 30); 
  int albH = (int)(mainStackY - albY - 100); 
  applicantListbox = controlP5.addListBox("applicantListbox", width-150, albY, 120, albH);
  applicantListbox.setItemHeight(12);
  applicantListbox.setBarHeight(20);
  applicantListbox.captionLabel().toUpperCase(true);
  applicantListbox.captionLabel().set("APPLICANTS");
  applicantListbox.captionLabel().style().marginTop = 3;
  applicantListbox.valueLabel().style().marginTop = 3;
  applicantListbox.setColorBackground(color(0, 128));
  applicantListbox.setColorActive(color(0, 0, 255, 128));

  COMPARISON_METRIC = 0; 
  sortStudentArray(FORWARD);

  for (int i=0;i<N_VALID_STUDENTS;i++) {
    String displayName = (studentArray[i].LASTNAME) + ", " + (studentArray[i].FIRSTNAME);
    studentArray[i].alphabeticalIndex = i;
    applicantListbox.addItem(displayName, i);
  }

  controlP5.addBang("Flat", shaperX, shaperY+2*(shaperW+10), 15, 15).setId(FLAT_SHAPER_ID);
  controlP5.addBang("Reload", shaperX+25, shaperY+2*(shaperW+10), 15, 15).setId(RELOAD_SHAPER_ID);

  //controlP5.addBang("Reload",shaperX+25,shaperY+shaperW+10,15,15).setId(RELOAD_SHAPER_ID);
  //SORT_BUTTON_ID

  /*
  toggleFemale = controlP5.addToggle("bFemaleOn");
   toggleFemale.setCaptionLabel("Female"); 
   toggleFemale.setPosition(500,500);
   toggleFemale.setSize(20,20);
   
   toggleMale = controlP5.addToggle("bMaleOn");
   toggleMale.setCaptionLabel("Male"); 
   toggleMale.setPosition(500,540);
   toggleMale.setSize(20,20);
   */

  toggleFormula = controlP5.addToggle("bUseAltFormula");
  toggleFormula.setCaptionLabel("ALT"); 
  toggleFormula.setPosition(970, 160);
  toggleFormula.setSize(20, 20);
  toggleFormula.setId(FORMULA_TOGGLE_ID);
}


void addToRadioButton(RadioButton theRadioButton, String theName, int theValue ) {
  Toggle t = theRadioButton.addItem(theName, theValue);
  t.captionLabel().setColorBackground(color(0, 128));
  t.captionLabel().style().movePadding(2, 0, -1, 2);
  t.captionLabel().style().moveMargin(-2, 0, 0, -2);
  t.captionLabel().style().backgroundWidth = 100;
}






//====================================================================================
void draw() {

  background(160);
  drawActivelyShownAdmissionsPriority();
  myPie.update();

  // println(mouseX + " " + mouseY); 

  if (bDORECALCULATION) {

    if (bUseAltFormula) {
      EV.computeWeightedStudentScoresAlt(); //2();
    } 
    else {
      EV.computeWeightedStudentScoresOld(); //2();
    }
    if (whichAdmissionPrioritySelected != -1) {

      COMPARISON_METRIC = admissionsPriorities[whichAdmissionPrioritySelected].factorID; 
      sortStudentArray(FORWARD);
      myStack1.update (whichAdmissionPrioritySelected);
      myStack2.updateBins (10, whichAdmissionPrioritySelected); 

      COMPARISON_METRIC = ID_SCORE; 
      sortStudentArray(FORWARD);
      myStack3.update(whichAdmissionPrioritySelected);

      bDORECALCULATION = false;
    }
  }


  myStack2.renderHorizontalBins(); 
  myStack1.renderHorizontal();
  myStack3.renderHorizontal();
  fill(255);
  textFont(arial14Font); 
  String apn = admissionsPriorities[whichAdmissionPrioritySelected].name;
  text(apn, myStack1.rx + 5, myStack1.ry+15);

  myMainStack.update();
  myMainStack.render();

  displayCurrentStudentText();
  displayCurrentStudentGraphic();
  myPie.render();

  displayOverview();
}


//====================================================================================
void selectAdmissionsPriority( int whichAPS) {
  bDORECALCULATION = true;

  whichAdmissionPrioritySelected = whichAPS;


  String dataName = admissionsPriorities[whichAdmissionPrioritySelected].name;
  //dataTypeRadiobutton.deactivateAll();
  //dataTypeRadiobutton.activate(dataName); 

  int whichDataPiece = admissionsPriorities[whichAdmissionPrioritySelected].factorID;
  myStack1.setWhichData (whichDataPiece);
  myStack2.setWhichData (whichDataPiece);
  myStack3.setWhichData (whichDataPiece);

  for (int i=0; i<N_ADMISSIONS_PRIORITIES; i++) {
    admissionsPriorities[i].bActivelyShown = (i==whichAdmissionPrioritySelected);
  }
}

//====================================================================================
void controlEvent (ControlEvent theEvent) {
  // ListBox is if type ControlGroup.
  // 1 controlEvent will be executed, where the event
  // originates from a ControlGroup. therefore
  // you need to check the Event with
  // if (theEvent.isGroup())
  // to avoid an error message from controlP5.

  if (theEvent.isGroup()) {
    // an event from a group e.g. scrollList
    if (theEvent.group() == dataTypeRadiobutton) {
      selectAdmissionsPriority ( (int)(dataTypeRadiobutton.value()));
    } 
    else if (theEvent.group() == applicantListbox) {

      int value = (int)( theEvent.group().value());
      value = max(0, min(value, N_VALID_STUDENTS)); 

      for (int i=0; i<N_VALID_STUDENTS; i++) {
        if (studentArray[i].alphabeticalIndex == value) {
          CURRENT_STUDENT_ALPHAID = value;
          CURRENT_STUDENT_ID = i;
          bDORECALCULATION = true;
          //break;

          for (int j=0; j<N_VALID_STUDENTS; j++) {
            studentArray[j].bIAmTheCurrentStudent = false;
          }
          studentArray[i].bIAmTheCurrentStudent = true;
          break;
        }
      }
    }
  } 
  else {

    if (theEvent.controller().id() == FLAT_SHAPER_ID) {
      linearizeActivelyShownAdmissionsPriority();
    } 
    else if (theEvent.controller().id() == RELOAD_SHAPER_ID) {
      reloadActivelyShownAdmissionsPriority();
    }
    else if (theEvent.controller().id() == FORMULA_TOGGLE_ID) {
      bDORECALCULATION = true;
    }
  }
}



//------------------------------------------------------------------------
int countAccepts() {
  int count = 0; 
  for (int i=0; i<N_VALID_STUDENTS; i++) {
    Student S = studentArray[i];

    char decn = (char)(S.fDataArrayRaw[ID_DECISION]);
    if (decn == 'A') {
      count++;
    }
  }
  return count;
}


int countThoseWithDecision(char whichDecn) {
  int count = 0; 
  for (int i=0; i<N_VALID_STUDENTS; i++) {
    Student S = studentArray[i];

    char decn = (char)(S.fDataArrayRaw[ID_DECISION]);
    if (decn == whichDecn) {
      count++;
    }

    else if (whichDecn == ' ') {
      if ((int)decn == 65535) {
        count++;
      }
    }
  }
  return count;
}


//------------------------------------------------------------------------
int countStudentsOfEthnicity (int whichEth, boolean bOnlyCountAdmitted) {
  int count = 0; 
  for (int i=0; i<N_VALID_STUDENTS; i++) {
    int eth = getStudentEthnicity(i); 

    if (bOnlyCountAdmitted) {
      char decn = getStudentDecision (i);
      if (decn == 'A') {
        if (eth == whichEth) {
          count++;
        }
      }
    } 
    else {
      if (eth == whichEth) {
        count++;
      }
    }
  }
  return count;
}


//------------------------------------------------------------------------
int countStudentsOfSex (char whichSex, boolean bOnlyCountAdmitted) {
  int count = 0; 

  for (int i=0; i<N_VALID_STUDENTS; i++) {
    Student S = studentArray[i];
    char sex = ((char)(studentArray[i].fDataArrayRaw[ID_SEX]));

    if (bOnlyCountAdmitted) {
      if (sex == whichSex) {
        char decn = getStudentDecision (i);
        if (decn == 'A') {
          count++;
        }
      }
    } 
    else {
      if (sex == whichSex) {
        count++;
      }
    }
  }
  return count;
}

//------------------------------------------------------------------------
int countBxaType (int whichBxaKind, boolean bOnlyCountAdmitted) {
  int count = 0; 
  int anyBxaCount = 0; 

  for (int i=0; i<N_VALID_STUDENTS; i++) {
    Student S = studentArray[i];

    if (bOnlyCountAdmitted) {
      char decn = getStudentDecision (i);
      if (decn == 'A') {
        int degreeType = getStudentDegreeOption (i);
        if ((whichBxaKind == BXA_BFA) && (degreeType == BXA_BFA)) {
          count++;
        }
        else if ((degreeType & whichBxaKind) > 0) {
          count++;
        } 

        if ((
        ((degreeType & BXA_BHA)>0) || 
          ((degreeType & BXA_BSA)>0) || 
          ((degreeType & BXA_BCSA)>0))
          && (whichBxaKind == BXA_ANY)) {
          anyBxaCount++;
        }
      }
    } 
    else {

      int degreeType = getStudentDegreeOption (i);
      if ((whichBxaKind == BXA_BFA) && (degreeType == BXA_BFA)) {
        count++;
      }
      else if ((degreeType & whichBxaKind) > 0) {
        count++;
      }

      if ((
      ((degreeType & BXA_BHA)>0) || 
        ((degreeType & BXA_BSA)>0) || 
        ((degreeType & BXA_BCSA)>0))
        && (whichBxaKind == BXA_ANY)) {
        anyBxaCount++;
      }
    }
  }

  if (whichBxaKind == BXA_ANY) {
    return anyBxaCount;
  }

  return count;
}


int nWithChoice[] = new int[N_PREF_CHOICES];
void countStudentsWithChoice (boolean bAdmittedStudentsOnly) {

  for (int i=0; i<N_PREF_CHOICES; i++) {
    nWithChoice[i] = 0;
  }

  for (int i=0; i<N_VALID_STUDENTS; i++) {
    Student S = studentArray[i];
    char decn = getStudentDecision (i);

    if ((bAdmittedStudentsOnly && (decn == 'A')) || (!bAdmittedStudentsOnly)) {
      int choiceType = getStudentChoiceType(i); 
      nWithChoice[choiceType]++;
    }
  }

  if (bAdmittedStudentsOnly) {
    for (int i=0; i<N_PREF_CHOICES; i++) {
      countsWithChoicesAdm[i] = nWithChoice[i];
    }
  } 
  else {
    for (int i=0; i<N_PREF_CHOICES; i++) {
      countsWithChoicesTot[i] = nWithChoice[i];
    }
  }
}

//------------------------------------------------------------------------
int countOverlooked() {
  int count = 0; 
  for (int i=0; i<N_VALID_STUDENTS; i++) {
    Student S = studentArray[i];

    char decn = (char)(S.fDataArrayRaw[ID_DECISION]);
    if ((decn != 'R') && (decn != 'A') && (decn != 'C') && (decn != 'W')) {
      S.printSelf();
      count++;
    }
  }
  return count;
}


//====================================================================================
void displayOverview() {

  int albY = (int)( myStack2.ry + myStack2.rh + 30); 
  int albH = (int)(mainStackY - albY - 90); 
  float ow = 200; 
  float ox = width-150 - (ow+10);
  float oy = albY;
  float oh = albH - 10;

  fill(225); 
  stroke(0); 
  rect(ox, oy, ow, oh); 

  float texty = 5; 
  float textdy = 15;
  float textNewline = 10;
  float oMargin = 10; 

  //-----------------------------------------
  int nBfaTot = countBxaType (BXA_BFA, false); 
  int nBfaAdm = countBxaType (BXA_BFA, true);

  int nBhaTot = countBxaType (BXA_BHA, false); 
  int nBhaAdm = countBxaType (BXA_BHA, true);

  int nBsaTot = countBxaType (BXA_BSA, false); 
  int nBsaAdm = countBxaType (BXA_BSA, true);

  int nBcsaTot = countBxaType (BXA_BCSA, false); 
  int nBcsaAdm = countBxaType (BXA_BCSA, true);

  int nDesTot = countBxaType (BXA_DES, false);
  int nDesAdm = countBxaType (BXA_DES, true);

  int nArcTot = countBxaType (BXA_ARC, false); 
  int nArcAdm = countBxaType (BXA_ARC, true);

  int nBxaAdm = countBxaType (BXA_ANY, true);   // nBhaAdm + nBsaAdm + nBcsaAdm; 
  int nBxaTot = countBxaType (BXA_ANY, false);  // nBhaTot + nBsaTot + nBcsaTot; 


  int nGirls      = countStudentsOfSex('F', false); 
  int nGirlsAdm   = countStudentsOfSex('F', true); 
  int nBoys       = countStudentsOfSex('M', false); 
  int nBoysAdm    = countStudentsOfSex('M', true); 

  int nTotal    = N_VALID_STUDENTS;
  int nAccepts  = countThoseWithDecision('A');
  int nWaitlist = countThoseWithDecision('W');
  int nRejected = countThoseWithDecision('R');
  int nAwaiting = countThoseWithDecision(' ');


  String admStr  = "Admits: " + nAccepts + " / " + nTotal;
  String rejStr  = "Rejected: " + nRejected; 
  String waitStr = "Waitlisted: " + nWaitlist; 
  String noDStr  = "Awaiting: " + nAwaiting + " / " + nTotal;

  String sexStr  = "M Admitted: " + (int)(100.0 * (float)nBoysAdm/ (float)nAccepts) + "%";
  String girlStr = "Women: " + nGirlsAdm + " / " + nGirls;
  String boyStr  = "Men:    " + nBoysAdm + " / " + nBoys + " (of " + (int)(100.0* (float)nBoys / (float)N_VALID_STUDENTS) + "% tot.)";

  String prefsAdm  = "Prefs (Adm)";
  String bxaStrAdm = "BXA Adm: " + nBxaAdm + ", " + (int)(100.0 * (float)nBxaAdm/ (float)nAccepts) + "%";
  String bxaStrTot = "BXA Tot: " + nBxaTot + ", " + (int)(100.0 * (float)nBxaTot/ (float)N_VALID_STUDENTS) + "%";
  String bfaStr  = "BFA:  "  + nBfaAdm + " / " + nBfaTot;
  String bhaStr  = "BHA:  "  + nBhaAdm + " / " + nBhaTot;
  String bsaStr  = "BSA:  "  + nBsaAdm + " / " + nBsaTot;
  String bcsaStr = "BCSA: " + nBcsaAdm + " / " + nBcsaTot;
  String desStr  = "DES:  "  + nDesAdm + " / " + nDesTot;
  String arcStr  = "ARC:  "  + nArcAdm + " / " + nArcTot;

  pushMatrix(); 
  translate(ox, oy); 
  fill(0); 

  text (admStr, oMargin, texty+=textdy); 
  text (rejStr, oMargin, texty+=textdy); 
  text (waitStr, oMargin, texty+=textdy); 
  text (noDStr, oMargin, texty+=textdy); 
  texty+=textNewline;

  text (sexStr, oMargin, texty+=textdy); 
  text (boyStr, oMargin, texty+=textdy); 
  text (girlStr, oMargin, texty+=textdy); 
  texty+=textNewline;

  text (prefsAdm, oMargin, texty+=textdy);
  text (bxaStrAdm, oMargin, texty+=textdy);
  text (bxaStrTot, oMargin, texty+=textdy);  
  texty+=textdy;
  text (bfaStr, oMargin, texty); 
  text (bhaStr, ow/2, texty); 
  texty+=textdy;
  text (bsaStr, oMargin, texty); 
  text (bcsaStr, ow/2, texty); 
  texty+=textdy;
  text (desStr, oMargin, texty);  
  text (arcStr, ow/2, texty); 
  texty+=textNewline;

  // display ethnicity counts
  texty+=textdy;
  for (int i=1; i<=6; i++) {
    int nOfEthRaw = countStudentsOfEthnicity (i, false);
    int nOfEthAdm = countStudentsOfEthnicity (i, true); 
    String ethStr = i + " (" + raceStrings[i].toLowerCase() + "): " + nOfEthAdm + " / " + nOfEthRaw;

    float textx = (i%2 == 0) ? ow/2 : oMargin;
    text (ethStr, textx, texty);

    if (i%2 == 0) {
      texty+=textdy;
    }
  }
  texty+=textNewline;

  popMatrix();

  //---------------------------

  pushMatrix();
  translate(ox, oy); 
  translate(ow/2, 5); 

  texty = 5; 
  float barW = ow/2 - oMargin;
  float barH = 10;

  stroke(0); 
  fill (80);

  // background rectangles
  texty = 5;
  rect(0, texty, barW, barH); // nAccepts
  texty+=textdy;
  texty+=textdy;
  texty+=textdy;
  texty+=textNewline;

  rect(0, texty+=textdy, barW, barH); // sex
  texty+=textdy; 
  texty+=textdy; 
  texty+=textNewline;


  rect(0, texty+=textdy, barW, barH); // enthusiasm
  rect(0, texty+=textdy, barW, barH); // bxa

  //------------------------
  // data rectangles
  texty = 5;

  float admTargetW = map(admitTarget, 0, nTotal, 0, barW);
  float admittedW  = map(nAccepts, 0, nTotal, 0, barW);
  float rejectedW  = map(nRejected, 0, nTotal, 0, barW);
  float waitlistW  = map(nWaitlist, 0, nTotal, 0, barW); 
  fill (102, 153, 0);
  rect(0, texty, admTargetW, barH); // nAccepts
  fill (153, 255, 0);
  rect(0, texty, admittedW, barH); // nAccepts
  fill (204, 51, 51);
  rect(admTargetW, texty, rejectedW, barH); // Rejects
  fill (153, 153, 51);
  rect(admTargetW+rejectedW, texty, waitlistW, barH); // nWaitlist

  texty+=textdy;
  texty+=textdy;
  texty+=textdy;
  texty+=textdy;
  texty+=textNewline;

  //---------------------
  // draw proportion of admitted students who are M/F
  float boyW  = map(nBoysAdm, 0, nAccepts, 0, barW); 
  float girlW = map(nGirlsAdm, 0, nAccepts, 0, barW); 
  fill(colorM);
  rect(0, texty, boyW, barH); 
  fill(colorF);
  rect(boyW, texty, girlW, barH);

  texty+=textdy;
  texty+=textdy;
  texty+=textdy;
  texty+=textNewline;

  //---------------------
  // draw proportions of accepted students with Art preferences (1st, 2nd, 3rd, etc.)
  countStudentsWithChoice (true);
  float prefx = 0; 
  for (int i=0; i<N_PREF_CHOICES; i++) { 
    fill (prefChoiceColors[i]);
    int nPrefi = countsWithChoicesAdm[i]; 
    float prefw = map(nPrefi, 0, nAccepts, 0, barW);
    rect(prefx, texty, prefw, barH);
    prefx += prefw;
  }
  texty+=textdy;

  //---------------------
  // draw proportion of admitted students who are BXA
  float bxaW = map(nBxaAdm, 0, nAccepts, 0, barW); 
  fill(180);
  rect(0, texty, bxaW, barH);



  popMatrix();
}


//====================================================================================
void displayCurrentStudentGraphic() {

  // figure out which student is the currently selected one
  int whichStudentID = 0; 
  for (int i=0; i<N_VALID_STUDENTS; i++) {
    if (studentArray[i].alphabeticalIndex == CURRENT_STUDENT_ALPHAID) {
      whichStudentID = i;
      break;
    }
  }

  // create a string to display their name
  Student S = studentArray[whichStudentID];
  String displayText = "";
  if (bAnonymizeByRot13) {
    displayText = rot13(S.LASTNAME) + ", " + rot13(S.FIRSTNAME) + "\n";
  } 
  else {
    displayText = S.LASTNAME + ", " + S.FIRSTNAME + "\n";
  }


  float xPos = 620;
  float yPos = ( myStack2.ry + myStack2.rh + 48); 
  int cubW = 36; 
  pushMatrix();
  translate (xPos, yPos);

  // draw their name
  fill(0);
  textFont(arial24Font, 30);
  text (displayText, 0, 0); 
  translate (0, 12); 

  // cubes profile 
  stroke (0); 

  char decn = getStudentDecision (whichStudentID);
  fill (getDecnColor (decn));
  rect (0*cubW, 0, cubW, cubW); 

  char sex = getStudentSex (whichStudentID);
  fill (getSexColor(sex)); 
  rect (1*cubW, 0, cubW, cubW); 

  int  pref = getStudentArtPreference (whichStudentID); 
  int  choice = getStudentChoiceType (whichStudentID); 
  fill (prefChoiceColors[choice]);
  rect (2*cubW, 0, cubW, cubW); 

  int  degreeOption = getStudentDegreeOption (whichStudentID);
  fill (  ((degreeOption & BXA_BCSA) > 0) ? bcsaCol : noneCol); 
  rect (3*cubW, 0, cubW, cubW); 
  fill (  ((degreeOption & BXA_BHA) > 0) ? bhaCol : noneCol);
  rect (4*cubW, 0, cubW, cubW); 
  fill (  ((degreeOption & BXA_BSA) > 0) ? bsaCol : noneCol);
  rect (5*cubW, 0, cubW, cubW); 
  fill (  ((degreeOption & BXA_DES) > 0) ? desCol : noneCol);
  rect (6*cubW, 0, cubW, cubW); 
  fill (  ((degreeOption & BXA_ARC) > 0) ? arcCol : noneCol);
  rect (7*cubW, 0, cubW, cubW); 

  int  toeflScore   = getStudentToeflScore (whichStudentID);
  color toeflCol = noneCol;
  float noneChan = red(noneCol);
  String toeflStr = "---";
  if (toeflScore > 0) {
    float toeflRed = map(toeflScore, 95, 120, 1, 0);
    toeflRed = 255*sqrt(toeflRed); 
    toeflRed = constrain(toeflRed, noneChan, 255); 
    toeflCol = color (toeflRed, noneChan, noneChan);
    toeflStr = "" + toeflScore;
  } 
  fill (toeflCol); 
  rect (8*cubW, 0, cubW, cubW);


  fill (0); 
  textFont(arial24Font, 16);
  float tx1 = 13; 
  float tx2 = 8;
  float ty  = 24;
  text (decn, tx1+0*cubW, ty);
  text (sex, tx1+1*cubW, ty);
  text (pref, tx1+2*cubW, ty); 
  text ("cs", tx1+3*cubW, ty); 
  text ("bha", tx2+4*cubW, ty); 
  text ("bsa", tx2+5*cubW, ty); 
  text ("des", tx2+6*cubW, ty); 
  text ("arc", tx2+7*cubW, ty); 
  text (toeflStr, tx2+8*cubW, ty);


  //---------------------------------
  // Personal pan pizza

  float cx = 100;
  float cy = 165;

  // the arcs themselves: filled, then linear curves
  noStroke(); 
  fill(0, 0, 0, 40); 
  float starRadius = 100; 
  float starMinRadius = starRadius * 0.1;
  ellipse(cx, cy, starRadius*2, starRadius*2); 
  for (int i=0; i<myPie.N_PIE_WEDGES; i++) {
    float startAngle = myPie.priorityAngle0[i];
    float endAngle   = myPie.priorityAngle1[i];

    int priorityID = myPie.priorityIDs[i];
    int factorID   = admissionsPriorities[priorityID].factorID;
    float rad = starMinRadius + S.fDataArrayShaped01[factorID] * (starRadius*0.9); 

    noStroke();
    noSmooth();

    color priorityColor = admissionsPriorities[priorityID].myColor;
    fill(priorityColor);
    arc (cx, cy, rad*2, rad*2, startAngle, endAngle);

    smooth();
    noFill();
    stroke(0, 0, 0);
    strokeWeight(1.0); 
    arc (cx, cy, rad*2, rad*2, startAngle, endAngle);

    stroke(0, 0, 0, 200);
    line(cx, cy, cx + rad*cos(startAngle), cy + rad*sin(startAngle)); 
    line(cx, cy, cx + rad*cos(endAngle), cy + rad*sin(endAngle));
  }

  fill(160);
  stroke(0, 0, 0);
  ellipse(cx, cy, starMinRadius*2*0.6, starMinRadius*2*0.6); 



  popMatrix();
}




//====================================================================================
void displayCurrentStudentText() {

  float xPos = 425;
  float yPos = ( myStack2.ry + myStack2.rh + 30); 

  int whichToDisplay = 0; 
  for (int i=0; i<N_VALID_STUDENTS; i++) {
    if (studentArray[i].alphabeticalIndex == CURRENT_STUDENT_ALPHAID) {
      whichToDisplay = i;
      break;
    }
  }


  fill(0);
  textFont(arial24Font, 14);

  Student S = studentArray[whichToDisplay];
  String displayText = "";

  String sexStr = "" + (char)(S.fDataArrayRaw[ID_SEX]);
  displayText += "Sex:       " + sexStr + "\n";

  int race = (int )(S.fDataArrayRaw[ID_RACE]) ;
  race = min(6, max(0, race));
  displayText += "Eth:       " + (int )(S.fDataArrayRaw[ID_RACE]) + "- " + raceStrings[race] + "\n";

  char decn = (char)(S.fDataArrayRaw[ID_DECISION]);
  if ((decn != 'R') && (decn != 'A') && (decn != 'C') && (decn != 'W')) {
    decn = '-';
  }

  int rank = N_VALID_STUDENTS - whichToDisplay;
  int percentile = (int) (100.0 *   (float)whichToDisplay / (float)N_VALID_STUDENTS); 
  displayText += "Rank:  " + rank + " / " + N_VALID_STUDENTS  + " (" + percentile + "%ile)" + "\n";
  displayText += "Decision:  " + decn + "\n";
  // displayText += "Suggestion:  " + ((int) S.fDataArrayRaw[ID_SUGGESTED]) + "\n";

  String bxaStr = ""; 
  int bxaCode = (int) S.fDataArrayRaw[ID_BXA];

  if (bxaCode == BXA_BFA) {
    bxaStr = "----";
  } 
  else {
    boolean bComma = false;
    if ((bxaCode & BXA_BCSA) > 0) {
      bxaStr += "BCSA";
      bComma = true;
    }
    if ((bxaCode & BXA_BHA)  > 0) {
      if (bComma) bxaStr += ", ";
      bxaStr += "BHA";
      bComma = true;
    }
    if ((bxaCode & BXA_BSA)  > 0) {
      if (bComma) bxaStr += ", ";
      bxaStr += "BSA";
      bComma = true;
    }
    if ((bxaCode & BXA_DES)  > 0) {
      if (bComma) bxaStr += ", ";
      bxaStr += "DES";
      bComma = true;
    }
    if ((bxaCode & BXA_ARC)  > 0) {
      if (bComma) bxaStr += ", ";
      bxaStr += "ARC";
    }
  }

  displayText += "Degree Options: " + bxaStr + "\n";
  displayText += "Portfolio Avg.: " + nf((S.fDataArrayRaw[ID_SLIDEROOM_PORTF]), 1, 2) + "\n"; 
  displayText += "Interview Avg.: " + nf((S.fDataArrayRaw[ID_SLIDEROOM_INTVW]), 1, 2) + "\n"; 

  displayText += "QPA: "   + nf((S.fDataArrayRaw[ID_QPA]), 1, 2 ) + "\n"; 
  int satCR = ((int)(S.fDataArrayRaw[ID_TESTCR]));
  int satM  = ((int)(S.fDataArrayRaw[ID_TESTM]));
  int satW  = ((int)(S.fDataArrayRaw[ID_TESTW]));
  displayText += "SAT (CR,M,W):  " + satCR + ", " + satM + ", " + satW  + "\n"; 

  String displayTex2 = "";
  displayTex2 += "Recommends: "  + ((int)(S.fDataArrayRaw[ID_RECOMMENDATIONS])) + "\n"; 
  displayTex2 += "Leadership: "  + ((int)(S.fDataArrayRaw[ID_LEADERSHIP])) + "\n"; 
  displayTex2 += "Recognition: " + ((int)(S.fDataArrayRaw[ID_RECOGNITION])) + "\n"; 
  displayTex2 += "XtraCurric: "  + ((int)(S.fDataArrayRaw[ID_EXTRACURRICULAR])) + "\n"; 
  displayTex2 += "Service: "     + ((int)(S.fDataArrayRaw[ID_SERVICE])) + "\n"; 
  displayTex2 += "Essay: "       + ((int)(S.fDataArrayRaw[ID_ESSAY])) + "\n"; 
  displayTex2 += "Curric Rigor: "+ ((int)(S.fDataArrayRaw[ID_CURRICULUMRIGOR])) + "\n"; 
  displayTex2 += "School Rigor: "+ ((int)(S.fDataArrayRaw[ID_SCHOOLRIGOR])) + "\n"; 


  int pref = ((int)(S.fDataArrayRaw[ID_PREF_N]));
  pref = max(0, min(pref, 4));
  String prefNames[] = {
    "---", "1st", "2nd", "3rd", "4th"
  };
  displayTex2 += "ART Preference: " + prefNames[pref] + "\n"; 

  if (S.fDataArrayRaw[ID_TOEFL] > 0) {
    displayTex2 += "TOEFL: "   + ((int)(S.fDataArrayRaw[ID_TOEFL])) + "\n";
  } 

  displayText += displayTex2;
  text(displayText, xPos, yPos);
  // text(displayTex2, xPos+240, yPos+40);
}


//====================================================================================
void setCurrentStudent(int whichStudentID) {

  if ((whichStudentID >= 0) && (whichStudentID < N_VALID_STUDENTS)) {
    CURRENT_STUDENT_ID = whichStudentID;
    CURRENT_STUDENT_ALPHAID = studentArray[CURRENT_STUDENT_ID].alphabeticalIndex; 
  
    for (int i=0; i<N_VALID_STUDENTS; i++) {
      studentArray[i].bIAmTheCurrentStudent = false;
    }
    studentArray[CURRENT_STUDENT_ID].bIAmTheCurrentStudent = true;
    bDORECALCULATION = true;
  }
}

//====================================================================================
boolean bCommandKeyDown = false;
void keyPressed() {

  // println(key + " " + keyCode);

  if (key == CODED) {
    if (keyCode == 157) {
      bCommandKeyDown = true;
    } 
    else if (keyCode == 37) { // left arrow
      setCurrentStudent(CURRENT_STUDENT_ID -1); 
    } 

    else if (keyCode == 39) { // right arrow
      setCurrentStudent(CURRENT_STUDENT_ID +1); 
    }
  }
  else {
    if (bCommandKeyDown) {
      switch(key) {

        //case 'p':
        //   printStudentAdmissionsData();
        //   break;


      case 'S':
      case 's':
        saveStudentAdmissionsData();
        saveAdmissionsPriorities();

        break;
      }
    } 
    else {
      // regular keypresses:
      switch(key) {

        //case 'f':
        //saveFrame();
        //break;

      case '!':
        loadSlideroomApplicantSummary();
        break;

      case 'P':
        myPie.pieReset();
        break;

      case 'A':
        for (int i=0; i<N_VALID_STUDENTS; i++) {
          if (studentArray[i].alphabeticalIndex == CURRENT_STUDENT_ALPHAID) {
            if (studentArray[i].fDataArrayRaw[ID_DECISION] == (float)('A')) {
              studentArray[i].fDataArrayRaw[ID_DECISION] = NO_DATA;
            } 
            else {
              studentArray[i].fDataArrayRaw[ID_DECISION] = (float)('A');
            }
          }
        }
        break;


      case 'W':
        for (int i=0; i<N_VALID_STUDENTS; i++) {
          if (studentArray[i].alphabeticalIndex == CURRENT_STUDENT_ALPHAID) {
            if (studentArray[i].fDataArrayRaw[ID_DECISION] == (float)('W')) {
              studentArray[i].fDataArrayRaw[ID_DECISION] = NO_DATA;
            } 
            else {
              studentArray[i].fDataArrayRaw[ID_DECISION] = (float)('W');
            }
          }
        }
        break;



      case 'R':
        for (int i=0; i<N_VALID_STUDENTS; i++) {
          if (studentArray[i].alphabeticalIndex == CURRENT_STUDENT_ALPHAID) {
            if (studentArray[i].fDataArrayRaw[ID_DECISION] == (float)('R')) {
              studentArray[i].fDataArrayRaw[ID_DECISION] = NO_DATA;
            } 
            else {
              studentArray[i].fDataArrayRaw[ID_DECISION] = (float)('R');
            }
          }
        }
        break;

      case 'E':
        bShowEnrollsOnly = !bShowEnrollsOnly;
        break;



        //case 'a':
        // EV.computeWeightedStudentScores2();
        // COMPARISON_METRIC = ID_SCORE;//ID_LASTNAME;//
        // sortStudentArray(FORWARD);
        // printStudentScores();
        // break;
      }
    }
  }
}



void keyReleased() {
  if (key == CODED) {
    if (keyCode == 157) {
      bCommandKeyDown = false;
    }
  }
}





//======================================================================================
void mouseReleased() {
  lastMouseReleasedTime = millis();
  myMainStack.mouseReleased();
}

void mousePressed() {
  lastMousePressedTime = millis();
  myMainStack.mousePressed();
}




String rot13 (String input) {
  String output = ""; 
  for (int i = 0; i < input.length(); i++) {
    char c = input.charAt(i);
    if       (c >= 'a' && c <= 'm') c += 13;
    else if  (c >= 'n' && c <= 'z') c -= 13;
    else if  (c >= 'A' && c <= 'M') c += 13;
    else if  (c >= 'A' && c <= 'Z') c -= 13;
    output += c;
  }
  return output;
}

