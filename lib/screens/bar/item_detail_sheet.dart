import 'package:flutter/material.dart';
import 'bar_menu_screen.dart'; // Importe para ter acesso aos modelos MenuItem e Topping

class ItemDetailSheet extends StatefulWidget {
  final MenuItem item;
  final Color themeColor;

  const ItemDetailSheet({
    super.key,
    required this.item,
    required this.themeColor,
  });

  @override
  State<ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<ItemDetailSheet> {
  int _quantity = 1;
  Topping? _selectedTopping; // Armazena o topping selecionado

  @override
  void initState() {
    super.initState();
    // Se houver toppings, pré-seleciona o primeiro
    if (widget.item.toppings.isNotEmpty) {
      _selectedTopping = widget.item.toppings.first;
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  double get _totalPrice {
    double toppingPrice = _selectedTopping?.price ?? 0.0;
    return (_quantity * (widget.item.price + toppingPrice));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Define a cor de fundo e os cantos arredondados
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Faz o modal ter a altura do conteúdo
        children: [
          // Imagem do item
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: Image.network(
              widget.item.imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Conteúdo de texto e opções
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preço e Seletor de Quantidade
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'R\$ ${widget.item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: widget.themeColor,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, color: widget.themeColor),
                            onPressed: _decrementQuantity,
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: widget.themeColor),
                            onPressed: _incrementQuantity,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nome e Descrição
                Text(
                  widget.item.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.item.description,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),

                // Divisor e Seção de Toppings (se houver)
                if (widget.item.toppings.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Toppings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Usando um ListView para as opções, caso sejam muitas
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.item.toppings.length,
                    itemBuilder: (context, index) {
                      final topping = widget.item.toppings[index];
                      return RadioListTile<Topping>(
                        title: Text(topping.name),
                        value: topping,
                        groupValue: _selectedTopping,
                        onChanged: (Topping? value) {
                          setState(() {
                            _selectedTopping = value;
                          });
                        },
                        secondary: Text(
                          '+ R\$${topping.price.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        activeColor: widget.themeColor,
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),

          // Botão de Adicionar ao Carrinho
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Lógica para adicionar ao carrinho
                  print('Adicionado: $_quantity x ${widget.item.name}');
                  if (_selectedTopping != null) {
                    print('Com topping: ${_selectedTopping!.name}');
                  }
                  print('Preço Total: R\$${_totalPrice.toStringAsFixed(2)}');

                  // Fecha o modal
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item adicionado ao carrinho!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  'Adicionar (R\$${_totalPrice.toStringAsFixed(2)})',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
