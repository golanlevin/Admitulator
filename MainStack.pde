


//====================================================================
class MainStackSubElement {
  color myColor;
  float myR;
  float myG;
  float myB;

  float X; 
  float Y; 
  float W; 
  float H;

  MainStackSubElement() {
  }

  void setColor(color c) {
    myColor = c;
    myR = red  (myColor);
    myG = green(myColor);
    myB = blue (myColor);
  }

  void set(float x, float y, float w, float h) {
    X = x;
    Y = y; 
    W = w; 
    H = h;
  }

  void render() {
    fill(myColor); 
    rect(X, floor(Y), W, ceil(H));
  }

  void renderDarkish() {
    float A = 0.66;
    float dr = A*red(myColor);
    float dg = A*green(myColor); 
    float db = A*blue (myColor);
    fill(dr, dg, db); 
    rect(X, floor(Y), W, ceil(H));
  }

  void renderReddish() {
    float A = 0.30;
    float B = 1.0-A;
    float dr = A*255 + B*red  (myColor);
    float dg = A*240 + B*green(myColor); 
    float db = A*100  + B*blue (myColor);

    fill(dr, dg, db); 
    rect(X, floor(Y), W, ceil(H));
  }
}

color prefChoiceColors[] = new color[N_PREF_CHOICES];
//====================================================================
class MainStackElement {
  float X; 
  float Y;
  float W;
  float H; 
  int studentID = 0;

  MainStackSubElement subElementArray[];
  int nSubElements;

  MainStackElement(int nSE) {
    nSubElements = nSE; 
    subElementArray = new MainStackSubElement[nSubElements];

    int subElementID = 0;
    for (int i=0; i<N_ADMISSIONS_PRIORITIES; i++) {
      if (admissionsPriorities[i].bIsFactored) {
        subElementArray[subElementID] = new MainStackSubElement();
        subElementArray[subElementID].setColor( admissionsPriorities[i].myColor);
        subElementID++;
      }
    }
  }

  void set (float x, float y, float w, float h) {
    X = x;
    Y = y; 
    W = w; 
    H = h;
  }

  void setStudentID (int sid) {
    studentID = sid;
  }

  //-------------------------------------------------
  void render () {

    float moreInfoBoxH = 10; 
    float moreInfoBoxY = Y - moreInfoBoxH;

    // Additional information pips stacked above main stack. 

    boolean bDrawDecision     = true; 
    boolean bDrawPref         = true;
    boolean bDrawSex          = true;
    boolean bDrawBCSA         = true;
    boolean bDrawBHA          = true;
    boolean bDrawBSA          = true;
    boolean bDrawDES          = true;
    boolean bDrawARC          = true; 
    boolean bDrawToefl        = true;

    char sex          = getStudentSex (studentID);
    char ourDecision  = getStudentDecision (studentID);
    int  degreeOption = getStudentDegreeOption (studentID);
    int  toeflScore   = getStudentToeflScore (studentID);
    int  pref         = getStudentArtPreference (studentID); 



    //--------------------
    noStroke();
    if (bDrawDecision) {
      switch (ourDecision) {
      case 'A':
        fill (colorAccept); 
        break;
      case 'W':
        fill (colorWaitlist); 
        break;
      case 'R':
      case 'C':
        fill (colorReject); 
        break;
      default: 
        fill (colorNoDecn);
        break;
      }
      rect(X, moreInfoBoxY, W, moreInfoBoxH);
      moreInfoBoxY -= moreInfoBoxH;
    }


    //--------------------
    if (bDrawSex) {
      switch (sex) {
      case 'F':
        fill(colorF);
        break;
      case 'M':
        fill(colorM);
        break;
      } 
      rect(X, moreInfoBoxY, W, moreInfoBoxH);
      moreInfoBoxY -= moreInfoBoxH;
    }


    prefChoiceColors[CHOICE_1A] = color (50, 80, 50);
    prefChoiceColors[CHOICE_1B] = color (60, 100, 45);
    prefChoiceColors[CHOICE_2A] = color (80, 120, 40);
    prefChoiceColors[CHOICE_2B] = color (140, 140, 20);
    prefChoiceColors[CHOICE_2C] = color (150, 130, 15);
    prefChoiceColors[CHOICE_3A] = color (170, 110, 15);
    prefChoiceColors[CHOICE_3B] = color (200, 100, 10);
    prefChoiceColors[CHOICE_4A] = color (250, 50, 5);

    if (bDrawPref) {

      boolean bBxa = ((degreeOption & BXA_BCSA)>0) || ((degreeOption & BXA_BSA)>0) || ((degreeOption & BXA_BHA)>0);
      boolean bDesOrArc = ((degreeOption & BXA_DES)>0) || ((degreeOption & BXA_ARC)>0) ;
      boolean bBxaExclusively = bBxa && (!bDesOrArc); 

      fill(60, 60, 60); 
      switch (pref) {
      case 1: 
        if (!bBxa) {
          fill(prefChoiceColors[CHOICE_1A]);
        } 
        else {
          fill(prefChoiceColors[CHOICE_1B]);
        }
        break;
      case 2: 
        // Art is second choice
        if (bBxaExclusively) {
          // But art is second choice to a BXA
          fill(prefChoiceColors[CHOICE_2A]);
        } 
        else if (bDesOrArc) { // des or arc!
          // Eww, art is second choice to design or architecture
          fill(prefChoiceColors[CHOICE_2B]);
        } 
        else {
          fill(prefChoiceColors[CHOICE_2C]);
        }
        break;
      case 3: 
        if (bBxa) {
          fill(prefChoiceColors[CHOICE_3A]);
        } 
        else {
          fill(prefChoiceColors[CHOICE_3B]);
        }
        break;
      case 4:
      default:
        fill(prefChoiceColors[CHOICE_4A]);
        break;
      }
      rect(X, moreInfoBoxY, W, moreInfoBoxH);
      moreInfoBoxY -= moreInfoBoxH;
    }


    //--------------------
    if (bDrawBCSA) {
      fill (  ((degreeOption & BXA_BCSA) > 0) ? bcsaCol : noneCol); 
      rect(X, moreInfoBoxY, W, moreInfoBoxH);
      moreInfoBoxY -= moreInfoBoxH;
    }
    if (bDrawBHA) {
      fill (  ((degreeOption & BXA_BHA) > 0) ? bhaCol : noneCol);
      rect(X, moreInfoBoxY, W, moreInfoBoxH);
      moreInfoBoxY -= moreInfoBoxH;
    }
    if (bDrawBSA) {
      fill (  ((degreeOption & BXA_BSA) > 0) ? bsaCol : noneCol);
      rect(X, moreInfoBoxY, W, moreInfoBoxH);
      moreInfoBoxY -= moreInfoBoxH;
    }
    if (bDrawDES) {
      fill (  ((degreeOption & BXA_DES) > 0) ? desCol : noneCol);
      rect(X, moreInfoBoxY, W, moreInfoBoxH);
      moreInfoBoxY -= moreInfoBoxH;
    }
    if (bDrawARC) {
      fill (  ((degreeOption & BXA_ARC) > 0) ? arcCol : noneCol);
      rect(X, moreInfoBoxY, W, moreInfoBoxH);
      moreInfoBoxY -= moreInfoBoxH;
    }
    if (bDrawToefl) {
      color toeflCol = noneCol;
      float noneChan = red(noneCol);
      if (toeflScore > 0) {
        float toeflRed = map(toeflScore, 95, 120, 1, 0);
        toeflRed = 255*sqrt(toeflRed); 
        toeflRed = constrain(toeflRed, noneChan, 255); 
        toeflCol = color (toeflRed, noneChan, noneChan);
      }
      fill (toeflCol); 
      rect(X, moreInfoBoxY, W, moreInfoBoxH);
      moreInfoBoxY -= moreInfoBoxH;
    }



    //--------------------
    // if (studentID == CURRENT_STUDENT_ID){
    if (getIsTheCurrentStudent(studentID)) {
      fill(255, 240, 0);
      rect(X, Y, W, H);
      for (int i=0; i<nSubElements; i++) {
        subElementArray[i].renderReddish();
      }
    } 
    else {


      // brighten background if accepted
      if (ourDecision == 'A') {
        fill(255, 255, 255, 50);
        rect(X, Y, W, H);
      } 
      else if (ourDecision == 'R') {
        fill(0, 0, 0, 50);
        rect(X, Y, W, H);
      }

      if ((ourDecision == 'R') || (ourDecision == 'C')) {
        for (int i=0; i<nSubElements; i++) {
          subElementArray[i].renderDarkish();
        }
      } 
      else {
        for (int i=0; i<nSubElements; i++) {
          subElementArray[i].render();
        }
      }


      if (bShowEnrollsOnly) {
        int enrolled  = getStudentEnrolled(studentID);
        if (enrolled == 0) {
          fill(0, 0, 0, 200);
          rect(X-0.5, Y, W+1.0, H);
        }
      }
     
      /*
      if (!bFemaleOn) {
        if (sex == 'F') {
          fill(0, 0, 0, 200);
          rect(X-0.5, Y, W+1.0, H);
        }
      }
      */
      
    }
  }
}

//====================================================================

boolean bAllowStackFilters = false;


class MainStack {

  float W;
  float H;
  float X;
  float Y;
  int startID;
  int endID;


  float thumbX;
  float thumbY; 
  float thumbW;
  float thumbH;
  boolean bClickedInThumb = false;
  boolean bAdjustingStart = false;
  boolean bAdjustingEnd   = false;
  float thumbClickX;
  float thumbClickW; 
  float thumbClickMouseX;
  float thumbEdgeW = 12;

  int N_STACK_SUB_ELEMENTS = 0;
  MainStackElement elementArray[];

  MainStack (float x, float y, float w, float h) {
    X = x;
    Y = y; 
    W = w; 
    H = h;

    thumbH = 20;
    thumbY = Y+H;
    thumbW = W; 
    thumbX = X; 
    thumbClickMouseX = X;
    bClickedInThumb = false;

    N_STACK_SUB_ELEMENTS = 0;
    for (int i=0; i<N_ADMISSIONS_PRIORITIES; i++) {
      if (admissionsPriorities[i].bIsFactored) {
        N_STACK_SUB_ELEMENTS++;
      }
    }


    startID = N_VALID_STUDENTS / 4;
    endID = N_VALID_STUDENTS - 1;
    elementArray = new MainStackElement[N_VALID_STUDENTS];
    for (int i=0; i<N_VALID_STUDENTS; i++) {
      elementArray[i] = new MainStackElement (N_STACK_SUB_ELEMENTS) ;
    }
  }

  //-------------------------------------------------------------------
  void update() {
    // make sure studentArray is already pre-sorted by ID_SCORE,
    // even though this leads to redundant computation.
    updateThumb();

    // get max score to normalize
    float maxScore = 0;
    for (int s=0; s<N_VALID_STUDENTS; s++) {
      Student S = studentArray[s];
      float score = S.fDataArrayShaped01[ID_SCORE];
      if (score > maxScore) {
        maxScore = score;
      }
    }
    float magnify = 1.0;
    if (maxScore > 0) {
      magnify = 1.0/maxScore;
    }

    int start = min(max(0, startID), N_VALID_STUDENTS-2);
    int end   = max(start+1, min(endID, N_VALID_STUDENTS-1)); 
    int range = end - start;





    float ex, ey, ew, eh;
    ew = W/ (float)(range+1);
    int nValidCount = 0;

    for (int s=start; s<=end; s++) {
      Student S = studentArray[s];

      boolean bCurrentValid = true;
      if (bCurrentValid) {
        MainStackElement E = elementArray[s];

        int subElementID = 0;
        ey = Y+H;
        //ex = X + (s-start)*ew;
        ex = X+ nValidCount*ew; 
        nValidCount++;

        for (int p=0; p<N_ADMISSIONS_PRIORITIES; p++) {
          if (admissionsPriorities[p].bIsFactored) {

            int factorID = admissionsPriorities[p].factorID;
            float shapedWeightedValue01 = S.fDataArrayWeightedShaped01[factorID];

            eh = (shapedWeightedValue01*H*magnify);

            E.subElementArray[subElementID].set(ex, ey-eh, ew, eh);
            E.setStudentID (s);
            E.set(ex, Y, ew, H);
            subElementID++;
            ey -= eh;
          }
        }
      }
    }  

    if (mousePressed) {
      computeCurrentStudent();
    }
  }

  //-------------------------------------------------------------------
  void render() {



    noStroke(); 
    fill(0, 0, 0); 
    int moreInfoBoxRegionH = 9*10; 
    rect(X, Y-moreInfoBoxRegionH, W, moreInfoBoxRegionH);

    fill(128);
    rect(X, Y, W, H); 

    noStroke();

    int start = min(max(0, startID), N_VALID_STUDENTS-2);
    int end   = max(start+1, min(endID, N_VALID_STUDENTS-1)); 
    for (int i=start; i<=end; i++) {
      elementArray[i].render();
    }

    stroke(0);
    noFill();
    rect(X, Y-moreInfoBoxRegionH, W, H+moreInfoBoxRegionH); 

    renderThumb();

    // println (nWithChoice1a + " " + nWithChoice1b + " " + nWithChoice2a + " " + nWithChoice2b + " " + nWithChoice3a + " " + nWithChoice3b + " " + nWithChoice4a);
  }


  //-----------------------------------------------------
  void mousePressed() {
    if (!bInPie) {
      if ((mouseX > thumbX) && (mouseX < (thumbX+thumbW)) && (mouseY > thumbY) && (mouseY < (thumbY+thumbH))) {
        bClickedInThumb = true;
        thumbClickX      = thumbX;
        thumbClickW      = thumbW;
        thumbClickMouseX = mouseX;

        bAdjustingStart = false;
        bAdjustingEnd   = false;
        if ((mouseX - thumbX) < thumbEdgeW) {
          bAdjustingStart = true;
        } 
        else if ((thumbX+thumbW - mouseX) < thumbEdgeW) {
          bAdjustingEnd   = true;
        }
      } 
      else {
        bClickedInThumb = false;
        bAdjustingStart = false;
        bAdjustingEnd   = false;

        computeCurrentStudent();
      }
    }
  }


  //-----------------------------------------------------
  void computeCurrentStudent() {
    // check to see if CURRENT_STUDENT_ID modified
    if ((mouseX > X) && (mouseY > Y) && (mouseX < (X+W)) && (mouseY < (Y+H))) {
      int start = min(max(0, startID), N_VALID_STUDENTS-2);
      int end   = max(start+1, min(endID, N_VALID_STUDENTS-1)); 
      int range = end - start;

      float ew = (float)W/(float)(range+1);
      float ex = ew * (int)((float)(mouseX-X)/ew);
      int   s  = startID + (int)round(ex/ew);
      s = max(0, min(N_VALID_STUDENTS-1, s));
      
      CURRENT_STUDENT_ID = s;
      CURRENT_STUDENT_ALPHAID = studentArray[s].alphabeticalIndex; 
      bDORECALCULATION = true;

      for (int i=0; i<N_VALID_STUDENTS; i++) {
        studentArray[i].bIAmTheCurrentStudent = false;
      }
      studentArray[s].bIAmTheCurrentStudent = true;

      ;
    }
  }


  void mouseReleased() {
    bClickedInThumb = false;
    bAdjustingStart = false;
    bAdjustingEnd   = false;
  }

  //-----------------------------------------------------
  void updateThumb() {
    if (bClickedInThumb && mousePressed) {

      if (bAdjustingStart) {
        float mouseMovementX = mouseX - thumbClickMouseX; 
        float newThumbX = thumbClickX + mouseMovementX; 

        if (endID < (N_VALID_STUDENTS-1)) {
          newThumbX = max(X, min(newThumbX, X+W-thumbW));
        } 
        else {
          newThumbX = max(X, min(newThumbX, X+W));
        }

        float startFrac = (newThumbX-X)/W;
        float endFrac   = (float)endID  /(N_VALID_STUDENTS-1);
        int start = (int)round(startFrac * (N_VALID_STUDENTS-1));
        start = max(0, min(start, endID-1)); 
        startID = start;

        thumbX = X + startFrac*W;
        thumbW = (endFrac - startFrac)*W;
      } 

      else if (bAdjustingEnd) {
        float mouseMovementX = mouseX - thumbClickMouseX; 
        float newThumbW = thumbClickW + mouseMovementX;
        newThumbW = max(1, min(W-thumbX-1, newThumbW));

        float startFrac = (thumbX-X)/W;
        float endFrac   = (thumbX + newThumbW-X)/W;

        endID = (int)floor(endFrac * (N_VALID_STUDENTS-1));
        thumbW = newThumbW;
      } 

      else {

        float mouseMovementX = mouseX - thumbClickMouseX; 
        float newThumbX = thumbClickX + mouseMovementX; 
        newThumbX = max(X, min(newThumbX, X+W-thumbW));

        float startFrac = (newThumbX-X)/W;
        float endFrac   = (newThumbX+thumbW-X)/W;

        int start = (int)floor(startFrac * (N_VALID_STUDENTS-1));
        int end   = (int)floor(endFrac   * (N_VALID_STUDENTS-1));
        start = max(0, min(start, N_VALID_STUDENTS-2));
        end   = min(max(end, start+1), N_VALID_STUDENTS-1);

        startID = start;
        endID   = end;

        start = min(max(0, startID), N_VALID_STUDENTS-2);
        end   = max(start+1, min(endID, N_VALID_STUDENTS-1));  

        thumbX = X + startFrac*W;
        thumbW = (endFrac - startFrac)*W;
      }
    }
  }

  //-----------------------------------------------------
  void renderThumb() {


    int start = min(max(0, startID), N_VALID_STUDENTS-2);
    int end   = max(start+1, min(endID, N_VALID_STUDENTS-1)); 
    float startFrac = (float)start/(N_VALID_STUDENTS-1); 
    float endFrac   = (float)end  /(N_VALID_STUDENTS-1); 

    thumbX = X + startFrac*W;
    thumbW = (endFrac - startFrac)*W;

    fill(64);
    noStroke();
    rect(X, thumbY, W, thumbH); // background
    noFill();
    stroke(0);
    rect(X, thumbY, W, thumbH); // background frame

    fill(192);
    stroke(0); 
    rect(thumbX, thumbY, thumbW, thumbH); // thumb


    noStroke();
    fill(255, 0, 0, 64);
    if (bAdjustingStart) {
      fill(255, 0, 0, 128);
    }
    rect(thumbX, thumbY, thumbEdgeW, thumbH); 
    fill(255, 0, 0, 64);
    if (bAdjustingEnd) {
      fill(255, 0, 0, 128);
    }
    rect(thumbX+thumbW-thumbEdgeW, thumbY, thumbEdgeW, thumbH); 

    stroke(255);
    line(thumbX+1, thumbY+1, thumbX+thumbW-1, thumbY+1);
    line(thumbX+thumbW-1, thumbY+1, thumbX+thumbW-1, thumbY+thumbH-1);


    fill(255);
    textFont(arial14Font, 14); 
    textAlign(CENTER);
    String displayStr = (endID - startID + 1) + ": (" + startID + "-" + endID + ")";
    text(displayStr, thumbX+thumbW/2, thumbY+thumbH-4); 
    textAlign(LEFT);
  }
}

