import 'package:flutter/material.dart';
/* 222. Adding the http Package
La palabra clave "as" le dice a Dart que todo el contenido que es proporcionado 
por este paquete debe ser agrupado en el objeto nombrado "http" (puede tener 
cualquier nombre) */
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  /* 213. Getting Form Access via a Global Key
  La diferencia entre GlobalKey() y ValueKey(), es que la primera también nos da
  fácil acceso al widget subyacente al que está conectado y asegura que si ese 
  método build se ejecuta de nuevo, porque establecemos algún estado. Este 
  widget de formulario no se RECONSTRUYE, en su lugar mantiene su estado interno, 
  esto es importante que trabajaremos con ese estado, por ejemplo, este estado 
  le dirá a Flutter si mostrar o no algunos errores de validación. En conclusión,
  siempre que trabajemos con formularios, debemos manejar GlobalKeys.

  Con esto añadido <FormState> le estoy diciendo a Flutter que el widget o el 
  objeto al que se conectará esta GlobalKey será un objeto de FormState.
  */
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  void _saveItem() {
    /* VIDEO #213. Getting Form Access via a Global Key
    El objetivo de esta funcion es activar la validación. Lo podemos hacer ya
    que _formKey está conectada al formulario y desde ella, podemos acceder a la
    propiedad currentState (recordar que al poner ! estamos diciéndole a Dart 
    que nunca será Null).
    Al momento de presionar el botón, el formulario ya se habrá creado y la 
    clave del formulario se habrá adjuntado.

    validate() retorna un bool: true si todas las funciones del validador han 
    pasado o false, si al menos una función del validador falló. De esta manera,
    estamos habilitando las validaciones del formulario que podrían devolver 
    mensajes de error . */
    if (_formKey.currentState!.validate()) {
      /* VIDEO #214. Extracting Entered Values
    Al llamar el método guardar, se activará una función especial en todos estos
    widgets de campo formulario dentro del formulario */
      _formKey.currentState!.save();
      /* 215. Passing Data Between Screens
      Recordar que para cerrar esta pantalla y pasar los valores a dicha 
      pantalla, usamos .pop y en el argumento debemos enviar la infomación */
      Navigator.of(context).pop(
        GroceryItem(
          id: DateTime.now().toString(),
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        /* VIDEO #209. The Form & TextFormField Widgets */
        child: Form(
          /* VIDEO #213. Getting Form Access via a Global Key
          Para ejecutar todas la validaciones que realizamos en los campos de 
          texto dentro del formulario, necesitaremos un acceso a esos campos por
          medio de KEY */
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  /* VIDEO #212. Adding Validation Logic 
                  Realizaremos una validación para el campo de texto */
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters';
                  }
                  /* Si esta función retorna un null, es porque la validación se
                  realizó de manera correcta, es decir, el valor es válido */
                  return null;
                },
                /* 214. Extracting Entered Values
                Esta función recibe el valor que se introdujo en este campo de 
                texto como argumento (value) y este será el valor en el momento 
                en que se ejecute .save */
                onSaved: (value) {
                  /* Recordar que al escribir ! estamos 
                  dejando claro que value nunca será nulo o se podría hacer de 
                  la siguiente manera, pero sería redundante: */
                  // if (value == null) {
                  //   return;
                  // }
                  _enteredName = value!;
                },
              ), //instead of TextField()
              Row(
                /* Recordar que para que los hijos estén alineados entre sí, 
                usamos la propiedad crossAxisAlignment*/
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  /* VIDEO #210. A Form-aware Dropdown Button 
                  Si debajo de este children, ubicamos un TextFormField habría 
                  un error de renderización, ya que al final estamos usando un 
                  campo de texto en lugar de una fila. Recordar que el campo de 
                  texto es un unconstrained horizontalmente, por eso el error. 
                  Se soluciona usando Expanded. */
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        /* VIDEO #212. Adding Validation Logic 
                        Realizaremos una validación para el campo de texto */
                        if (value == null ||
                            value.isEmpty ||
                            /* tryParse retorna un null si falla al convertir la
                            cadena a un número */
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid, positive number';
                        }
                        /* Si esta función retorna un null, es porque la 
                        validación se realizó de manera correcta, es decir, el 
                        valor es válido */
                        return null;
                      },
                      onSaved: (value) {
                        /* La diferencia entre parse y tryParse es que parse 
                        arrojará un error si no consigue convertir la cadena, 
                        mientras que tryParse devuelve un null. Igualmente, esta
                        verificación la realizamos en el condicional anterior */
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        /* VIDEO #210. A Form-aware Dropdown Button
                      Aquí vamor a realizar un loop (for) para recorrer una 
                      lista, pero categories no es una lista, es un map. Por lo 
                      cual, usaremos entries, es una propiedad proporcionada por 
                      Flutter en cada map, entries le da un ITERABLE que al 
                      final contiene todos los pares clave-valor de su mapa como 
                      elementos en ese iterable. */
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        /* VIDEO #214. Extracting Entered Values
                        Es necesario restablecer el estado ya que la categoría 
                        seleccionada se utiliza para establecer el valor visible
                        actualmente y por supuesto, debe permanecer en sincronía
                        con lo que hemos seleccionado en el menú desplegable y 
                        debe actualizarse cada vez que cambiamos nuestra 
                        selección para que el valor seleccionado actualmente se 
                        refleja en la pantalla */
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                /* Empujamos todos los botones hacía la derecha */
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _saveItem,
                    child: const Text('Add item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
