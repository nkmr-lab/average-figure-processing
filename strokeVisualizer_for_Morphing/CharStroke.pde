class CharStroke {
  ArrayList<Stroke> m_Strokes;  // :どういったストロークで構成されるか
  int m_iIndex;                 // :識別ID
  String m_sText;               // :なんて文字か
  String m_sHand;               // :どっちの手によるものか(利き手/非利き手)
  int m_iCount;                 // :1~5回目のうち何回目に書いたか
  int m_iNumOfStroke;           // :画数
  float m_iWidth;                 // :縦幅
  float m_iHeight;                // :横幅
  PointF m_CenterPt;            // :中心点座標

  String path;                  // :ファイルパス

  CharStroke() {
    m_Strokes = new ArrayList<Stroke>();
  }

  CharStroke(int id, String _text, String _hand, int _count, int _numOfStroke ) {
    m_Strokes = new ArrayList<Stroke>();
    m_iIndex = id;
    m_sText = _text;
    m_sHand = _hand;
    m_iCount = _count;
    m_iNumOfStroke = _numOfStroke;
    m_iWidth = 0.0;
    m_iHeight = 0.0;
    m_CenterPt = new PointF( 0.0, 0.0 );
    path = null;
  }

  // JSON形式でストローク情報を保存する
  void saveStrokes( String _fileName ) {
    JSONObject HandwritingJSON = new JSONObject();//吐き出すファイルそのもの
    JSONArray strokesJSON = new JSONArray(); //strokeの集まり配列をstrokesにする

    //_charstrokeクラスの情報をすべて引きずり出しjsonで保存する
    HandwritingJSON.setString("character", m_sText);//書かれている文字情報
    HandwritingJSON.setInt("strokeLength", m_Strokes.size());

    for (Stroke _stroke : m_Strokes) {//_m_Strokesに登録サれてる画数分回す
      JSONObject strokeJSON = new JSONObject();//1画分が入る

      /* ====================================== */
      // オリジナルの点列を保存する
      
      JSONArray points;
      if(_stroke.m_orgPt != null && _stroke.m_orgPt.length > 0)
        points = savePoints(_stroke.m_orgPt);
      else 
        points = savePoints(_stroke.m_FourierSeriesPt);
      strokeJSON.setJSONArray("points", points);

      /* ====================================== */

      /* ====================================== */
      // DFTの級数を保存する
      Fourier dft = _stroke.m_Fourier;
      JSONObject DFT = saveDFT(dft);
      strokeJSON.setJSONObject("DFT", DFT);
      /* ====================================== */

      /* ====================================== */
      // splineの情報を保存する(環境依存のため)
      JSONObject spline = new JSONObject();
      spline.setInt("magnification", Config.magnification);
      spline.setInt("default_double_back_margin", Config.default_double_back_margin);
      strokeJSON.setJSONObject("spline", spline);
      /* ====================================== */

      // 追加していく
      strokesJSON.append(strokeJSON);
    }
    HandwritingJSON.setJSONArray("strokes", strokesJSON);
    saveJSONObject(HandwritingJSON, _fileName);
  }

  boolean loadStrokesFromJSON( String _fileName ) {
    //_fileName += ".json";
    path = _fileName;
    m_Strokes = new ArrayList<Stroke>(); // 一応初期化する
    JSONObject jsonload = loadJSONObject( _fileName );
    if(jsonload == null) return false;
    m_sText = jsonload.getString("character");
    m_iNumOfStroke = jsonload.getInt("strokeLength");
    if(g_iNumOfStroke == 0){
      g_iNumOfStroke = m_iNumOfStroke;
    } else if(m_iNumOfStroke != g_iNumOfStroke){
      println("not match (# of stroke): ", m_iNumOfStroke, g_iNumOfStroke);
      return false;
    }
         
    JSONArray _strokes = jsonload.getJSONArray("strokes");
    for (int i = 0; i< _strokes.size (); i++) {
      JSONObject _stroke = _strokes.getJSONObject(i);
      JSONArray jsonPoints = _stroke.getJSONArray("points");
      PointF [] points = jsonToPointF(jsonPoints);//pointFの配列を作成
      if(points.length == 1){
        println("error: dot");
        return false;
      }
      Stroke stroke = new Stroke(points);//strokeを作成
      stroke.doSpline( Config.g_iMultiple );
      m_Strokes.add(stroke);
    }
    resizeStrokes(Config.leftTopX, Config.leftTopY, Config.rightBottomX, Config.rightBottomY);  

    for (int i=0; i<m_Strokes.size(); i++) {
      m_Strokes.get(i).doFourier();
    }

    // Fourierしてあるかを確認
    /*
      if ( _stroke.isNull("DFT") == false ) {
     println("~~~~~~~~~~");
     JSONObject jsonDFT = _stroke.getJSONObject("DFT");
     //Fourier _m_Fourier = jsonToFourier(jsonDFT);
     //stroke.m_Fourier = _m_Fourier;//DFTをstrokeに追加
     JSONObject spline = _stroke.getJSONObject("spline");
     Config.magnification = spline.getInt("magnification");
     Config.default_double_back_margin = spline.getInt("default_double_back_margin");
     } else {
     // してなかった場合Fourierしてあげる
     stroke.doSpline( Config.g_iMultiple );
     stroke.doFourier();
     }
     m_Strokes.add(stroke);
     */
     return true;
  }

  void resizeStrokes(int x1, int y1, int x2, int y2) {
    float minX = m_Strokes.get(0).getMinX();
    float minY = m_Strokes.get(0).getMinY();
    float maxX = m_Strokes.get(0).getMaxX();
    float maxY = m_Strokes.get(0).getMaxY();

    for (int i=1; i<m_Strokes.size(); i++) {
      if (minX > m_Strokes.get(i).getMinX()) minX = m_Strokes.get(i).getMinX(); 
      if (minY > m_Strokes.get(i).getMinY()) minY = m_Strokes.get(i).getMinY(); 
      if (maxX < m_Strokes.get(i).getMaxX()) maxX = m_Strokes.get(i).getMaxX(); 
      if (maxY < m_Strokes.get(i).getMaxY()) maxY = m_Strokes.get(i).getMaxY();
    }

    float centerX = (maxX + minX) / 2;
    float centerY = (maxY + minY) / 2;
    float squareLength;
    if (maxX - minX > maxY - minY) { // 横が長い時は縦を差し替え
      squareLength = maxX - minX;
      minY = centerY - squareLength / 2;
      maxY = centerY + squareLength / 2;
    } else {
      squareLength = maxY - minY;
      minX = centerX - squareLength / 2;
      maxX = centerX + squareLength / 2;
    }

    for (int i=0; i<m_Strokes.size(); i++) {
      for (int j=0; j<m_Strokes.get(i).m_orgPt.length; j++) {
        m_Strokes.get(i).m_orgPt[j].x = (m_Strokes.get(i).m_orgPt[j].x - minX) * (x2 - x1) / squareLength + x1;
        m_Strokes.get(i).m_orgPt[j].y = (m_Strokes.get(i).m_orgPt[j].y - minY) * (y2 - y1) / squareLength + y1;
      }
    }

    for (int i=0; i<m_Strokes.size(); i++) {
      for (int j=0; j<m_Strokes.get(i).m_SplinePt.length; j++) {
        m_Strokes.get(i).m_SplinePt[j].x = (m_Strokes.get(i).m_SplinePt[j].x - minX) * (x2 - x1) / squareLength + x1;
        m_Strokes.get(i).m_SplinePt[j].y = (m_Strokes.get(i).m_SplinePt[j].y - minY) * (y2 - y1) / squareLength + y1;
      }
    }
  }

  void loadStrokes( String _strFileName ) {
    String [] lines = loadStrings( _strFileName );
    PointF [] mouseStroke = null;

    for (int i=1; i<lines.length-1; i++) {
      String line=lines[i].substring(2, lines[i].length()-3);
      // println(i+"画目:"+line);
      // println(" ");
      String list[]=split(line, "},{");
      for (int j=0; j<list.length-1; j++) {
        // println(list[j]);
        String position[]=split(list[j], ",");
        // println("X:"+position[0]);
        //  println("Y:"+position[1]);
        int x=int(position[0]);
        int y=int(position[1]);
        if (j==0) {
          mouseStroke = new PointF [1];
          mouseStroke[0] = new PointF( x, y );
        } else {
          mouseStroke = (PointF[])append( mouseStroke, new PointF( x, y ) );
        }
      }
      Stroke st = new Stroke( mouseStroke );
      // strokeを追加
      AddStroke( st );
      //println();
    }
  }

  void loadStrokes( String _strFileName, int _marginX, int _marginY ) {
    String [] lines = loadStrings( _strFileName );
    PointF [] mouseStroke = null;

    for (int i=1; i<lines.length-1; i++) {
      String line=lines[i].substring(2, lines[i].length()-3);
      // println(i+"画目:"+line);
      // println(" ");
      String list[]=split(line, "},{");
      for (int j=0; j<list.length-1; j++) {
        // println(list[j]);
        String position[]=split(list[j], ",");
        // println("X:"+position[0]);
        //  println("Y:"+position[1]);
        int x=int(position[0]);
        int y=int(position[1]);
        if (j==0) {
          mouseStroke = new PointF [1];
          mouseStroke[0] = new PointF( x - _marginX, y - _marginY );
        } else {
          mouseStroke = (PointF[])append( mouseStroke, new PointF( x - _marginX, y - _marginY) );
        }
      }
      Stroke st = new Stroke( mouseStroke );
      // strokeを追加
      AddStroke( st );
      //println();
    }
  }

  void setColor( color _col ) {
    for ( int i=0; i<m_Strokes.size (); i++ ) {
      Stroke stroke = m_Strokes.get(i);
      stroke.setColor( _col);
    }
  }

  void getWHC() {
    //縦横中心の値を取得するための関数

    // スプラインした点列から取得する
    for ( int i=0; i<m_Strokes.size (); i++ ) {
      Stroke stroke = m_Strokes.get(i);
      float minX = Config.g_defaultCharSize;
      float minY =  Config.g_defaultCharSize;
      float maxX = 0;
      float maxY = 0;
      for ( int j=0; j<stroke.m_SplinePt.length; j++ ) {
      }
    }
  }

  void setFourierSeriesPt() {
    for ( int i=0; i<m_Strokes.size (); i++ ) {
      Stroke stroke = m_Strokes.get(i);
      stroke.setFourierSeriesPt();
    }
  }

  void doSpline( int _iMultiple ) {
    for ( int i=0; i<m_Strokes.size (); i++ ) {
      Stroke stroke = m_Strokes.get(i);
      stroke.doSpline( _iMultiple );
    }
  }

  void GenerateEquationWithSpline( int _iMultiple ) {
    for ( int i=0; i<m_Strokes.size (); i++ ) {
      Stroke stroke = m_Strokes.get(i);
      if ( stroke.m_bFourier == false ) {
        // スプライン補間する
        stroke.doSpline( _iMultiple );
        // フーリエ級数展開する
        stroke.doFourier( );
      }
    }
  }

  void displayStroke() {
    for ( int i=0; i<m_Strokes.size (); i++ ) {
      Stroke stroke = m_Strokes.get(i);
      stroke.displayStroke();
    }
  }

  void displaySplinedStroke() {
    for ( int i=0; i<m_Strokes.size (); i++ ) {
      Stroke stroke = m_Strokes.get(i);
      stroke.displaySplinedStroke();
    }
  }

  void displayStrokeOnCanvas(PGraphics _Canvas) {
    for (  int i=0; i<m_Strokes.size (); i++  ) {
      Stroke stroke = m_Strokes.get(i);
      stroke.displayStrokeOnCanvas(_Canvas);
    }
  }

  void displayStrokeByFourier(int _iMultiple) {
    GenerateEquationWithSpline( _iMultiple );
    for ( int i=0; i<m_Strokes.size (); i++ ) {
      Stroke stroke = m_Strokes.get(i);
      stroke.displayStrokeByFourier();
    }
  }

  void displayStrokeByFourierOnCanvas(int _iMultiple, PGraphics _Canvas, color _col) {
    GenerateEquationWithSpline( _iMultiple );
    for ( int i=0; i<m_Strokes.size (); i++ ) {
      Stroke stroke = m_Strokes.get(i);
      stroke.displayStrokeByFourierOnCanvas( _Canvas, _col);
    }
  }

  void displayResizeStrokeByFourierOnCanvas(int _iMultiple, PGraphics _Canvas, float _value) {
    GenerateEquationWithSpline( _iMultiple );
    for ( int i=0; i<m_Strokes.size (); i++ ) {
      Stroke stroke = m_Strokes.get(i);
      stroke.displayResizeStrokeByFourierOnCanvas( _Canvas, _value );
    }
  }

  void AddStroke( Stroke _stroke ) {
    m_Strokes.add( _stroke );
  }
}

//*copy*
CharStroke getAverageCharStroke( ArrayList<CharStroke> _listCharStrokes, int _targetNumOfCharStrokes ) {
  CharStroke avgCharStroke = new CharStroke();
  int iTargetNumOfCharStrokes;
  if( _targetNumOfCharStrokes > 0 ){
    iTargetNumOfCharStrokes = _targetNumOfCharStrokes;
  } else {
    iTargetNumOfCharStrokes = _listCharStrokes.size();
  }
  
  if ( iTargetNumOfCharStrokes > 0 ) {
    CharStroke objCharStroke = _listCharStrokes.get(0);
    int iNumOfStroke = objCharStroke.m_Strokes.size();

    for ( int j=0; j<iNumOfStroke; j++ ) {
      int iTotalPoints = 0;
      for ( int i=0; i<iTargetNumOfCharStrokes; i++ ) {
        CharStroke charstroke = _listCharStrokes.get(i);
        Stroke st = charstroke.m_Strokes.get(j);
        iTotalPoints += st.m_SplinePt.length;
      }
      Stroke avgStroke = new Stroke(iTotalPoints/iTargetNumOfCharStrokes);

      for ( int k=0; k<=Config.g_iMaxDegreeOfFourier; k++ ) {
        avgStroke.m_Fourier.m_aX[k] = 0;
        avgStroke.m_Fourier.m_bX[k] = 0;
        avgStroke.m_Fourier.m_aY[k] = 0;
        avgStroke.m_Fourier.m_bY[k] = 0;

        for ( int i=0; i<iTargetNumOfCharStrokes; i++ ) {
          CharStroke charstroke = _listCharStrokes.get(i);
          Stroke st = charstroke.m_Strokes.get(j);
          avgStroke.m_Fourier.m_aX[k] += st.m_Fourier.m_aX[k];
          avgStroke.m_Fourier.m_aY[k] += st.m_Fourier.m_aY[k];
          avgStroke.m_Fourier.m_bX[k] += st.m_Fourier.m_bX[k];
          avgStroke.m_Fourier.m_bY[k] += st.m_Fourier.m_bY[k];
        }
        avgStroke.m_Fourier.m_aX[k] /= iTargetNumOfCharStrokes;
        avgStroke.m_Fourier.m_aY[k] /= iTargetNumOfCharStrokes;
        avgStroke.m_Fourier.m_bX[k] /= iTargetNumOfCharStrokes;
        avgStroke.m_Fourier.m_bY[k] /= iTargetNumOfCharStrokes;
      }
      avgStroke.m_bFourier = true;
      avgCharStroke.AddStroke( avgStroke );
    }
  }
  //avgCharStroke.GenerateEquationWithSpline( g_iMultiple );
  avgCharStroke.setFourierSeriesPt();
  return avgCharStroke;
}

CharStroke createCharStrokeFromJSON(String _url) {
  if (new File( _url ).exists()) {
    CharStroke createdStroke = new CharStroke();
    if(createdStroke.loadStrokesFromJSON(_url) == false) return null;
    println(_url);
    return createdStroke;
  } else {
    println(_url + " is not exist");
    return null;
  }
}
