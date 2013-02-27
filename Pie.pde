


class Pie {
  

  float priorityAngle0[];
  float priorityAngle1[];
  int   priorityIDs[];
  
  int pieLatchSelection = -1;
  int N_PIE_WEDGES = 0;

  //----------------------------------
  Pie(){
    pieLatchSelection = -1;
    initPieSettingsFromAdmissionsPriorities();
    setPieSettingsFromAdmissionsPriorities(false);
  }

  //----------------------------------
  void initPieSettingsFromAdmissionsPriorities(){
    int count = 0;
    for (int i=0; i<N_ADMISSIONS_PRIORITIES; i++){
      if (admissionsPriorities[i].bIsFactored){
        count++;
      }
    }
    N_PIE_WEDGES = count;
    priorityAngle0   = new float[N_PIE_WEDGES];
    priorityAngle1   = new float[N_PIE_WEDGES];
    priorityIDs      = new int  [N_PIE_WEDGES];

    count = 0; 
    for (int i=0; i<N_ADMISSIONS_PRIORITIES; i++){
      if (admissionsPriorities[i].bIsFactored){
        priorityIDs[count] = i;
        count++;
      }
    }

  }
  
  

  //----------------------------------
  void setPieSettingsFromAdmissionsPriorities (boolean bReload){
    float angle = 0;
    for (int i=0; i<N_PIE_WEDGES; i++){
      int priorityID = priorityIDs[i];
      float priorityPercent = admissionsPriorities[priorityID].weight; // 0...1
      if (bReload){
        priorityPercent = admissionsPriorities[priorityID].loadedWeight;
      }
      
      float dAngle = priorityPercent*TWO_PI;
      priorityAngle0[i]   = angle;
      priorityAngle1[i]   = angle + dAngle;
      angle += dAngle;
    }

    // Repair last if missing
    if ((TWO_PI - priorityAngle1[N_PIE_WEDGES-1]) > 0.0001){
      priorityAngle1[N_PIE_WEDGES-1] = TWO_PI;
      float dAngle = abs(TWO_PI - priorityAngle0[N_PIE_WEDGES-1]);
      float priorityPercent = dAngle / TWO_PI;
      admissionsPriorities[N_PIE_WEDGES-1].weight = priorityPercent;
    }
  }


  //----------------------------------
  void pieReset(){
    float dx = mouseX - pieX;
    float dy = mouseY - pieY;
    float dh = dist(0,0,dx,dy); 
    if (dh < pieR){
      setPieSettingsFromAdmissionsPriorities(true);
    }
  }
  //----------------------------------
  void update(){
    
    //pieX = mouseX;
    //pieY = mouseY;
    //println(pieX + " " + pieY); 

    float dx = mouseX - pieX;
    float dy = mouseY - pieY;
    float dh = sqrt(dx*dx + dy*dy);

    if (mousePressed == false){
      pieLatchSelection = -1; 
    }


    if ((pieLatchSelection > -1) || ((dh < pieR) && (dh > (pieR*0.1)))){
      float mouseAngle = atan2(dy,dx);
      if (mouseAngle < 0){
        mouseAngle += TWO_PI;
      }
      
      bDORECALCULATION = true;
      int whichAngle = -1;
      float dang = PI;


      if (pieLatchSelection == -1){
        for (int i=1; i<N_PIE_WEDGES; i++){
          dang = abs(mouseAngle - priorityAngle0[i]);
          if ((dang < (DEG_TO_RAD*4.0)) || (dang > (DEG_TO_RAD*356.0))){
            whichAngle = i;
            pieLatchSelection = i;
          } 
        }
      }
      
      int nP = N_PIE_WEDGES;
      if (mousePressed && pieLatchSelection == -1){
        for (int i=0; i<N_PIE_WEDGES; i++){
          if ((mouseAngle > priorityAngle0[i]) && (mouseAngle < priorityAngle1[i])){
            if ((lastMousePressedTime - lastMouseReleasedTime) < 500){
              selectAdmissionsPriority( priorityIDs[i]); 
            }
          }
        }
      }

      bInPie = false;
      if (mousePressed && (pieLatchSelection > -1)){
        int p = pieLatchSelection;
        float da = TWO_PI/200.0;
        bInPie = true;

        float newAng = (mouseAngle+TWO_PI)%TWO_PI;
        float oldAng = (priorityAngle0[p]+TWO_PI)%TWO_PI;
        if (abs(oldAng - newAng) > PI){
          if (newAng < PI){ //p==(nP-1)){
            newAng = TWO_PI;
          } 
          else {
            newAng = 0;
          }
        }


        float hiLimit = (priorityAngle1[p]-da+TWO_PI)%TWO_PI;
        float loLimit = (priorityAngle1[(p-2+nP)%nP]+da+TWO_PI)%TWO_PI;
        if (p==(nP-1)){
          hiLimit = TWO_PI-da;
        }
        if (p==0){
          loLimit = 0+da;
        }

        newAng = min(newAng, hiLimit);
        newAng = max(newAng, loLimit);

        priorityAngle0[p] = newAng;
        priorityAngle1[(p-1+nP)%nP] = newAng;

      }
    }

    for (int i=0; i<N_PIE_WEDGES; i++){
      float a0 = priorityAngle0[i];
      float a1 = priorityAngle1[i];
      float dang = a1-a0;
      int priorityID = priorityIDs[i];
      admissionsPriorities[priorityID].weight = dang/TWO_PI;
    }
    

    

  }



  //----------------------------------
  void render(){

    boolean bDrawDropShadow = true;
    boolean bDrawLabels = true; 

    // draw a drop-shadow
    if (bDrawDropShadow){
      fill(0,0,0,8);
      noStroke();
      noSmooth();
      for (int i=0; i<6; i++){
        ellipse(pieX+i, pieY+i, pieR*2, pieR*2); 
      }
    }


    // the arcs themselves: filled, then linear curves
    for (int i=0; i<N_PIE_WEDGES; i++){
      float startAngle = priorityAngle0[i];
      float endAngle   = priorityAngle1[i];

      noStroke();
      noSmooth();
      int priorityID = priorityIDs[i];
      color priorityColor = admissionsPriorities[priorityID].myColor;
      fill(priorityColor);
      arc (pieX, pieY, pieR*2, pieR*2, startAngle,endAngle);

      smooth();
      noFill();
      stroke(0,0,0);
      strokeWeight(1.0); 
      arc (pieX, pieY, pieR*2, pieR*2, startAngle,endAngle);
    }

    // the separators between arcs
    for (int i=0; i<N_PIE_WEDGES; i++){
      if (mousePressed && (pieLatchSelection == i)){
        stroke(255,0,0);
      } 
      else {
        stroke(0,0,0);
      }

      float startAngle = priorityAngle0[i];
      float Lr = pieR;
      if (i==0) Lr += 16;
      line(pieX,pieY, pieX+Lr*cos(startAngle), pieY+Lr*sin(startAngle));
    }


    // the rotating labels
    if (bDrawLabels){
      fill(0,0,0);
      textFont(arial14Font, 12); 

      for (int i=0; i<N_PIE_WEDGES; i++){
        int priorityID = priorityIDs[i];
        float a0  = priorityAngle0[i]; 
        float a1  = priorityAngle1[i]; 
        float textAngle = (a0+a1)/2.0;

        float tr = pieR + 5; 
        boolean outBumped = false;
        if ((abs(a1-a0) < (DEG_TO_RAD*10.0))) {
          tr += (i%2)*30;
          if (i%2 > 0){
            outBumped = true;
          }
        }

        if (outBumped){
          float px = pieX + (tr-2)*cos(textAngle);
          float py = pieY + (tr-2)*sin(textAngle);
          float qx = pieX + pieR*cos(textAngle);
          float qy = pieY + pieR*sin(textAngle);
          stroke(0,0,0, 96);
          line(px,py, qx,qy); 
        } 
        else {
          stroke(0,0,0);
        }

        float tx = pieX + tr*cos(textAngle);
        float ty = pieY + tr*sin(textAngle);


        pushMatrix();
        float weight = admissionsPriorities[priorityID].weight;
        String ts = nf(100.0*weight, 1,1) + "%";
        String tn = (admissionsPriorities[priorityID].displayName);//.toLowerCase();
        float tw = textWidth(ts);
        float tv = textWidth (tn);

        translate(tx,ty);
        rotate(textAngle + HALF_PI);

        text (ts, 0-tw/2,0); 
        text (tn, 0-tv/2, -14);
        popMatrix();
      }
    }

  }

}














