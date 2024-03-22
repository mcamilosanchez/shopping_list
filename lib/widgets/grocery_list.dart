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

  //var _isLoading = true;
  /* VIDEO #233. Using the FutureBuilder Widget */
  late Future<List<GroceryItem>> _loadedItems;

  /* 225. Fetching & Transforming Data
  Recordar que initState es un método que permite realizar algunas tareas de 
  inicialización. Y el trabajo de inicialización que quiero hacer aquí, es 
  ENVIAR MI SOLICITUD, es decir, listar los items. */
  @override
  void initState() {
    super.initState();
    /* VIDEO #233. Using the FutureBuilder Widget */
    _loadedItems = _loadItems();
  }

  /* 225. Fetching & Transforming Data */
  Future<List<GroceryItem>> _loadItems() async {
    /* VIDEO #225. Fetching & Transforming Data
    Aquí volvimos de la navegación, podemos y debemos crear una nueva URL */
    final url = Uri.https(
        'flutter-prep-8ab88-default-rtdb.firebaseio.com', 'shopping-list.json');

    /* VIDEO #231. Better Error Handling
    Pueden aparecer errores no generados por el backend, por ejemplo si no hay 
    internet o si se escribió mal la dirección de la url. En este caso, los 
    podemos manejar con TRY & CATCH: */
    //try {
    /* Recordar que get es para obtener datos, no para enviarlos */
    final response = await http.get(url);
    /* VIDEO #228. Error Response Handling
      Podemos avergiguar si la petición fue realizada correctamente, si es > 400 
      es un error. Entonces */
    if (response.statusCode >= 400) {
      /* Habría un error.
        Debo asegurarme que la UI se actualice si se produce un error. */
      // setState(() {
      //   _error = 'Failed to fetch data. Please try again later. ';
      // });
      // Ya no es necesario restablecer el estado, gracias a FutureBuilder
      throw Exception('Failed to fetch grocery items. Please try again later.');
    }
    //print('Get response: ${response.body}');
    /* VIDEO #230. Handling the "No Data" Case
      El problema aquí es que si no tengo elementos en la respuesta Firebase, el 
      body no producirá el map listData. Por lo tanto, añadiremos la siguiente 
      comprobación: */
    if (response.body == 'null') {
      //Esto significa que no tenemos nada en el backend y no ejecutaremos más
      //código, por eso escribimos el return y restablecemos el estado.
      // setState(() {
      //   _isLoading = false;
      // });
      // Ya no es necesario restablecer el estado, gracias a FutureBuilder
      return [];
    }
    //////////////////////////////////////////////////////////////////////////
    /*225. Fetching & Transforming Data 
      Aquí vamos a convertir los datos de response JSON a objetos y lo 
      almacenaremos en listData el cuál será un valor DINÁMICO y como las 
      respuestas json se parece a un map, definiremos listData como un map. Por 
      último, la convertiremos en una List<GroceryItem>.
      Se tiene que mirar response en la consola para poder entender el siguiente 
      código: final Map<String, Map<String, dynamic>>*/
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      /* Lo que estamos haciendo en la variable local category, no hay 
        necesidad de hacerlo siempre, se hace en este caso particular ya que 
        quiero hacer más cosas con esta propiedad. De igual manera, ver video 
        si hay duda*/
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
    // setState(() {
    //   _groceryItems = loadedItems;
    //   _isLoading = false;
    // });
    return loadedItems;
    // } catch (error) {
    //   /* Este objeto "error" podría contener información útil respecto al error,
    //   información más detallada */
    //   setState(() {
    //     _error = 'Something went wrong!. Please try again later. ';
    //   });
    // }
  }

  void _addItem() async {
    /* VIDEO #225. Fetching & Transforming Data
    Aquí ya no estamos recibiendo datos del pop, ya que lo estaremos realizando 
    desde peticiones http */
    /* VIDEO #226. Avoiding Unnecessary Requests
    Pero ahora en este video, si estamos recibiendo la información del request*/
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
    //Widget content = const Center(child: Text('Try adding a new item'));
    /* VIDEO #227. Managing the Loading State */
    // if (_isLoading) {
    //   content = const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }

    // if (_groceryItems.isNotEmpty) {
    //   content = ListView.builder(
    //     itemCount: _groceryItems.length,
    //     itemBuilder: (ctx, index) => Dismissible(
    //       /* 216. Final Challenge Solution */
    //       key: ValueKey(_groceryItems[index].id),
    //       onDismissed: (direction) {
    //         _removedItem(_groceryItems[index]);
    //       },
    //       child: ListTile(
    //         title: Text(_groceryItems[index].name),
    //         leading: Container(
    //           width: 24,
    //           height: 24,
    //           color: _groceryItems[index].category.color,
    //         ),
    //         trailing: Text(
    //           _groceryItems[index].quantity.toString(),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    /* 228. Error Response Handling */
    // if (_error != null) {
    //   //Hay un error, entonces:
    //   content = Center(child: Text(_error!));
    // }

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
      /* VIDEO #233. Using the FutureBuilder Widget
      Este widget necesita al menos dos parámetros: el futuro, que debe escuchar
      al final y el builder, que requiere de una función que se ejecute cada vez
      que el futuro produzca datos. Por lo tanto, es una función que recibe un 
      context (proporcionado por Flutter) y un snapshot que nos da acceso al 
      estado actual del futuro y a los datos que se hayan podido producir. Al 
      final, quiero tener un FUTURO que produzca List<GroceryItem> loadedItems 
      una vez que obtuvimos el response de get. Para obtener dicha lista, 
      debemos cambiar el void _loadedItems para que retorne una 
      List<GroceryItem>, como este void tiene async el cual obliga al método 
      retornar un Futuro, por lo cual queda de la siguiente manera:

      Future<List<GroceryItem>> _loadItems() async {  ...
        
      Buscar dicho método arriba del código para ver los cambios.
      Además, ya no hay necesidad de manejar TRY & CATCH con FutureBuilder, ya 
      que podemos manejar los errores de una manera diferente, donde se necesita
      menos código. Por lo anterior, quitamos el TRY&CATCH de _loadItems().

      En future, no deseamos llamar _loadItems() ya que se considera una mala 
      practica. Debido a dicha función se ejecutaría cada vez que se llame a 
      build, por lo cual, ésta función de aquí (GroceryList) solo debe 
      ejecutarse una vez en el widget GroceryList cuando se cargue por primera 
      vez, ya que es el único momento en el que queremos RECUPERAR datos. 
      Entonces lo que debemos hacer es iniciar el estado, es decir initState. 
      Por eso, más arriba del código, hacemos lo siguiente:

        @override
        void initState() {
          super.initState();
          _loadedItems = _loadItems();
        }
      
      Por eso, en el parámetro de future asignamos _loadedItems
      */
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          /* Ahora que tenemos este futuro (_loadedItems) en este método 
          constructor debemos retornar un widget o diferentes widgets basados en 
          el estado actual del futuro. Para eso, tenemos SNAPSHOT la cual se usa 
          para EVALUAR el estado actual de ese futuro (_loadedItems)*/
          if (snapshot.connectionState == ConnectionState.waiting) {
            /* ConnectionState.waiting vendría siendo el estado inicial cuando 
          enviamos la petición y aún estemos esperando la respuesta. Y si 
          estamos esperando un resultado, queremos devolver nuestro spinner de 
          carga: */
            return const Center(child: CircularProgressIndicator());
          }
          /* Ahora, si no estamos esperando, significa que tenemos un resultado. 
          Pero el resultado, puede ser un ERROR o que tenga datos. Entonces 
          realizamos lo siguiente */
          if (snapshot.hasError) {
            /* Esto será cierto si nuestro futuro ha sido rechazado. Es decir, 
            si en _loadedItems() internamente ha arrojado un error. Por ejemplo,
            si get lanza una excepción por falta de conexión a internet, el 
            futuro será RECHAZADO. Por eso, si vamos a la línea de código 65, en
            el condicional del statusCode escribimos: throw Exception() es 
            decir, lanzamos nuestra propia excepción.
            Ahora, para obtener el mensaje de Exception de la línea 65 hacemos 
            lo siguiente: */
            Center(child: Text(snapshot.error.toString()));
          }
          /* Luego, si no hay un error, es porque tenemos los datos y aquí 
          quiero dar salida a mi ListView o el 
          Center(child: Text('Try adding a new item')) por si no hay items en el
          backend. Entonces realizamos otro condicional: */
          if (snapshot.data!.isEmpty) {
            /* Si es cierto, es decir, no hay datos en la lista o null y el 
            signo ! es porque sabemos que no será null debido a los 
            condicionales anteriores. Hacemos lo siguiente: */
            const Center(child: Text('Try adding a new item'));
          }
          /* Y si superamos la comprobación if anterior, sabremos que los datos 
          no estarán vacíos, existe una lista de comestibles. Entonces, podemos 
          retornar aquí el ListView.builder: */

          return ListView.builder(
            /* Aquí habría un error, ya que estamos inflando el ListView.builder
            con la lista _groceryItems y no debería ser así. Ya que estamos 
            dentro de FutureBuilder y el dato que estoy esperando está adentro 
            de snapshot. Por lo anterior, cambiamos _groceryItems por 
            snapshot.data! y sabemos que este valor nunca será nulo (debido a 
            las condiciones anteriores) por eso escribimos ! */
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, index) => Dismissible(
              /* 216. Final Challenge Solution */
              key: ValueKey(snapshot.data![index].id),
              onDismissed: (direction) {
                _removedItem(snapshot.data![index]);
              },
              child: ListTile(
                title: Text(snapshot.data![index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: snapshot.data![index].category.color,
                ),
                trailing: Text(
                  snapshot.data![index].quantity.toString(),
                ),
              ),
            ),
          );
        },
        /* IMPORTANTE: HAY UN GRAN PROBLEMA CON FUTUREBUILDER YA QUE SI LOS 
        DATOS SE CARGAN CORRECTAMENTE, EL MÉTODO CONSTRUCTOR (BUILDER) DE 
        FUTUREBUILDER NUNCA SE EJECUTARÁ DE NUEVO, incluso si llamo setState. 
        Esto genera errores, por ejemplo si quiero añadir un nuevo elemento la 
        UI no se actualizará o si elimino un item, aparecerá un error.
        
        En conclusión, NO es aconsejable usar FutureBuilder en esta app debido a
        la complejidad de esta pantalla. Pero si tuviéramos una pantalla o un 
        widget dónde sólo necesitamos cargar datos, mostrar diferentes estados 
        en función de si has terminado de cargar o no y NO TIENES NINGUNA OTRA 
        LÓGICA RELACIONADA CON LOS DATOS */
      ),
    );
  }
}
