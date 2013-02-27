



//==============================================================
class Stack {

  float rx; 
  float ry; 
  float rw; 
  float rh;
  int   whichDataID;
  int   bins[];
  int   nBins = 0;
  int   maxNBins = 20;
  float displayValues[];
  float displayAvg;
  float displayStdv;
  int   currentPriority = -1;
  int   highlightID = -1;

  Stack (float x, float y, float w, float h, int whichDataPiece){
    whichDataID = whichDataPiece;
    bins = new int[maxNBins];
    displayValues = new float[1000];
    rx = x;
    ry = y; 
    rw = w;
    rh = h;
  }

  void setWhichData (int whichDataPiece){
    whichDataID = whichDataPiece;
  }
  


  //-----------------------------------------------
  void updateBins (int n, int whichPriority){
    currentPriority = whichPriority;
    nBins = n;
    
    if ((whichDataID >= 0) && (whichDataID < N_DATA_PIECES)){ 

      float binWidth = 1.0/(float)nBins;
      for (int i=0; i<nBins; i++){
        bins[i] = 0;
      }
      //----------------------------------
      for (int s=0; s<N_VALID_STUDENTS; s++){
        Student S = studentArray[s];
        float shapedValue01 = S.fDataArrayShaped01[whichDataID];
        shapedValue01 = max(0, min(1, shapedValue01)); 
        int whichBin = (int)(0.999*shapedValue01 / binWidth);
        bins[whichBin]++;
      }
      float maxBinVal = 0; 
      for (int i=0; i<nBins; i++){
        if (bins[i] > maxBinVal){
          maxBinVal = bins[i];
        }
      }
      for (int i=0; i<nBins; i++){
        displayValues[i] = round((float)bins[i]/maxBinVal * rh);
      }

    }
    
    
  }

  //-----------------------------------------------
  void renderHorizontalBins (){

    color fillCo = color(200);
    if (currentPriority >= 0){
      fillCo = admissionsPriorities[whichAdmissionPrioritySelected].myColor;
    }

    noStroke(); 
    fill(96);
    rect(rx,ry,rw,rh); 
    
    float bx = rx;
    float by = ry;
    float bw = rw / (float)nBins;
    float bh;

    stroke (0,0,0, 120); 
    fill (fillCo); 
    if ((whichDataID >= 0) && (whichDataID < N_DATA_PIECES)){ 
      for (int i=0; i<nBins; i++){
        bh = displayValues[i];
        by = ry+rh-bh;
        rect(bx,ry+rh-bh,bw,bh);
        bx += bw;
      }
    }

    noFill();
    stroke(0,0,0);
    rect(rx,ry,rw,rh); 
  }



  //-----------------------------------------------
  void update (int whichPriority){
    currentPriority = whichPriority;

    if ((whichDataID >= 0) && (whichDataID < N_DATA_PIECES)){ 

      //----------------------------------
      for (int s=0; s<N_VALID_STUDENTS; s++){
        Student S = studentArray[s];
        float shapedValue01 = S.fDataArrayShaped01[whichDataID];
        shapedValue01 = max(0, min(1, shapedValue01)); 
        displayValues[s] = round(shapedValue01 * rh);
        
        if (studentArray[s].alphabeticalIndex == CURRENT_STUDENT_ALPHAID){
          highlightID = s;
        }
      }

      //----------------------------------
      // compute average & stdv
      float avg = 0.0;
      float count = 0; 
      for (int s=0; s<N_VALID_STUDENTS; s++){
        Student S = studentArray[s];
        float shapedValue01 = S.fDataArrayShaped01[whichDataID];
        if (shapedValue01 > 0){
          avg += shapedValue01;
          count++;
        }
      }
      if (count > 0){
        avg /= count;
        displayAvg = avg;

        count = 0;
        float sum = 0;
        for (int s=0; s<N_VALID_STUDENTS; s++){
          Student S = studentArray[s];
          float shapedValue01 = S.fDataArrayShaped01[whichDataID];
          if (shapedValue01 > 0){
            sum += sq(shapedValue01 - avg);
            count++;
          }
        }
        displayStdv = sqrt(sum/count); 
      }
    }
  }


  //-----------------------------------------------
  void renderHorizontal (){

    color fillCo = color(200);
    if (currentPriority >= 0){
      fillCo = admissionsPriorities[whichAdmissionPrioritySelected].myColor;
    }

    noStroke(); 
    fill(96);
    rect(rx,ry,rw,rh); 

    float bx = rx;
    float by = ry;
    float bw = rw / (float)N_VALID_STUDENTS;
    float bh;
    stroke (0,0,0, 120); 
    fill(fillCo); 

    if ((whichDataID >= 0) && (whichDataID < N_DATA_PIECES)){ 

      for (int s=0; s<N_VALID_STUDENTS; s++){
        bh = displayValues[s];
        by = ry+rh-bh;
        
        fill(fillCo);
        if (s == highlightID){
          fill(255,0,0);
        }
        rect(bx,ry+rh-bh,bw,bh);
        bx += bw;
      }
      
      float ay = ry+rh - displayAvg*rh;
      float rt1 = max(ry,ay-rh*displayStdv*1.0);
      float rh1 = min(rh*displayStdv*2.0, ry+rh-rt1);
      fill(255,200,200, 70); 
      noStroke();
      rect(rx,rt1, rw,rh1); 

      stroke(255,0,0, 201);
      line(rx,ay,rx+rw,ay);
    }

    noFill();
    stroke(0,0,0);
    rect(rx,ry,rw,rh); 
  }





  void renderVertical(){
    fill(128);
    rect(rx,ry,rw,rh); 

    float bx = rx;
    float by = ry;
    float bh = rh / (float)N_VALID_STUDENTS;
    float bw;

    stroke (0,0,0, 120); 
    fill(200); 

    if ((whichDataID >= 0) && (whichDataID < N_DATA_PIECES)){ 
      for (int s=0; s<N_VALID_STUDENTS; s++){
        Student S = studentArray[s];
        float shapedValue01 = S.fDataArrayShaped01[whichDataID];
        shapedValue01 = max(0, min(1, shapedValue01)); 

        bw = shapedValue01 * rw;
        rect(bx,by,bw,bh);
        by += bh;
      }
    }
  }
}







/*
    int N_ADMISSIONS_STUDENTS_RAW = 0; // number of students in Admissions database
 int N_SLIDEROOM_STUDENTS_RAW = 0;  // number of students in Slideroom 
 int N_VALID_STUDENTS = 0;
 */

/*

 for (int s=0; s<N_VALID_STUDENTS; s++){
 Student S = studentArray[s];
 
 float score = 0.0;
 for (int p=0; p<N_ADMISSIONS_PRIORITIES; p++){
 int factorID   = admissionsPriorities[p].factorID;
 float value = S.fDataArray01[factorID];
 
 if ((value != NO_DATA) & (value != NOT_APPLICABLE)){
 Shaper aShaper = admissionsPriorities[p].myShaper;
 float weight   = admissionsPriorities[p].weight;
 
 float shapedValue = aShaper.getShaped (value);
 S.fDataArrayShaped01[factorID] = shapedValue;
 
 float shapedWeightedValue = (weight * shapedValue);
 score += shapedWeightedValue;
 }
 }
 */





