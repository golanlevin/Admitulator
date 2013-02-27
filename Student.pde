




class Student implements Comparable {

  float   fDataArrayRaw[];
  float   fDataArray01[];
  float   fDataArrayShaped01[];
  float   fDataArrayWeightedShaped01[];
  int     ID;
  String  LASTNAME;
  String  FIRSTNAME;
  
  int     matchingPortfolioID = -1;
  boolean bHasPortfolioRating = false;
  Float   handyFloatObject;
  int     alphabeticalIndex = -1;
  boolean bIAmTheCurrentStudent = false;


  //----------------------------------
  Student (String spreadsheetRowString, int id){

    fDataArrayRaw      = new float[N_DATA_PIECES];
    fDataArray01       = new float[N_DATA_PIECES];
    fDataArrayShaped01 = new float[N_DATA_PIECES];
    fDataArrayWeightedShaped01 = new float[N_DATA_PIECES];

    for (int i=0; i<N_DATA_PIECES; i++){
      fDataArrayRaw[i]      = NO_DATA;
      fDataArray01[i]       = NO_DATA;
      fDataArrayShaped01[i] = NO_DATA;
      fDataArrayWeightedShaped01[i] = NO_DATA;
    }
    fDataArrayRaw[ID_BXA]   = BXA_BFA;
    // println(spreadsheetRowString); 
    // println(id); 
    
    String dataPieceStrings[] = split(spreadsheetRowString, ",");
    int nDataPieces = dataPieceStrings.length;
    ID = id;

    if ((nDataPieces > 0) && (nDataPieces <= N_DATA_PIECES)){
      for (int i=0; i<nDataPieces; i++){
        String dataPieceString = dataPieceStrings[i];
        dataPieceString = dataPieceString.trim();
        if ((dataPieceString == null) || (dataPieceString.length() == 0)){
          ; // set to NO_DATA above
        } 
        else {
          switch(dataTypes[i]){
          case TS: // data is of type String
            fDataArrayRaw[i] = STRING_DATA;
            switch (i){
            case 0: // 
              LASTNAME = dataPieceString;
              break;
            case 1: // 
              FIRSTNAME = dataPieceString;
              break;
            }
            break;
          case TF: // data is of type float
            fDataArrayRaw[i] = max(0, Float.valueOf(dataPieceString).floatValue());
            break;
          case TC: // data is of type char
            fDataArrayRaw[i] = max(0, (float)(dataPieceString.charAt(0)));
            break;
          case TI: // data is of type int
            fDataArrayRaw[i] = max(0, (float)(Integer.parseInt(dataPieceString)));
            break;
          }
          
        }

      }
    }


  }


  //====================================================================
  void printSelf(){
    String s = getStudentSpreadsheetString();
    println(s); 
  }

  //====================================================================
  void printScore(){
    String output = "";
    output += LASTNAME + ",";
    output += FIRSTNAME + "    \t";
    output += nf(fDataArrayShaped01[ID_SCORE],1,4);
    println (output);
  }

  //====================================================================
  void printNormalizedShapedData(){
    String output = "";
    output += LASTNAME + ",";
    output += FIRSTNAME + ",";

    for (int i=2; i<N_DATA_PIECES; i++){
      if (fDataArrayShaped01[i] == NO_DATA){ 
        output+=""; 
      } 
      else {
        if (EV.dataIsFactored[i] != NO_DATA_I){
          output += nf(fDataArrayShaped01[i],1,1);
        } 
        else {
          output += "";
        }
      }
      if (i < (N_DATA_PIECES-1)){
        output += ",";
      }
    }
    println(output);
  }

  //====================================================================
  String getStudentSpreadsheetString(){
    String output = "";
    //print("STUDENT " + (nf(ID,3)) + ": ");
    
    for (int i=0; i<N_DATA_PIECES; i++){
      if (fDataArrayRaw[i] == NO_DATA){
        output+="";
      } 
      else {

        switch (dataTypes[i]){
        case TS:  // data is of type String
          switch(i){
          case 0:
            output+=LASTNAME;
            break;
          case 1:
            output+=FIRSTNAME;
            break;
          }
          break;
        case TF:  // data is of type float
          String fstr = nf (fDataArrayRaw[i], 1,3);
          output+= fstr;
          break;
        case TC:  // data is of type char
          char c = (char)((int)fDataArrayRaw[i]);
          output+= c;
          break;
        case TI:  // data is of type int
          int d = ((int)fDataArrayRaw[i]);
          output+= d;
          break;
        }
      }
      if (i < (N_DATA_PIECES-1)){
        output+=",";
      }
    }
    return output;
  }



  //====================================================================
  float getDatum01 (int which){
    if ((which >= 0) && (which < N_DATA_PIECES)){
      return (fDataArrayShaped01[which]);
    } 
    else {
      return NO_DATA;
    }
  }



  //====================================================================
  public int compareTo (Object obj){
    Student tmp = (Student) obj;

    if (COMPARISON_METRIC == ID_LASTNAME){
      String myName  = this.LASTNAME + ", " + this.FIRSTNAME;
      String tmpName = tmp.LASTNAME  + ", " +  tmp.FIRSTNAME;
      int comp = myName.compareToIgnoreCase(tmpName);
      if (comp < 0){
        return (SORT_DIRECTION == FORWARD) ? -1:1;
      }
      else if (comp > 0){
        return (SORT_DIRECTION == FORWARD) ? 1:-1;
      }
      return 0;

    } 
    else {
      if (this.getDatum01(COMPARISON_METRIC) < tmp.getDatum01(COMPARISON_METRIC)){
        // instance less-than received 
        return (SORT_DIRECTION == FORWARD) ? -1:1;
      }
      else if (this.getDatum01(COMPARISON_METRIC) > tmp.getDatum01(COMPARISON_METRIC)){
        // instance gt received 
        return (SORT_DIRECTION == FORWARD) ? 1:-1;
      }
      // instance == received 
      return 0;
    }
  }



}




















