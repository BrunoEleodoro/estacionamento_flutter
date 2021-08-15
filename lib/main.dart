//import 'package:estacionamento_joao/pages/pagamento.dart';
import 'package:estacionamento/utils/routes.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';

import 'widgets/themes.dart';

// Build store and make it part of app
void main() {
  runApp(
    //VxState(
    //store: MyStore(),
    //child:
    MyApp(),
    //)
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system, //ThemeMode.light,
      theme: MyTheme.lightTheme(context),
      darkTheme: MyTheme.darkTheme(context),
      debugShowCheckedModeBanner: false,
      initialRoute: MyRoutes.homeRoute, //MyRoutes.loginRoute,
      routes: {
        "/": (context) => LoginPage(),
        MyRoutes.homeRoute: (context) => HomePage(),
        MyRoutes.loginRoute: (context) => LoginPage(),
        //MyRoutes.pagamento: (context) => Pagamento(),
      },
    );
  }
}
