class Spline {
  Spline() {
    ;
  }

  PointF [] GetSpline( PointF [] _arrayPt, int _multiple )
  {
    float [] _arrayT = new float [_arrayPt.length];
    for ( int i=0; i<_arrayPt.length; i++ ) {
      _arrayT[i] = (float)i*TWO_PI/(_arrayPt.length-1)-PI;
    }

    PointF [] _points = GetSplineSeries( _arrayT, _arrayPt, _multiple );

    PointF [] _retPoints = new PointF [_points.length*2-1];
    for ( int i=0; i<_points.length; i++ ) {
      _retPoints[i] = _points[i];
      _retPoints[_retPoints.length-i-1]  = _points[i];
    }
    return _retPoints;
  }

  // この処理がミスってた。色々影響してそうなコードがあるなぁ... 2022/07/06
  PointF [] GetInterXYSeries( float [] _t, PointF [] _arrayPt, int _multiple )
  {
    PointF [] _retPoints = new PointF [_arrayPt.length*_multiple];
    _retPoints[0] = new PointF( _arrayPt[0].x, _arrayPt[0].y );
    _retPoints[_arrayPt.length*_multiple-1] = new PointF( _arrayPt[_arrayPt.length-1].x, _arrayPt[_arrayPt.length-1].y );
    for ( int i=1; i<_arrayPt.length*_multiple-1; i++ ) {
      _retPoints[i] = new PointF(
        _arrayPt[0].x+i*(_arrayPt[_arrayPt.length-1].x-_arrayPt[0].x)/(_arrayPt.length*_multiple-1), 
        _arrayPt[0].y+i*(_arrayPt[_arrayPt.length-1].y-_arrayPt[0].y)/(_arrayPt.length*_multiple-1) );
    }
    return _retPoints;
  }
  
  PointF [] GetSplineSeries( float [] _t, PointF [] _arrayPt, int _multiple ){
    if ( _arrayPt.length == 2 ) {
      return GetInterXYSeries( _t, _arrayPt, _multiple );
    }
    
    PointF [] _retPoints;

    float [] _arrayX = new float [_arrayPt.length];
    float [] _arrayY = new float [_arrayPt.length];
    
    for ( int i=0; i<_arrayPt.length; i++ ) {
      _arrayX[i] = _arrayPt[i].x;
      _arrayY[i] = _arrayPt[i].y;
    }

    // multi倍の点を取る
    float [] _interX = GetSplineValues( _t, _arrayX, _multiple );
    float [] _interY = GetSplineValues( _t, _arrayY, _multiple );

    // Remove duplicate points
    int number = 1;
    int skipFrom = 1;
    for ( int i=1; i<_interX.length; i++ ) {
      if ( dist( (float)_interX[i], (float)_interY[i], (float)_interX[skipFrom], (float)_interY[skipFrom])<Config.g_fThresholdToRemove ) {
      } else if ( _interX[i] == -1 && _interY[i] == -1 ) {
      } else {
        skipFrom = i;
        number++;
      }
    }

    _retPoints = new PointF [number];  
    _retPoints[0] = new PointF( _interX[0], _interY[0] );

    number = 1;
    skipFrom = 1;
    for ( int i=1; i<_interX.length; i++ ) {
      if ( dist( (float)_interX[i], (float)_interY[i], (float)_interX[skipFrom], (float)_interY[skipFrom])<Config.g_fThresholdToRemove) {
      } else if ( _interX[i] == -1 && _interY[i] == -1 ) {
      } else {
        skipFrom = i;
        _retPoints[number] = new PointF( _interX[i], _interY[i] );
        number++;
      }
    }

    //println( "original array size = " + _interX.length );
    //println( "         array size = " + _retPoints.length );
    return _retPoints;
  }

  float [] GetSplineValues(float [] _t, float [] _value, int _multiple) {
    float [] retValue = new float [(_value.length-1) * _multiple+1];

    int n = _t.length -1;
    float h[] = new float [ n ];
    float b[] = new float [ n ];
    float d[] = new float [ n ];
    float g[] = new float [ n ];
    float u[] = new float [ n ];
    float r[] = new float [n+1];
    float q[] = new float [ n ];
    float s[] = new float [ n ];

    int i1 = 0;

    for (i1 = 0; i1 < n; i1++) {
      h[i1] = _t[i1+1] - _t[i1];
    }
    for (i1 = 1; i1 < n; i1++) {
      b[i1] = (float) (2.0 * (h[i1] + h[i1-1]));
      d[i1] = (float) (3.0 * ((_value[i1+1] - _value[i1]) / h[i1] - (_value[i1] - _value[i1-1]) / h[i1-1]));
    }
    g[1] = h[1] / b[1];
    for (i1 = 2; i1 < n-1; i1++) {
      g[i1] = h[i1] / (b[i1] - h[i1-1] * g[i1-1]);
    }
    u[1] = d[1] / b[1];
    for (i1 = 2; i1 < n; i1++) {
      u[i1] = (d[i1] - h[i1-1] * u[i1-1]) / (b[i1] - h[i1-1] * g[i1-1]);
    }

    r[0]    = 0.0;
    r[n]    = 0.0;
    r[n-1]  = u[n-1];
    for (i1 = n-2; i1 >= 1; i1--) {
      r[i1] = u[i1] - g[i1] * r[i1+1];
    }

    int num = 0;
    for (int i = 0; i < _value.length-1; i++) {
      float between = _t[i+1]-_t[i];
      float splineT = between/_multiple;
      for (float j = 0; j < _multiple; j++ ) {
        float sp = j * splineT;
        float qi = (float) ((_value[i+1] - _value[i]) / h[i] - h[i] * (r[i+1] + 2.0 * r[i]) / 3.0);
        float si = (float) ((r[i+1] - r[i]) / (3.0 * h[i]));
        float y1 = _value[i] + sp * (qi + sp * (r[i]  + si * sp));
        retValue[num] = y1;
        num++;
      }
    }
    retValue[retValue.length-1] = _value[_value.length-1];

    return retValue;
  }
}
