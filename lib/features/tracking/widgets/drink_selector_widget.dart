import 'package:flutter/material.dart';
import '../../../core/services/drink_database_service.dart';

class DrinkSelectorWidget extends StatefulWidget {
  final Function(DrinkInfo) onDrinkSelected;
  final List<String> favoriteDrinkIds;
  final DrinkInfo? initialSelection;

  const DrinkSelectorWidget({
    super.key,
    required this.onDrinkSelected,
    this.favoriteDrinkIds = const [],
    this.initialSelection,
  });

  @override
  State<DrinkSelectorWidget> createState() => _DrinkSelectorWidgetState();
}

class _DrinkSelectorWidgetState extends State<DrinkSelectorWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<DrinkInfo> _favoriteDrinks = [];
  List<DrinkInfo> _basicDrinks = [];
  List<DrinkInfo> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = true;
  DrinkInfo? _selectedDrink;

  @override
  void initState() {
    super.initState();
    _selectedDrink = widget.initialSelection;
    _loadDrinks();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadDrinks() async {
    setState(() => _isLoading = true);
    
    try {
      final drinkService = DrinkDatabaseService.instance;
      
      // Load favorites and basic drinks
      _favoriteDrinks = await drinkService.getFavoriteDrinks(widget.favoriteDrinkIds);
      _basicDrinks = await drinkService.getBasicDrinks();
      
      // Remove favorites from basic drinks to avoid duplicates
      _basicDrinks = _basicDrinks.where((drink) => 
        !widget.favoriteDrinkIds.contains(drink.id)).toList();
      
    } catch (e) {
      debugPrint('Error loading drinks: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() => _isSearching = true);
    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await DrinkDatabaseService.instance.searchDrinks(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      debugPrint('Error searching drinks: $e');
    }
  }

  void _selectDrink(DrinkInfo drink) {
    setState(() {
      _selectedDrink = drink;
    });
    widget.onDrinkSelected(drink);
    
    // Clear search when selection is made
    if (_isSearching) {
      _searchController.clear();
      _searchFocusNode.unfocus();
    }
  }

  Widget _buildDrinkCard(DrinkInfo drink, {bool isSelected = false}) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
      child: InkWell(
        onTap: () => _selectDrink(drink),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildDrinkIcon(drink.category),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      drink.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                drink.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${drink.standardDrinks} drink${drink.standardDrinks != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (drink.ingredients.length > 1) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        drink.ingredients.join(', '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrinkIcon(String category) {
    IconData iconData;
    Color iconColor;
    
    switch (category) {
      case 'beer':
        iconData = Icons.sports_bar;
        iconColor = Colors.amber;
        break;
      case 'wine':
        iconData = Icons.wine_bar;
        iconColor = Colors.purple;
        break;
      case 'spirits':
        iconData = Icons.local_bar;
        iconColor = Colors.brown;
        break;
      case 'cocktails':
        iconData = Icons.local_drink;
        iconColor = Colors.teal;
        break;
      default:
        iconData = Icons.local_drink;
        iconColor = Colors.grey;
    }
    
    return Icon(iconData, color: iconColor, size: 20);
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search for cocktails, beer, wine...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchFocusNode.unfocus();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        _buildSearchBar(),
        
        if (_isSearching) ...[
          // Search results
          _buildSectionHeader('Search Results', Icons.search),
          if (_searchResults.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No drinks found matching "${_searchController.text}"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            )
          else
            ..._searchResults.map((drink) => _buildDrinkCard(
              drink, 
              isSelected: _selectedDrink?.id == drink.id,
            )),
        ] else ...[
          // Favorites section
          if (_favoriteDrinks.isNotEmpty) ...[
            _buildSectionHeader('Your Favorites', Icons.favorite),
            ..._favoriteDrinks.map((drink) => _buildDrinkCard(
              drink, 
              isSelected: _selectedDrink?.id == drink.id,
            )),
          ],
          
          // Basic drinks section
          _buildSectionHeader('Quick Select', Icons.local_drink),
          ..._basicDrinks.map((drink) => _buildDrinkCard(
            drink, 
            isSelected: _selectedDrink?.id == drink.id,
          )),
          
          const SizedBox(height: 16),
          
          // Search hint
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Looking for something specific? Use the search bar above to find cocktails, mixed drinks, and more!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 24),
      ],
    );
  }
}
