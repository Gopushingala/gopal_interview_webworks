import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _apiKey = 'AIzaSyDIVO-0L6-BmSkGkIfm2AqYO2UBFYZSzeo';

  static const String _model = 'gemini-2.0-flash';

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  final http.Client _client;

  Future<String> analyzeSentiment(String text) async {
    final url = '$_baseUrl/$_model:generateContent?key=$_apiKey';

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                  'Perform sentiment analysis on the following text. Reply with one of: Positive, Negative, or Neutral.\n\nText: "$text"'
                }
              ]
            }
          ]
        }),
      );
print("object////////// ${response.statusCode}");
      if (response.statusCode != 200) {
        debugPrint('Sentiment analysis error: ${response.body}');
        // throw Exception('Sentiment analysis failed: ${response.body}');
      }

      final decoded = jsonDecode(response.body);
      final sentiment = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return sentiment?.trim() ?? 'Sentiment analysis failed.';
    } catch (e, st) {
      debugPrint('Sentiment analysis exception: $e\n$st');
      return 'Error performing sentiment analysis.';
    }
  }

  Future<String> generateImageCaption(List<int> imageBytes) async {
    final url = '$_baseUrl/$_model:generateContent?key=$_apiKey';
    final base64Image = base64Encode(imageBytes);

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Describe this image briefly in one sentence.'},
                {
                  'inlineData': {
                    'mimeType': 'image/jpeg',
                    'data': base64Image,
                  }
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Image caption error: ${response.body}');
        // throw Exception('Image caption failed: ${response.body}');
      }

      final decoded = jsonDecode(response.body);
      final caption = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return caption?.trim() ?? 'Failed to generate caption.';
    } catch (e, st) {
      debugPrint('Image caption exception: $e\n$st');
      return 'Error generating image caption.';
    }
  }

  Future<String> generateImageCaptionFromFile(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) return 'Error: File not found';
    final bytes = await file.readAsBytes();
    return generateImageCaption(bytes);
  }

  Future<String> summarizeText(String text, {int maxLength = 50}) async {
    final url = '$_baseUrl/$_model:generateContent?key=$_apiKey';

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                  'Summarize the following text in less than $maxLength words:\n\n$text'
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Summarization error: ${response.body}');
        // throw Exception('Summarization failed: ${response.body}');
      }

      final decoded = jsonDecode(response.body);
      final summary = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return summary?.trim() ?? 'Failed to summarize text.';
    } catch (e, st) {
      debugPrint('Summarization exception: $e\n$st');
      return 'Error summarizing text.';
    }
  }

  Future<String> summarizeVideoTitle(String title) async {
    return summarizeText(title, maxLength: 20);
  }
}



// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
//
// class ApiService {
//   static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
//   String? _geminiApiKey;
//
//   final http.Client _client;
//
//   ApiService({
//     http.Client? client,
//     String? geminiApiKey,
//   })  : _client = client ?? http.Client(),
//         _geminiApiKey = geminiApiKey;
//
//   void setGeminiApiKey(String? apiKey) {
//     _geminiApiKey = apiKey;
//   }
//
//   Future<String> analyzeSentiment(String text) async {
//     if (text.trim().isEmpty) {
//       return 'Error: Empty text provided';
//     }
//
//     if (_geminiApiKey == null || _geminiApiKey!.isEmpty) {
//       return 'Error: Gemini API key not configured';
//     }
//
//     try {
//       final url = '$_geminiBaseUrl/models/gemini-1.5-pro:generateContent?key=$_geminiApiKey';
//
//       final response = await _client.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {
//                   'text': 'Analyze the sentiment of this text and respond ONLY with a JSON object in this exact format: {"sentiment": "POSITIVE" or "NEGATIVE", "confidence": "HIGH" or "MEDIUM" or "LOW", "explanation": "brief explanation"}. Do not include any other text. Text to analyze: $text',
//                 },
//               ],
//             },
//           ],
//           'generationConfig': {
//             'temperature': 0.3,
//             'maxOutputTokens': 150,
//             'topP': 0.8,
//             'topK': 40,
//           },
//         }),
//       ).timeout(
//         const Duration(seconds: 30),
//         onTimeout: () {
//           throw TimeoutException('Request timed out');
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         return _parseSentimentResponse(decoded);
//       } else {
//         debugPrint('Sentiment analysis error: ${response.statusCode} ${response.body}');
//         final errorBody = jsonDecode(response.body);
//         final errorMessage = errorBody['error']?['message'] ?? response.body;
//         return 'Error: ${response.statusCode} - $errorMessage';
//       }
//     } on TimeoutException catch (e) {
//       debugPrint('Sentiment analysis timeout: $e');
//       return 'Error: Request timed out. Please try again.';
//     } catch (e, stackTrace) {
//       debugPrint('Sentiment analysis exception: $e\n$stackTrace');
//       return 'Error: Failed to analyze sentiment';
//     }
//   }
//
//   String _parseSentimentResponse(dynamic decoded) {
//     try {
//       if (decoded['candidates'] != null &&
//           decoded['candidates'].isNotEmpty &&
//           decoded['candidates'][0]['content'] != null &&
//           decoded['candidates'][0]['content']['parts'] != null &&
//           decoded['candidates'][0]['content']['parts'].isNotEmpty) {
//         final content = decoded['candidates'][0]['content']['parts'][0]['text'] as String;
//
//         try {
//           final jsonResponse = jsonDecode(content);
//           final sentiment = jsonResponse['sentiment']?.toString().toUpperCase() ?? 'UNKNOWN';
//           final confidence = jsonResponse['confidence']?.toString().toUpperCase() ?? 'MEDIUM';
//           final explanation = jsonResponse['explanation']?.toString() ?? '';
//
//           return 'Sentiment: $sentiment ($confidence confidence)${explanation.isNotEmpty ? " - $explanation" : ""}';
//         } catch (e) {
//           final lowerContent = content.toLowerCase();
//           if (lowerContent.contains('positive')) {
//             return 'Sentiment: POSITIVE - $content';
//           } else if (lowerContent.contains('negative')) {
//             return 'Sentiment: NEGATIVE - $content';
//           }
//           return 'Sentiment: $content';
//         }
//       }
//       return 'Error: Unexpected response format';
//     } catch (e) {
//       debugPrint('Error parsing sentiment response: $e');
//       return 'Error: Failed to parse response';
//     }
//   }
//
//   Future<String> generateImageCaption(List<int> imageBytes) async {
//     if (imageBytes.isEmpty) {
//       return 'Error: Empty image provided';
//     }
//
//     if (_geminiApiKey == null || _geminiApiKey!.isEmpty) {
//       return 'Error: Gemini API key not configured';
//     }
//
//     try {
//       final base64Image = base64Encode(imageBytes);
//
//       final url = '$_geminiBaseUrl/models/gemini-1.5-pro:generateContent?key=$_geminiApiKey';
//
//       final response = await _client.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {
//                   'text': 'Generate a concise, descriptive caption for this image in one sentence (max 15 words).',
//                 },
//                 {
//                   'inlineData': {
//                     'mimeType': 'image/jpeg',
//                     'data': base64Image,
//                   },
//                 },
//               ],
//             },
//           ],
//           'generationConfig': {
//             'temperature': 0.7,
//             'maxOutputTokens': 50,
//             'topP': 0.8,
//             'topK': 40,
//           },
//         }),
//       ).timeout(
//         const Duration(seconds: 30),
//         onTimeout: () {
//           throw TimeoutException('Request timed out');
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         return _parseImageCaptionResponse(decoded);
//       } else {
//         debugPrint('Image caption error: ${response.statusCode} ${response.body}');
//         final errorBody = jsonDecode(response.body);
//         final errorMessage = errorBody['error']?['message'] ?? response.body;
//         return 'Error: ${response.statusCode} - $errorMessage';
//       }
//     } on TimeoutException catch (e) {
//       debugPrint('Image caption timeout: $e');
//       return 'Error: Request timed out. Please try again.';
//     } catch (e, stackTrace) {
//       debugPrint('Image caption exception: $e\n$stackTrace');
//       return 'Error: Failed to generate caption';
//     }
//   }
//
//   Future<String> generateImageCaptionFromFile(String imagePath) async {
//     try {
//       final file = File(imagePath);
//       if (!await file.exists()) {
//         return 'Error: Image file not found';
//       }
//       final imageBytes = await file.readAsBytes();
//       return generateImageCaption(imageBytes);
//     } catch (e) {
//       debugPrint('Error reading image file: $e');
//       return 'Error: Failed to read image file';
//     }
//   }
//
//   String _parseImageCaptionResponse(dynamic decoded) {
//     try {
//       if (decoded['candidates'] != null &&
//           decoded['candidates'].isNotEmpty &&
//           decoded['candidates'][0]['content'] != null &&
//           decoded['candidates'][0]['content']['parts'] != null &&
//           decoded['candidates'][0]['content']['parts'].isNotEmpty) {
//         final content = decoded['candidates'][0]['content']['parts'][0]['text'] as String;
//         return content.trim();
//       }
//       return 'Error: Unexpected response format';
//     } catch (e) {
//       debugPrint('Error parsing caption response: $e');
//       return 'Error: Failed to parse caption';
//     }
//   }
//
//   Future<String> summarizeText(String text, {int maxLength = 15}) async {
//     if (text.trim().isEmpty) {
//       return 'Error: Empty text provided';
//     }
//
//     if (_geminiApiKey == null || _geminiApiKey!.isEmpty) {
//       return 'Error: Gemini API key not configured';
//     }
//
//     try {
//       final url = '$_geminiBaseUrl/models/gemini-1.5-pro:generateContent?key=$_geminiApiKey';
//
//       final response = await _client.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {
//                   'text': 'Summarize this text in exactly $maxLength words or less. Respond with only the summary, no additional text: $text',
//                 },
//               ],
//             },
//           ],
//           'generationConfig': {
//             'temperature': 0.7,
//             'maxOutputTokens': 50,
//             'topP': 0.8,
//             'topK': 40,
//           },
//         }),
//       ).timeout(
//         const Duration(seconds: 30),
//         onTimeout: () {
//           throw TimeoutException('Request timed out');
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         return _parseSummarizationResponse(decoded);
//       } else {
//         debugPrint('Summarization error: ${response.statusCode} ${response.body}');
//         final errorBody = jsonDecode(response.body);
//         final errorMessage = errorBody['error']?['message'] ?? response.body;
//         return 'Error: ${response.statusCode} - $errorMessage';
//       }
//     } on TimeoutException catch (e) {
//       debugPrint('Summarization timeout: $e');
//       return 'Error: Request timed out. Please try again.';
//     } catch (e, stackTrace) {
//       debugPrint('Summarization exception: $e\n$stackTrace');
//       return 'Error: Failed to summarize text';
//     }
//   }
//
//   Future<String> summarizeVideoTitle(String title) async {
//     return summarizeText(title, maxLength: 15);
//   }
//
//   String _parseSummarizationResponse(dynamic decoded) {
//     try {
//       if (decoded['candidates'] != null &&
//           decoded['candidates'].isNotEmpty &&
//           decoded['candidates'][0]['content'] != null &&
//           decoded['candidates'][0]['content']['parts'] != null &&
//           decoded['candidates'][0]['content']['parts'].isNotEmpty) {
//         final content = decoded['candidates'][0]['content']['parts'][0]['text'] as String;
//         return content.trim();
//       }
//       return 'Error: Unexpected response format';
//     } catch (e) {
//       debugPrint('Error parsing summarization response: $e');
//       return 'Error: Failed to parse summary';
//     }
//   }
//
//   bool isApiKeyConfigured() {
//     return _geminiApiKey != null && _geminiApiKey!.isNotEmpty;
//   }
//
//   /// Dispose resources
//   void dispose() {
//     _client.close();
//   }
// }
//
// class TimeoutException implements Exception {
//   final String message;
//   TimeoutException(this.message);
//
//   @override
//   String toString() => message;
// }

///
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
//
//
// class ApiService {
//
//   static const String _geminiBaseUrl =
//       'https://generativelanguage.googleapis.com/v1';
//   static const String _geminiModel = 'gemini-1.5-flash-latest';
//   String? _geminiApiKey;
//
//   final http.Client _client;
//
//   ApiService({
//     http.Client? client,
//     String? geminiApiKey,
//   })  : _client = client ?? http.Client(),
//         _geminiApiKey = geminiApiKey;
//
//   void setGeminiApiKey(String? apiKey) {
//     _geminiApiKey = apiKey;
//   }
//
//
//   Future<String> analyzeSentiment(String text) async {
//     if (text.trim().isEmpty) return 'Error: Empty text provided';
//     if (_geminiApiKey == null || _geminiApiKey!.isEmpty) {
//       return 'Error: Gemini API key not configured';
//     }
//
//     try {
//       final url =
//           '$_geminiBaseUrl/models/$_geminiModel:generateContent?key=$_geminiApiKey';
//
//       final response = await _client
//           .post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {
//                   'text':
//                   'Analyze the sentiment of this text and respond ONLY with a JSON object in this exact format: {"sentiment": "POSITIVE" or "NEGATIVE", "confidence": "HIGH" or "MEDIUM" or "LOW", "explanation": "brief explanation"}. Text: $text',
//                 }
//               ]
//             }
//           ],
//           'generationConfig': {
//             'temperature': 0.3,
//             'maxOutputTokens': 150,
//             'topP': 0.8,
//             'topK': 40,
//           },
//         }),
//       )
//           .timeout(const Duration(seconds: 30), onTimeout: () {
//         throw TimeoutException('Request timed out');
//       });
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         return _parseSentimentResponse(decoded);
//       } else {
//         debugPrint(
//             'Sentiment analysis error: ${response.statusCode} ${response.body}');
//         final errorBody = jsonDecode(response.body);
//         final errorMessage = errorBody['error']?['message'] ?? response.body;
//         return 'Error: ${response.statusCode} - $errorMessage';
//       }
//     } on TimeoutException catch (_) {
//       return 'Error: Request timed out. Please try again.';
//     } catch (e, st) {
//       debugPrint('Sentiment analysis exception: $e\n$st');
//       return 'Error: Failed to analyze sentiment';
//     }
//   }
//
//   String _parseSentimentResponse(dynamic decoded) {
//     try {
//       final text = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];
//       if (text == null) return 'Error: Unexpected response format';
//
//       try {
//         final jsonResponse = jsonDecode(text);
//         final sentiment = jsonResponse['sentiment']?.toString().toUpperCase();
//         final confidence =
//             jsonResponse['confidence']?.toString().toUpperCase() ?? 'MEDIUM';
//         final explanation = jsonResponse['explanation'] ?? '';
//         return 'Sentiment: $sentiment ($confidence confidence)${explanation.isNotEmpty ? " - $explanation" : ""}';
//       } catch (_) {
//         final lower = text.toLowerCase();
//         if (lower.contains('positive')) return 'Sentiment: POSITIVE - $text';
//         if (lower.contains('negative')) return 'Sentiment: NEGATIVE - $text';
//         return 'Sentiment: $text';
//       }
//     } catch (e) {
//       debugPrint('Error parsing sentiment: $e');
//       return 'Error: Failed to parse response';
//     }
//   }
//
//
//   Future<String> generateImageCaption(List<int> imageBytes) async {
//     if (imageBytes.isEmpty) return 'Error: Empty image provided';
//     if (_geminiApiKey == null || _geminiApiKey!.isEmpty) {
//       return 'Error: Gemini API key not configured';
//     }
//
//     try {
//       final base64Image = base64Encode(imageBytes);
//       final url =
//           '$_geminiBaseUrl/models/$_geminiModel:generateContent?key=$_geminiApiKey';
//
//       final response = await _client
//           .post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {'text': 'Generate a short, descriptive caption for this image.'},
//                 {
//                   'inlineData': {
//                     'mimeType': 'image/jpeg',
//                     'data': base64Image,
//                   }
//                 }
//               ]
//             }
//           ],
//           'generationConfig': {
//             'temperature': 0.7,
//             'maxOutputTokens': 60,
//           },
//         }),
//       )
//           .timeout(const Duration(seconds: 30), onTimeout: () {
//         throw TimeoutException('Request timed out');
//       });
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         return _parseImageCaptionResponse(decoded);
//       } else {
//         final errorBody = jsonDecode(response.body);
//         final errorMessage = errorBody['error']?['message'] ?? response.body;
//         return 'Error: ${response.statusCode} - $errorMessage';
//       }
//     } on TimeoutException catch (_) {
//       return 'Error: Request timed out. Please try again.';
//     } catch (e, st) {
//       debugPrint('Image caption exception: $e\n$st');
//       return 'Error: Failed to generate caption';
//     }
//   }
//
//   Future<String> generateImageCaptionFromFile(String path) async {
//     try {
//       final file = File(path);
//       if (!await file.exists()) return 'Error: File not found';
//       return generateImageCaption(await file.readAsBytes());
//     } catch (e) {
//       return 'Error reading image: $e';
//     }
//   }
//
//   String _parseImageCaptionResponse(dynamic decoded) {
//     try {
//       final text = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];
//       return text?.trim() ?? 'Error: Unexpected response format';
//     } catch (e) {
//       return 'Error parsing caption: $e';
//     }
//   }
//
//
//   Future<String> summarizeText(String text, {int maxLength = 15}) async {
//     if (text.trim().isEmpty) return 'Error: Empty text provided';
//     if (_geminiApiKey == null || _geminiApiKey!.isEmpty) {
//       return 'Error: Gemini API key not configured';
//     }
//
//     try {
//       final url =
//           '$_geminiBaseUrl/models/$_geminiModel:generateContent?key=$_geminiApiKey';
//       final response = await _client
//           .post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {
//                   'text':
//                   'Summarize this text in $maxLength words or less. Respond only with the summary: $text'
//                 }
//               ]
//             }
//           ],
//           'generationConfig': {
//             'temperature': 0.6,
//             'maxOutputTokens': 60,
//           },
//         }),
//       )
//           .timeout(const Duration(seconds: 30), onTimeout: () {
//         throw TimeoutException('Request timed out');
//       });
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         return _parseSummarizationResponse(decoded);
//       } else {
//         final errorBody = jsonDecode(response.body);
//         final errorMessage = errorBody['error']?['message'] ?? response.body;
//         return 'Error: ${response.statusCode} - $errorMessage';
//       }
//     } on TimeoutException catch (_) {
//       return 'Error: Request timed out.';
//     } catch (e, st) {
//       debugPrint('Summarization exception: $e\n$st');
//       return 'Error: Failed to summarize text';
//     }
//   }
//
//   Future<String> summarizeVideoTitle(String title) async =>
//       summarizeText(title, maxLength: 15);
//
//   String _parseSummarizationResponse(dynamic decoded) {
//     try {
//       final text = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];
//       return text?.trim() ?? 'Error: Unexpected response format';
//     } catch (e) {
//       return 'Error parsing summary: $e';
//     }
//   }
//
//
//   bool isApiKeyConfigured() =>
//       _geminiApiKey != null && _geminiApiKey!.isNotEmpty;
//
//   void dispose() => _client.close();
// }
//
// class TimeoutException implements Exception {
//   final String message;
//   TimeoutException(this.message);
//   @override
//   String toString() => message;
// }

