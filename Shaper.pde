// Bezier Shapers
// adapted from BEZMATH.PS (1993)
// by Don Lancaster, SYNERGETICS Inc. 
// http://www.tinaja.com/text/bezmath.html

class Shaper {

  String name;

  float sx0;
  float sy0;
  float sx1;
  float sy1;

  float sw; 
  float sh;
  float a,b,c,d;
  float la,lb,lc,ld;
  float ax,by;
  float cx,dy;

  boolean adjustingAB; 
  boolean adjustingCD;
  color myColor;

  Shaper (float x, float y, float w, float h, color col, String ns){
    name = ns;
    myColor = col;

    sw = w;
    sx0 = x;
    sx1 = x+sw;
    sh = h;
    sy0 = y;
    sy1 = y+sh; 

    la = a = 0.333;
    lb = b = 0.333;
    lc = c = 0.666;
    ld = d = 0.666;

    ax = sx0+a*sw;
    by = sy0+(1.0-b)*sh;
    cx = sx0+c*sw;
    dy = sy0+(1.0-d)*sh;

    adjustingAB = false;
    adjustingCD = false;

  }

  void setA (float va){
    la = a = va;
    ax = sx0+a*sw;
  }
  void setB (float vb){
    lb = b = vb;
    by = sy0+(1.0-b)*sh;
  }
  void setC (float vc){
    lc = c = vc;
    cx = sx0+c*sw;
  }
  void setD (float vd){
    ld = d = vd;
    dy = sy0+(1.0-d)*sh;
  }
  
  void setLoadedValues (float va, float vb, float vc, float vd){
    la = a = va;
    lb = b = vb;
    lc = c = vc;
    ld = d = vd;
    ax = sx0+a*sw;
    by = sy0+(1.0-b)*sh;
    cx = sx0+c*sw;
    dy = sy0+(1.0-d)*sh;
  }

  void setValues (float va, float vb, float vc, float vd){
    a = va;
    b = vb;
    c = vc;
    d = vd;
    ax = sx0+a*sw;
    by = sy0+(1.0-b)*sh;
    cx = sx0+c*sw;
    dy = sy0+(1.0-d)*sh;
  }

  void reset(){
    a = la;
    b = lb;
    c = lc;
    d = ld;
    ax = sx0+a*sw;
    by = sy0+(1.0-b)*sh;
    cx = sx0+c*sw;
    dy = sy0+(1.0-d)*sh;
  }

  void linearize(){
    a = 0.333;
    b = 0.333;
    c = 0.666;
    d = 0.666;
    ax = sx0+a*sw;
    by = sy0+(1.0-b)*sh;
    cx = sx0+c*sw;
    dy = sy0+(1.0-d)*sh;
  }

  //============================================
  boolean mouseInside(){
    boolean result = false;
    if ((mouseX > sx0) && (mouseX < sx1) && 
      (mouseY > sy1) && (mouseY < sy0)){
      result = true;
    }
    return result;
  }
  
  //============================================
  float getShaped (float in){
    float out = function_CubicBezier (in, a,b, c,d);
    return out; 
  }

  //============================================
  float process (float value){
    return function_CubicBezier (value, a,b, c,d);
  }

  //============================================
  void adjust(){

    if (!mousePressed){
      adjustingAB = false;
      adjustingCD = false;
    }
    else {

      if (adjustingAB || adjustingCD || ((mouseX >= sx0) && (mouseX < sx1) && (mouseY >= sy0) && (mouseY < sy1))){
        bDORECALCULATION = true;

        float dxa = mouseX - ax;
        float dyb = by - mouseY;
        float dhab = sqrt(dxa*dxa + dyb*dyb);

        float dxc = mouseX - cx;
        float dyd = dy - mouseY;
        float dhcd = sqrt(dxc*dxc + dyd*dyd);

        float M = 0.75;
        float N = 1.0-M;

        if ((dhab <= 5) || adjustingAB){
          float axTmp = mouseX;
          float byTmp = mouseY;
          axTmp = (axTmp - sx0)/sw;
          byTmp = (sy1 - byTmp)/sh;
          a = M*a + N*axTmp;
          b = M*b + N*byTmp;
          a = constrain(a, 0.001,0.999); 
          b = constrain(b, 0.001,0.999); 
          adjustingAB = true;
          adjustingCD = false;
        } 
        else if ((dhcd <= 5) || adjustingCD){
          float cxTmp = mouseX;
          float dyTmp = mouseY;
          cxTmp = (cxTmp - sx0)/sw;
          dyTmp = (sy1 - dyTmp)/sh;
          c = M*c + N*cxTmp;
          d = M*d + N*dyTmp;
          c = constrain(c, 0.001,0.999); 
          d = constrain(d, 0.001,0.999); 
          adjustingAB = false;
          adjustingCD = true;
        }

        ax = sx0+a*sw;
        by = sy0+(1.0-b)*sh;
        cx = sx0+c*sw;
        dy = sy0+(1.0-d)*sh;

      }
    }
  }



  //============================================
  void render(){
    noSmooth();
    stroke(0);
    fill(myColor);
    rect(sx0,sy0,sw,sh);

    smooth();
    noFill();
    stroke(0,0,0, 120);
    line(sx0,sy1, ax,by);
    line(ax,by,   cx,dy);
    line(cx,dy,   sx1,sy0);
    ellipse(ax,by, 8,8);
    ellipse(cx,dy, 8,8);

    //noSmooth();
    stroke(0,0,0);
    strokeWeight(0.5);
    noFill();
    beginShape();
    for (int i=0; i<=sw; i++){
      float xFrac = (float)i/sw;
      float val01 = 1.0 - function_CubicBezier (xFrac, a,b, c,d);
      float x = sx0 + xFrac*sw;
      float y = sy0 + val01*sh;
      vertex(x,y);
    }
    endShape();

    //fill(96);
    //textFont(smallFont);
    //textFont(arialFont);
    //text(name, sx0,sy0+17);

  }


}




//------------------------------------------------------------------
float function_CubicBezier (float x, float a, float b, float c, float d){

  float epsilon = 0.000001;
  float min_param_a = 0.0 + epsilon;
  float max_param_a = 1.0 - epsilon;
  float min_param_b = 0.0;
  float max_param_b = 1.0;
  float min_param_c = 0.0 + epsilon;
  float max_param_c = 1.0 - epsilon;
  float min_param_d = 0.0;
  float max_param_d = 1.0;
  a = constrain(a, min_param_a, max_param_a); 
  b = constrain(b, min_param_b, max_param_b); 
  c = constrain(c, min_param_c, max_param_c); 
  d = constrain(d, min_param_d, max_param_d); 

  //-------------------------------------------
  float y0a = 0.00; // initial y
  float x0a = 0.00; // initial x 
  float y1a = b;    // 1st influence y   
  float x1a = a;    // 1st influence x 
  float y2a = d;    // 2nd influence y
  float x2a = c;    // 2nd influence x
  float y3a = 1.00; // final y 
  float x3a = 1.00; // final x 

  float A =   x3a - 3*x2a + 3*x1a - x0a;
  float B = 3*x2a - 6*x1a + 3*x0a;
  float C = 3*x1a - 3*x0a;   
  float D =   x0a;

  float E =   y3a - 3*y2a + 3*y1a - y0a;    
  float F = 3*y2a - 6*y1a + 3*y0a;             
  float G = 3*y1a - 3*y0a;             
  float H =   y0a;

  // Solve for t given x (using Newton-Raphelson), then solve for y given t.
  // Assume for the first guess that t = x.
  float currentt = x;
  int nRefinementIterations = 5;
  for (int i=0; i<nRefinementIterations; i++){
    float currentx = xFromT (currentt, A,B,C,D); 
    float currentslope = slopeFromT (currentt, A,B,C);
    currentt -= (currentx - x)*(currentslope);
    currentt = constrain(currentt, 0,1);
  } 

  //------------
  float y = yFromT (currentt,  E,F,G,H);
  return y;
}


//==========================================================
float slopeFromT (float t, float A, float B, float C){
  float dtdx = 1.0/(3.0*A*t*t + 2.0*B*t + C); 
  return dtdx;
}
//==========================================================
float xFromT (float t, float A, float B, float C, float D){
  float x = A*(t*t*t) + B*(t*t) + C*t + D;
  return x;
}
//==========================================================
float yFromT (float t, float E, float F, float G, float H){
  float y = E*(t*t*t) + F*(t*t) + G*t + H;
  return y;
}

//------------------------------------------------------------------
float function_QuadraticBezier (float x, float a, float b){

  float epsilon = 0.00001;
  float min_param_a = 0.0;
  float max_param_a = 1.0;
  float min_param_b = 0.0;
  float max_param_b = 1.0;
  a = constrain(a, min_param_a, max_param_a); 
  b = constrain(b, min_param_b, max_param_b); 

  if (a == 0.5){
    a += epsilon;
  }
  // solve t from x (an inverse operation)
  float om2a = 1 - 2*a;
  float t = (sqrt(a*a + om2a*x) - a)/om2a;
  float y = (1-2*b)*(t*t) + (2*b)*t;
  return y;
}



//------------------------------------------------------------------
float function_AdjustableCenterDoubleExponentialSigmoid (float x, float a, float b){
  
  float epsilon = 0.00001;
  float min_param_a = 0.0 + epsilon;
  float max_param_a = 1.0 - epsilon;
  a = constrain(a, min_param_a, max_param_a); 
  a = 1.0-a;
  
  float y = 0;
  float w = max(0, min(1, x-(b-0.5)));
  if (w<=0.5){
    y = (pow(2.0*w, 1.0/a))/2.0;
  } 
  else {
    y = 1.0 - (pow(2.0*(1.0-w), 1.0/a))/2.0;
  }
  return y;
}

