import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:smartcampusadmin/mod/usersmodel.dart';
import 'package:smartcampusadmin/utils.dart';

class ManageuserMethod {
  createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    const graphQLDocument =
        '''mutation MyMutation(\$email:AWSEmail!, \$password :String!, \$username : String! ) {
             createUser(email: \$email, password: \$password, username: \$username)
           }
            ''';
    final echoRequest = GraphQLRequest<String>(
      document: graphQLDocument,
      variables: <String, String>{
        "email": email,
        "password": password,
        "username": name
      },
    );
    final response = await Amplify.API.query(request: echoRequest).response;
    print(response);
    Map<String, dynamic> jsonMap = json.decode(response.data!);
    List res = graphqlresponsehandle(
        response: response,
        function: () {
          String userId = jsonMap["createUser"];
          return userId;
        });
    return res;
  }

  listUsersInGroup() async {
    const graphQLDocument = '''query MyQuery {
              users: listUsersInGroup(groupName: "STAFF")
              }''';
    final echoRequest = GraphQLRequest<String>(
      document: graphQLDocument,
    );
    final response = await Amplify.API.query(request: echoRequest).response;
    Map<String, dynamic> jsonMap = json.decode(response.data!);
    var res = graphqlresponsehandle(
        response: response,
        function: () {
          String studens = jsonMap['users'];
          List<dynamic> studentslist = jsonDecode(studens);
          List<UserModel> studentsmodels = [];
          for (int i = 0; i < studentslist.length; i++) {
            Map<String, String> resultMapstudens = {
              for (var item in studentslist[i]) item['Name']!: item['Value']!
            };
            UserModel model = UserModel.fromMap(resultMapstudens);
            studentsmodels.add(model);
          }
          return studentsmodels;
        });
    return res;
  }
}
