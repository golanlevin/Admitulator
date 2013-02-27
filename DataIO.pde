
String inputFileHeaderRow = "";


//====================================================================
void loadStudentAdmissionsData(){

  String admissionsFileStrings[] = loadStrings(admissionsFileName);
  int nLines = admissionsFileStrings.length;
  rawAdmissionsStudentVector = new ArrayList<Student>(); //(nLines);

  int count = 0;
  for (int i=0; i<nLines; i++){
    String spreadsheetRowString = admissionsFileStrings[i];

    if ((spreadsheetRowString.startsWith("last") == true) || 
        (spreadsheetRowString.startsWith("LAST") == true)){
      inputFileHeaderRow = spreadsheetRowString;
      
      // if this is a sheet given directly from the Admissions office, then...
      if (inputFileHeaderRow.endsWith("tot_nonacad")){ // brittle failure point
        inputFileHeaderRow += ",SLIDEROOM_PORTF,SLIDEROOM_INTVW,TESTCR,TESTM,TESTW,SCORE,BXA";
      } 
    

      dataNames = split(inputFileHeaderRow, ",");
      for (int j=0; j<dataNames.length; j++){
        dataNames[j] = dataNames[j].trim();
      }
    } 
    else if (spreadsheetRowString.startsWith("null") == true){
      ;
    } 
    else {
      Student aStudent = new Student (spreadsheetRowString, count++);
      rawAdmissionsStudentVector.add(aStudent);
    } 
  }
  N_ADMISSIONS_STUDENTS_RAW = rawAdmissionsStudentVector.size();
  println("Loaded data for " + N_ADMISSIONS_STUDENTS_RAW + " students from " + admissionsFileName);
  
  findAdmissionsStudentsWithSameName();
}



//====================================================================
void printStudentAdmissionsData(){
  String output = generateStudentAdmissionsDataString();
  println(output);
}

//====================================================================
String generateStudentAdmissionsDataString(){
  // generate output
  String output = "";
  output += inputFileHeaderRow + "\n";
  for (int i=0; i<N_ADMISSIONS_STUDENTS_RAW; i++){
    Student S = (Student) rawAdmissionsStudentVector.get(i);
    output += S.getStudentSpreadsheetString();
    if (i < (N_ADMISSIONS_STUDENTS_RAW-1)){
      output += "\n";
    }
  }
  return output;
}

//====================================================================
void saveStudentAdmissionsData(){

  String output = generateStudentAdmissionsDataString();
  String outputArray[] = {
    output    };

  // compute filename
  String previousFileName = admissionsFileName;
  String yearPrefix = theYear + "/";
  if (previousFileName.startsWith((theYear + "/"))){
    previousFileName = admissionsFileName.substring( yearPrefix.length() );  
  }
  
  String date = nf(year(), 4) + nf(month(),2) + nf(day(),2);
  String time = nf(hour(),2) + nf(minute(),2) + nf(second(),2);
  String mod  = "-mod-";
  int indexOfMod = admissionsFileName.indexOf(mod);
  if (indexOfMod > 0){
    previousFileName = admissionsFileName.substring(indexOfMod+mod.length(), admissionsFileName.length());
  }
  String outputFileName = theYear + "/" + date + "-" + time + mod + previousFileName;
  
  
  // write file
  saveStrings(("data/" + outputFileName), outputArray);
  println("Saved student data to " + outputFileName);

}


