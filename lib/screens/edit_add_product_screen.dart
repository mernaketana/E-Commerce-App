import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

class EditAddProductScreen extends StatefulWidget {
  const EditAddProductScreen({Key? key}) : super(key: key);
  static const routeName = 'edit-add-product-screen';

  @override
  _EditAddProductScreenState createState() => _EditAddProductScreenState();
}

class _EditAddProductScreenState extends State<EditAddProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: '', description: '', imageUrl: '', price: 0, title: '');
  var _isInit = true;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments as String?;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    _descFocusNode.dispose();
    _priceFocusNode
        .dispose(); //Since focusNodes don't clear out on their own -> we have to do that to free up the memory and avoid memory leaks
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      } else {
        setState(() {});
      }
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState?.validate();
    if (!isValid!) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != '') {
      await Provider.of<Products>(context, listen: false)
          .update(_editedProduct.id, _editedProduct);
      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
        Navigator.of(context).pop();
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('An error occured'),
                  content: const Text('Something went wrong'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Ok')),
                  ],
                ));
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product'), actions: <Widget>[
        IconButton(onPressed: _saveForm, icon: const Icon(Icons.add))
      ]),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                  // autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _form,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          initialValue: _initValues['title'],
                          decoration: const InputDecoration(
                            labelText: 'Title',
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_priceFocusNode);
                          },
                          onSaved: (e) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                description: _editedProduct.description,
                                imageUrl: _editedProduct.imageUrl,
                                price: _editedProduct.price,
                                isFavourite: _editedProduct.isFavourite,
                                title: e as String);
                          },
                          validator: (e) {
                            // return null; // Means the input is correct
                            // return 'Some Text'; // Means the input is incorrect
                            if (e!.isEmpty) {
                              return 'This field cannot be empty';
                            } else {
                              return null;
                            }
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['price'],
                          decoration: const InputDecoration(
                            labelText: 'Price',
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          focusNode: _priceFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_descFocusNode);
                          },
                          onSaved: (e) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                description: _editedProduct.description,
                                imageUrl: _editedProduct.imageUrl,
                                price: double.parse(e as String),
                                isFavourite: _editedProduct.isFavourite,
                                title: _editedProduct.title);
                          },
                          validator: (e) {
                            if (e!.isEmpty) {
                              return 'This field cannot be empty';
                            }
                            if (double.tryParse(e) == null) {
                              return 'Please enter a valid number';
                            }
                            if (double.parse(e) <= 0) {
                              return 'Please enter a number greater that zero';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['description'],
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          focusNode: _descFocusNode,
                          onSaved: (e) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                description: e as String,
                                imageUrl: _editedProduct.imageUrl,
                                price: _editedProduct.price,
                                isFavourite: _editedProduct.isFavourite,
                                title: _editedProduct.title);
                          },
                          validator: (e) {
                            if (e!.isEmpty) {
                              return 'This field cannot be empty';
                            }
                            if (e.length < 10) {
                              return 'The description should be at least 10 characters long';
                            }
                            return null;
                          },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(top: 8, right: 10),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                              ),
                              child: _imageUrlController.text.isEmpty
                                  ? const Text('Enter a URL')
                                  : FittedBox(
                                      child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Image URL',
                                ),
                                keyboardType: TextInputType.url,
                                focusNode: _imageUrlFocusNode,
                                controller: _imageUrlController,
                                textInputAction: TextInputAction.done,
                                onSaved: (e) {
                                  _editedProduct = Product(
                                      id: _editedProduct.id,
                                      description: _editedProduct.description,
                                      imageUrl: e as String,
                                      price: _editedProduct.price,
                                      isFavourite: _editedProduct.isFavourite,
                                      title: _editedProduct.title);
                                },
                                validator: (e) {
                                  if (e!.isEmpty) {
                                    return 'This field cannot be empty';
                                  }
                                  if (!e.startsWith('http') &&
                                      !e.startsWith('https')) {
                                    return 'Please enter a valid URL';
                                  }
                                  if (!e.endsWith('.png') &&
                                      !e.endsWith('.jpg') &&
                                      !e.endsWith('.jpeg')) {
                                    return 'Please enter a valid URL';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  _saveForm();
                                },
                                onEditingComplete: () {
                                  setState(() {
                                    // even though it's empty it forces flutter to rebuild picking up the latest image value entered
                                  }); //I haven't seen that video yet
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )),
            ),
    );
  }
}
