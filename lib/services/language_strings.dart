class LanguageStrings {
  static const Map<String, String> english = {
    'hello': 'Hello',
    'im_bibi': "I'm [b]Bibi[/b]",
    'assalam_o_alaikum': 'Assalam-o-Alaikum!',
    'breast_cancer': "Breast Cancer [b]Survivor[/b]",
    'life': 'life is too beautiful to take chances',
    'make_smarter_purchase_decisions': 'Make smarter purchase decisions',
    'life_is_too_short': 'Life is too short for bad choices',
    'choose_wisely': 'Choose wisely with BIBI',
    'skip': 'Skip',
    'next': 'Next',
    'back': 'Back',
    'get_started': 'Get Started',
  };

  static const Map<String, String> urdu = {
    'hello': 'اسلام علیکم',
    'im_bibi': 'میں [b]بِبی[/b] ہوں',
    'assalam_o_alaikum': 'السلام علیکم!',
    'breast_cancer': "[b]بریسٹ کینسر[/b]\nسے [b]صحتیاب[/b]\nہونے والی مریضہ",
    'life' :  '[b]زندگی[/b] [b]اتنی[/b]\n[b]خوبصورت[/b] [b]ہے[/b]\nکہ اسے خطرے میں\nنہیں ڈالا جا سکتا',
    'make_smarter_purchase_decisions': 'اپنی خریداری کو بہتر بنائیں',
    'life_is_too_short': '[b]زندگی[/b] [b]اتنی[/b]\n[b]خوبصورت[/b] [b]ہے[/b]\nکہ اسے خطرے میں\nنہیں ڈالا جا سکتا',
    'choose_wisely': 'BIBI کے ساتھ صحیح انتخاب کریں',
    'skip': 'چھوڑ دیں',
    'next': 'آگے',
    'back': 'پیچھے',
    'get_started': 'شروع کریں',
  };

  static const Map<String, String> RomanUrdu = {
    'im_bibi': "Main [b]BIBI[/b]  hoon",
    'assalam_o_alaikum': 'Assalam-o-Alaikum!',
    'breast_cancer': "[b]Breast cancer[/b] se [b]sehatyab[/b] hone wali mariza",
    'life': '[b]Zindagi itni\n khoobsurat hai[/b]\n ke isay khatray mein \n nahi daala ja sakta',
  };

static String getTranslation(String language, String key) {
    if (language == 'Roman Urdu') {
      return RomanUrdu[key] ?? key;
    }

    if (language == 'اردو') {
      return urdu[key] ?? key;
    }

    return english[key] ?? key;
  }
}