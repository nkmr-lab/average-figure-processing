
int getNow() {
  int time =(hour()*60+minute())*60+second(); 
  return time;
}

PointF [] DoubleBack( PointF [] _points ) {
  PointF [] _retPoints = new PointF [_points.length*2-1];
  for ( int i=0; i<_points.length; i++ ) {
    _retPoints[i] = new PointF( _points[i].x, _points[i].y );
    _retPoints[_retPoints.length-i-1] = new PointF( _points[i].x, _points[i].y );
  }
  return _retPoints;
}

// 重複しないような長さ_nの_min~_maxの値を持つ配列を返す
int [] getRandomArray(int _min, int _max, int _n) {
  int [] _rndArray = new int [_n];
  IntList _rndIntList = new IntList(_max-_min);

  if ( _min > _max ) {
    println( "getRandomArray Function Error: _min > _max!");
    return null;
  }

  for ( int i=_min; i<_max; i++ ) {
    _rndIntList.append(i);
  }

  _rndIntList.shuffle();
  IntList _tmpIntList = new IntList( _n );
  for ( int i=0; i<_n; i++) {
    _tmpIntList.append( _rndIntList.get(i) );
  }

  _tmpIntList.sort();
  _rndArray = _tmpIntList.array();

  return _rndArray;
}

void saveArrayIntList(String _fileName, ArrayList<int[]> _arrayIntList ) {
  String [] _lines = new String[_arrayIntList.size()];
  for (int i=0; i<_arrayIntList.size (); i++) {
    int [] _array = _arrayIntList.get(i);
    _lines[i] = "";
    for ( int j=0; j<_array.length; j++ ) {
      _lines[i] += _array[j];
      if ( j<_array.length-1 ) {
        _lines[i] += ",";
      }
    }
  }
  saveStrings( _fileName, _lines);
}

PointF [] jsonToPointF(JSONArray _jsonPoints) {
  ArrayList<PointF> _pointFs = new ArrayList<PointF>();
  for (int i = 0; i<_jsonPoints.size (); i++) {
    JSONObject jsonPoint = _jsonPoints.getJSONObject(i);
    PointF _point = new PointF(jsonPoint.getFloat("x")-50, jsonPoint.getFloat("y")-50);
    _pointFs.add(_point);
  }
  PointF[] _points=(PointF[])_pointFs.toArray(new PointF[0]);
  return _points;
}

Fourier jsonToFourier(JSONObject _dft) {
  float[] reX = jsonToDFTArray(_dft.getJSONArray("reX"));
  float[] reY = jsonToDFTArray(_dft.getJSONArray("reY"));
  float[] imX = jsonToDFTArray(_dft.getJSONArray("imX"));
  float[] imY = jsonToDFTArray(_dft.getJSONArray("imY"));

  /************/
  //各種設定ファイル
  float _strokeLength = _dft.getFloat("strokeLenfgth");
  int _maxDegree = _dft.getInt("maxDegree");
  int _splineSize = _dft.getInt("splineSize");
  float _thresholdOfCoefficient = _dft.getFloat("thresholdOfCoefficient");
  /************/
  return new Fourier(reX, imX, reY, imY);
}
float[] jsonToDFTArray(JSONArray _jsondft) {
  float [] _coefficient = new float[_jsondft.size()];
  for (int i=0; i<_jsondft.size (); i++) {
    _coefficient[i] = _jsondft.getFloat(i);
  }
  return _coefficient;
}

String array2string( int [] _array ) {
  String _line = "";
  for ( int i=0; i<_array.length; i++ ) {
    _line += (_array[i]+1);
    if ( i<_array.length-1 ) {
      _line += "-";
    }
  }
  return _line;
}

void println( int [] _array ) {
  print("[");
  for ( int i=0; i<_array.length; i++ ) {
    print(_array[i]);
    if ( i < _array.length -1 ) {
      print(",");
    }
  }
  println("]");
}

void println( PointF[] _arrayPt ) {
  for ( int i=0; i<_arrayPt.length; i++ ) {
    _arrayPt[i].show();
  }
}

float getDistanceStroke(Stroke st1, Stroke st2) {
  // 数式にしたものを 0 -> PI でdistをとって比較する

  // Fourierしてなかったらする
  if ( st1.m_bFourier == false ) {
    st1.doSpline(Config.g_iMultiple);
    st1.doFourier();
  }
  if ( st2.m_bFourier == false ) {
    st2.doSpline(Config.g_iMultiple);
    st2.doFourier();
  }

  // 取るてんの数は決め打ちで10000点にした（なるべく多く取った方が距離を求める時に都合がいいから)
  st1.m_FourierSeriesPtFromZeroToPI = st1.m_Fourier.GetFourierSeriesFromZeroToPI(  st1.m_iAppropriateDegreeOfFourier, 10000, Config.g_fThresholdOfCoefficient );
  st2.m_FourierSeriesPtFromZeroToPI = st2.m_Fourier.GetFourierSeriesFromZeroToPI(  st2.m_iAppropriateDegreeOfFourier, 10000, Config.g_fThresholdOfCoefficient );

  float sumDist = 0.0;
  float st1_length = 0.0;
  float st2_length = 0.0;
  int splitN = 100;

  PointF [] st1_points = new PointF [0];
  PointF [] st2_points = new PointF [0];


  for (int num = 0; num < st1.m_FourierSeriesPtFromZeroToPI.length/2-1; num++) {
    st1_length += dist(st1.m_FourierSeriesPtFromZeroToPI[num].x, st1.m_FourierSeriesPtFromZeroToPI[num].y, st1.m_FourierSeriesPtFromZeroToPI[num+1].x, st1.m_FourierSeriesPtFromZeroToPI[num+1].y );
  }

  for (int num = 0; num < st2.m_FourierSeriesPtFromZeroToPI.length/2-1; num++) {
    st2_length += dist(st2.m_FourierSeriesPtFromZeroToPI[num].x, st2.m_FourierSeriesPtFromZeroToPI[num].y, st2.m_FourierSeriesPtFromZeroToPI[num+1].x, st2.m_FourierSeriesPtFromZeroToPI[num+1].y );
  }

  // 1セグメントあたりの距離
  float st1_splitLen = st1_length/splitN;
  float st2_splitLen = st2_length/splitN;
  float sum_dist = 0;
  for ( int i = 0; i < splitN; i++ ) {
    int j = 0;
    sum_dist = 0;
    while ( sum_dist < st1_splitLen*i ) {
      sum_dist += dist(st1.m_FourierSeriesPtFromZeroToPI[j].x, st1.m_FourierSeriesPtFromZeroToPI[j].y, st1.m_FourierSeriesPtFromZeroToPI[j+1].x, st1.m_FourierSeriesPtFromZeroToPI[j+1].y);
      j++;
    }
    st1_points = (PointF[])append( st1_points, new PointF(st1.m_FourierSeriesPtFromZeroToPI[j].x, st1.m_FourierSeriesPtFromZeroToPI[j].y) );
  }

  for ( int i = 0; i < splitN; i++ ) {
    int j = 0;
    sum_dist = 0;
    while ( sum_dist < st2_splitLen*i ) {
      sum_dist += dist(st2.m_FourierSeriesPtFromZeroToPI[j].x, st2.m_FourierSeriesPtFromZeroToPI[j].y, st2.m_FourierSeriesPtFromZeroToPI[j+1].x, st2.m_FourierSeriesPtFromZeroToPI[j+1].y);
      j++;
    }
    st2_points = (PointF[])append( st2_points, new PointF(st2.m_FourierSeriesPtFromZeroToPI[j].x, st2.m_FourierSeriesPtFromZeroToPI[j].y) );
  }

  //終点も追加する
  st1_points = (PointF[])append( st1_points, new PointF(st1.m_FourierSeriesPtFromZeroToPI[st1.m_FourierSeriesPtFromZeroToPI.length/2-1].x, st1.m_FourierSeriesPtFromZeroToPI[st1.m_FourierSeriesPtFromZeroToPI.length/2-1].y)); 
  st2_points = (PointF[])append( st2_points, new PointF(st2.m_FourierSeriesPtFromZeroToPI[st2.m_FourierSeriesPtFromZeroToPI.length/2-1].x, st2.m_FourierSeriesPtFromZeroToPI[st2.m_FourierSeriesPtFromZeroToPI.length/2-1].y));

  // 特徴点の差を比較する
  for (int num = 0; num < splitN+1; num++) {
    strokeWeight(1);
    stroke(0, 0, 255);
    line(st1_points[num].x, st1_points[num].y, st2_points[num].x, st2_points[num].y);
    sumDist += dist(st1_points[num].x, st1_points[num].y, st2_points[num].x, st2_points[num].y);
  }

  return sumDist/splitN;
}

float getDistanceCharStroke(CharStroke charSt1, CharStroke charSt2) {
  float sumDist = 0.0;
  if ( charSt1.m_Strokes.size() != charSt2.m_Strokes.size() ) return 0.0;
  for ( int i=0; i< charSt1.m_Strokes.size (); i++ ) {
    Stroke st1 = charSt1.m_Strokes.get(i);
    Stroke st2 = charSt2.m_Strokes.get(i);
    sumDist += getDistanceStroke(st1, st2);
  }
  return sumDist/charSt1.m_Strokes.size();
}

// ====== 順列を考える関数 ==========
int [][] perm(int n, int r) {
  if ( n < r ) return null;
  println("perm:", n, r) ;
  int i, c=1; 
  for (i=n-r+1; i<=n; i++) c*=i;
  int[] z=new int[n];
  int[][] p=new int[c][r];
  for (i=0; i<n; i++) {
    z[i]=i+1; 
    if (i<r) p[0][i]=i+1;
  }
  for (i=1; i<c; i++) {
    nxpm(z, n, r); 
    for (int j=0; j<r; j++) {
      p[i][j]=z[j];
    }
  }

  return p;
}

void nxpm(int[] z, int n, int r) {
  int i, t, k;
  for (i=r-1; i>=0; i--) if (i<n-1) {
    t=z[i];
    for (k=i+1; k<n; k++) if (z[i]<z[k])break;
    if (k<n) {
      z[i]=z[k]; 
      z[k]=t; 
      return;
    } else {
      for (k=i; k<n-1; k++) {
        z[k]=z[k+1];
      } 
      z[k]=t;
    }
  }
  return;
}

String arrayInt2String(int[] _array, String _joinChar ){
  String str = "";
  for(int i=0; i<_array.length; i++){
    str += _array[i];
    if( i < _array.length-1){
      str += _joinChar;
    }
  }
  return str;
}
