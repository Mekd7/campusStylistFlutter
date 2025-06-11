import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusstylistflutter/services/api_service.dart';
import 'package:campusstylistflutter/providers/api_provider.dart';
import 'package:campusstylistflutter/viewmodel/client_home_view_model.dart';

final clientHomeProvider = ChangeNotifierProvider<ClientHomeViewModel>(
      (ref) => ClientHomeViewModel(ref.read(apiServiceProvider)),
);