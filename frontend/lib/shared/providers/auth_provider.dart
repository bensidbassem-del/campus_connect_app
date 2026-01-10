import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/models/user_model.dart';

final authProvider = StateProvider<AppUser?>((ref) => null);
