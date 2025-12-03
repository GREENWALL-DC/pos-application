/*
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopx/application/products/product_notifier.dart';

class UserDashboard extends HookConsumerWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productNotifierProvider);

    useEffect(() {
      ref.read(productNotifierProvider.notifier).fetchProducts();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(title: const Text("User Dashboard")),
      body: productState.error != null
          ? Center(child: Text("Error: ${productState.error}"))
          : productState.products.isEmpty
              ? const Center(child: Text("No products available"))
              : ListView.builder(
                  itemCount: productState.products.length,
                  itemBuilder: (_, index) {
                    final product = productState.products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text("${product.category} • ₹${product.price}"),
                    );
                  },
                ),
    );
  }
}

 "username": "employee1",
  "email": "employee1@gmail.com",
  "password": "12345678",
  "phone": "9876543210"

*/

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopx/application/cart/cart_notifier.dart';
import 'package:shopx/application/products/product_state.dart';
import 'package:shopx/core/constants.dart';
import 'package:shopx/domain/products/product.dart';
import 'package:shopx/application/auth/auth_notifier.dart'; // Adjust if path differs
// Import your provider file location
import 'package:shopx/application/products/product_notifier.dart';
import 'package:shopx/presentation/cart/add_quantity_dialog.dart';
import 'package:shopx/presentation/cart/cart_screen.dart'; // Ensure this points to where you defined productNotifierProvider

class UserDashboard extends HookConsumerWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Fetch products on initial load
    useEffect(() {
      Future.microtask(() {
        ref.read(productNotifierProvider.notifier).fetchProducts();
      });
      return null;
    }, []);

    // 2. Watch State
    final productState = ref.watch(productNotifierProvider);
    final user = ref.watch(authNotifierProvider).user;

    // 3. Local UI State (Hooks)
    final isGridView = useState(true); // Toggle Grid/List
    final isSearchActive = useState(false); // Toggle Search Bar
    final searchQuery = useState(""); // Search Text
    final searchController = useTextEditingController();
    final sortOption = useState("All"); // Sorting: All, LowToHigh, HighToLow

    // 4. Filter & Sort Logic
    List<Product> getProcessedProducts() {
      List<Product> items = List.from(productState.products);

      // Filter by Search
      if (searchQuery.value.isNotEmpty) {
        items = items
            .where(
              (p) =>
                  p.name.toLowerCase().contains(
                    searchQuery.value.toLowerCase(),
                  ) ||
                  p.category.toLowerCase().contains(
                    searchQuery.value.toLowerCase(),
                  ),
            )
            .toList();
      }

      // Sort
      if (sortOption.value == "LowToHigh") {
        items.sort((a, b) => a.price.compareTo(b.price));
      } else if (sortOption.value == "HighToLow") {
        items.sort((a, b) => b.price.compareTo(a.price));
      }

      return items;
    }

    final displayProducts = getProcessedProducts();

    return Scaffold(
     backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER (Time, Menu, Username) ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.blue),
                    onPressed: () {
                      // Handle Menu
                    },
                  ),
                  Text(
                    user?.username ?? "UserName", // Dynamic Username
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  // Placeholder for spacing to center title relative to screen
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // --- CONTROLS (Search, View Toggle, Sort) ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: isSearchActive.value
                  ? _buildSearchBar(
                      isSearchActive,
                      searchQuery,
                      searchController,
                    )
                  : _buildControlBar(isSearchActive, isGridView, sortOption),
            ),

            // --- PRODUCT CONTENT ---
            Expanded(
              child: productState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : productState.error != null
                  ? Center(child: Text("Error: ${productState.error}"))
                  : displayProducts.isEmpty
                  ? const Center(child: Text("No products found."))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: isGridView.value
                          ? _buildGridView(displayProducts,ref)
                          : _buildListView(displayProducts,ref),
                    ),
            ),

            // --- BOTTOM CART BAR ---
            _buildBottomCartBar(context,displayProducts.length),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildControlBar(
    ValueNotifier<bool> isSearchActive,
    ValueNotifier<bool> isGridView,
    ValueNotifier<String> sortOption,
  ) {
    return Row(
      children: [
        // Sort Dropdown
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value:
                  sortOption.value == "All" ||
                      sortOption.value == "LowToHigh" ||
                      sortOption.value == "HighToLow"
                  ? sortOption.value
                  : "All",
              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
              isExpanded: true,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              items: const [
                DropdownMenuItem(value: "All", child: Text("All products")),
                DropdownMenuItem(
                  value: "LowToHigh",
                  child: Text("Price: Low to High"),
                ),
                DropdownMenuItem(
                  value: "HighToLow",
                  child: Text("Price: High to Low"),
                ),
              ],
              onChanged: (val) {
                if (val != null) sortOption.value = val;
              },
            ),
          ),
        ),

        // Vertical Divider
        Container(height: 20, width: 1, color: Colors.grey[300]),
        const SizedBox(width: 8),

        // Search Icon
        IconButton(
          icon: Icon(Icons.search,color: Colors.black),
          onPressed: () => isSearchActive.value = true,
        ),

        // Barcode Icon (Mock)
        IconButton(
          icon: Image.asset("assets/images/bar-code.png",
          width: 20,
          height: 20,
          color: Colors.black
          ),
          onPressed: () => isSearchActive.value = true,
        ),

        // View Toggle Icon
        IconButton(
          icon: Icon(
            isGridView.value ? Icons.list : Icons.grid_view,
            color: Colors.black54,
          ),
          onPressed: () => isGridView.value = !isGridView.value,
        ),
      ],
    );
  }

  Widget _buildSearchBar(
    ValueNotifier<bool> isSearchActive,
    ValueNotifier<String> searchQuery,
    TextEditingController controller,
  ) {
    return Row(
      children: [
        const Icon(Icons.search, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Search...",
              border: InputBorder.none,
            ),
            onChanged: (val) => searchQuery.value = val,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () {
            searchQuery.value = "";
            controller.clear();
            isSearchActive.value = false;
          },
        ),
      ],
    );
  }

  // --- GRID VIEW IMPLEMENTATION ---
  Widget _buildGridView(List<Product> products,WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75, // Adjust height ratio
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image (Placeholder)
                Expanded(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: product.images.isEmpty
                          ? const Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                "http://localhost:5000" + product.images.first,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                    ),
                  ),
                ),

                kHeight10,
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SAR ${product.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    InkWell(
onTap: () {
  showDialog(
    context: context,
    builder: (_) => AddQuantityDialog(
      product: product,
      availableStock: product.quantity,   // ✅ stock from backend
      onAddToCart: (qty) {
        // 1️⃣ Add to cart provider
        ref.read(cartProvider.notifier).addToCart(product, qty);

        // 2️⃣ Show message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Added to cart"),
            duration: Duration(seconds: 2),
          ),
        );
      },
    ),
  );
},

                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- LIST VIEW IMPLEMENTATION ---
  Widget _buildListView(List<Product> products,WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 10, bottom: 80),
      itemCount: products.length,
      separatorBuilder: (c, i) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          height: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: product.images.isEmpty
                    ? const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          "http://localhost:5000" + product.images.first,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),

              const SizedBox(width: 15),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      product.category,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "SAR ${product.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Add Button
              InkWell(
                onTap: () {
  showDialog(
    context: context,
    builder: (_) => AddQuantityDialog(
      product: product,
      availableStock: product.quantity,   // ✅ stock from backend
      onAddToCart: (qty) {
        // 1️⃣ Add to cart provider
        ref.read(cartProvider.notifier).addToCart(product, qty);

        // 2️⃣ Show message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Added to cart"),
            duration: Duration(seconds: 2),
          ),
        );
      },
    ),
  );
},

                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- BOTTOM CART SUMMARY BAR ---
  Widget _buildBottomCartBar(BuildContext context,int count) {
    // Note: 'Total' is hardcoded or sum of displayed items for UI purposes.
    // In real app, connect this to a CartProvider
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0), // Darker Blue
        borderRadius: BorderRadius.circular(15),
      ),
      child:
      
      Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
      },
      child: Row(
        children: [
          const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            "$count elements",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),

    const Text(
      "Total: SAR 0.00",
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  ],
)



    );
  }

  // --- BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNavBar() {
  return Container(
    height: 70,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          blurRadius: 10,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        Icon(Icons.grid_view_rounded, color: Colors.blue, size: 38),
        Icon(Icons.edit_note, color: Colors.grey, size: 38),
      ],
    ),
  );
}

}
