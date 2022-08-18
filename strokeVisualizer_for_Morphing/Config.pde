static class Config {
  /*環境依存の変数*/
  static int magnification = 200;
  static int default_double_back_margin = 16;

  static final int g_defaultCharSize = 1000;

  // config =======================================
  // フーリエの最大次数（次数を高くし過ぎると色々問題が有るため）
  static int g_iMaxDegreeOfFourier = 100;
  // 法線ベクトルを表示するかどうか（現在そもそも削除）
  static boolean g_bShowNormalVector = false;
  // フーリエ級数展開の係数カットの閾値
  static float g_fThresholdOfCoefficient = 0.001;
  // フルスクリーンにするかどうかのフラグ
  static boolean g_bFullScreen = false;
  // スプライン補間した後の近接点の除去に利用
  static double g_fThresholdToRemove = 0.05;
  //スプライン補間の倍数
  static int g_iMultiple = 200;
  // ==============================================
  
  static int canvasWidth = 700;
  static int canvasHeight = 700;

  static int leftTopX = 100;
  static int leftTopY = 100;
  static int rightBottomX = 3500;
  static int rightBottomY = 3500;
//  static int rightBottomX = 2300;
//  static int rightBottomY = 2300;
}
