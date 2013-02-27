
class Evaluator {

  float   dataMins[];
  float   dataMaxs[];
  int     dataIsFactored[]; // NO_DATA_I, **OR** the id of the AdmissionsPriority
  float   dataWeights[];

  //====================================================================================
  Evaluator() {
    createDataMinsAndMaxs();
  }

  //====================================================================================
  void calculateNormalizedStudentData () {
    // For each piece of data owned by a student, 
    // fetch the raw value (from S.fDataArrayRaw[])
    // normalize it to the range 0...1 using map(), mins/maxes
    // store in S.fDataArray01[] -- note: not Shaped! yet

    for (int s=0; s<N_VALID_STUDENTS; s++) {
      Student S = studentArray[s];

      //----------------------------
      // normalize the raw data (SAT, QPA, etc)
      for (int d=0; d<N_DATA_PIECES; d++) {
        if (dataIsFactored[d] != NO_DATA_I) {

          float value = S.fDataArrayRaw[d];
          if (value >= 0) { // simple validity test 
            value = constrain(value, dataMins[d], dataMaxs[d]);
            value = map(value, dataMins[d], dataMaxs[d], 0.0, 1.0); // now in the range 0...1
            S.fDataArrayShaped01[d] = S.fDataArray01[d] = value;
          } 
          else {
            S.fDataArrayShaped01[d] = S.fDataArray01[d] = NO_DATA;
          }
        } 
        else {
          S.fDataArrayShaped01[d] = S.fDataArray01[d] = NOT_APPLICABLE;
        }
      }
    }
  }


  //====================================================================================
  void computeWeightedStudentScoresAlt() { // Faster
    for (int s=0; s<N_VALID_STUDENTS; s++) {
      Student S = studentArray[s];

      float score = 0.0;
      float scalar = 1.0; 

      for (int p=0; p<N_ADMISSIONS_PRIORITIES; p++) {

        int factorID   = admissionsPriorities[p].factorID;
        float value = S.fDataArray01[factorID];

        if ((value != NO_DATA) && (value != NOT_APPLICABLE) && (value >= 0.0)) {

          // Get the shaper, and compute the shaped 0..1 value
          Shaper aShaper = admissionsPriorities[p].myShaper;
          float shapedValue = aShaper.getShaped (value);
          S.fDataArrayShaped01[factorID] = shapedValue;


          // Multiplicatively accumulate the scalar, 
          // to suppress the total later as a result of really terrible components. 
          if (factorID == ID_QPA) {
            scalar *= function_AdjustableCenterDoubleExponentialSigmoid (shapedValue, 0.80, .02); //0.80, .02);
          } 
          else if (factorID == ID_TESTCR) {
            scalar *= function_AdjustableCenterDoubleExponentialSigmoid (shapedValue, 0.80, .06); //0.86, .06);
          } 
          else if (factorID == ID_TESTW) {
            scalar *= function_AdjustableCenterDoubleExponentialSigmoid (shapedValue, 0.85, .08); //0.90, .10);
          } 
          else if (factorID == ID_TESTM) {
            scalar *= function_AdjustableCenterDoubleExponentialSigmoid (shapedValue, 0.88, .05); //0.92, .05);
          }
          else if (factorID == ID_SLIDEROOM_PORTF) {
            scalar *= function_AdjustableCenterDoubleExponentialSigmoid (shapedValue, 0.88, .05); //0.95, .06);
          }
          else if (factorID == ID_SLIDEROOM_INTVW) {
            scalar *= function_AdjustableCenterDoubleExponentialSigmoid (shapedValue, 0.88, .05); //0.95, .06);
          } 
          else if (factorID == ID_TOEFL) {
            scalar *= function_AdjustableCenterDoubleExponentialSigmoid (shapedValue, 0.99, .72); //0.80, .02);
          }


          if (admissionsPriorities[p].bIsFactored) {
            float weight   = admissionsPriorities[p].weight;
            float shapedWeightedValue = (weight * shapedValue);
            S.fDataArrayWeightedShaped01[factorID] = shapedWeightedValue;
            score += shapedWeightedValue;
          }
        }
      }


      for (int p=0; p<N_ADMISSIONS_PRIORITIES; p++) {
        int factorID   = admissionsPriorities[p].factorID;
        float value = S.fDataArray01[factorID];
        if ((value != NO_DATA) && (value != NOT_APPLICABLE) && (value >= 0.0)) {
          S.fDataArrayShaped01[factorID] *= scalar;
          if (admissionsPriorities[p].bIsFactored) {
            S.fDataArrayWeightedShaped01[factorID] *= scalar;
          }
        }
      }
      score *= scalar;

      S.fDataArrayShaped01[ID_SCORE] = score;
      S.fDataArray01[ID_SCORE]       = score;
      S.fDataArrayRaw[ID_SCORE]      = score;
    }
  }




  //====================================================================================
  void computeWeightedStudentScoresOld() { // Faster
    for (int s=0; s<N_VALID_STUDENTS; s++) {
      Student S = studentArray[s];

      float score = 0.0;
      for (int p=0; p<N_ADMISSIONS_PRIORITIES; p++) {

        int factorID   = admissionsPriorities[p].factorID;
        float value = S.fDataArray01[factorID];

        if ((value != NO_DATA) && (value != NOT_APPLICABLE) && (value >= 0.0)) {

          Shaper aShaper = admissionsPriorities[p].myShaper;
          float shapedValue = aShaper.getShaped (value);
          S.fDataArrayShaped01[factorID] = shapedValue;

          if (admissionsPriorities[p].bIsFactored) {
            float weight   = admissionsPriorities[p].weight;
            float shapedWeightedValue = (weight * shapedValue);
            S.fDataArrayWeightedShaped01[factorID] = shapedWeightedValue;
            score += shapedWeightedValue;
          }
        }
      }


      S.fDataArrayShaped01[ID_SCORE] = score;
      S.fDataArray01[ID_SCORE]       = score;
      S.fDataArrayRaw[ID_SCORE]      = score;
    }
  }






  //====================================================================================
  /*
  void computeWeightedStudentScores(){
   for (int s=0; s<N_VALID_STUDENTS; s++){
   Student S = studentArray[s];
   
   float score = 0.0;
   for (int d=0; d<N_DATA_PIECES; d++){
   int whichPriority = dataIsFactored[d];
   if (whichPriority != NO_DATA_I){
   
   float value = S.fDataArray01[d];
   if ((value != NO_DATA) & (value != NOT_APPLICABLE)){
   
   
   
   float weight = admissionsPriorities[whichPriority].weight;
   Shaper aShaper   = admissionsPriorities[whichPriority].myShaper;
   
   float shapedValue = aShaper.getShaped (value);
   S.fDataArrayShaped01[d] = shapedValue; 
   score += (weight * shapedValue);
   }
   }
   }
   
   S.fDataArrayShaped01[ID_SCORE] = score;
   S.fDataArray01[ID_SCORE]       = score;
   S.fDataArrayRaw[ID_SCORE]      = score;
   }
   }
   */

  //====================================================================================
  float shapeDataPiece01 (float value01, int whichPiece) {
    int whichShaper = dataIsFactored[whichPiece];
    if (whichShaper != NO_DATA_I) {
      //
      return value01;
    }
    return 0.0;
  }


  //====================================================================================
  void createDataMinsAndMaxs() {
    dataMins        = new float  [N_DATA_PIECES];
    dataMaxs        = new float  [N_DATA_PIECES];
    dataIsFactored  = new int    [N_DATA_PIECES];
    dataWeights     = new float  [N_DATA_PIECES];

    for (int i=0; i<N_DATA_PIECES; i++) {
      dataIsFactored[i] = NO_DATA_I;
    }

    dataMins[ID_LASTNAME]         = 0;                
    dataMaxs[ID_LASTNAME]         = 1;  
    dataMins[ID_FIRSTNAME]        = 0;                
    dataMaxs[ID_FIRSTNAME]        = 1; 
    dataMins[ID_SEX ]             = 0;                
    dataMaxs[ID_SEX]              = 1;   
    dataMins[ID_RACE]             = 0;                
    dataMaxs[ID_RACE]             = 1;  
    dataMins[ID_PREF_N]           = 0;                
    dataMaxs[ID_PREF_N]           = 4;     
    dataMins[ID_APPTYPE]          = 0;                
    dataMaxs[ID_APPTYPE]          = 1;   

    dataMins[ID_DECISION]         = 0;                
    dataMaxs[ID_DECISION]         = 1;   
    dataMins[ID_FINEARTSRATING]   = 1;                
    dataMaxs[ID_FINEARTSRATING]   = 9;  
    dataMins[ID_SUGGESTED]        = 0;                
    dataMaxs[ID_SUGGESTED]        = 2;
    dataMins[ID_QPA]              = 1;                
    dataMaxs[ID_QPA]              = 4;
    dataMins[ID_SATCR]            = 200;              
    dataMaxs[ID_SATCR]            = 800;
    dataMins[ID_SATM]             = 200;              
    dataMaxs[ID_SATM]             = 800;
    dataMins[ID_SATW]             = 200;              
    dataMaxs[ID_SATW]             = 800;
    dataMins[ID_ACTC]             = 11;               
    dataMaxs[ID_ACTC]             = 36;
    dataMins[ID_ACTV]             = 11;               
    dataMaxs[ID_ACTV]             = 36;
    dataMins[ID_ACTM]             = 11;               
    dataMaxs[ID_ACTM]             = 36;
    dataMins[ID_TOEFL]            = 50;               
    dataMaxs[ID_TOEFL]            = 120;

    dataMins[ID_CURRICULUMRIGOR]  = 0;                
    dataMaxs[ID_CURRICULUMRIGOR]  = 4;
    dataMins[ID_GRADES]           = 0;                
    dataMaxs[ID_GRADES]           = 4;
    dataMins[ID_SCHOOLRIGOR]      = 0;                
    dataMaxs[ID_SCHOOLRIGOR]      = 4;
    dataMins[ID_GPA]              = 0;                
    dataMaxs[ID_GPA]              = 4;
    dataMins[ID_RECOMMENDATIONS]  = 0;                
    dataMaxs[ID_RECOMMENDATIONS]  = 4;
    dataMins[ID_TOTALACADEMIC]    = 0;                
    dataMaxs[ID_TOTALACADEMIC]    = 4;
    dataMins[ID_EXTRACURRICULAR]  = 0;                
    dataMaxs[ID_EXTRACURRICULAR]  = 4;
    dataMins[ID_RECOGNITION]      = 0;                
    dataMaxs[ID_RECOGNITION]      = 4;
    dataMins[ID_LEADERSHIP]       = 0;                
    dataMaxs[ID_LEADERSHIP]       = 4;
    dataMins[ID_SERVICE]          = 0;                
    dataMaxs[ID_SERVICE]          = 4;
    dataMins[ID_ESSAY]            = 0;                
    dataMaxs[ID_ESSAY]            = 4;
    dataMins[ID_OVERALL]          = 0;                
    dataMaxs[ID_OVERALL]          = 4;
    dataMins[ID_TOTALNONACADEMIC] = 0;                
    dataMaxs[ID_TOTALNONACADEMIC] = 4;

    dataMins[ID_SLIDEROOM_PORTF]  = 1;                
    dataMaxs[ID_SLIDEROOM_PORTF]  = 9;
    dataMins[ID_SLIDEROOM_INTVW]  = 1;                
    dataMaxs[ID_SLIDEROOM_INTVW]  = 9;
    dataMins[ID_TESTCR]           = 200;              
    dataMaxs[ID_TESTCR]           = 800;
    dataMins[ID_TESTM]            = 200;              
    dataMaxs[ID_TESTM]            = 800;
    dataMins[ID_TESTW]            = 200;              
    dataMaxs[ID_TESTW]            = 800;
    dataMins[ID_SCORE]            = 0;                
    dataMaxs[ID_SCORE]            = 1;
  }
}










