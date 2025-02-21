
/*import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService
{
  static String? get bannerAdUnit{
    if (Platform.isAndroid)
      {
        return 'ca-app-pub-7872400733478168~5760302954';
      }
    else if(Platform.isIOS)
      {
        return 'ca-app-pub-7872400733478168~6158962042';
      }
    return null;
  }
  static String? get interstitialAdUnit{
    if (Platform.isAndroid)
    {
      return 'ca-app-pub-7872400733478168~5760302954';
    }
    else if(Platform.isIOS)
    {
      return 'ca-app-pub-7872400733478168~6158962042';
    }
    return null;
  }
  static final BannerAdListener bannerListener= BannerAdListener(
    onAdLoaded: (ad)=>debugPrint("Ad loaded"),
    onAdFailedToLoad: (ad, error){
      ad.dispose();
      debugPrint('Ad failed to load : $error');
  },
    onAdOpened: (ad)=>debugPrint("Ad opened"),
    onAdClosed: (ad)=>debugPrint("Ad closed"),
  );
}*/