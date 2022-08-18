class Stroke {
  PointF [] m_orgPt;
  PointF [] m_SplinePt;
  PointF [] m_FourierSeriesPt;
  PointF [] m_FourierSeriesPtFromZeroToPI; //0からPIに等間隔で
  PointF [] m_EquallyFourierSeriesPt; // 数を統一したフーリエシリーズ
  Fourier m_Fourier;
  boolean m_bFourier = false;
  color m_Color;
  int m_iAppropriateDegreeOfFourier;


  Stroke( PointF [] _orgPt )
  {
    m_orgPt = _orgPt;
    m_SplinePt = new PointF [_orgPt.length]; //_orgPt;
    m_Fourier = new Fourier( );
    m_Color = color(0, 0, 200);
  }

  Stroke( int _iSize ) {
    //m_orgPt = new PointF [_iSize]; //ここはnullでいい
    m_SplinePt = new PointF [_iSize];
    m_Fourier = new Fourier( min(_iSize/2, Config.g_iMaxDegreeOfFourier));
    m_Color = color(0, 0, 200);
  }

  void setColor( color _col ) {
    m_Color = _col;
  }

  void doSpline( int _iMultiple ) {
    // 0 ～ PI で t を作成する
    float [] _arrayT = new float [m_orgPt.length];
    for ( int j=0; j<m_orgPt.length; j++ ) {
      _arrayT[j] = (float)j*PI/(m_orgPt.length-1);
    }
    Spline sp = new Spline();
    m_SplinePt = sp.GetSplineSeries( _arrayT, m_orgPt, _iMultiple );
  }

  void doFourier() {
    // フーリエしてあったら何もしない
    if ( m_bFourier == true ) return;
    m_SplinePt = DoubleBack( m_SplinePt );
    m_Fourier.ExpansionFourierSeries( m_SplinePt, Config.g_iMaxDegreeOfFourier );
    m_iAppropriateDegreeOfFourier = m_Fourier.GetAppropriateDegree( Config.g_iMaxDegreeOfFourier, m_SplinePt.length, Config.g_fThresholdOfCoefficient );
    m_FourierSeriesPt = m_Fourier.GetFourierSeries( m_iAppropriateDegreeOfFourier, m_SplinePt.length, Config.g_fThresholdOfCoefficient );
    //println( "degree = ", m_iAppropriateDegreeOfFourier );
  }


  void displayInterXY(int _iShowMode )
  {
    for ( int i=0; i<m_SplinePt.length-1; i++ ) {
      fill( 0 );
      stroke( 0 );
      line( (float)m_SplinePt[i].x, (float)m_SplinePt[i].y, (float)m_SplinePt[i+1].x, (float)m_SplinePt[i+1].y );
    }
  }
  

  void display( int _iShowMode, float _fZoom ) {
    strokeWeight(2);

    //次数の導出とか
    int iDegree = m_Fourier.GetAppropriateDegree( Config.g_iMaxDegreeOfFourier, m_SplinePt.length, Config.g_fThresholdOfCoefficient );
    m_FourierSeriesPt = m_Fourier.GetFourierSeries( iDegree, m_SplinePt.length, Config.g_fThresholdOfCoefficient );
    stroke( 0, 0, 255 );
    for ( int i=0; i<m_FourierSeriesPt.length-1; i++ ) {
      line( m_FourierSeriesPt[i].x*_fZoom, m_FourierSeriesPt[i].y*_fZoom, m_FourierSeriesPt[i+1].x*_fZoom, m_FourierSeriesPt[i+1].y*_fZoom );
    }
    //m_Fourier.ShowEquations(10,g_fThresholdOfCoefficient);
  }

  void displayStroke() {
    strokeWeight(1);
    for ( int i=0; i<m_orgPt.length-1; i++ ) {
      line( m_orgPt[i].x, m_orgPt[i].y, m_orgPt[i+1].x, m_orgPt[i+1].y );
    }
  }

  void displaySplinedStroke() {
    strokeWeight(10);
    for ( int i=0; i<m_SplinePt.length-1; i++ ) {
      line( m_SplinePt[i].x, m_SplinePt[i].y, m_SplinePt[i+1].x, m_SplinePt[i+1].y );
    }
  }
  
  void displayStrokeOnCanvas(PGraphics Canvas) {

    Canvas.beginDraw();
    Canvas.strokeWeight(2);
    Canvas.stroke( m_Color );
    for ( int i=0; i<m_orgPt.length-1; i++ ) {
      Canvas.line( m_orgPt[i].x, m_orgPt[i].y, m_orgPt[i+1].x, m_orgPt[i+1].y );
    }
    Canvas.endDraw();
  }

  void displayStrokeByFourier() {
    m_iAppropriateDegreeOfFourier = m_Fourier.GetAppropriateDegree( Config.g_iMaxDegreeOfFourier, m_SplinePt.length, Config.g_fThresholdOfCoefficient );
    //println( "appropriate degree", m_iAppropriateDegreeOfFourier );
    m_FourierSeriesPt = m_Fourier.GetFourierSeries( m_iAppropriateDegreeOfFourier, m_SplinePt.length, Config.g_fThresholdOfCoefficient );

    smooth();
    //stroke( m_Color );
    strokeWeight( 30 );
    float lx = 0;
    float ly = 0;
    for (int num = 0; num <= m_FourierSeriesPt.length/2; num++) {
      line( int(m_FourierSeriesPt[num].x+0.5), int(m_FourierSeriesPt[num].y+0.5), int(m_FourierSeriesPt[num+1].x+0.5), int(m_FourierSeriesPt[num+1].y+0.5) );
    }
    //m_Fourier.ShowEquations(10, Config.g_fThresholdOfCoefficient);
  }
  
  void setFourierSeriesPt(){
    m_iAppropriateDegreeOfFourier = m_Fourier.GetAppropriateDegree( Config.g_iMaxDegreeOfFourier, m_SplinePt.length, Config.g_fThresholdOfCoefficient );
    m_FourierSeriesPt = m_Fourier.GetFourierSeries( m_iAppropriateDegreeOfFourier, m_SplinePt.length, Config.g_fThresholdOfCoefficient );
  }

  void displayStrokeByFourierOnCanvas(PGraphics _Canvas, color _col) {

    /*
    if( !m_bFourier ){
     doSpline( g_iMultiple );
     doFourier();
     }
     */
    
    //m_iAppropriateDegreeOfFourier = m_Fourier.GetAppropriateDegree( g_iMaxDegreeOfFourier, m_SplinePt.length, g_fThresholdOfCoefficient );
    //println( "appropriate degree", m_iAppropriateDegreeOfFourier );
    //m_FourierSeriesPt = m_Fourier.GetFourierSeries( m_iAppropriateDegreeOfFourier, m_SplinePt.length, g_fThresholdOfCoefficient );

    _Canvas.beginDraw();
    _Canvas.smooth();
    _Canvas.stroke( _col );
    _Canvas.strokeWeight(2);
    //_Canvas.strokeWeight(m_Weight);
    float lx = 0;
    float ly = 0;
    for (int num = 0; num <= m_FourierSeriesPt.length/2; num++) {
      _Canvas.line( int(m_FourierSeriesPt[num].x+0.5), int(m_FourierSeriesPt[num].y+0.5), int(m_FourierSeriesPt[num+1].x+0.5), int(m_FourierSeriesPt[num+1].y+0.5) );
    }
    //m_Fourier.ShowEquations(10, g_fThresholdOfCoefficient);
    _Canvas.endDraw();
  }

  void displayResizeStrokeByFourierOnCanvas(PGraphics _Canvas, float _value) {
    m_iAppropriateDegreeOfFourier = m_Fourier.GetAppropriateDegree( Config.g_iMaxDegreeOfFourier, m_SplinePt.length, Config.g_fThresholdOfCoefficient );
    //println( "appropriate degree", m_iAppropriateDegreeOfFourier );
    m_FourierSeriesPt = m_Fourier.GetFourierSeries( m_iAppropriateDegreeOfFourier, m_SplinePt.length, Config.g_fThresholdOfCoefficient );

    _Canvas.beginDraw();
    _Canvas.smooth();
    _Canvas.translate(-150, -120);
    _Canvas.stroke( m_Color  );
    _Canvas.strokeWeight(2);
    //_Canvas.strokeWeight(m_Weight);
    float lx = 0;
    float ly = 0;
    for (int num = 0; num <= m_FourierSeriesPt.length/2; num++) {
      _Canvas.line( int(m_FourierSeriesPt[num].x * _value+0.5), int(m_FourierSeriesPt[num].y * _value+0.5), int(m_FourierSeriesPt[num+1].x * _value+0.5), int(m_FourierSeriesPt[num+1].y * _value+0.5) );
    }
    //m_Fourier.ShowEquations(10, g_fThresholdOfCoefficient);
    _Canvas.endDraw();
  }
  
  float getMinX(){
    float minX = m_orgPt[0].x;
    for(int i=1; i<m_orgPt.length; i++){
      if(minX > m_orgPt[i].x) minX = m_orgPt[i].x; 
    }
    return minX;
  }
  float getMinY(){
    float minY = m_orgPt[0].y;
    for(int i=1; i<m_orgPt.length; i++){
      if(minY > m_orgPt[i].y) minY = m_orgPt[i].y; 
    }
    return minY;
  }
  float getMaxX(){
    float maxX = m_orgPt[0].x;
    for(int i=1; i<m_orgPt.length; i++){
      if(maxX < m_orgPt[i].x) maxX = m_orgPt[i].x; 
    }
    return maxX;
  }
  float getMaxY(){
    float maxY = m_orgPt[0].y;
    for(int i=1; i<m_orgPt.length; i++){
      if(maxY < m_orgPt[i].y) maxY = m_orgPt[i].y; 
    }
    return maxY;
  }
}
