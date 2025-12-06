import 'package:flutter/material.dart';
import '../../models/ingredients.dart';
import '../../db/ingrdient_database.dart';

class AddIngredientPage extends StatefulWidget {
  const AddIngredientPage({super.key});
  
  @override
  State<AddIngredientPage> createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  DateTime? _expirationDate;

  List<Ingredient> _ingredients = [];

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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  Future<void> _saveIngredient() async {
    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final qty = _quantityCtrl.text.trim();

    if (name.isEmpty) return;

    final newIngredient = Ingredient(
      name: name,
      description: desc,
      quantity: qty,
      expirationDate: _expirationDate,
    );

    await IngredientDatabase.instance.createIngredient(newIngredient);

    await _loadIngredients();

    _nameCtrl.clear();
    _descCtrl.clear();
    _quantityCtrl.clear();
    setState(() => _expirationDate = null);
  }

  Future<void> _removeIngredient(Ingredient ingredient) async {
    if (ingredient.id != null) {
      await IngredientDatabase.instance.deleteIngredient(ingredient.id!);
    }
    await _loadIngredients();
  }

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[50],
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Ingredients List
          Expanded(
            child: _ingredients.isEmpty
                ? const Center(
                    child: Text(
                      "No ingredients added yet",
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    itemCount: _ingredients.length,
                    itemBuilder: (context, index) {
                      final ing = _ingredients[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange[100],
                            child: const Icon(Icons.fastfood, color: Colors.orange),
                          ),
                          title: Text(
                            ing.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (ing.quantity != null && ing.quantity!.isNotEmpty)
                                Text("Quantity: ${ing.quantity}"),
                              if (ing.description != null && ing.description!.isNotEmpty)
                                Text("Notes: ${ing.description}"),
                              if (ing.expirationDate != null)
                                Text(
                                  "Expires: ${ing.expirationDate!.toLocal().toString().split(' ')[0]}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: ing.expirationDate!.isBefore(DateTime.now()) ||
                                            ing.expirationDate!.difference(DateTime.now()) <
                                                const Duration(days: 3)
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeIngredient(ing),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.orange[200], thickness: 1.2),
          const SizedBox(height: 8),
          // Input fields (moved to bottom)
          _buildTextField(_nameCtrl, "Ingredient Name", Icons.restaurant),
          const SizedBox(height: 12),
          _buildTextField(_quantityCtrl, "Quantity (e.g. 2kg, 500ml)", Icons.scale),
          const SizedBox(height: 12),
          _buildTextField(_descCtrl, "Description", Icons.notes, maxLines: 2),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _expirationDate == null
                      ? "No expiration date chosen"
                      : "Expires: ${_expirationDate!.toLocal().toString().split(' ')[0]}",
                  style: TextStyle(
                    color: _expirationDate == null ? Colors.black54 : Colors.orange[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
                onPressed: _pickDate,
                icon: const Icon(Icons.date_range),
                label: const Text("Pick Date"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveIngredient,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Add Ingredient", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orange, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }
}