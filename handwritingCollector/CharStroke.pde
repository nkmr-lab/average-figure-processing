class CharStroke {
  ArrayList<Stroke> m_Strokes;  // :どういったストロークで構成されるか
  String m_sText;

  CharStroke(String _text) {
    m_Strokes = new ArrayList<Stroke>();
    m_sText = _text;
  }

  void saveStrokes(String _fileName ) {
    _fileName += ".json";
    JSONObject HandwritingJSON = new JSONObject();//吐き出すファイルそのもの
    JSONArray strokesJSON = new JSONArray(); //strokeの集まり配列をstrokesにする

    //_charstrokeクラスの情報をすべて引きずり出しjsonで保存する
    HandwritingJSON.setString("character", m_sText);//書かれている文字情報
    HandwritingJSON.setInt("strokeLength", m_Strokes.size());

    for (Stroke _stroke : m_Strokes) {//_m_Strokesに登録サれてる画数分回す
      JSONObject strokeJSON = new JSONObject();//1画分が入る

      /* ====================================== */
      // オリジナルの点列を保存する
      JSONArray points = savePoints(_stroke.points);
      strokeJSON.setJSONArray("points", points);
      /* ====================================== */

      /* ====================================== */
      // DFTの級数を保存する
      // dftを_stroke.m_Fourierに書き換え必要
      // JSONObject DFT = saveDFT(dft);
      // strokeJSON.setJSONObject("DFT", DFT);
      /* ====================================== */

      /* ====================================== */
      // splineの情報を保存する(環境依存のため)
      // JSONObject spline = new JSONObject();
      // spline.setInt("magnification", magnification);
      // spline.setInt("default_double_back_margin", default_double_back_margin);
      // strokeJSON.setJSONObject("spline", spline);
      /* ====================================== */

      // 追加していく
      strokesJSON.append(strokeJSON);
    }
    HandwritingJSON.setJSONArray("strokes", strokesJSON);
    saveJSONObject(HandwritingJSON, _fileName);
  }

  void displayStroke(PGraphics Canvas) {
    for ( int i=0; i<m_Strokes.size (); i++ ) {
      Stroke stroke = m_Strokes.get(i);
      stroke.displayStrokeOnCanvas(Canvas);
    }
  }
  
  void setStrokes(ArrayList<Stroke> _strokes){
   m_Strokes =  _strokes;
  }

  void addStroke(Stroke _stroke) {
    m_Strokes.add( _stroke );
  }
}
