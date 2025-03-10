import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartcampusadmin/amplify_outputs.dart';
import 'package:smartcampusadmin/createuser/bloc/manageusers_bloc.dart';
import 'package:smartcampusadmin/layout/layout.dart';
import 'package:smartcampusadmin/models/ModelProvider.dart';


Future<void> _configureAmplify() async {
  try {
    final api = AmplifyAPI(
        options: APIPluginOptions(modelProvider: ModelProvider.instance));
    final auth = AmplifyAuthCognito();
     final storage = AmplifyStorageS3();
    await Amplify.addPlugins([auth, api, storage]);
    await Amplify.configure(amplifyConfig);
  } on Exception catch (e) {
    safePrint('An error occurred configuring Amplify: $e');
  }
}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await _configureAmplify();
    runApp(MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ManageusersBloc(),
        ),
       
      ],
      child: const MyApp(),
    ));
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
         builder: Authenticator.builder(),
        home: LayoutPage(),
      ),
    );
  }
}