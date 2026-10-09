import 'package:built_value/built_value.dart';

part 'auth_state.g.dart';

abstract class AuthState implements Built<AuthState, AuthStateBuilder> {
  String? get token;
  String? get username;

  bool get isLoggedIn => token != null;

  AuthState._();
  factory AuthState([void Function(AuthStateBuilder)? updates]) = _$AuthState;
}
