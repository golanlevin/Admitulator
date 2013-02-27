



//====================================================================================
class Rating {
  String   comment; 
  String   raterName;
  float    portfolioRating;
  float    interviewRating;
  boolean  bOnCampus;


  Rating (float p, float i, String c, String rn) {
    portfolioRating = p;
    interviewRating = i;
    comment = c;
    raterName = rn;
  }

  String getRaterNameAndComment() {
    if (!comment.equals("")) {
      return (raterName + ": " + comment);
    } 
    else {
      return (raterName + ": ---");
    }
  }
}


//====================================================================================
class SlideroomApplicant {

  String FirstName;
  String LastName;

  int    matchingAdmissionsID; // ID from associated spreadsheet
  boolean bValid;

  int SlideroomSubmissionId; 
  ArrayList ratingArray;
  ArrayList portfolioRatings;
  ArrayList interviewRatings;

  float averagePortfolio;
  float averageInterview;
  int  bxaCode; 



  SlideroomApplicant() {
    bValid = false;
    matchingAdmissionsID = -1;
    bxaCode = BXA_BFA; 

    ratingArray = new ArrayList();
    portfolioRatings = new ArrayList();
    interviewRatings = new ArrayList();
  }


  void addRating (float pRating, float iRating, String cmt, String rater) {
    Rating r = new Rating (pRating, iRating, cmt, rater);
    ratingArray.add(r);
    portfolioRatings.add((int) pRating); 
    interviewRatings.add((int) iRating);
  }


  //-----------------------------------------------
  void computeStatistics() {

    averagePortfolio = 0; 
    averageInterview = 0; 

    int nRatings = ratingArray.size();
    if (nRatings > 0) {

      float portfolioSum = 0; 
      int nPortfolioRatings = 0; 
      float interviewSum = 0; 
      int nInterviewRatings = 0; 

      for (int i=0; i<nRatings; i++) {
        Rating R = (Rating) ratingArray.get(i); 

        float pval = R.portfolioRating;
        float ival = R.interviewRating; 

        if (pval > 0) {
          nPortfolioRatings++;
          portfolioSum += pval;
        }

        if (ival > 0) {
          nInterviewRatings++;
          interviewSum += ival;
        }
      }

      if (nPortfolioRatings > 0) {
        averagePortfolio = (float) portfolioSum / (float) nPortfolioRatings;
      } 
      else {
        averagePortfolio = 1; // what else should it be?
      }

      if (nInterviewRatings > 0) {
        averageInterview = (float) interviewSum / (float) nInterviewRatings;
      } 
      else {
        averageInterview = 1; // what else should it be?
      }
    }
  }




  //--------------------------------------
  void printSelf() {
    String output = "" + SlideroomSubmissionId + "\t" + LastName + "\t" + FirstName;
    output += "\t" + portfolioRatings;
    output += "\t" + interviewRatings;
    output += "\t" + averagePortfolio + ", " + averageInterview;
    println(output);
  }
}

// 
//====================================================================================
void computeSlideroomStats() {
  N_SLIDEROOM_STUDENTS_RAW = slideroomApplicants.length;
  for (int i=0; i<N_SLIDEROOM_STUDENTS_RAW; i++) {
    slideroomApplicants[i].computeStatistics();
  }
}


//====================================================================================
void printSlideroomData() {
  int nSlideroomApplicants = slideroomApplicants.length;
  for (int i=0; i<nSlideroomApplicants; i++) {
    slideroomApplicants[i].printSelf();
  }
}




////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

void loadSlideRoomData () {

  println ("Begin loadSlideRoomData()"); 
  //
  if (theYear >= 2012) {
    loadRatingReport2012 ();
    loadOnCampusRatingReport();

    // copy into the data structure used here...
    int nSA = slideroomApplicantVector.size();
    slideroomApplicants = new SlideroomApplicant[nSA];
    for (int i=0; i<nSA; i++) {
      slideroomApplicants[i] = (SlideroomApplicant)(slideroomApplicantVector.get(i));
      slideroomApplicants[i].bValid = true;
      slideroomApplicants[i].matchingAdmissionsID = -1;
    }
    
    loadSlideroomApplicantSummary();
    ;
  } 
  else {
    loadRatingReport2011 ();
  }
  computeSlideroomStats();
  // printSlideroomData();

  println("Loaded " + N_SLIDEROOM_STUDENTS_RAW + " SlideRoom portfolio ratings forstudents from " + ratingReportFilename);
}

//======================================================
void loadSlideroomApplicantSummary() {
  // this is NOT the reviews; it's the student short 'essays' , where they answer the question about BXA
  println ("Loading Slideroom applicant summaries, from: " + slideroomApplicantSummaryFilename);
  String testPrefix = "School of Art"; 

  String[] rawFile = loadStrings(slideroomApplicantSummaryFilename); 
  int nLinesRaw = rawFile.length;
  for (int i=0; i<nLinesRaw; i++) {
    if (rawFile[i].startsWith (testPrefix)) {
      String aLine = rawFile[i];
      String aLineElements[] = split(aLine, '\t');
      if (aLineElements.length > 19) {
        
        int field_FirstName = 5;
        int field_LastName  = 6;
        int field_BXA       = 24;
        String firstname = (stripQuotesAndTrim ( aLineElements[field_FirstName] )).toUpperCase();
        String lastname  = (stripQuotesAndTrim ( aLineElements[field_LastName]  )).toUpperCase();
        
        String bxaString  = aLineElements[field_BXA].toUpperCase();
        int bxaCode = BXA_BFA;
        if (bxaString.contains("NO OTHERS")) {
          bxaCode = BXA_BFA;
        } 
        if (bxaString.contains("BHA")) {
          bxaCode += BXA_BHA;
        } 
        if (bxaString.contains("BSA")) {
          bxaCode += BXA_BSA;
        } 
        if (bxaString.contains("BCSA")) {
          bxaCode += BXA_BCSA;
        } 
        if (bxaString.contains("DESIGN")) {
          bxaCode += BXA_DES;
        }
        if (bxaString.contains("ARCHITECTURE")) {
          bxaCode += BXA_ARC;
        }
        
        int nSA = slideroomApplicants.length;
        for (int j=0; j<nSA; j++) {
          String jFN = slideroomApplicants[j].FirstName;
          String jLN = slideroomApplicants[j].LastName;
          if ((jFN.equals(firstname)) && (jLN.equals(lastname))){
            slideroomApplicants[j].bxaCode = bxaCode;
            // println(jFN + "\t" + jLN + "\t" + bxaCode + "\t" + bxaString); 
          }
        }
        ;
        
      }
    }
  }
}



//======================================================
ArrayList<SlideroomApplicant> slideroomApplicantVector;

void loadRatingReport2012() { 
  // a variant of loadSlideroomRatingReport in the XYApp

  String testPrefix = "School of";
  slideroomApplicantVector = new ArrayList<SlideroomApplicant>();

  // load the raw file from Slideroom
  String[] rawFile = loadStrings(ratingReportFilename); 
  int nLinesRaw = rawFile.length;
  int nLines = nLinesRaw;


  // Deal with the fact that some of the Raters' comments contain return characters. 
  // Therefore a simple loadStrings() won't work. Concatenate lines broken up in this way.
  ArrayList linesWithReturnsFiltered = new ArrayList();
  for (int i=0; i<nLinesRaw; i++) {
    if ((i==0) || (rawFile[i].startsWith (testPrefix))) {
      linesWithReturnsFiltered.add ( rawFile[i] );
    } 
    else {
      int count = linesWithReturnsFiltered.size();
      String lineSoFar = (String) linesWithReturnsFiltered.get(count-1); 
      lineSoFar += rawFile[i];
      linesWithReturnsFiltered.set(count-1, lineSoFar);
    }
  }

  String linesClean[] = new String[linesWithReturnsFiltered.size()];
  linesWithReturnsFiltered.toArray(linesClean);

  // linesClean now contains the corrected lines, one per rating. 
  rawFile = null;
  rawFile = linesClean;
  nLines = linesClean.length;


  int previousSubmissionId = -1;
  SlideroomApplicant currentSlideroomApplicant = null;

  if (nLines > 1) {
    int dataStartLine = 1;
    for (int i=dataStartLine; i<nLines; i++) {

      String aLine = rawFile[i];
      // println (nf(i,3) + "\t" + aLine); 

      String aLineElements[] = split(aLine, '\t');

      int submissionIdIndex = 1; // line item 1 is the SubmissionID
      // int ithLineSubmissionId = Integer.parseInt(aLineElements[submissionIdIndex]); // OLD BAD
      int ithLineSubmissionId = (int) Long.parseLong(aLineElements[submissionIdIndex]);
      if (ithLineSubmissionId != previousSubmissionId) {
        previousSubmissionId = ithLineSubmissionId;

        int    firstNameIndex = 5; 
        int    lastNameIndex  = 6; 
        String firstName = aLineElements[firstNameIndex];
        String lastName  = aLineElements[lastNameIndex];

        currentSlideroomApplicant = new SlideroomApplicant();
        currentSlideroomApplicant.SlideroomSubmissionId = ithLineSubmissionId;
        currentSlideroomApplicant.FirstName = (stripQuotesAndTrim (firstName)).toUpperCase();
        currentSlideroomApplicant.LastName  = (stripQuotesAndTrim (lastName)).toUpperCase();
        slideroomApplicantVector.add (currentSlideroomApplicant);

        // worth checking if there is name duplication in slideroom!
      }

      // fetch and concatenate ratings.
      if (currentSlideroomApplicant != null) {

        int portfolioRating = -1;
        int interviewRating = -1;
        String comment = ""; 
        String rater = ""; 

        int raterNameIndex       = 16;
        int commmentIndex        = 18;
        int portfolioRatingIndex = 19;
        int interviewRatingIndex = 20; 

        rater = aLineElements[raterNameIndex];
        comment = aLineElements[commmentIndex];

        try {
          portfolioRating = Integer.parseInt(aLineElements[portfolioRatingIndex]);
        } 
        catch (NumberFormatException e) {
          ;
        }

        try {
          interviewRating = Integer.parseInt(aLineElements[interviewRatingIndex]);
        } 
        catch (NumberFormatException e) {
          ;
        }

        currentSlideroomApplicant.addRating( portfolioRating, interviewRating, comment, rater);
        // println (currentSlideroomApplicant.LastName + ", " + currentSlideroomApplicant.FirstName + "\t" + portfolioRating + "\t" + interviewRating);
      }
    }
  }
}


//======================================================
void loadOnCampusRatingReport () {
  // Loads Keni's spreadsheet. 
  // This will always be done AFTER slideroom students are loaded, OK? 

  // Format: LastName	FirstName	Interview	Faculty	Port1	Faculty	Port2	Faculty	Port3	Faculty	Major
  String onCampusRawLines[] = loadStrings (onCampusRatingReportFilename);
  int nOnCampusRawLines = onCampusRawLines.length;
  if (nOnCampusRawLines > 1) { // 1st line is header
    for (int i=1; i<nOnCampusRawLines; i++) {

      String aLine = onCampusRawLines[i]; 
      String aLineElements[] = split(aLine, '\t');
      if (aLineElements.length == 11) {
        String studentLastName  = (aLineElements[0].trim()).toUpperCase();
        String studentFirstName = (aLineElements[1].trim()).toUpperCase();
        String studentBxaStr    = (aLineElements[10].trim()).toUpperCase();

        int bxaCode = BXA_BFA;
        if (studentBxaStr.equals("BHA")) {
          bxaCode |= BXA_BHA;
        } 
        else if (studentBxaStr.equals("BSA")) {
          bxaCode |= BXA_BSA;
        } 
        else if (studentBxaStr.equals("BCSA")) {
          bxaCode |= BXA_BCSA;
        }
        else if (studentBxaStr.equals("DES")) {
          bxaCode |= BXA_DES;
        }  
        else if (studentBxaStr.equals("ARC")) {
          bxaCode |= BXA_ARC;
        }  


        // Test to see if there is already a (previous/Slideroom) student with this name. 
        SlideroomApplicant currentStudent = new SlideroomApplicant();
        boolean bPreviousMatchFound = false;
        int nPreviousStudents = slideroomApplicantVector.size();
        for (int j=0; j<nPreviousStudents; j++) {
          SlideroomApplicant Sj = (SlideroomApplicant) slideroomApplicantVector.get(j);
          String Sjln = Sj.LastName.toUpperCase();
          String Sjfn = Sj.FirstName.toUpperCase();
          String Siln = studentLastName.toUpperCase();
          String Sifn = studentFirstName.toUpperCase();
          if (Siln.equals(Sjln) && Sifn.equals(Sjfn)) {

            // Watch out for students with exactly the same name. 
            // In fact, this happened at least once, with Daniel Kim.
            // Include a comparison on the ID number. 
            // println ("ALERT: previous rating found for: " + studentLastName + " " + studentFirstName); 
            bPreviousMatchFound = true;
            currentStudent = Sj;
          }
        }
        if (bPreviousMatchFound == false) {
          // currentStudent.SlideroomSubmissionId = 0;
          currentStudent.FirstName = studentFirstName;
          currentStudent.LastName  = studentLastName;
          currentStudent.bxaCode   = bxaCode; 
          slideroomApplicantVector.add (currentStudent);
        }

        // There is only one interview rating for the on-campus reviews,
        // and it might also be accompanied by a portfolio review by the same person. 
        // Since the interview rating comes first, store it temporarily to see 
        // if we later see a portfolio rating by the same faculty. 


        String interviewRaterName = ""; 

        for (int r=2; r<=8; r+=2) {

          String raterRatingStr = aLineElements[r  ];
          String raterName      = aLineElements[r+1].trim();

          int portfolioRating   = -1;
          int interviewRating   = -1;
          int ratingVal         = -1;

          try {
            ratingVal = Integer.parseInt ( raterRatingStr);
          } 
          catch (NumberFormatException e) {
            ;
          }
          if (ratingVal != -1) {

            if (r == 2) {
              interviewRating = ratingVal;
              currentStudent.addRating( -1, ratingVal, "", raterName);
            } 
            else {
              portfolioRating = ratingVal;
              currentStudent.addRating( ratingVal, -1, "", raterName);
            }
            // println (currentStudent.LastName + ", " + currentStudent.FirstName + "\t" + portfolioRating + "\t" + interviewRating);
          }
        }
      } 
      else {
        println("Faulty input in on-campus ratings: " + aLine);
      }
    }
  }
}




//======================================================
void loadRatingReport2011() {

  ArrayList<SlideroomApplicant> slideroomApplicantVector = new ArrayList<SlideroomApplicant>();

  String rawFile[];
  rawFile = loadStrings(ratingReportFilename); 
  int nLines = rawFile.length;
  int previousSubmissionId = -1;
  SlideroomApplicant currentSlideroomApplicant = null;

  if (nLines > 1) {
    int dataStartLine = 1;
    for (int i=dataStartLine; i<nLines; i++) {

      String aLine = rawFile[i];
      String aLineElements[] = split(aLine, '\t');

      int submissionIdIndex = 1; // line item 1 is the SubmissionID
      int ithLineSubmissionId = (int) Long.parseLong(aLineElements[submissionIdIndex]);
      if (ithLineSubmissionId != previousSubmissionId) {
        previousSubmissionId = ithLineSubmissionId;

        int    firstNameIndex = 5; 
        int    lastNameIndex  = 6; 
        String firstName = aLineElements[firstNameIndex];
        String lastName  = aLineElements[lastNameIndex];

        currentSlideroomApplicant = new SlideroomApplicant();
        currentSlideroomApplicant.SlideroomSubmissionId = ithLineSubmissionId;
        currentSlideroomApplicant.FirstName = (firstName.trim()).toUpperCase();
        currentSlideroomApplicant.LastName  = (lastName.trim()).toUpperCase();
        slideroomApplicantVector.add (currentSlideroomApplicant);
        currentSlideroomApplicant.printSelf(); 
      }

      // fetch and concatenate ratings.
      if (currentSlideroomApplicant != null) {

        int portfolioRating = -1;
        int interviewRating = -1;
        String comment = ""; 
        String rater = ""; 

        int raterNameIndex       = 16;
        int commmentIndex        = 18;
        int portfolioRatingIndex = 19;
        int interviewRatingIndex = 20; 

        rater = aLineElements[raterNameIndex];
        comment = aLineElements[commmentIndex];

        try {
          portfolioRating = Integer.parseInt(aLineElements[portfolioRatingIndex]);
        } 
        catch (NumberFormatException e) {
          ;
        }

        try {
          interviewRating = Integer.parseInt(aLineElements[interviewRatingIndex]);
        } 
        catch (NumberFormatException e) {
          ;
        }

        currentSlideroomApplicant.addRating( portfolioRating, interviewRating, comment, rater);
      }
    }
  }

  // copy into the data structure used here...
  int nSA = slideroomApplicantVector.size();
  slideroomApplicants = new SlideroomApplicant[nSA];
  for (int i=0; i<nSA; i++) {
    slideroomApplicants[i] = (SlideroomApplicant)(slideroomApplicantVector.get(i));
    slideroomApplicants[i].bValid = true;
    slideroomApplicants[i].matchingAdmissionsID = -1;
  }
}







String stripQuotesAndTrim (String inputStr) {
  String quoteStr = "" + '"';
  if (inputStr.startsWith(quoteStr) && (inputStr.endsWith(quoteStr))) {
    inputStr = inputStr.substring(1, inputStr.length()-1); 
    inputStr = inputStr.trim();
  }
  return inputStr;
}













