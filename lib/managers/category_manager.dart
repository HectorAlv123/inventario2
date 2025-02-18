class CategoryManager {
  static final CategoryManager instance = CategoryManager._internal();

  CategoryManager._internal();

  List<String> categories = []; // Inicialmente vacía.

  void addCategory(String category) {
    if (!categories.contains(category)) {
      categories.add(category);
    }
  }

  void removeCategory(String category) {
    categories.remove(category);
  }
}
