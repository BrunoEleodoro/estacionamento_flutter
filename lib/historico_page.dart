import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoricPage extends StatefulWidget {
  const HistoricPage({Key? key}) : super(key: key);

  @override
  _HistoricPageState createState() => _HistoricPageState();
}

class _HistoricPageState extends State<HistoricPage> {
  List<dynamic> historico = [
    {
      'titulo': 'RG: 123, Placa: ABC, horario_entrada: 2323, horario_saida',
    }
  ];

  void listarHistoricoBancoDeDados() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> historicoDatabase =
        jsonDecode(prefs.getString('historico').toString());

    setState(() {
      historico = historicoDatabase;
    });
  }

  @override
  void initState() {
    super.initState();
    listarHistoricoBancoDeDados();
  }

  @override
  Widget build(BuildContext context) {
    print('historico');
    print(historico);
    return Scaffold(
        appBar: AppBar(title: Text('Historico')),
        body: ListView.separated(
            itemCount: historico.length,
            separatorBuilder: (context, index) {
              return Divider();
            },
            itemBuilder: (context, index) {
              return ListTile(title: Text(historico[index]["titulo"]));
            }));
  }
}
