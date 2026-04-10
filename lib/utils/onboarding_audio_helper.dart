import 'package:bibi/pages/audio_player_page.dart';

/// Maps each onboarding page to its corresponding audio content
class OnboardingAudioHelper {
  static const Map<String, List<double>> lyricTimestamps = {
    'assets/audio/whatisbreastcancer.m4a': [
      0,    // line 1
      4,    // line 2
      6,    // line 3
      9,    // line 4
      11,   // line 5
      15,   // line 6
      17,   // line 7
    ],
    'assets/audio/whatisbreastcancer_urdu.m4a': [
      0,
      4,
      6,
      9,
    ],
    'assets/audio/risk.m4a': [
      0,    // line 1
      4,    // line 2
      8,    // line 3
      12,   // line 4
    ],
    'assets/audio/risk_urdu.m4a': [
      0,
      4,
      8,
      12,
    ],
    'assets/audio/screen.m4a': [
      0,
      5,
      8,
      12,
      16,
      20,
    ],
    'assets/audio/screen_urdu.m4a': [
      0,
      5,
      8,
      12,
    ],
    'assets/audio/treat.m4a': [
      0,
      7,
      12,
      18,
    ],
    'assets/audio/treat_urdu.m4a': [
      0,
      7,
      12,
      18,
    ],
    'assets/audio/biopsy.m4a': [
      0,
      5,
      9,
      13,
    ],
    'assets/audio/biopsy_urdu.m4a': [
      0,
      4,
      8,
      12,
    ],
    'assets/audio/prevent.m4a': [
      0,
      5,
      9,
      13,
    ],
    'assets/audio/prevent_urdu.m4a': [
      0,
      4,
      8,
      12,
    ],
    'assets/audio/support.m4a': [
      0,
      6,
      12,
      16,
    ],
    'assets/audio/support_urdu.m4a': [
      0,
      4,
      8,
      12,
    ],
  };

  static AudioContent? getAudioContentForPage(int pageNumber) {
    switch (pageNumber) {
      case 2: // Page 3 - What is Breast Cancer
        return AudioContent(
          title: 'What is Breast Cancer',
          subtitle: 'Understanding breast cancer',
          audioPath: 'assets/audio/whatisbreastcancer.m4a',
          urduAudioPath: 'assets/audio/whatisbreastcancer_urdu.m4a',
          animationPath: 'assets/images/Bibi_Onboarding_Leftt.lottie',
          englishLyrics: [
            'Breast cancer is a disease',
            'where cancer cells grow',
            'in the breast tissue.',
            'It is one of the most common',
            'cancers in women.',
            'Early detection is important',
            'for better treatment outcomes.'
          ],
          urduLyrics: [
            'سینے کا سرطان ایک بیماری ہے',
            'جہاں سرطان کے خلیے بڑھتے ہیں',
            'سینے کے ٹشو میں',
            'خواتین میں یہ سب سے عام سرطان ہے'
          ],
        );
      case 3: // Page 4 - Life/Risk
        return AudioContent(
          title: 'Risk Factors',
          subtitle: 'Understanding your risk',
          audioPath: 'assets/audio/risk.m4a',
          urduAudioPath: 'assets/audio/risk_urdu.m4a',
          animationPath: 'assets/images/Bibi_Onboarding_Leftt.lottie',
          englishLyrics: [
            'Risk factors include age,',
            'family history, and lifestyle.',
            'Knowing your risk helps',
            'you take preventive steps.'
          ],
          urduLyrics: [
            'خطرے کے عوامل میں عمر شامل ہے',
            'خاندانی تاریخ اور طرز زندگی',
            'اپنا خطرہ جاننا مدد کرتا ہے',
            'آپ احتیاطی اقدامات لیں'
          ],
        );
      case 5: // Page 6 - Family Tree/Screening
        return AudioContent(
          title: 'Screening',
          subtitle: 'Regular screening saves lives',
          audioPath: 'assets/audio/screen.m4a',
          urduAudioPath: 'assets/audio/screen_urdu.m4a',
          animationPath: 'assets/images/family_tree.lottie',
          englishLyrics: [
            'Regular screening can detect',
            'breast cancer early.',
            'Mammograms are recommended',
            'for women over 40.',
            'Early detection improves',
            'treatment success rates.'
          ],
          urduLyrics: [
            'باقاعدہ جانچ سرطان کو جلد پکڑ سکتی ہے',
            'ممو گرام 40 سال سے زیادہ عمر کی خواتین کے لیے',
            'جلد تشخیص بہتر نتائج دیتی ہے'
          ],
        );
      case 4: // Page 5 - Cancer Cells/Biopsy
        return AudioContent(
          title: 'Cancer Cells',
          subtitle: 'Understanding diagnosis',
          audioPath: 'assets/audio/biopsy.m4a',
          urduAudioPath: 'assets/audio/biopsy_urdu.m4a',
          animationPath: 'assets/images/Cancer Cell Animation from Bibi Project (1).lottie',
          englishLyrics: [
            'A biopsy confirms diagnosis',
            'by examining tissue samples.',
            'Different types of breast cancer',
            'have different treatment options.'
          ],
          urduLyrics: [
            'بایپسی ٹشو کے نمونوں کا امتحان کرتی ہے',
            'مختلف قسمیں مختلف علاج کی ضرورت ہیں',
            'تشخیص کی تصدیق ضروری ہے'
          ],
        );
      case 7: // Page 8 - Treatment
        return AudioContent(
          title: 'Treatment Options',
          subtitle: 'How to treat breast cancer',
          audioPath: 'assets/audio/treat.m4a',
          urduAudioPath: 'assets/audio/treat_urdu.m4a',
          animationPath: 'assets/images/Bibi_Onboarding_Leftt.lottie',
          englishLyrics: [
            'Treatment options include surgery,',
            'chemotherapy, radiation therapy,',
            'and hormonal therapy.',
            'Your doctor will recommend',
            'the best option for you.'
          ],
          urduLyrics: [
            'علاج کے طریقوں میں سرجری شامل ہے',
            'کیموتھراپی، ریڈی ایشن',
            'اور ہارمونل تھراپی',
            'ڈاکٹر بہترین آپشن تجویز کریں گے'
          ],
        );
      case 8: // Page 9 - Prevention
        return AudioContent(
          title: 'Prevention',
          subtitle: 'How to prevent breast cancer',
          audioPath: 'assets/audio/prevent.m4a',
          urduAudioPath: 'assets/audio/prevent_urdu.m4a',
          animationPath: 'assets/images/Bibi_Onboarding_Leftt.lottie',
          englishLyrics: [
            'Maintain a healthy lifestyle',
            'with regular exercise.',
            'Eat a balanced diet',
            'and limit alcohol consumption.'
          ],
          urduLyrics: [
            'صحت مند طرز زندگی برقرار رکھیں',
            'باقاعدہ ورزش کریں',
            'متوازن غذا کھائیں',
            'الکحل کم کریں'
          ],
        );
      case 9: // Page 10 - Support
        return AudioContent(
          title: 'Support',
          subtitle: 'How to support yourself and others',
          audioPath: 'assets/audio/support.m4a',
          urduAudioPath: 'assets/audio/support_urdu.m4a',
          animationPath: 'assets/images/Bibi_Onboarding_Leftt.lottie',
          englishLyrics: [
            'Support is essential during',
            'cancer treatment and recovery.',
            'Connect with support groups',
            'and seek professional help.'
          ],
          urduLyrics: [
            'علاج کے دوران مدد ضروری ہے',
            'سپورٹ گروپوں سے رابطہ کریں',
            'پروفیشنل مدد لیں',
            'ایک دوسرے کی حمایت کریں'
          ],
        );
      default:
        return null;
    }
  }
}
