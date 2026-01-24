class LanguageStrings {
  static const Map<String, String> english = {
    'hello': 'Hello',
    'welcome_to_bibi': 'Welcome to BIBI',
    'im_bibi': "I'm [b]Bibi[/b]",
    'assalam_o_alaikum': 'Assalam-o-Alaikum!',
    'breast_cancer': "Breast Cancer [b]Survivor[/b]",
    'smart_shopping_summaries': 'Smart Shopping Summaries',
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
    'breast_cancer': 'بریسٹ کینسر سے صحتیاب ہونے والی مریضہ',
    'smart_shopping_summaries': 'سمارٹ شاپنگ سمریز',
    'make_smarter_purchase_decisions': 'اپنی خریداری کو بہتر بنائیں',
    'life_is_too_short': 'زندگی بہت مختصر ہے برے انتخاب کے لیے',
    'choose_wisely': 'BIBI کے ساتھ صحیح انتخاب کریں',
    'skip': 'چھوڑ دیں',
    'next': 'آگے',
    'back': 'پیچھے',
    'get_started': 'شروع کریں',
  };

  static String getTranslation(String language, String key) {
    final isUrdu = language == 'اردو';
    final strings = isUrdu ? urdu : english;
    return strings[key] ?? key;
  }
}
