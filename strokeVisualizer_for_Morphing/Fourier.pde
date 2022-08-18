
class Fourier {
  float [] m_aX;   //xについてFourierSeriesの実部
  float [] m_bX;   //xについてFourierSeriesの虚部
  float [] m_aY;   //yについてFourierSeriesの実部
  float [] m_bY;   //yについてFourierSeriesの虚部

  Fourier() {
    m_aX = null;
    m_bX = null;
    m_aY = null;
    m_bY = null;
  }

  Fourier( int _iDegree ) {
    Init( _iDegree );
  }
  
  Fourier( float [] _aX, float [] _bX, float [] _aY, float [] _bY ){
    m_aX = _aX;
    m_bX = _bX;
    m_aY = _aY;
    m_bY = _bY;
  }

  // 初期化
  void Init( int _iDegree ) {
    m_aX = new float [_iDegree+1];
    m_aY = new float [_iDegree+1];
    m_bX = new float [_iDegree+1];
    m_bY = new float [_iDegree+1];
    for ( int i=0; i<_iDegree+1; i++ ) {
      m_aX[i] = 0.0;
      m_aY[i] = 0.0;
      m_bX[i] = 0.0;
      m_bY[i] = 0.0;
    }
  }

  // フーリエ級数展開
  void ExpansionFourierSeries( PointF [] _arrayPt, int _iMaxDegree ) {
    int k, n;
    int _iNumOfUnit = _arrayPt.length;

    m_aX = new float [_iMaxDegree+1]; // FourierSeriesの実部
    m_bX = new float [_iMaxDegree+1]; // FourierSeriesの虚部
    m_aY = new float [_iMaxDegree+1]; // FourierSeriesの実部
    m_bY = new float [_iMaxDegree+1]; // FourierSeriesの虚部
    //println("num of unit", _iNumOfUnit );

    // フーリエ級数展開の主たる部分
    for (k=0; k<=min (_iMaxDegree, _iNumOfUnit/2); k++) {
      // xのk次についてフーリエ級数展開
      m_aX[k] = 0.0; // a_xk
      m_bX[k] = 0.0; // b_xk
      // yのk次についてフーリエ級数展開
      m_aY[k] = 0.0;
      m_bY[k] = 0.0;

      // -PI -> PI
      for (n=0; n<_iNumOfUnit; n++) {
        float t = TWO_PI * (float)n / (float)(_iNumOfUnit) - PI;
        m_aX[k] += _arrayPt[n].x * Math.cos( k * t );
        m_bX[k] += _arrayPt[n].x * Math.sin( k * t );

        m_aY[k] += _arrayPt[n].y * Math.cos( k * t );
        m_bY[k] += _arrayPt[n].y * Math.sin( k * t );
      }

      m_aX[k] = m_aX[k] * (2.0/(_iNumOfUnit));
      m_bX[k] = m_bX[k] * (2.0/(_iNumOfUnit));
      m_aY[k] = m_aY[k] * (2.0/(_iNumOfUnit));
      m_bY[k] = m_bY[k] * (2.0/(_iNumOfUnit));
    }

    // ここで2分の1倍する！
    m_aX[0] /= 2;
    m_aY[0] /= 2;
    m_bX[0] /= 2;
    m_bY[0] /= 2;
  }

  // 係数をまとめて設定する
  void SetCoefficientValue( float [] _faX, float [] _fbX, float [] _faY, float [] _fbY ) {
    m_aX = _faX;
    m_bX = _fbX;
    m_aY = _faY;
    m_bY = _fbY;
  }

  /*************/
  // 適切な次数を求める（次数を上げ過ぎると拡大した時にウネウネするため）
  int GetAppropriateDegree( int _iMaxDegree, int _iNumOfPoints, float _fThresholdForCals) {
    if(_iMaxDegree >= 100) return _iMaxDegree;
    
    PointF [] now = null;
    PointF [] pre = null;
    int _start = 2;
    int iRetDegree = _start;

    // 次数を上げた時の変化を見ることで適切な次数を求める
    for (int l=_start; l<=_iMaxDegree; l++) {
      float sumBetween = 0;
      now = GetFourierSeries( l, _iNumOfPoints, _fThresholdForCals );
      if ( pre != null ) {
        for (int t = 0; t < now.length; t++) {
          sumBetween = sumBetween + dist( now[t].x, now[t].y, pre[t].x, pre[t].y );
        }
        if ( sumBetween / now.length < 1 ) {
          iRetDegree = l;
          break;
        }
        iRetDegree = l;
      }
      pre = now;
      now = null;
    }
    return iRetDegree;
  }

  PointF [] GetFourierSeries( int _iDegree, int _iNumOfPoints, float _fThresholdForCals ) {
    // フーリエ級数展開を利用して求めた点列を取得する
    PointF [] _retPoints = new PointF [_iNumOfPoints];
    for ( int i=0; i<_iNumOfPoints; i++ ) {
      // ここで2分の1倍しない！
      float x = m_aX[0];
      float y = m_aY[0];
      for ( int k=1; k<=_iDegree; k++ ) {
        float t = TWO_PI * (float)i/_iNumOfPoints;
        if ( abs(m_aX[k]) > _fThresholdForCals ) x += (m_aX[k] * cos( k*t ));
        if ( abs(m_bX[k]) > _fThresholdForCals ) x += (m_bX[k] * sin( k*t ));
        if ( abs(m_aY[k]) > _fThresholdForCals ) y += (m_aY[k] * cos( k*t ));
        if ( abs(m_bY[k]) > _fThresholdForCals ) y += (m_bY[k] * sin( k*t ));
      }

      _retPoints[i] = new PointF( x, y );
    }
    return _retPoints;
  }

  PointF [] GetFourierSeriesFromZeroToPI( int _iDegree, int _iNumOfPoints, float _fThresholdForCals ) {
    // フーリエ級数展開を利用して求めた点列を取得する
    PointF [] _retPoints = new PointF [_iNumOfPoints];
    for ( int i=0; i<_iNumOfPoints; i++ ) {
      float x = m_aX[0]/2;
      float y = m_aY[0]/2;
      for ( int k=1; k<=_iDegree; k++ ) {
        float t = TWO_PI * (float)i/_iNumOfPoints;
        x += (m_aX[k] * cos( k*t ));
        x += (m_bX[k] * sin( k*t ));
        y += (m_aY[k] * cos( k*t ));
        y += (m_bY[k] * sin( k*t ));
      }

      _retPoints[i] = new PointF( x, y );
    }
    return _retPoints;
  }

  void ShowEquations( int _iNumOfDegree, float _fThreshold ) {
    // 単に数式を表示する
    println( "f(x,t) = " );
    for ( int i=0; i<=_iNumOfDegree; i++ ) {
      if ( abs(m_aX[i]) > _fThreshold ) 
        print( " + " + m_aX[i] + " * Cos[" + i + "t]" );
      if ( abs(m_bX[i]) > _fThreshold ) 
        print( " + " + m_bX[i] + " * Sin[" + i + "t]" );
      println();
    }
    println();

    println( "f(y,t) = " );
    for ( int i=0; i<=_iNumOfDegree; i++ ) {
      if ( abs(m_aY[i]) > _fThreshold ) 
        print( " + " + m_aY[i] + " * Cos[" + i + "t]" );
      if ( abs(m_bY[i]) > _fThreshold ) 
        print( " + " + m_bY[i] + " * Sin[" + i + "t]" );
      println();
    }
    println();
  }
}
