// generate_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../db/ingrdient_database.dart';
import '../../models/ingredients.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _recipes = [];
  List<Ingredient> _ingredients = [];

  // <-- Replace with your real key or keep as environment variable
  final String apiKey = "AIzaSyANgBI7tbuLiaEaJnr91OxbzUwrVd2pRG4";

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    final data = await IngredientDatabase.instance.readAllIngredients();
    setState(() {
      _ingredients = data;
    });
  }

  // Compute percentage: how many recipe ingredients match the available ingredients
  int _computeMatchPercentage(List<dynamic> recipeIngredients, List<Ingredient> available) {
    if (recipeIngredients.isEmpty) return 0;
    final availNames = available
        .map((e) => (e.name ?? '').toString().toLowerCase().trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (availNames.isEmpty) return 0;

    int matched = 0;
    for (var raw in recipeIngredients) {
      final r = raw.toString().toLowerCase().trim();
      final rClean = r.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
      bool found = false;
      for (var a in availNames) {
        final aClean = a.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
        if (rClean.contains(aClean) || aClean.contains(rClean)) {
          found = true;
          break;
        }
        // also check word-level matches
        final rWords = rClean.split(RegExp(r'\s+')).where((x) => x.length > 1);
        final aWords = aClean.split(RegExp(r'\s+')).where((x) => x.length > 1);
        if (rWords.any((w) => aWords.contains(w))) {
          found = true;
          break;
        }
      }
      if (found) matched++;
    }

    final percent = ((matched / recipeIngredients.length) * 100).round();
    return percent.clamp(0, 100);
  }

  Future<void> _generateRecipes() async {
    if (_ingredients.isEmpty) {
      // show a friendly prompt
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No ingredients found. Add some ingredients first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _recipes = [];
    });

    try {
      const modelName = "models/gemini-2.0-flash"; // example
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/$modelName:generateContent?key=$apiKey",
      );

      final ingredientNames = _ingredients.map((e) => e.name).whereType<String>().join(", ");

      final prompt = """
Generate 3 creative recipes in strict JSON format (return only JSON).
Each recipe must have:
- title (string)
- ingredients (array of strings; prefer ingredients from [$ingredientNames])
- steps (array of short steps)
Example:
[
  {
    "title": "Tomato Omelette",
    "ingredients": ["Tomato", "Eggs", "Onion"],
    "steps": ["Chop vegetables", "Whisk eggs", "Cook together"],
    "matchPercentage": 80
  }
]
Return only the JSON array.
""";

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Attempt to extract the text field where model output is stored
        String? text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]?.toString();

        if (text == null) {
          throw Exception("Invalid API output: missing text field.");
        }

        // Clean up common wrappers and debug prefixes
        text = text.replaceAll(RegExp(r'```(?:json)?'), '');
        text = text.replaceAll(RegExp(r'```'), '');
        // remove emulator/debug prefixes like "I/flutter ( 12345): "
        text = text.replaceAll(RegExp(r'^[A-Z]\/[^\n]*\(\s*\d+\)\:\s*', multiLine: true), '');
        // remove any leading/trailing whitespace
        text = text.trim();

        List<dynamic>? parsed;
        try {
          parsed = jsonDecode(text) as List<dynamic>?;
        } catch (e) {
          // try to extract a JSON array substring (fallback)
          final start = text.indexOf('[');
          final end = text.lastIndexOf(']');
          if (start != -1 && end != -1 && end > start) {
            final sub = text.substring(start, end + 1);
            try {
              parsed = jsonDecode(sub) as List<dynamic>?;
            } catch (e2) {
              // give up parse
              parsed = null;
              debugPrint("JSON parse failed (fallback) : $e2\nSUB: $sub");
            }
          } else {
            debugPrint("JSON parse failed: $e");
            parsed = null;
          }
        }

        if (parsed == null) {
          // show cleaned text in logs for debug and present an error card
          debugPrint("CLEANED RESPONSE:\n$text");
          setState(() {
            _recipes = [
              {
                "title": "Error parsing response",
                "ingredients": [],
                "steps": ["Failed to parse the model response. Check console debug logs."],
                "computedMatch": 0
              }
            ];
          });
        } else {
          // Convert to Map<String,dynamic>, compute match percentage for each recipe,
          // sort and keep top 3 highest matches
          final List<Map<String, dynamic>> asMaps = parsed
              .whereType<Map>()
              .map((m) => Map<String, dynamic>.from(m.cast()))
              .toList();

          for (var rec in asMaps) {
            final recIngs = (rec['ingredients'] ?? []) as List<dynamic>;
            final computed = _computeMatchPercentage(recIngs, _ingredients);
            rec['computedMatch'] = computed;
          }

          // Sort descending by computedMatch
          asMaps.sort((a, b) => (b['computedMatch'] ?? 0).compareTo(a['computedMatch'] ?? 0));

          // Keep top 3 (or fewer if less returned)
          final top = asMaps.take(3).toList();

          // If none have any match, still show top 3 (already taken). If you want to show only >0, you could filter here.

          setState(() {
            _recipes = top;
          });
        }
      } else {
        // API returned error status
        debugPrint("API ERROR ${response.statusCode}: ${response.body}");
        setState(() {
          _recipes = [
            {
              "title": "API Error",
              "ingredients": [],
              "steps": ["Failed to generate recipes. See logs for details."],
              "computedMatch": 0
            }
          ];
        });
      }
    } catch (e) {
      debugPrint("Exception while generating recipes: $e");
      setState(() {
        _recipes = [
          {
            "title": "Error",
            "ingredients": [],
            "steps": ["Error occurred: $e"],
            "computedMatch": 0
          }
        ];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final int match = (recipe['computedMatch'] ?? 0).clamp(0, 100);

    final ingredientsList = (recipe['ingredients'] ?? []) as List<dynamic>;
    final stepsList = (recipe['steps'] ?? []) as List<dynamic>;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Title
          Text(
            recipe['title'] ?? 'Untitled Recipe',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          // Match row
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Ingredient Match", style: TextStyle(fontSize: 13)),
            Text("$match%", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (match / 100),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
          const SizedBox(height: 12),

          // Ingredients
          const Text("Ingredients:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          if (ingredientsList.isEmpty)
            const Text("None listed", style: TextStyle(fontSize: 14))
          else
            ...ingredientsList.map((ing) => Text("• ${ing.toString()}", style: const TextStyle(fontSize: 14))),

          const SizedBox(height: 12),

          // Steps
          const Text("Steps:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          if (stepsList.isEmpty)
            const Text("No steps provided", style: TextStyle(fontSize: 14))
          else
            ...stepsList.map((s) => Text("• ${s.toString()}", style: const TextStyle(fontSize: 14))),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // Use SafeArea so bottom button isn't obstructed by system UI
      body: SafeArea(
        child: Column(
          children: [
            // Recipes area - shows top results (or message)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _recipes.isEmpty
                      ? Center(
                          child: Text(
                            "No recipes yet. Tap Generate below to create recipes from your ingredients.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 12, top: 6),
                          itemCount: _recipes.length,
                          itemBuilder: (context, i) {
                            return _buildRecipeCard(_recipes[i]);
                          },
                        ),
            ),

            // Bottom area contains available ingredients list and Generate button just below it
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ingredients displayed immediately above the button
                  if (_ingredients.isNotEmpty) ...[
                    Text("Available Ingredients:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    // show as wrapped chips for better UI
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _ingredients.map((ing) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange.shade100),
                            ),
                            child: Text("${ing.name} ${ing.quantity != null ? '(${ing.quantity})' : ''}",
                                style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        "No ingredients found. Add ingredients to generate recipes.",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    )
                  ],

                  // Generate button (bottom)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generateRecipes,
                      icon: const Icon(Icons.auto_awesome, color: Colors.white),
                      label: Text(_isLoading ? "Generating..." : "Generate Recipes", style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}