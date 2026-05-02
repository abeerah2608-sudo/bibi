# Firestore Schema Setup Guide

This document provides the exact Firestore collection and document structure needed for the Firebase-driven UI system.

## Collections Overview

```
Firestore Database
├── page_configs/              (Full configurations)
├── onboarding_pages/          (Individual onboarding pages)
├── quiz_pages/                (Individual quiz pages)
├── dashboard_pages/           (Individual dashboard pages)
├── privacy_policy_page/       (Policy pages)
├── splash_screen/             (Splash screens)
├── testimonials_page/         (Testimonials)
└── [other_page_collections]/
```

## 1. Collection: `page_configs`

**Purpose**: Store complete page configurations including assets, styles, and all pages

### Document: `onboardingFlow`

```firestore
page_configs/onboardingFlow
{
  "schemaVersion": "2.0.0",
  "metadata": {
    "version": "2.0.0",
    "sourceFile": "onboardingFlow.json",
    "convertedOn": "2026-04-30",
    "notes": "Complete onboarding flow with 7 pages"
  },
  "assets": {
    "animations": {
      "Bibi_Onboarding_Leftt.lottie": "gs://bibi-app-d41a0.firebasestorage.app/animations/Bibi_Onboarding_Leftt.lottie",
      "Bibi_Onboarding_Right.lottie": "gs://bibi-app-d41a0.firebasestorage.app/animations/Bibi_Onboarding_Right.lottie"
    },
    "images": {
      "logo": "gs://bibi-app-d41a0.firebasestorage.app/images/Bibi_Logo_Vector_1.png",
      "timer": "gs://bibi-app-d41a0.firebasestorage.app/images/timer.png"
    },
    "audio": {
      "onboarding_1": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_1.mp3",
      "onboarding_1_urdu": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_1_urdu.mp3",
      "onboarding_2": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_2.mp3",
      "onboarding_2_urdu": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_2_urdu.mp3"
    }
  },
  "styleTokens": {
    "textStyles": {
      "overlay": {
        "fontSize": 28,
        "fontWeight": "w800",
        "fontFamily": "Inter",
        "color": "#8B5E3C",
        "textAlign": "center"
      },
      "subtitle": {
        "fontSize": 16,
        "fontWeight": "w400",
        "color": "#666666"
      },
      "caption": {
        "fontSize": 12,
        "fontWeight": "w500",
        "color": "#999999"
      }
    }
  },
  "pages": [
    {
      "id": "page_1",
      "order": 0,
      "type": "screen",
      "background": {
        "color": "#FFFFFF"
      },
      "audio": {
        "English": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_1.mp3",
        "اردو": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_1_urdu.mp3"
      },
      "layout": {
        "type": "layers",
        "alignment": "center"
      },
      "components": [
        {
          "id": "animation",
          "type": "lottie",
          "assetKey": "Bibi_Onboarding_Leftt.lottie",
          "size": {
            "width": 200,
            "height": 200
          },
          "behavior": {
            "autoplay": true,
            "loop": true
          },
          "layoutHints": {
            "scale": 3.7,
            "translate": {
              "xPercent": 0.75,
              "yPercent": -0.10
            },
            "preferredAlignment": "center_left"
          },
          "position": {
            "alignment": "center_left"
          }
        },
        {
          "id": "greeting_text",
          "type": "text",
          "content": {
            "textKey": "assalam_o_alaikum",
            "translations": {
              "English": "Assalam-o-Alaikum!",
              "اردو": "السلام علیکم!",
              "Roman Urdu": "Assalam-o-Alaikum!"
            }
          },
          "styleRef": "overlay",
          "position": {
            "alignment": "center_right"
          },
          "behavior": {
            "supportsBoldParsing": false
          }
        }
      ]
    },
    {
      "id": "page_2",
      "order": 1,
      "type": "screen",
      "background": {
        "color": "#FFFFFF"
      },
      "audio": {
        "English": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_2.mp3",
        "اردو": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_2_urdu.mp3"
      },
      "layout": {
        "type": "layers"
      },
      "components": [
        {
          "id": "animation",
          "type": "lottie",
          "assetKey": "Bibi_Onboarding_Leftt.lottie",
          "behavior": {
            "autoplay": true,
            "loop": true
          },
          "position": {
            "alignment": "center_left"
          }
        },
        {
          "id": "text",
          "type": "text",
          "content": {
            "textKey": "my_name",
            "translations": {
              "English": "My name is [b]Bibi[/b]",
              "اردو": "میرا نام [b]بِبی[/b] ہے"
            }
          },
          "styleRef": "overlay",
          "behavior": {
            "supportsBoldParsing": true
          },
          "position": {
            "alignment": "center_right"
          }
        }
      ]
    }
  ]
}
```

### Document: `dashboard`

```firestore
page_configs/dashboard
{
  "schemaVersion": "2.0.0",
  "metadata": {
    "version": "2.0.0",
    "sourceFile": "dashboard.json"
  },
  "assets": {
    "images": {
      "logo": "gs://bibi-app-d41a0.firebasestorage.app/images/Bibi_Logo_Vector_1.png",
      "timer": "gs://bibi-app-d41a0.firebasestorage.app/images/timer.png",
      "whatIsIt": "gs://bibi-app-d41a0.firebasestorage.app/images/whatIsIt.png"
    }
  },
  "styleTokens": {
    "textStyles": {
      "welcome_title": {
        "fontSize": 15,
        "fontWeight": "w700",
        "color": "#333333"
      },
      "card_title": {
        "fontSize": 14,
        "fontWeight": "w700",
        "color": "#FFFFFF"
      }
    }
  },
  "pages": [
    {
      "id": "dashboard_main",
      "order": 0,
      "type": "screen",
      "background": {
        "color": "#FFF4F4"
      },
      "layout": {
        "type": "column",
        "padding": {
          "left": 16,
          "right": 16,
          "top": 16,
          "bottom": 24
        },
        "gap": 16
      },
      "components": [
        {
          "id": "logo",
          "type": "image",
          "assetKey": "logo",
          "size": {
            "width": 72,
            "height": 72
          },
          "position": {
            "alignment": "top_left"
          }
        },
        {
          "id": "greeting_card",
          "type": "card",
          "content": {
            "greeting": {
              "textKey": "good_morning",
              "translations": {
                "English": "Good Morning!",
                "اردو": "صبح بخیر!"
              }
            }
          },
          "position": {
            "padding": {
              "all": 16
            }
          }
        }
      ]
    }
  ]
}
```

## 2. Collection: `onboarding_pages`

**Purpose**: Store individual onboarding pages (optional, for dynamic updates)

### Document: `page_1`

```firestore
onboarding_pages/page_1
{
  "id": "page_1",
  "order": 0,
  "type": "screen",
  "background": {
    "color": "#FFFFFF"
  },
  "audio": {
    "English": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_1.mp3",
    "اردو": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_1_urdu.mp3"
  },
  "layout": {
    "type": "layers",
    "alignment": "center"
  },
  "components": [
    {
      "id": "animation",
      "type": "lottie",
      "assetKey": "Bibi_Onboarding_Leftt.lottie",
      "behavior": {
        "autoplay": true,
        "loop": true
      },
      "layoutHints": {
        "scale": 3.7,
        "translate": {
          "xPercent": 0.75,
          "yPercent": -0.10
        }
      },
      "position": {
        "alignment": "center_left"
      }
    }
  ]
}
```

## 3. Collection: `quiz_pages`

```firestore
quiz_pages/quiz_page_1
{
  "id": "quiz_page_1",
  "order": 0,
  "type": "screen",
  "background": {
    "color": "#FFFFFF"
  },
  "layout": {
    "type": "column",
    "padding": {
      "all": 20
    },
    "gap": 16
  },
  "components": [
    {
      "id": "title",
      "type": "text",
      "content": {
        "textKey": "quiz_title",
        "translations": {
          "English": "Breast Cancer Quiz",
          "اردو": "بریسٹ کینسر کوئز"
        }
      },
      "styleRef": "quiz_title"
    },
    {
      "id": "question",
      "type": "text",
      "content": {
        "textKey": "q1",
        "translations": {
          "English": "What is breast cancer?",
          "اردو": "بریسٹ کینسر کیا ہے؟"
        }
      },
      "styleRef": "quiz_question"
    }
  ]
}
```

## 4. Collection: `privacy_policy_page`

```firestore
privacy_policy_page/main
{
  "id": "privacy_policy",
  "order": 0,
  "type": "screen",
  "background": {
    "color": "#FFFFFF"
  },
  "layout": {
    "type": "column",
    "padding": {
      "all": 16
    }
  },
  "components": [
    {
      "id": "title",
      "type": "text",
      "content": {
        "textKey": "privacy_policy_title",
        "translations": {
          "English": "Privacy Policy",
          "اردو": "رازداری کی پالیسی"
        }
      },
      "styleRef": "heading_1"
    }
  ]
}
```

## 5. Collection: `splash_screen`

```firestore
splash_screen/main
{
  "id": "splash",
  "order": 0,
  "type": "screen",
  "background": {
    "color": "#FFFFFF"
  },
  "layout": {
    "type": "layers",
    "alignment": "center"
  },
  "components": [
    {
      "id": "logo",
      "type": "lottie",
      "assetKey": "splash_animation",
      "behavior": {
        "autoplay": true,
        "loop": false
      }
    },
    {
      "id": "title",
      "type": "text",
      "content": {
        "textKey": "app_title",
        "translations": {
          "English": "BIBI",
          "اردو": "بی بی"
        }
      },
      "styleRef": "splash_title"
    }
  ]
}
```

## 6. Collection: `testimonials_page`

```firestore
testimonials_page/main
{
  "id": "testimonials",
  "order": 0,
  "type": "screen",
  "background": {
    "color": "#FFF4F4"
  },
  "layout": {
    "type": "column",
    "gap": 16
  },
  "components": [
    {
      "id": "title",
      "type": "text",
      "content": {
        "textKey": "testimonials_title",
        "translations": {
          "English": "Patient Stories",
          "اردو": "مریض کی کہانیاں"
        }
      },
      "styleRef": "heading_1"
    },
    {
      "id": "testimonials_list",
      "type": "collection",
      "content": {
        "viewType": "list",
        "items": [
          {
            "id": "testimonial_1",
            "name": "Sarah",
            "story": "My journey..."
          }
        ]
      }
    }
  ]
}
```

## Firestore Security Rules

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Public read access to page configs
    match /page_configs/{document=**} {
      allow read: if request.auth != null;
    }
    
    // Public read access to all pages
    match /{document=**} {
      allow read: if request.auth != null;
    }
    
    // Admin only write access
    match /{document=**} {
      allow write: if request.auth.token.admin == true;
    }
  }
}
```

## Setup Instructions

1. **Create Collections in Firestore Console**
   - Navigate to: https://console.firebase.google.com/
   - Select your project
   - Create new collections (or they auto-create on first document)

2. **Add Documents**
   - Use the provided JSON structures above
   - Copy/paste into Firestore console
   - Or use Firebase Admin SDK

3. **Update Assets**
   - Ensure all `gs://` URLs point to actual files in Firebase Storage
   - Upload assets to corresponding folders

4. **Test in App**
   ```dart
   final service = DynamicContentService();
   await service.initialize();
   final config = await service.loadPageConfiguration(
     configName: 'onboardingFlow'
   );
   ```

## Firestore Admin SDK (Optional)

To bulk upload configurations:

```bash
npm install -g firebase-admin

# Create script to upload configurations
node upload_configs.js
```

Upload script example:

```javascript
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert('serviceAccountKey.json'),
  projectId: 'bibi-app-d41a0'
});

const db = admin.firestore();

async function uploadConfigs() {
  // Upload onboardingFlow
  await db.collection('page_configs').doc('onboardingFlow').set(
    require('./onboardingFlow.json')
  );
  
  // Upload dashboard
  await db.collection('page_configs').doc('dashboard').set(
    require('./dashboard.json')
  );
  
  console.log('Configurations uploaded successfully');
}

uploadConfigs().catch(console.error);
```

## Firestore Limits & Best Practices

- **Document Size Limit**: 1 MB per document
- **Collection Naming**: Use snake_case (onboarding_pages)
- **Indexing**: Firestore auto-indexes most queries
- **Batch Operations**: Use batch writes for multiple documents
- **Cost**: Read 1 doc = 1 read operation

---

## Verification Checklist

- [ ] All collections created in Firestore
- [ ] Documents match JSON schema exactly
- [ ] Asset URLs are valid (test in browser)
- [ ] Firestore rules allow app to read
- [ ] Local JSON files exist as fallback
- [ ] DynamicContentService tested
- [ ] Pages render correctly
- [ ] Audio URLs work
- [ ] Offline mode works (local JSON loads)

---

**Version**: 2.0.0  
**Last Updated**: 2026-04-30
