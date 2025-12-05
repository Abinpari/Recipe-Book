import 'package:flutter/material.dart';
import '../../db/recipe_database.dart';
import '../../db/ingrdient_database.dart';
import '../../models/recipes.dart';
import '../../models/ingredients.dart';
import 'package:flutterassignment/app/auth_service.dart';
import 'recipe_detail_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userName;
  List<Recipe> recipes = [];
  List<Ingredient> ingredients = [];
  // Example, you can fetch from user db or API

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _loadIngredients();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final user = authServices.value.currentUser; // Firebase user
      setState(() {
        _userName = user?.displayName ?? "Guest User";
      });
    } catch (e) {
      print('Error loading user details: $e');
    }
  }

  Future<void> _loadRecipes() async {
    final fetchedRecipes = await DatabaseHelper.instance.getRecipes();
    setState(() {
      recipes = fetchedRecipes;
    });
  }

  Future<void> _loadIngredients() async {
    final fetchedIngredients =
        await IngredientDatabase.instance.readAllIngredients();
    setState(() {
      ingredients = fetchedIngredients;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with username
                _buildHeader(),
                const SizedBox(height: 20),

                // Recipe categories (Optional tags)
                _buildRecipeCategories(),
                const SizedBox(height: 20),

                // Recommended section title
                _buildSectionTitle("Recommended"),
                const SizedBox(height: 15),

                // Recommended recipes (Dynamic)
                _buildRecommendedRecipes(),
                const SizedBox(height: 20),

                // Ingredients section title
                _buildSectionTitle("Ingredients"),
                const SizedBox(height: 15),

                // Ingredients list (Dynamic)
                _buildIngredientsList(),
                const SizedBox(height: 20),
                _buildAboutSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------
  // HEADER WITH USERNAME
  // ----------------------
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hello, $_userName",
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "What would you like to cook today?",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  // ----------------------
  // CATEGORIES
  // ----------------------
  Widget _buildRecipeCategories() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip("Breakfast"),
          _buildCategoryChip("Dinner"),
          _buildCategoryChip("Launch"),
          _buildCategoryChip("Drinks"),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String title) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ----------------------
  // SECTION TITLE
  // ----------------------
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  // ----------------------
  // DYNAMIC RECIPES
  // ----------------------
  Widget _buildRecommendedRecipes() {
    if (recipes.isEmpty) {
      return const Center(child: Text("No recipes available"));
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return _buildRecipeCard(recipe);
        },
      ),
    );
  }
Widget _buildRecipeCard(Recipe recipe) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeDetailPage(recipe: recipe),
        ),
      );
    },
    child: Container(
      width: 180,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              recipe.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, size: 40),
              ),
            ),
            Container(color: Colors.black.withOpacity(0.3)),

            // Text content
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${recipe.steps.length} steps",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ----------------------
  // DYNAMIC INGREDIENTS
  // ----------------------
  Widget _buildIngredientsList() {
    if (ingredients.isEmpty) {
      return const Center(child: Text("No ingredients available"));
    }

    return Column(
      children:
          ingredients.map((ingredient) {
            return _buildIngredientItem(
              ingredient.name,
              ingredient.quantity ?? 'N/A',
            );
          }).toList(),
    );
  }

  Widget _buildIngredientItem(String name, String quantity) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 16)),
          Text(
            quantity,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
Widget _buildAboutSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),
      const Text(
        "About This Recipe Book",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
      const SizedBox(height: 10),

      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon or Image
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.book,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),

            // Dummy text
            const Expanded(
              child: Text(
                "Welcome to our Recipe Book app! "
                "Here you can explore a variety of delicious recipes, "
                "step-by-step cooking instructions, and detailed ingredient lists. "
                "Discover new dishes and make cooking fun and easy!",
                style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

}