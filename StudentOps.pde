

String getStudentSpreadsheetString (int whichStudentID) {
  String s = studentArray[whichStudentID].getStudentSpreadsheetString();
  return s;
}
int getStudentDegreeOption (int whichStudentID) {
  int degreeOption = ((int) (studentArray[whichStudentID].fDataArrayRaw[ID_BXA]));
  return degreeOption;
}
char getStudentSex (int whichStudentID) {
  char sex =  ((char)(studentArray[whichStudentID].fDataArrayRaw[ID_SEX]));
  return sex;
}
char getStudentDecision (int whichStudentID) {
  char decn = ((char)(studentArray[whichStudentID].fDataArrayRaw[ID_DECISION]));
  return decn;
}
int getStudentEnrolled (int whichStudentID) {
  int enrolled  = ((int) (studentArray[whichStudentID].fDataArrayRaw[ID_ENROLLED]));
  return enrolled;
}
int getStudentToeflScore (int whichStudentID) {
  int toefl = ((int) (studentArray[whichStudentID].fDataArrayRaw[ID_TOEFL]));
  return toefl;
}
int getStudentEthnicity (int whichStudentID) {
  int ethnicity = ((int) (studentArray[whichStudentID].fDataArrayRaw[ID_RACE]));
  return ethnicity;
}
int getStudentArtPreference (int whichStudentID) {
  int pref = ((int) (studentArray[whichStudentID].fDataArrayRaw[ID_PREF_N]));
  return pref;
}


color getDecnColor (char decn) {
  color out = colorNoDecn;
  switch (decn) {
  case 'A':
    out = (colorAccept); 
    break;
  case 'W':
    out = (colorWaitlist); 
    break;
  case 'R':
  case 'C':
    out = (colorReject); 
    break;
  default: 
    out = (colorNoDecn);
    break;
  }
  return out;
}

color getSexColor (char sex) {
  color out = color(0, 0, 0); 
  switch (sex) {
  case 'F':
  default:
    out = colorF;
    break;
  case 'M':
    out = colorM;
    break;
  }
  return out;
}


int getStudentChoiceType (int whichStudentID) {
  int choiceType = CHOICE_1A;   

  Student S = studentArray[whichStudentID];
  int  degreeOption = getStudentDegreeOption (whichStudentID);
  int  pref         = getStudentArtPreference (whichStudentID); 

  boolean bBxa = ((degreeOption & BXA_BCSA)>0) || ((degreeOption & BXA_BSA)>0) || ((degreeOption & BXA_BHA)>0);
  boolean bDesOrArc = ((degreeOption & BXA_DES)>0) || ((degreeOption & BXA_ARC)>0) ;
  boolean bBxaExclusively = bBxa && (!bDesOrArc); 

  switch (pref) {
  case 1: 
    if (!bBxa) {
      choiceType = CHOICE_1A;
    } 
    else {
      choiceType = CHOICE_1B;
    }
    break;

  case 2: 
    if (bBxaExclusively) {
      choiceType = CHOICE_2A; // Art is second choice to a BXA
    } 
    else if (bDesOrArc) { 
      choiceType = CHOICE_2B; // Art is second choice to design or architecture
    } 
    else {
      choiceType = CHOICE_2C; // Art is second choice to something else altogether
    }
    break;

  case 3: 
    if (bBxa) {
      choiceType = CHOICE_3A;
    } 
    else {
      choiceType = CHOICE_3B;
    }
    break;

  case 4:
  default:
    choiceType = CHOICE_4A;
    break;
  }

  return choiceType;
}









boolean getIsTheCurrentStudent (int whichStudentID) {
  return studentArray[whichStudentID].bIAmTheCurrentStudent;
}

int getRank (int whichStudentID) {
  return 0;
}

//====================================================================================
void compileStudentsWithPortfolioRatings() {

  int validStudentCount = 0;
  for (int i=0; i<N_ADMISSIONS_STUDENTS_RAW; i++) {
    Student S = (Student) rawAdmissionsStudentVector.get(i);
    if (S.bHasPortfolioRating) {
      validStudentCount++;
    }
  }

  N_VALID_STUDENTS = validStudentCount;
  studentArray = new Student[validStudentCount];

  int count = 0;
  for (int i=0; i<N_ADMISSIONS_STUDENTS_RAW; i++) {
    Student S = (Student) rawAdmissionsStudentVector.get(i);
    if (S.bHasPortfolioRating) {
      // Copy by reference!
      studentArray[count] = S;
      count++;
    }
  }
}

//====================================================================================
void printStudentArrayRawData() {
  for (int i=0; i<N_VALID_STUDENTS; i++) {
    String s = studentArray[i].getStudentSpreadsheetString();
    println(i+ "\t" + s);
  }
}


//====================================================================================
void printStudentsWithMissingData() {
  for (int i=0; i<N_VALID_STUDENTS; i++) {

    boolean bMissing = false;
    for (int d=0; d<N_DATA_PIECES; d++) {
      if (EV.dataIsFactored[d] != NO_DATA_I) {
        if (studentArray[i].fDataArrayRaw[d] < 0) {
          bMissing = true;
        }
      }
    }
    if (bMissing) {
      println(studentArray[i].LASTNAME + ", " + studentArray[i].FIRSTNAME + " is missing data");
    }
  }
}

//====================================================================================
void printStudentArrayNormalizedShapedData() {
  for (int i=0; i<N_VALID_STUDENTS; i++) {
    studentArray[i].printNormalizedShapedData();
  }
}


//====================================================================================
void printStudentScores() {
  for (int i=0; i<N_VALID_STUDENTS; i++) {
    studentArray[i].printScore();
  }
}



//====================================================================================
void sortStudentArray(int direction) {
  SORT_DIRECTION  = direction;
  Arrays.sort(studentArray);
}


void printSlideRoomStudentsMissingAdmissionsData() {
  println("---------------------"); 
  int noMatchCount = 0;
  for (int j=0; j<N_SLIDEROOM_STUDENTS_RAW; j++) {
    if (slideroomApplicants[j].matchingAdmissionsID == -1) {
      String slideroomLastName  = slideroomApplicants[j].LastName;
      String slideroomFirstName = slideroomApplicants[j].FirstName;

      noMatchCount++;
      println(nf(noMatchCount, 3) + ": no admissions data found for:\t" + slideroomLastName + "\t" + slideroomFirstName);
    }
  }
}



//====================================================================
void findAdmissionsStudentsWithSameName() {
  // Some unlucky souls are born with the exact same name as each other. 
  println("---------------------"); 
  boolean bExactMatchFound = false;


  for (int i=0; i<N_ADMISSIONS_STUDENTS_RAW; i++) {
    Student Si = (Student) rawAdmissionsStudentVector.get(i);
    String lastNamei   = Si.LASTNAME;
    String firstNamei  = Si.FIRSTNAME;

    for (int j=0; j<i; j++) {
      Student Sj = (Student) rawAdmissionsStudentVector.get(j);
      String lastNamej   = Sj.LASTNAME;
      String firstNamej  = Sj.FIRSTNAME;
      //  println (i + ", " + j + "\t Comparing " + lastNamei  + " & " + lastNamej); 

      if (lastNamei.equals(lastNamej)) {
        // println(lastNamei); //
        if (firstNamei.equals(firstNamej)) {
          println("EXACT NAME MATCH: " + lastNamei + ", " + firstNamei); 
          bExactMatchFound = true;
        }
      }
    }
  }
  if (bExactMatchFound == false) {
    println("No exact names match.");
  }
}


void findAdmissionsStudentsMissingSlideroomData() {

  println("---------------------"); 
  int noMatchCount = 0;
  for (int i=0; i<N_ADMISSIONS_STUDENTS_RAW; i++) {
    Student S = (Student) rawAdmissionsStudentVector.get(i);

    if (S.matchingPortfolioID == -1) {
      String admissionsLastName  = S.LASTNAME;
      String admissionsFirstName = S.FIRSTNAME;
      noMatchCount++;
      println(nf(noMatchCount, 3) + ": No portfolio data found for:\t" + admissionsLastName + "\t" + admissionsFirstName);

      for (int j=0; j<N_SLIDEROOM_STUDENTS_RAW; j++) {
        String slideroomLastName  = slideroomApplicants[j].LastName;
        String slideroomFirstName = slideroomApplicants[j].FirstName;

        if ((admissionsLastName.equals(slideroomLastName)) && 
          (slideroomApplicants[j].matchingAdmissionsID == -1)) { //[Adm==SR] 
          println("Is " + admissionsLastName + " " + admissionsFirstName + " == " + slideroomLastName + " " + slideroomFirstName + " ?");
        }
      }
    }
  }
}

float getAverageScoreOfEnrolledStudents() {
  int nEnrolled = 0; 
  float scoreSum = 0; 
  for (int s=0; s<N_VALID_STUDENTS; s++) {
    Student S = studentArray[s];
    int enrolled = (int) S.fDataArrayRaw[ID_ENROLLED];
    if (enrolled == 1) {
      float score = S.fDataArrayShaped01[ID_SCORE];
      scoreSum += score;
      nEnrolled++;
    }
  }
  if (nEnrolled == 0) {
    return 0;
  } 

  scoreSum /= (float) nEnrolled;
  return scoreSum;
}

//====================================================================================
int findMatchesBetweenSlideroomAndAdmissions() {

  println ("Begin findMatchesBetweenSlideroomAndAdmissions()"); 

  int matchCount = 0; 
  for (int i=0; i<N_ADMISSIONS_STUDENTS_RAW; i++) {
    Student S = (Student) rawAdmissionsStudentVector.get(i);
    String admissionsLastName  = S.LASTNAME;
    String admissionsFirstName = S.FIRSTNAME;

    for (int j=0; j<N_SLIDEROOM_STUDENTS_RAW; j++) {
      if (slideroomApplicants[j].bValid) {
        if (slideroomApplicants[j].matchingAdmissionsID == -1) {
          String slideroomLastName  = slideroomApplicants[j].LastName;
          String slideroomFirstName = slideroomApplicants[j].FirstName;

          if (admissionsLastName.equals(slideroomLastName) && 
            admissionsFirstName.equals(slideroomFirstName)) {
            matchCount++; // Match found!
            // println (matchCount + ": Matched\t" + admissionsLastName + "\t" + admissionsFirstName); 
            slideroomApplicants[j].matchingAdmissionsID = i;
            S.matchingPortfolioID = j;
          }
        }
      }
    }
  }


  println ("Found " + matchCount + " matching students between Admissions and SlideRoom data."); 

  boolean bPrintStudentsWithNoMatches = true;
  if (bPrintStudentsWithNoMatches) {
    if (matchCount < N_SLIDEROOM_STUDENTS_RAW) {
      for (int j=0; j<N_SLIDEROOM_STUDENTS_RAW; j++) {
        if (slideroomApplicants[j].matchingAdmissionsID == -1) {
          String fn = slideroomApplicants[j].FirstName;
          String ln = slideroomApplicants[j].LastName;
          //println("No Admissions match found for Slideroom student: " + ln + ", " + fn);
        }
      }
    }
  }



  return matchCount;
}




//====================================================================================
void populateStudentsAdmissionsDataWithSlideroomData() {

  println("Begin populateStudentsAdmissionsDataWithSlideroomData()"); 

  int countOfStudentsWithOnlyNewRatings = 0;
  int countOfStudentsWithOnlyOldRatings = 0;
  int countOfStudentsWithBothRatings    = 0;
  int countOfStudentsWithNoRatingsAtAll = 0;

  for (int i=0; i<N_ADMISSIONS_STUDENTS_RAW; i++) {
    Student S = (Student) rawAdmissionsStudentVector.get(i);
    int whichPortfolioID  = S.matchingPortfolioID;
    float inHouseRating = S.fDataArrayRaw[ID_FINEARTSRATING];

    if (whichPortfolioID != -1) {

      countOfStudentsWithOnlyNewRatings++;
      S.bHasPortfolioRating = true;

      float slideroomPortfolioRating  = slideroomApplicants[whichPortfolioID].averagePortfolio;
      float slideroomInterviewRating  = slideroomApplicants[whichPortfolioID].averageInterview;
      int   bxaCode                   = slideroomApplicants[whichPortfolioID].bxaCode;

      S.fDataArrayRaw[ID_SLIDEROOM_PORTF]   = slideroomPortfolioRating;
      S.fDataArrayRaw[ID_SLIDEROOM_INTVW]   = slideroomInterviewRating;
      S.fDataArrayRaw[ID_BXA            ]   = bxaCode;
      // println ("-----> " + S.FIRSTNAME + " " + S.LASTNAME + "\t" + bxaCode);

      if (inHouseRating != NO_DATA) {
        // Student has both kinds of ratings, 1-9 and 0-100
        countOfStudentsWithBothRatings++;

        //float dif = slideroomPortfolioRating - inHouseRating;
        //println(slideroomApplicants[whichPortfolioID].LastName + ", " + slideroomApplicants[whichPortfolioID].FirstName + "\t" + dif);
      }
    } 
    else {

      // Some students have old-style ratings 1-9, stored in the ID_FINEARTSRATING field
      if (inHouseRating != NO_DATA) {
        S.bHasPortfolioRating = true;
        float inhousePortfolioRating = inHouseRating;
        float inhouseInterviewRating = inHouseRating; // a guess

        S.fDataArrayRaw[ID_SLIDEROOM_PORTF]   = inhousePortfolioRating;
        S.fDataArrayRaw[ID_SLIDEROOM_INTVW]   = inhouseInterviewRating;
        S.fDataArrayRaw[ID_BXA            ]   = BXA_BFA; 

        // S.printSelf(); 
        countOfStudentsWithOnlyOldRatings++;
      } 
      else {
        // Student lacks any rating whatsoever
        countOfStudentsWithNoRatingsAtAll++;
        S.bHasPortfolioRating = false;
        // S.printSelf();
      }
    }
  }
  println("# Students with SLIDEROOM ratings     : " + countOfStudentsWithOnlyNewRatings);
  println("# Students with IN-HOUSE  ratings only: " + countOfStudentsWithOnlyOldRatings);
  println("# Students with BOTH rating types     : " + countOfStudentsWithBothRatings);
  println("# Students with NO ratings at all     : " + countOfStudentsWithNoRatingsAtAll);
}





//====================================================================================
void compileStudentTestScores() {

  // what to do if a student has the ACT but no SAT.
  int nWithoutSAT = 0;
  int nWithoutACT = 0;

  for (int i=0; i<N_ADMISSIONS_STUDENTS_RAW; i++) {
    Student S = (Student) rawAdmissionsStudentVector.get(i);
    boolean bHasSAT = true;
    boolean bHasACT = true; 

    // identify those without ACT
    if ((S.fDataArrayRaw[ID_ACTV] == NO_DATA) || (S.fDataArrayRaw[ID_ACTM] == NO_DATA) || (S.fDataArrayRaw[ID_ACTC] == NO_DATA)) {
      nWithoutACT++;
      bHasACT = false;
    }

    // identify those without SAT
    if ((S.fDataArrayRaw[ID_SATCR] == NO_DATA) || (S.fDataArrayRaw[ID_SATM] == NO_DATA) || (S.fDataArrayRaw[ID_SATW] == NO_DATA)) {
      nWithoutSAT++;
      bHasSAT = false;
    }

    //-------------------------
    if (bHasSAT && !bHasACT) { // Has SAT only. Copy values to "TEST" fields
      S.fDataArrayRaw[ID_TESTCR] = S.fDataArrayRaw[ID_SATCR];
      S.fDataArrayRaw[ID_TESTM]  = S.fDataArrayRaw[ID_SATM];
      S.fDataArrayRaw[ID_TESTW]  = S.fDataArrayRaw[ID_SATW];
    } 

    else if (!bHasSAT && bHasACT) { // Has ACT only. Convert values.

      int actC = (int) S.fDataArrayRaw[ID_ACTC];
      int actV = (int) S.fDataArrayRaw[ID_ACTV];
      int actM = (int) S.fDataArrayRaw[ID_ACTM];
      int concordanceLength = ACT_to_SAT.length;


      int satCR = 200;
      int satM  = 200; 
      int satW  = 200;
      for (int a=0; a<concordanceLength; a++) {
        if (actV     == ACT_to_SAT[a][0]) {
          satCR = (int) ACT_to_SAT[a][1];
        } 
        if (actM    == ACT_to_SAT[a][0]) {
          satM = (int) ACT_to_SAT[a][1];
        }
        if (actC    == ACT_to_SAT[a][0]) {
          satW = (int) ACT_to_SAT[a][1];
        }
      }

      S.fDataArrayRaw[ID_TESTCR] = (float) satCR;
      S.fDataArrayRaw[ID_TESTM]  = (float) satM;
      S.fDataArrayRaw[ID_TESTW]  = (float) satW;

      // println("Converted " + actV + "," + actM + " = " + satV + "," + satM);
    } 

    else if (bHasSAT && bHasACT) {  // Has BOTH. Just take SAT.
      S.fDataArrayRaw[ID_TESTCR] = S.fDataArrayRaw[ID_SATCR];
      S.fDataArrayRaw[ID_TESTM]  = S.fDataArrayRaw[ID_SATM];
      S.fDataArrayRaw[ID_TESTW]  = S.fDataArrayRaw[ID_SATW];
    } 

    else if (!bHasACT && !bHasSAT) { // Has NEITHER
      // if (S.bHasPortfolioRating){
      // println(S.LASTNAME + "," + S.FIRSTNAME + " has Portfolio but no ACT OR SAT!"); 
      // } 
      S.fDataArrayRaw[ID_TESTCR] = 200;
      S.fDataArrayRaw[ID_TESTM]  = 200;
      S.fDataArrayRaw[ID_TESTW]  = 200;
    }

    /*
    float tw = S.fDataArrayRaw[ID_TESTW];
     float tv = S.fDataArrayRaw[ID_TESTV];
     float tm = S.fDataArrayRaw[ID_TESTM];
     float Ma = 0.38; // !!!!!!
     float Mb = (1.0 - Ma)/2.0;
     float ta = (Ma*tm) + (Mb*tv) + (Mb*tw);
     S.fDataArrayRaw[ID_TESTAVG] = ta;
     */
  }
}


float ACT_to_SAT[][] = {
  {
    36, 800
  }
  , {
    35, 790
  }
  , {
    34, 770
  }
  , {
    33, 740
  }
  , {
    32, 720
  }
  , {
    31, 690
  }
  , {
    30, 670
  }
  , {
    29, 650
  }
  , {
    28, 630
  }
  , {
    27, 610
  }
  , {
    26, 590
  }
  , {
    25, 570
  }
  , {
    24, 550
  }
  , {
    23, 530
  }
  , {
    22, 510
  }
  , {
    21, 490
  }
  , {
    20, 470
  }
  , {
    19, 450
  }
  , {
    18, 430
  }
  , {
    17, 420
  }
  , {
    16, 400
  }
  , {
    15, 380
  }
  , {
    14, 360
  }
  , {
    13, 340
  }
  , {
    12, 330
  }
  , {
    11, 310
  }
};

