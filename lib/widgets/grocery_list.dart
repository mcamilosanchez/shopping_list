import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() {
    return _GroceryListState();
  }
}

class _GroceryListState extends State<GroceryList> {
  /* 215. Passing Data Between Screens */
  final List<GroceryItem> _groceryItems = [];
  /* 215. Passing Data Between Screens
  Al momento de cerrar la pantalla NewItem por medio de .pop, llega la 
  información del nuevo item. Para eso, debemos escribir async en el método 
  _addItem() y await para recuperar los datos. newItem puede ser un VALOR NULO, 
  ya que el usuario puede salir de la pantalla presionando la tecla atrás sin 
  haber guardado */
  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    /* Entonces, como newItem puede ser nulo, realizamos lo siguiente: */
    if (newItem == null) {
      return;
    }
    /* Si se salta el condicional, es porque se tiene un nuevo elemento, 
    entonces debe ser agregado a la _groceryItems. Podemos hacerlo de la 
    siguiente manera:

    _groceryItems = newItem;

    Peor sería un error ya que _groceryItems en final. Por lo anterior, 
    usaremos add() */
    setState(() {
      /* Llamamos setState ya que queremos ejecutar el método build de nuevo 
      porque ahora quiero usar artículos de comestibles en mi UI*/
      _groceryItems.add(newItem);
    });
  }

  void _removedItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Uh oh ... nothing here!'),
          SizedBox(height: 16),
          Text('Try adding a new item')
        ],
      ),
    );
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          /* 216. Final Challenge Solution */
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) {
            _removedItem(_groceryItems[index]);
          },
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
