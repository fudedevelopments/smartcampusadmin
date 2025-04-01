import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

Future<void> fetchCurrentUserAttributes() async {
  try {
    final result = await Amplify.Auth.fetchUserAttributes();
    safePrint(result);
  } on AuthException catch (e) {
    safePrint('Error fetching user attributes: ${e.message}');
  }
}

List graphqlresponsehandle({
  required GraphQLResponse response,
  required Function function,
  List? emptyListresponse,
}) {
  if (response.hasErrors) {
    String error = response.errors[0].message;
    return [500, error];
  }
  if (emptyListresponse != null && emptyListresponse.isEmpty) {
    return [300, null];
  } else {
    return [200, function()];
  }
}

void handlebloc({
  required int statuscode,
  required VoidCallback success,
  required VoidCallback failure,
  VoidCallback? empty,
}) {
  if (statuscode == 200) {
    success();
  } else if (statuscode == 500) {
    failure();
  } else if (statuscode == 300 && empty != null) {
    empty();
  }
}

void showsnakbar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

navigatorpushandremove(BuildContext context, Widget route) {
  Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (context) => route), (route) => false);
}

navigationpush(BuildContext context, Widget route) {
  Navigator.push(context, (MaterialPageRoute(builder: (context) => route)));
}

pop(BuildContext context) {
  Navigator.pop(context);
}

Future<String> getimage({required String path}) async {
  final result = await Amplify.Storage.getUrl(
    path: StoragePath.fromString(path),
  ).result;
  final url = result.url;
  final urlstr = url.toString();
  return urlstr;
}

void showLoadingDialog(BuildContext context) {
  showDialog(
    barrierDismissible:
        false,
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading... Please wait'),
            ],
          ),
        ),
      );
    },
  );
}
