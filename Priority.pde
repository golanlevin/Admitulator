



//--------------------------------------------------
void loadAdmissionsPriorities(){
  println("begin loadAdmissionsPriorities()"); 
  bDORECALCULATION = true;
  
  // load data from "admissionsPriorities.csv"
  String priorityFileStrings[] = loadStrings(admissionsPrioritiesFileName);
  int nLines = priorityFileStrings.length;
  N_ADMISSIONS_PRIORITIES = nLines - 1;
  admissionsPriorities = new AdmissionsPriority[N_ADMISSIONS_PRIORITIES];


  int count = 0; 
  for (int i=0; i<nLines; i++){
    String rowString = priorityFileStrings[i];
    if (rowString.length() > 0){
      if (rowString.startsWith("FactorID")){
        ;
      } 
      else {
        String lineElts[] = split(rowString, ",");
        String factorIDStr = lineElts[0];
        factorIDStr = factorIDStr.trim();
        int factorID = (int)(Integer.parseInt(factorIDStr));
        String name = dataNames[factorID];

        float weight = Float.valueOf(lineElts[2]).floatValue();
        float a      = Float.valueOf(lineElts[3]).floatValue();
        float b      = Float.valueOf(lineElts[4]).floatValue();
        float c      = Float.valueOf(lineElts[5]).floatValue();
        float d      = Float.valueOf(lineElts[6]).floatValue();

        int re = (int)(Integer.parseInt(lineElts[7]));
        int gr = (int)(Integer.parseInt(lineElts[8]));
        int bl = (int)(Integer.parseInt(lineElts[9]));
        
        int isFactoredInt = (int)(Integer.parseInt(lineElts[10]));
        boolean bIsFactored = (isFactoredInt > 0)? true : false;
        int isAMultiplierOn = (int)(Integer.parseInt(lineElts[11]));

        admissionsPriorities[count] = new AdmissionsPriority (name, factorID);
        
        admissionsPriorities[count].loadedWeight = weight;
        admissionsPriorities[count].setWeights(weight, a,b,c,d); 
        admissionsPriorities[count].setColor(re,gr,bl);
        admissionsPriorities[count].bIsFactored = bIsFactored;
        admissionsPriorities[count].isAMultiplierOn = isAMultiplierOn;
        admissionsPriorities[count].displayName = lineElts[12];
        count++;
      }
    }
  }
  N_ADMISSIONS_PRIORITIES = count;

  // reset which data is factored, i.e. used in the weighted average of admissions considerations.
  for (int d=0; d<N_DATA_PIECES; d++){
    EV.dataIsFactored[d] = NO_DATA_I;
  }
  for (int i=0; i<N_ADMISSIONS_PRIORITIES; i++){
    int factorID = admissionsPriorities[i].factorID; 
    EV.dataIsFactored[factorID] = i; 
  } 


}



//--------------------------------------------------
void saveAdmissionsPriorities(){
  String output = "FactorID,Name,Weighting,ShaperA,ShaperB,ShaperC,ShaperD,Red,Green,Blue,IsUsed,Multiplier" + "\n";
  for (int i=0; i<N_ADMISSIONS_PRIORITIES; i++){
    output += admissionsPriorities[i].getSaveString() + "\n"; 
  }

  String outputArray[] = {
    output              };
  saveStrings(("data/" + admissionsPrioritiesFileName), outputArray);
  println("Saved AdmissionsPriorities data to " + admissionsPrioritiesFileName);
}

//--------------------------------------------------
void drawActivelyShownAdmissionsPriority(){
  for (int i=0; i<N_ADMISSIONS_PRIORITIES; i++){
    admissionsPriorities[i].draw();
    if (admissionsPriorities[i].bActivelyShown){
      admissionsPriorities[i].myShaper.adjust();
    }
  }
}

void linearizeActivelyShownAdmissionsPriority(){
  bDORECALCULATION = true;
  for (int i=0; i<N_ADMISSIONS_PRIORITIES; i++){
    if (admissionsPriorities[i].bActivelyShown){
      admissionsPriorities[i].myShaper.linearize();
    }
  }
}

void reloadActivelyShownAdmissionsPriority(){
  bDORECALCULATION = true;
  for (int i=0; i<N_ADMISSIONS_PRIORITIES; i++){
    if (admissionsPriorities[i].bActivelyShown){
      admissionsPriorities[i].myShaper.reset();
    }
  }
}


//--------------------------------------------------
void createAdmissionsPrioritiesFromScratch(){
  // no longer necessary, only needed once.
  // Depends on Evaluator being constructed first, for dataIsFactored[];
  int count = 0;
  for (int d=0; d<N_DATA_PIECES; d++){
    if (EV.dataIsFactored[d] != NO_DATA_I){
      count++;
    }
  }
  N_ADMISSIONS_PRIORITIES = count;
  admissionsPriorities = new AdmissionsPriority[N_ADMISSIONS_PRIORITIES];

  count = 0;
  for (int d=0; d<N_DATA_PIECES; d++){
    if (EV.dataIsFactored[d] != NO_DATA_I){
      int factorID = d;
      String name = dataNames[factorID];
      admissionsPriorities[count] = new AdmissionsPriority(name, factorID);
      count++;
    }
  }
}




//======================================================================================
class AdmissionsPriority {
  String name;
  String displayName;
  int    factorID;
  color  myColor;
  Shaper myShaper;
  float  weight;   // 0.....1, used for the pie chart and student evaluation.
  boolean bActivelyShown;
  boolean bIsFactored;
  int     isAMultiplierOn;
  float   loadedWeight;

  //--------------------------------------------------
  AdmissionsPriority (String na, int id){
    bActivelyShown = false;
    name     = na;
    factorID = id;
    weight   = 1.0/(float)N_ADMISSIONS_PRIORITIES;
    myColor  = color (random(200,255), random(200,255), random(200,255));
    myShaper = new Shaper(shaperX,shaperY,shaperW,shaperW, myColor, name);
  }


  //--------------------------------------------------
  void setWeights (float w, float a, float b, float c, float d){
    weight = w;
    myShaper.setLoadedValues(a,b,c,d);
  }

  //--------------------------------------------------
  void setColor (int r, int g, int b){
    myColor = color(r,g,b); 
    myShaper.myColor = myColor;
  }

  //--------------------------------------------------
  void draw(){
    if (bActivelyShown){
      myShaper.render();
    }
  }

  //--------------------------------------------------
  String getSaveString(){
    String output = factorID + "," + name + "," + weight + ","; 
    output += myShaper.a + "," + myShaper.b + "," + myShaper.c + "," + myShaper.d + ",";
    output += (int)(red(myColor)) + "," + (int)(green(myColor)) + "," + (int)(blue(myColor)) + ",";
    output += ((bIsFactored) ? "1":"0") + ",";
    output += isAMultiplierOn + ","; 
    output += displayName; 
    return output; 
  }
}












