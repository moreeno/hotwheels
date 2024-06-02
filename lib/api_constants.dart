class APIConstants {
  static const String apiBaseUrl = 'http://192.168.246.224:8000';

  //GETS
  static const String dbConnectionEndpoint = '/test-db-connection';
  static const String getUserCodeEndpoint = '/get-user-code/';
  static const String getAllHw = '/get-all-hotwheels';
  static const String getUserNumber = '/request-number/';

  static const String getUserRequests =
      '/get-user-requests'; // Asegúrate de tener este endpoint configurado
  static const String acceptRequest = '/accept-friend-request-by-code';
  static const String rejectRequest = '/reject-friend-request-by-code';

  static const String getCollection = '/collection?email=';
  static const String getWishlist = '/wishlist?email=';

  // POST
  static const String addHwToWishlist = '/add-hw-to-wishlist';
  static const String addHwToCollection = '/add-hw-to-collection';
  static const String checkWishlist = '/check-wishlist';
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';

  //DELETE
  static const String removeHwFromCollection = '/remove-hw-from-collection';
  static const String removeHwFromWishlist = '/remove-hw-from-wishlist';
}
