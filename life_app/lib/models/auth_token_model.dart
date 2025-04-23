class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['token'],
      refreshToken: json['refreshToken'],
      expiresIn: json['expiresIn'],
      tokenType: json['tokenType'] ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'tokenType': tokenType,
    };
  }
}
