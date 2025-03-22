import 'package:flutter/material.dart';
import '../Models/productos_model.dart';
import '../Models/categoria_model.dart';
import 'info_screen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../services/producto_services.dart';
import '../store/app_colors.dart';
import '../widgets/card_categorias.dart';

class TiendaScreen extends StatefulWidget {
  const TiendaScreen({super.key});

  @override
  State<TiendaScreen> createState() => _TiendaScreenState();
}

const TextStyle tituloScreenFont = TextStyle(
  fontSize: 30,
  fontWeight: FontWeight.bold,
);

class _TiendaScreenState extends State<TiendaScreen> {
  late Future<List<Producto>> futureProductos;
  List<Categoria> categorias = [];
  int activo = 0;
  final ScrollController _scrollController = ScrollController();
  final Map<String, List<String>> filtros = {
    "Material": ["Todos", "Oro", "Plata", "Otros"],
    "Genero": ["Todos", "Mujer", "Hombre", "Unisex"]
  };
  String? materialSeleccionado = "Todos";
  String? generoSeleccionado = "Todos";
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    futureProductos = ProductoService().fetchProductos();
  }

  void _onRefresh() async {
    // Actualizar datos al hacer el pull down refresh
    setState(() {
      futureProductos = ProductoService().fetchProductos();
    });
    // Si la carga fue exitosa, finaliza la animación de refresh
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // Cargar más datos si es necesario
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  List<Categoria> extractCategorias(List<Producto> productos) {
    final Map<int, Categoria?> categoriasMap = {};

    for (var producto in productos) {
      categoriasMap[producto.idCategoria] = producto.categoria;
    }

    return categoriasMap.values.whereType<Categoria>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Center(
            
          ),
        ),
        FutureBuilder<List<Producto>>(
          future: futureProductos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 40,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 40,
                child: Center(
                  child: Text(
                    "Error al cargar productos: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 40,
                child: Center(
                  child: Text("No hay productos disponibles"),
                ),
              );
            } else {
              // Extract categories from products
              final productos = snapshot.data!;
              categorias = extractCategorias(productos);

              // Add "Todas" category at the beginning
              final List<Categoria> categoriasConTodas = [
                Categoria(idCategoria: 0, nombre: "Todas"),
                ...categorias,
              ];

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(categoriasConTodas.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: CardCategorias(
                        categoria: categoriasConTodas[index],
                        index: index,
                        activo: activo,
                        onTap: (int newIndex) {
                          setState(() {
                            activo = newIndex;
                          });
                          Future.delayed(Duration.zero, () {
                            if (_scrollController.hasClients) {
                              _scrollController.jumpTo(0);
                            }
                          });
                        },
                      ),
                    );
                  }),
                ),
              );
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "Material",
                  filtros["Material"]!,
                  materialSeleccionado,
                  (value) {
                    setState(() {
                      materialSeleccionado = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDropdown(
                  "Genero",
                  filtros["Genero"]!,
                  generoSeleccionado,
                  (value) {
                    setState(() {
                      generoSeleccionado = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Producto>>(
            future: futureProductos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            futureProductos =
                                ProductoService().fetchProductos();
                          });
                        },
                        child: const Text("Reintentar"),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 60, color: AppColors.subtitle),
                      SizedBox(height: 16),
                      Text(
                        "No hay productos disponibles",
                        style:
                            TextStyle(fontSize: 18, color: AppColors.subtitle),
                      ),
                    ],
                  ),
                );
              } else {
                final productos = snapshot.data!;

                // Apply filters
                final productosFiltrados = _filtrarProductos(productos);

                if (productosFiltrados.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list,
                            size: 60, color: AppColors.subtitle),
                        SizedBox(height: 16),
                        Text(
                          "No hay productos que coincidan con los filtros",
                          style: TextStyle(
                              fontSize: 18, color: AppColors.subtitle),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return SmartRefresher(
                  enablePullDown: true,
                  header: const WaterDropHeader(
                    waterDropColor: AppColors.primary,
                    complete: Icon(Icons.check, color: AppColors.primary),
                  ),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: productosFiltrados.length,
                    itemBuilder: (context, index) {
                      final producto = productosFiltrados[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductoInfoScreen(producto: producto),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  child: producto.file != null
                                      ? Image.network(
                                          producto.file,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Container(
                                              color: Colors.grey[200],
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          (loadingProgress
                                                                  .expectedTotalBytes ??
                                                              1)
                                                      : null,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(
                                                    Icons.image_not_supported,
                                                    size: 50),
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(
                                                Icons.image_not_supported,
                                                size: 50),
                                          ),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      producto.nombre,
                                      textAlign: TextAlign.left,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          producto.material,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.subtitle,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          producto.genero,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.subtitle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "LPS. ${producto.precio.toStringAsFixed(2)}",
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.subtitle),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedValue,
                icon:
                    const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: AppColors.title, fontSize: 14),
                onChanged: onChanged,
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Producto> _filtrarProductos(List<Producto> productos) {
    return productos.where((producto) {
      bool filtroPorCategoria = activo == 0;

      if (activo > 0 &&
          categorias.isNotEmpty &&
          activo - 1 < categorias.length) {
        String selectedCategoryName = categorias[activo - 1].nombre;

        filtroPorCategoria = producto.categoria.nombre.toLowerCase() ==
            selectedCategoryName.toLowerCase();
      }

      // Filter by material
      bool filtroPorMaterial = materialSeleccionado == "Todos" ||
          producto.material.toLowerCase() ==
              materialSeleccionado?.toLowerCase();

      // Filter by gender
      bool filtroPorGenero = generoSeleccionado == "Todos" ||
          producto.genero.toLowerCase() == generoSeleccionado?.toLowerCase();

      return filtroPorCategoria && filtroPorMaterial && filtroPorGenero;
    }).toList();
  }
}
