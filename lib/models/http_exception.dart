class HttpException implements Exception {
// Exception is an abstract lass meaning we can't directly instantiate it
// when we implement a class we are forced to all functions inside it
// every class in dart has a toString() method since every class in dart invisibly extends Object
// Object is the base class in dart which every object is based on
// but implements overrides that because normally toString() of classes prints what type of class it is
// However we want to display a message
  final String message;

  HttpException(this.message);

  @override
  String toString() {
    return message;
  }
}
