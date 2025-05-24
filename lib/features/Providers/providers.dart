
import 'package:riverpod/riverpod.dart';

import '../../data/repositories/authentication_repo/auth_repository.dart';
import '../../data/repositories/chat_repo/chat_repository.dart';


final chatProvider = Provider(
  (ref) => ChatRepository(),
);

final authProvider = Provider(
  (ref) => AuthRepository(),
);