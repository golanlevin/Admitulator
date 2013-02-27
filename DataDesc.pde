
static final int   NO_DATA_I = -1;
static final float NO_DATA = -1;
static final float STRING_DATA = -2;
static final float NOT_APPLICABLE = -3;

static final int TS = 0; // String
static final int TC = 1; // Char
static final int TI = 2; // Int
static final int TF = 3; // Float

static final int BXA_BFA  =  0; 
static final int BXA_BHA  =  1; 
static final int BXA_BSA  =  2; 
static final int BXA_BCSA =  4;
static final int BXA_DES  =  8;
static final int BXA_ARC  = 16;
static final int BXA_ANY  = 1024; 

static final int CHOICE_1A = 0; 
static final int CHOICE_1B = 1; 
static final int CHOICE_2A = 2; 
static final int CHOICE_2B = 3;
static final int CHOICE_2C = 4;
static final int CHOICE_3A = 5; 
static final int CHOICE_3B = 6; 
static final int CHOICE_4A = 7;
static final int N_PREF_CHOICES = 8;
int countsWithChoicesTot[] = new int[N_PREF_CHOICES];
int countsWithChoicesAdm[] = new int[N_PREF_CHOICES];

final color noneCol  = color (65,65,65); 
final color bcsaCol  = color (0, 200, 255);
final color bhaCol   = color (180, 105, 100);
final color bsaCol   = color (0, 128, 0);
final color desCol   = color (144, 0, 128);
final color arcCol   = color (180, 140, 20);

final color colorAccept   = color (153, 255, 153);
final color colorWaitlist = color (153, 102, 0);
final color colorReject   = color (20, 0, 0);
final color colorNoDecn   = color (60, 60, 60);

final color colorM = color (115, 165, 255);
final color colorF = color (145, 100, 100);

String raceStrings[] = {
  "---", "AFAM", "ASIAN", "NATVAM", "HISP", "CAUC", "UNDEC"
};

String dataNames[];
static int dataTypes[] = {
  /*LN, FN, SX, RC, PR, AP, DC, PF, SG, QP, SC, SM, SW, AC, AV, AM, TO, CR, GR, SR, GP, RC, TA, XC, OR, LS, SV, ES, OA, TN,SRP,SRI,TCR, TM, TW, SC, BX, EN */
    TS, TS, TC, TI, TI, TC, TC, TF, TS, TF, TI, TI, TI, TI, TI, TI, TI, TI, TI, TI, TI, TI, TF, TI, TI, TI, TI, TI, TI, TF, TF, TF, TI, TI, TI, TF, TI, TI
}; //---------------------------------------------------------------admissions---------------  -slideroom-- --sat&act- -SCORE-

static int N_DATA_PIECES = dataTypes.length;	

static   int    ID_LASTNAME;        // TS  //  1   
static   int    ID_FIRSTNAME;       // TS  //  2
static   int    ID_SEX;	            // TC  //  3
static   int    ID_RACE;            // TI  //  4 
static   int    ID_PREF_N;          // TI  //  5
static   int    ID_APPTYPE;         // TC  //  6
static   int    ID_DECISION;        // TC  //  7
static   int    ID_FINEARTSRATING;  // TF  //  8  
static   int    ID_SUGGESTED;       // TS  //  9
static   int    ID_QPA;             // TF  //  10
static   int    ID_SATCR;           // TI  //  11
static   int    ID_SATM;            // TI  //  12
static   int    ID_SATW;            // TI  //  13
static   int    ID_ACTC;            // TI  //  14
static   int    ID_ACTV;	    // TI  //  15
static   int    ID_ACTM;            // TI  //  16
static   int    ID_TOEFL;           // TI  //  17

static   int    ID_CURRICULUMRIGOR; // TI  //  18
static   int    ID_GRADES;          // TI  //  19
static   int    ID_SCHOOLRIGOR;     // TI  //  20
static   int    ID_GPA;	            // TI  //  21
static   int    ID_RECOMMENDATIONS; // TI  //  22
static   int    ID_TOTALACADEMIC;   // TF  //  23
static   int    ID_EXTRACURRICULAR; // TI  //  24
static   int    ID_RECOGNITION;	    // TI  //  25
static   int    ID_LEADERSHIP;	    // TI  //  26
static   int    ID_SERVICE;	    // TI  //  27
static   int    ID_ESSAY;	    // TI  //  28
static   int    ID_OVERALL;	    // TI  //  29
static   int    ID_TOTALNONACADEMIC;// TF  //  30

static   int    ID_SLIDEROOM_PORTF; // TF  //  31
static   int    ID_SLIDEROOM_INTVW; // TF  //  32
static   int    ID_TESTCR;          // TI  //  33
static   int    ID_TESTM;           // TI  //  34
static   int    ID_TESTW;           // TI  //  35
static   int    ID_SCORE;           // TF  //  36
static   int    ID_BXA;             // TI  //  37
static   int    ID_ENROLLED;        // TI  //  38

void createDataPieceIDs() {

  int count = 0;
  /* ID_IDNUM           = count++; */
  ID_LASTNAME        = count++;   
  ID_FIRSTNAME       = count++;     
  ID_SEX             = count++;      	     
  ID_RACE            = count++;
  ID_PREF_N          = count++;    
  ID_APPTYPE         = count++;  
  ID_DECISION        = count++; 
  ID_FINEARTSRATING  = count++;  
  ID_SUGGESTED       = count++;
  ID_QPA             = count++; 
  ID_SATCR           = count++;                   
  ID_SATM            = count++;   
  ID_SATW            = count++;                    
  ID_ACTC            = count++;
  ID_ACTV            = count++;
  ID_ACTM            = count++; 
  ID_TOEFL           = count++;  

  ID_CURRICULUMRIGOR = count++;      
  ID_GRADES          = count++;     
  ID_SCHOOLRIGOR     = count++;     
  ID_GPA             = count++;     
  ID_RECOMMENDATIONS = count++;     	
  ID_TOTALACADEMIC   = count++;      	
  ID_EXTRACURRICULAR = count++;     	
  ID_RECOGNITION     = count++;     	
  ID_LEADERSHIP      = count++;     	
  ID_SERVICE         = count++;     	     	
  ID_ESSAY           = count++;     	
  ID_OVERALL         = count++;     	
  ID_TOTALNONACADEMIC= count++; 

  ID_SLIDEROOM_PORTF = count++;
  ID_SLIDEROOM_INTVW = count++;
  ID_TESTCR          = count++;
  ID_TESTM           = count++;
  ID_TESTW           = count++;
  ID_SCORE           = count++;
  ID_BXA             = count++;
  ID_ENROLLED        = count++;
}





