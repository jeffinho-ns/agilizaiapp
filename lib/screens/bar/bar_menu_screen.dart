// lib/screens/bar/bar_menu_screen.dart

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/bar_model.dart'; // Importe Bar para acessar o slug
import 'package:agilizaiapp/data/bar_data.dart'; // Importe os dados dos bares
import 'item_detail_sheet.dart'; // Importando a nova tela de detalhes
import 'package:collection/collection.dart'; // <--- NOVO: Importe firstWhereOrNull

// --- MODELOS DE DADOS --- (Permanecem como estão)
class Topping {
  final String name;
  final double price;

  Topping({required this.name, required this.price});
}

class MenuItem {
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<Topping> toppings;

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.toppings = const [],
  });
}

class MenuCategory {
  final String name;
  final List<MenuItem> items;

  MenuCategory({
    required this.name,
    required this.items,
  });
}

// --- DADOS MOCKADOS (EXEMPLO COMPLETO) --- (Permanecem como estão)
final Map<String, List<MenuCategory>> barMenus = {
  'seujustino': [
    MenuCategory(
      name: 'Entradinhas',
      items: [
        MenuItem(
          name: 'Justino Fries with Cheddar Cream',
          description: 'French fries with cheddar and smoked sausage farofa.',
          price: 46.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/1eb6dcf0-6642-11ef-a44d-f10c103cb578.jpg',
        ),
        MenuItem(
          name: 'Crispy Chicken Strips',
          description:
              'Breaded chicken strips in corn flakes flour. Served with spicy citrus mayonnaise.',
          price: 46.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/09fafb60-6643-11ef-a44d-f10c103cb578.jpg',
        ),
      ],
    ),
    MenuCategory(
      name: 'Lanches',
      items: [
        MenuItem(
          name: 'Sanduíche de bife de parmesão no pão francês',
          description:
              'Sanduíche de filé mignon à parmegiana no pão francês. Servido com batatas fritas.',
          price: 52.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/fa858420-6647-11ef-938a-a76c2488c351.jpg',
          toppings: [
            Topping(name: 'Bacon extra', price: 4.00),
            Topping(name: 'Cebola caramelizada', price: 3.50),
            Topping(name: 'Ovo', price: 2.50),
          ],
        ),
        MenuItem(
          name: 'Justa Burger',
          description:
              'Cheeseburger de 180g com queijo prato, bacon, picles de pepino e cebola roxa. Acompanha batata frita e maionese.',
          price: 48.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/353be190-6648-11ef-938a-a76c2488c351.jpg',
          toppings: [
            Topping(name: 'Bacon extra', price: 4.00),
            Topping(name: 'Batata', price: 3.50),
            Topping(name: 'Molho', price: 2.50),
          ],
        ),
      ],
    ),
    MenuCategory(
      name: 'Principal',
      items: [
        MenuItem(
          name: 'Bife à parmegiana',
          description:
              'Bife empanado com molho de tomate rústico, coberto com queijo mussarela derretido. Servido com arroz e fritas.',
          price: 58.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/a0523260-6646-11ef-938a-a76c2488c351.jpg',
        ),
        MenuItem(
          name: 'Risoto de Limão Siciliano',
          description: 'Risoto clássico de limao siciliano.',
          price: 46.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/7291d5a0-be17-11ef-aff9-d1b98f4953c6.jpg',
        ),
      ],
    ),
    MenuCategory(
      name: 'Chapas',
      items: [
        MenuItem(
          name: 'Bife de Fraldinha Grelhado 1953',
          description:
              'Fraldinha na chapa, acompanhada de batata frita, farofa e vinagrete.',
          price: 139.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/2fca2180-be28-11ef-aff9-d1b98f4953c6.jpg?ims=filters:quality(70):format(webp)',
        ),
        MenuItem(
          name: 'Carne Seca Grelhada',
          description:
              'Carne-seca desfiada, passada na manteiga de garrafa com cebola dourada e pimenta biquinho. Servida com vinagrete e mandioca frita.',
          price: 89.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/d59eb7a0-be29-11ef-aff9-d1b98f4953c6.jpg?ims=filters:quality(70):format(webp)',
        ),
      ],
    ),
    MenuCategory(
      name: 'Saladas',
      items: [
        MenuItem(
          name: 'Salada Caesar de Frango',
          description:
              'Mini alface americana e romana com espeto de medalhão de frango e bacon, molho Caesar, parmesão e croutons.',
          price: 46.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/1538b440-2b6e-11f0-bb82-33a551cf21f9.jpg?ims=filters:quality(70):format(webp)',
        ),
      ],
    ),
    MenuCategory(
      name: 'Sobremesas',
      items: [
        MenuItem(
          name: 'Pote de Nutella',
          description:
              'Sorvete de creme, ganache de Nutella, chantilly e canudo biju.',
          price: 32.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/47143d20-be29-11ef-aff9-d1b98f4953c6.jpg?ims=filters:quality(70):format(webp)',
        ),
      ],
    ),
  ],
  'pracinha': [
    MenuCategory(
      name: 'Para compartilhar!',
      items: [
        MenuItem(
          name: 'Carne Guioza',
          description:
              'Diretamente da Feira da Liberdade, 6 pastéis finos e fritos, recheados com carne bovina, servidos com molho de gergelim.',
          price: 38.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/b6f08a60-5f04-11ef-8b79-1d6149ef83bb.jpg?ims=filters:quality(70):format(webp)',
        ),
        MenuItem(
          name: 'faturamento de pizza',
          description:
              'Queijo, tomate e orégano. O sabor da comida de rua para petiscar com os amigos. Podemos sentir falta do caldo de cana, mas com certeza uma das nossas bebidas vai te refrescar.',
          price: 36.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/6c8d27c0-5f05-11ef-8b79-1d6149ef83bb.jpg?ims=filters:quality(70):format(webp)',
        ),
      ],
    ),
    MenuCategory(
      name: 'Sanduiches',
      items: [
        MenuItem(
          name: 'X-Picanha Burger',
          description:
              'Clássico e bem feito, hambúrguer de picanha, mussarela e batata frita. Direto ao ponto.',
          price: 38.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/cdd05600-5f06-11ef-8b79-1d6149ef83bb.jpg?ims=filters:quality(70):format(webp)',
          toppings: [
            Topping(name: 'Provolone', price: 5.00),
            Topping(name: 'Batata', price: 3.00),
          ],
        ),
        MenuItem(
          name: 'Estadao Sandwich',
          description:
              'Perna de porco super suculenta, com cebola, um toque de churrasco e muito queijo derretido!!',
          price: 38.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/149789a0-5f07-11ef-8b79-1d6149ef83bb.jpg?ims=filters:quality(70):format(webp)',
          toppings: [
            Topping(name: 'Provolone', price: 5.00),
            Topping(name: 'Batata', price: 3.00),
          ],
        ),
      ],
    ),
    MenuCategory(
      name: 'Espetos',
      items: [
        MenuItem(
          name: 'Espeto de carne',
          description:
              'Seja no estádio, na saída do clube, no trem ou no metrô, sempre podemos contar com um espeto para matar a fome. Aqui, ele é sempre servido com bastante farofa e vinagrete.',
          price: 16.00,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/a2f8aa30-5f07-11ef-8b79-1d6149ef83bb.jpg?ims=filters:quality(70):format(webp)',
        ),
      ],
    ),
    MenuCategory(
      name: 'Drinks',
      items: [
        MenuItem(
          name: 'Classic Caipirinha',
          description:
              'Frutas disponíveis: limão, morango, uva verde, abacaxi, maracujá.',
          price: 28.00,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/Product/41cbda80-6000-11ef-8b79-1d6149ef83bb.jpg?ims=filters:quality(70):format(webp)',
          toppings: [
            Topping(name: 'Cachaça Salinissíma', price: 32.90),
            Topping(name: 'Vodka Tuvalu', price: 34.90),
            Topping(name: 'Absolut Vodka', price: 38.90),
            Topping(name: 'Vodka Elyx', price: 48.90),
          ],
        ),
      ],
    ),
  ],
  'highline': [
    MenuCategory(
      name: 'Aperitivos',
      items: [
        MenuItem(
          name: 'Bolinho de Costela Defumada',
          description:
              'Carne desfiada e marcada pelo sabor intenso da defumação, envolta em massa crocante. Acompanha barbecue',
          price: 42.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/7f8a57a0-1164-11f0-9d96-b5544eadcadd.jpg?ims=filters:quality(70):format(webp)',
        ),
        MenuItem(
          name: 'Burrata',
          description:
              'Burrata cremosa de búfala recheada com molho pesto! Acompanhada de tomates-cereja confitados, tapenade de azeitonas, rúcula e torrada.',
          price: 88.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/3075c900-1165-11f0-9d96-b5544eadcadd.jpg?ims=filters:quality(70):format(webp)',
        ),
      ],
    ),
    MenuCategory(
      name: 'Hamburgueres',
      items: [
        MenuItem(
          name: 'Mini Sanduíche de Carpaccio',
          description:
              'Carpaccio rústico, marinado em ervas frescas, maionese de alcaparras, lascas de parmesão e brotos de rúcula',
          price: 52.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/02ebdd30-1160-11f0-9d96-b5544eadcadd.jpg?ims=filters:quality(70):format(webp)',
          toppings: [
            Topping(name: 'Batata Frita', price: 12.00),
            Topping(name: 'Onion Rings', price: 15.00),
          ],
        ),
        MenuItem(
          name: 'Hambúrguer fofo',
          description:
              'Delicioso hambúrguer de filé mignon, com rúcula e mix de queijos. Acompanha fritas',
          price: 54.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/3140ac60-1160-11f0-9d96-b5544eadcadd.jpg?ims=filters:quality(70):format(webp)',
          toppings: [
            Topping(name: 'Batata Frita', price: 12.00),
            Topping(name: 'Onion Rings', price: 15.00),
          ],
        ),
      ],
    ),
    MenuCategory(
      name: 'Principal',
      items: [
        MenuItem(
          name: 'O Oceano',
          description:
              'Deliciosa massa com tinta de lula, acompanhada de pequenos camarões salteados na manteiga, brotos e tomate cereja, finalizada com um toque do nosso azeite de ervas.',
          price: 74.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/b2b37d20-1162-11f0-bd3f-d523131bd650.jpg?ims=filters:quality(70):format(webp)',
        ),
        MenuItem(
          name: 'Risoto de cogumelos com medalhão de filé mignon',
          description:
              'Risoto de cogumelos hidratados ao vinho branco, com medalhão de filé mignon aromatizado com azeite trufado.',
          price: 76.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/bc7da230-1163-11f0-bd3f-d523131bd650.jpg?ims=filters:quality(70):format(webp)',
        ),
      ],
    ),
    MenuCategory(
      name: 'Sobremesas',
      items: [
        MenuItem(
          name: 'Da Vinci',
          description:
              'Criação original da casa. Sobremesa com um leve sabor de doce de leite, base de cream cheese, pedaços de biscoito Oreo entre biscoitos de chocolate e ganache. Finalizada com caldas de caramelo e framboesa.',
          price: 42.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/9eb78270-115e-11f0-9d96-b5544eadcadd.jpg?ims=filters:quality(70):format(webp)',
        ),
      ],
    ),
  ],
  'ohfregues': [
    MenuCategory(
      name: 'Entradinhas',
      items: [
        MenuItem(
          name: 'Justino Fries with Cheddar Cream',
          description: 'French fries with cheddar and smoked sausage farofa.',
          price: 46.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/1eb6dcf0-6642-11ef-a44d-f10c103cb578.jpg',
        ),
        MenuItem(
          name: 'Crispy Chicken Strips',
          description:
              'Breaded chicken strips in corn flakes flour. Served with spicy citrus mayonnaise.',
          price: 46.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/09fafb60-6643-11ef-a44d-f10c103cb578.jpg',
        ),
      ],
    ),
    MenuCategory(
      name: 'Lanches',
      items: [
        MenuItem(
          name: 'Sanduíche de bife de parmesão no pão francês',
          description:
              'Sanduíche de filé mignon à parmegiana no pão francês. Servido com batatas fritas.',
          price: 52.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/fa858420-6647-11ef-938a-a76c2488c351.jpg',
          toppings: [
            Topping(name: 'Bacon extra', price: 4.00),
            Topping(name: 'Cebola caramelizada', price: 3.50),
            Topping(name: 'Ovo', price: 2.50),
          ],
        ),
        MenuItem(
          name: 'Justa Burger',
          description:
              'Cheeseburger de 180g com queijo prato, bacon, picles de pepino e cebola roxa. Acompanha batata frita e maionese.',
          price: 48.90,
          imageUrl:
              'https://static.tagme.com.br/pubimg/thumbs/MenuItem/353be190-6648-11ef-938a-a76c2488c351.jpg',
          toppings: [
            Topping(name: 'Bacon extra', price: 4.00),
            Topping(name: 'Batata', price: 3.50),
            Topping(name: 'Molho', price: 2.50),
          ],
        ),
      ],
    ),
    MenuCategory(
      name: 'Drinks',
      items: [
        MenuItem(
          name: 'Manzana',
          description:
              'Gin 142, energético Baly de maçã verde, xarope de maçã verde, finalizado com espuma cítrica e hortelã.',
          price: 29.90,
          imageUrl:
              'https://dg-media.com.br/cardapio/produto_379187.png?v=624943130',
          toppings: [
            Topping(name: 'Com Cachaça Premium', price: 8.00),
            Topping(name: 'Com Vodka', price: 6.00),
          ],
        ),
      ],
    ),
    MenuCategory(
      name: 'Gin',
      items: [
        MenuItem(
          name: 'Gin Tônica Mule',
          description:
              'Gin & Tônica Clássico com deliciosa espuma artesanal cítrica',
          price: 26.90,
          imageUrl:
              'https://dg-media.com.br/cardapio/produto_379233.png?v=179357896',
        ),
      ],
    ),
    MenuCategory(
      name: 'Cervejas',
      items: [
        MenuItem(
          name: 'Corona Long Neck',
          description: 'Corona Long Neck, cremosa e gelada.',
          price: 16.90,
          imageUrl:
              'https://dg-media.com.br/cardapio/produto_379237.png?v=822150555',
        ),
      ],
    ),
    MenuCategory(
      name: 'Destilados',
      items: [
        MenuItem(
          name: 'Gin 142',
          description: 'Dose de Gin 142, perfeito para compartilhar.',
          price: 24.90,
          imageUrl:
              'https://dg-media.com.br/cardapio/produto_379979.png?v=1294786646',
        ),
      ],
    ),
  ],
};

// --- WIDGET DA TELA ---

class BarMenuScreen extends StatefulWidget {
  final int barId; // Alterado para int barId
  final Color appBarColor;

  const BarMenuScreen({
    super.key,
    required this.barId, // Agora espera barId
    this.appBarColor = Colors.deepPurple,
  });

  @override
  State<BarMenuScreen> createState() => _BarMenuScreenState();
}

class _BarMenuScreenState extends State<BarMenuScreen> {
  late List<MenuCategory> _currentMenu;
  int _selectedCategoryIndex = 0;
  String _barName = 'Cardápio'; // Para exibir no AppBar

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  void _loadMenu() {
    // Busca o Bar pelo ID na lista allBars
    // Usando firstWhereOrNull para evitar erros se o barId não for encontrado
    final Bar? bar = allBars.firstWhereOrNull(
      (b) => b.id == widget.barId,
    );

    if (bar != null) {
      _barName = bar.name; // Usa o nome real do bar
      // <<-- CORREÇÃO AQUI: bar.slug deve ser usado para buscar no barMenus
      final standardizedBarName =
          removeDiacritics(bar.slug.toLowerCase()).replaceAll(' ', '');
      _currentMenu = barMenus[standardizedBarName] ?? [];
    } else {
      _currentMenu = [];
      _barName = 'Cardápio não encontrado';
    }

    if (_currentMenu.isNotEmpty) {
      _selectedCategoryIndex =
          _currentMenu.indexWhere((category) => category.items.isNotEmpty);
      if (_selectedCategoryIndex == -1) {
        _selectedCategoryIndex = 0;
      }
    }
    setState(
        () {}); // Atualiza o estado para reconstruir a UI com o menu carregado
  }

  bool _isColorDark(Color color) {
    return color.computeLuminance() < 0.5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _barName, // Usa o nome do bar encontrado
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: widget.appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _currentMenu.isEmpty
          ? const Center(
              child: Text(
                'Cardápio não disponível no momento.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _currentMenu.length,
                      itemBuilder: (context, index) {
                        final category = _currentMenu[index];
                        final isSelected = _selectedCategoryIndex == index;
                        Color textColor;

                        if (isSelected) {
                          textColor = _isColorDark(widget.appBarColor)
                              ? Colors.white
                              : Colors.black;
                        } else {
                          textColor = Colors.black87;
                        }

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? widget.appBarColor
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: textColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: _currentMenu.isEmpty ||
                          _currentMenu[_selectedCategoryIndex].items.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhum item nesta categoria.',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount:
                              _currentMenu[_selectedCategoryIndex].items.length,
                          itemBuilder: (context, itemIndex) {
                            final item = _currentMenu[_selectedCategoryIndex]
                                .items[itemIndex];

                            return GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    return ItemDetailSheet(
                                      item: item,
                                      themeColor: widget.appBarColor,
                                    );
                                  },
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(15)),
                                      child: Image.network(
                                        item.imageUrl,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: double.infinity,
                                            height: 200,
                                            color: Colors.grey[300],
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey[600],
                                              size: 50,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            item.description,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey[700],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 12.0),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              'R\$ ${item.price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: widget.appBarColor,
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
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
