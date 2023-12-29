class TokenManager {
  static String authToken = "";

  static void setToken(String token) {
    authToken = token;
  }

  static String getToken() {
    return authToken;
  }
}
