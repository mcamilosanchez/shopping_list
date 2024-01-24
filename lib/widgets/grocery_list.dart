import 'dart:convert';

import 'package:flutter/material.dart';
/* 222. Adding the http Package
La palabra clave "as" le dice a Dart que todo el contenido que es proporcionado 
por este paquete debe ser agrupado en el objeto nombrado "http" (puede tener 
cualquier nombre) */
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
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
  List<GroceryItem> _groceryItems = [];

  var _isLoading = true;
  String? _error;

  /* 225. Fetching & Transforming Data
  Recordar que initState es un método que permite realizar algunas tareas de 
  inicialización. Y el trabajo de inicialización que quiero hacer aquí, es 
  ENVIAR MI SOLICITUD, es decir, listar los items. */
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  /* 225. Fetching & Transforming Data */
  void _loadItems() async {
    /* VIDEO #225. Fetching & Transforming Data
    Aquí volvimos de la navegación, podemos y debemos crear una nueva URL */
    final url = Uri.https(
        'flutter-prep-8ab88-default-rtdb.firebaseio.com', 'shopping-list.json');
    /* Recordar que get es para obtener datos, no para enviarlos */
    final response = await http.get(url);
    /* VIDEO #228. Error Response Handling
    Podemos avergiguar si la petición fue realizada correctamente, si es > 400 
    es un error. Entonces */
    if (response.statusCode >= 400) {
      /* Habría un error.
      Debo asegurarme que la UI se actualice si se produce un error. */
      setState(() {
        _error = 'Failed to fetch data. Please try again later. ';
      });
    }
    //print('Get response: ${response.body}');
    /*225. Fetching & Transforming Data 
    Aquí vamos a convertir los datos de response JSON a objetos y lo 
    almacenaremos en listData el cuál será un valor DINÁMICO y como las 
    respuestas json se parece a un map, definiremos listData como un map. Por 
    último, la convertiremos en una List<GroceryItem>.
    Se tiene que mirar response en la consola para poder entender el siguiente 
    código: final Map<String, Map<String, dynamic>>*/
    final List<GroceryItem> loadedItems = [];
    final Map<String, dynamic> listData = json.decode(response.body);
    for (final item in listData.entries) {
      /* Lo que estamos haciendo en la variable local category, no hay necesidad
      de hacerlo siempre, se hace en este caso particular ya que quiero hacer 
      más cosas con esta propiedad. De igual manera, ver video si hay duda*/
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    /* VIDEO #225. Fetching & Transforming Data
    Aquí ya no estamos recibiendo datos del pop, ya que lo estaremos realizando 
    desde peticiones http */
    /* VIDEO #226. Avoiding Unnecessary Requests
    Pero ahora en este video, si estamos recibiendo la información del request */
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
    /* VIDEO #225. Fetching & Transforming Data */
    // _loadItems();
  }

  void _removedItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    /* VIDEO #229. Sending DELETE Requests
    Para eliminar un item desde la BD de Firebase, necesito un ID. Por lo cual, 
    debemos incluir el ID del item que queremos eliminar en la URL, ya que si no
    lo hacemos pordríamos eliminar toda la lista.
    Es importante saber si esta petición se ejecutó exitosamente, ya que si 
    no se verifica, puede haber un error en la eliminación del item y pueda que 
    aparezca de nuevo en la lista. Por lo cual usaremos ASYNC en el método */
    final url = Uri.https('flutter-prep-8ab88-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      //Optional: Show error message
      /* Hubo un error en la petición delete. Por lo anterior, vamos a deshacer 
      esta eliminación: _groceryItems.remove(item). Lo haremos de la siguiente 
      manera: */
      setState(() {
        /*Recordar que INSERT, es un método incorporado por DART que se puede 
        usar en cualquier lista para agregar un elemento (item) en un específico
        índice (index) en la lista. */
        _groceryItems.insert(index, item);
      });
    }
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
    /* VIDEO #227. Managing the Loading State */
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

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

    /* 228. Error Response Handling */
    if (_error != null) {
      //Hay un error, entonces:
      content = Center(
        child: Text(_error!),
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
