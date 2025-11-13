# AI Features Usage Guide

This document explains how to use all the AI features implemented in the `ApiService`.

## Features Overview

1. **Sentiment Analysis** - Analyze sentiment of text/captions (FREE - Hugging Face)
2. **Image Caption Generation** - Generate captions for uploaded images (FREE - Hugging Face)
3. **Video Title Summarization** - Summarize video titles using Google Gemini (FREE - if key available) or Hugging Face

---

## 1. Sentiment Analysis

Analyze the sentiment (positive/negative) of any text or caption.

### Usage Example:

```dart
import 'package:your_app/core/services/api_service.dart';

// Initialize the service
final apiService = ApiService();

// Analyze sentiment
String result = await apiService.analyzeSentiment("This is amazing!");
// Returns: "Sentiment: POSITIVE (95.2% confidence)"

String result2 = await apiService.analyzeSentiment("This is terrible!");
// Returns: "Sentiment: NEGATIVE (98.5% confidence)"
```

### In Dashboard Controller:

```dart
final controller = Get.find<DashboardController>();
String sentiment = await controller.analyzeCaptionSentiment("Your text here");
```

---

## 2. Image Caption Generation

Generate a descriptive caption for an uploaded image.

### Usage Example:

```dart
import 'dart:io';
import 'package:your_app/core/services/api_service.dart';

final apiService = ApiService();

// Option 1: From image bytes
File imageFile = File('path/to/image.jpg');
List<int> imageBytes = await imageFile.readAsBytes();
String caption = await apiService.generateImageCaption(imageBytes);
// Returns: "a group of people standing on a beach"

// Option 2: From file path
String caption = await apiService.generateImageCaptionFromFile('path/to/image.jpg');
```

### In Dashboard Controller:

```dart
final controller = Get.find<DashboardController>();

// From bytes
List<int> imageBytes = await File('image.jpg').readAsBytes();
String caption = await controller.generateImageCaption(imageBytes);

// From file path
String caption = await controller.generateImageCaptionFromFile('image.jpg');
```

---

## 3. Video Title Summarization

Summarize long video titles into shorter, concise versions.

### Usage Example:

```dart
import 'package:your_app/core/services/api_service.dart';

// Initialize with Google Gemini key (optional, FREE tier)
final apiService = ApiService(
  geminiApiKey: 'AIzaSy-your-key-here', // Optional, FREE
);

// Summarize video title
// If Gemini key is set, uses Google Gemini 1.5 Flash (FREE)
// Otherwise, falls back to Hugging Face BART model
String summary = await apiService.summarizeVideoTitle(
  "Complete Guide to Flutter Development: Building Cross-Platform Mobile Apps with Dart Programming Language"
);
// Returns: "Flutter development guide for cross-platform apps"
```

### In Dashboard Controller:

```dart
final controller = Get.find<DashboardController>();
String summary = await controller.summarizeVideoTitle("Long video title here...");
```

---

## Complete Integration Example

```dart
import 'package:get/get.dart';
import 'package:your_app/core/services/api_service.dart';
import 'package:your_app/modules/dashboard/dashboard_controller.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    
    return Column(
      children: [
        // Analyze sentiment
        ElevatedButton(
          onPressed: () async {
            String sentiment = await controller.analyzeCaptionSentiment(
              "I love this app!"
            );
            print(sentiment); // "Sentiment: POSITIVE (95.2% confidence)"
          },
          child: Text('Analyze Sentiment'),
        ),
        
        // Generate image caption
        ElevatedButton(
          onPressed: () async {
            String caption = await controller.generateImageCaptionFromFile(
              'path/to/image.jpg'
            );
            print(caption); // "a beautiful sunset over the ocean"
          },
          child: Text('Generate Image Caption'),
        ),
        
        // Summarize video title
        ElevatedButton(
          onPressed: () async {
            String summary = await controller.summarizeVideoTitle(
              "Complete Guide to Building Mobile Apps with Flutter and Dart"
            );
            print(summary); // "Flutter mobile app development guide"
          },
          child: Text('Summarize Video Title'),
        ),
      ],
    );
  }
}
```

---

## API Configuration

### Hugging Face (FREE)

- **No API key required** for basic usage
- Token is already configured in `ApiService`
- Free tier with generous limits

### Google Gemini (Optional - FREE Tier)

1. **Get API Key (FREE, No Credit Card Required):**
   - Go to https://aistudio.google.com/app/apikey
   - Sign in with your Google account
   - Click "Create API Key"
   - Select or create a Google Cloud project
   - Copy the key (starts with `AIzaSy-`)

2. **Set the Key:**
   
   **Option A: In Dashboard Binding**
   ```dart
   Get.lazyPut<ApiService>(
     () => ApiService(
       geminiApiKey: 'AIzaSy-your-key-here',
     ),
   );
   ```
   
   **Option B: Using Environment Variables**
   ```dart
   // In main.dart
   await dotenv.load();
   
   Get.lazyPut<ApiService>(
     () => ApiService(
       geminiApiKey: dotenv.env['GEMINI_API_KEY'],
     ),
   );
   ```
   
   **Option C: Set After Initialization**
   ```dart
   final apiService = ApiService();
   apiService.setGeminiApiKey('AIzaSy-your-key-here');
   ```

---

## Error Handling

All methods return error messages as strings if something goes wrong:

```dart
String result = await apiService.analyzeSentiment("text");
if (result.startsWith('Error:')) {
  // Handle error
  print('Failed: $result');
} else {
  // Success
  print('Result: $result');
}
```

---

## Pricing Information

### Hugging Face
- **FREE** - No credit card required
- Generous free tier limits

### Google Gemini
- **FREE TIER:** 60 requests per minute, 1,500 requests per day
- **Gemini 1.5 Flash:** FREE for most use cases
- **No credit card required** for free tier
- Check current pricing: https://ai.google.dev/pricing

---

## Security Best Practices

1. **Never commit API keys to version control**
2. **Use environment variables** for production
3. **Set usage limits** in OpenAI dashboard
4. **Monitor usage** regularly
5. **Rotate keys** periodically

---

## Troubleshooting

### Sentiment Analysis Returns 404
- The endpoint format has been updated to use the new Hugging Face router
- Make sure you're using the latest version of `api_service.dart`

### Gemini Not Working
- Verify your API key is correct (starts with `AIzaSy-`)
- Check if you've exceeded the free tier limits (60 req/min, 1500/day)
- Ensure the key is properly set in the service initialization
- Verify API is enabled in Google Cloud Console

### Image Caption Generation Fails
- Make sure the image file exists and is readable
- Check image format is supported (JPEG, PNG, etc.)
- Verify image size is reasonable (not too large)

---

## Support

For issues or questions:
- Hugging Face: https://huggingface.co/docs/api-inference
- OpenAI: https://platform.openai.com/docs

