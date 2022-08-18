// implemented by matasuna
void saveHandwiting(String _filename, ArrayList<Stroke> _m_Strokes, String _character) {

  _filename+=".json";
  JSONObject HandwritingJSON;//保存する情報そのもの
  JSONArray strokesJSON;//複数画の情報を保存

  /*環境依存の変数*/
  int magnification;
  int default_double_back_margin;

  /*環境依存の変数*/
  magnification = 200;
  default_double_back_margin = 16;

  strokesJSON = new JSONArray();//strokeの集まり配列をstrokesにする
  HandwritingJSON = new JSONObject();//吐き出すファイル

  //_charstrokeクラスの情報をすべて引きずり出しjsonで保存する
  HandwritingJSON.setString("character", _character);//書かれている文字情報
  HandwritingJSON.setInt("strokeLength", _m_Strokes.size());

  for (Stroke _stroke : _m_Strokes) {//_m_Strokesに登録サれてる画数分回す
    JSONObject strokeJSON = new JSONObject();//1画分が入る

    /***********/
    //オリジナルpointを保存する
    //origpointを_stroke.m_orgPtに書き換え必要
    if ( _stroke.m_orgPt != null ) {
      JSONArray points = savePoints(_stroke.m_orgPt);
      strokeJSON.setJSONArray("points", points);
    }
    /***********/

    /***********/
    //DFTの級数を保存する
    //dftを_stroke.m_Fourierに書き換え必要
    Fourier dft = _stroke.m_Fourier;
    JSONObject DFT = saveDFT(dft);
    strokeJSON.setJSONObject("DFT", DFT);
    /***********/

    //splineの情報を保存する(環境依存のため)
    JSONObject spline = new JSONObject();
    spline.setInt("magnification", magnification);
    spline.setInt("default_double_back_margin", default_double_back_margin);
    strokeJSON.setJSONObject("spline", spline);

    //1画を確定して保存
    strokesJSON.append(strokeJSON);
  }
  HandwritingJSON.setJSONArray("strokes", strokesJSON);
  saveJSONObject(HandwritingJSON, _filename);
}

JSONArray savePoints(PointF[] _points) {
  JSONArray points = new JSONArray();
  if ( _points == null) return  points;
  for (PointF _point : _points) {
    JSONObject point = new JSONObject();
    point.setFloat("x", _point.x);
    point.setFloat("y", _point.y);
    points.append(point);
  }
  return points;
}

JSONObject saveDFT(Fourier _dft) {

  /*********************/
  //_dftからの情報に書き換えてください
  float[] _reX = _dft.m_aX;
  float[] _reY = _dft.m_aY;
  float[] _imX = _dft.m_bX;
  float[] _imY = _dft.m_bY;
  float _strokeLength = 0.0;
  int _maxDegree = 0;
  int _splineSize = 0;
  float _thresholdOfCoefficient = 0.0;
  float aX = 1.0;//1点だった場合の中心
  float aY = 1.0;
  /*********************/

  JSONObject _DFT = new JSONObject();

  JSONArray reX = ArrayToDFT(_reX);
  JSONArray reY = ArrayToDFT(_reY);
  JSONArray imX = ArrayToDFT(_imX);
  JSONArray imY = ArrayToDFT(_imY);

  _DFT.setJSONArray("reX", reX);
  _DFT.setJSONArray("reY", reY);
  _DFT.setJSONArray("imX", imX);
  _DFT.setJSONArray("imY", imY);
  _DFT.setFloat("aX", aX);
  _DFT.setFloat("aY", aY);
  _DFT.setFloat("strokeLength", _strokeLength);
  _DFT.setInt("maxDegree", _maxDegree);
  _DFT.setInt("splineSize", _splineSize);
  _DFT.setFloat("thresholdOfCoefficient", _thresholdOfCoefficient);
  return _DFT;
}

JSONArray ArrayToDFT(float[] coefficient) {
  //DFTの級数の配列をjsonへ
  JSONArray _DFT= new JSONArray();
  for (float i : coefficient) {
    _DFT.append(i);
  }
  return _DFT;
}
