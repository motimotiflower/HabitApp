//星座の説明と画像データ
class ConstellationData {
  static const Map<String, String> descriptions = {
    'おひつじ座': '春の夜空に見つけられる黄道十二星座のひとつ。',
    'おうし座': '明るい星アルデバランを含む冬の星座。',
    'ふたご座': 'カストルとポルックスが並ぶ冬の星座。',
    'かに座': '春の夜空にある、淡い星々でできた星座。',
    'しし座': '春を代表する、獅子の姿を描く星座。',
    'おとめ座': '一等星スピカを持つ春の大きな星座。',
    'てんびん座': '天秤の形に結ばれる黄道十二星座。',
    'さそり座': '赤いアンタレスが輝く夏の代表的な星座。',
    'いて座': '天の川の濃い方向にある夏の星座。',
    'やぎ座': '夏から秋の夜空に見える黄道十二星座。',
    'みずがめ座': '秋の夜空に広がる大きな星座。',
    'うお座': '二匹の魚を結んだ姿で描かれる秋の星座。',
  };

  //生成画像の実際の並びに合わせて紐付ける
  static const Map<String, String> imagePaths = {
    'おひつじ座': 'assets/images/constellations2.png',
    'おうし座': 'assets/images/constellations3.png',
    'ふたご座': 'assets/images/constellations4.png',
    'かに座': 'assets/images/constellations5.png',
    'しし座': 'assets/images/constellations6.png',
    'おとめ座': 'assets/images/constellations7.png',
    'てんびん座': 'assets/images/constellations8.png',
    'さそり座': 'assets/images/constellations9.png',
    'いて座': 'assets/images/constellations10.png',
    'やぎ座': 'assets/images/constellations11.png',
    'みずがめ座': 'assets/images/constellations12.png',
    'うお座': 'assets/images/constellations1.png',
  };

  static String description(String name) {
    return descriptions[name] ?? '夜空に輝く星座です。';
  }

  static String imagePath(String name) {
    return imagePaths[name] ?? 'assets/images/constellations.png';
  }
}
