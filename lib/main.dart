import 'dart:convert';

import 'package:estacionamento/historico_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> vagas = [
    {
      'key': 'vaga1',
      'title': 'Vaga 1',
      'placa': '',
      'rg': '',
      'ocupado': false,
      'horario_entrada': '',
      'horario_saida': ''
    },
    {
      'key': 'vaga2',
      'title': 'Vaga 2',
      'placa': '',
      'rg': '',
      'ocupado': false,
      'horario_entrada': '',
      'horario_saida': ''
    },
    {
      'key': 'vaga3',
      'title': 'Vaga 3',
      'placa': '',
      'rg': '',
      'ocupado': false,
      'horario_entrada': '',
      'horario_saida': ''
    },
    {
      'key': 'vaga4',
      'title': 'Vaga 4',
      'placa': '',
      'rg': '',
      'ocupado': false,
      'horario_entrada': '',
      'horario_saida': ''
    },
    {
      'key': 'vaga5',
      'title': 'Vaga 5',
      'placa': '',
      'rg': '',
      'ocupado': false,
      'horario_entrada': '',
      'horario_saida': ''
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString('vagas') == null) {
        prefs.setString('vagas', jsonEncode(vagas));
        prefs.setString('historico', jsonEncode([]));
      }
      listarVagasDoBancoDeDados();
    });
  }

  void ocuparVaga(String key) {
    TextEditingController placaController = new TextEditingController();
    TextEditingController rgController = new TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Preencha os dados'),
              content: Container(
                height: 400,
                child: Column(children: [
                  TextFormField(
                      controller: placaController,
                      decoration: InputDecoration(
                          labelText: 'Placa', border: OutlineInputBorder())),
                  SizedBox(height: 20),
                  TextFormField(
                      controller: rgController,
                      decoration: InputDecoration(
                          labelText: 'RG', border: OutlineInputBorder())),
                ]),
              ),
              actions: [
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('CANCELAR')),
                MaterialButton(
                    onPressed: () async {
                      String placa = placaController.text;
                      String rg = rgController.text;
                      print(placa);
                      print(rg);

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      List<dynamic> vagas =
                          jsonDecode(prefs.getString('vagas').toString());

                      int i = 0;
                      while (i < vagas.length) {
                        if (vagas[i]["key"] == key) {
                          vagas[i]["placa"] = placa;
                          vagas[i]["rg"] = rg;
                          vagas[i]["ocupado"] = true;
                          vagas[i]["horario_entrada"] =
                              DateTime.now().millisecondsSinceEpoch;
                        }
                        i++;
                      }

                      prefs.setString('vagas', jsonEncode(vagas));
                      listarVagasDoBancoDeDados();
                      Navigator.pop(context);
                    },
                    child: Text('SALVAR')),
              ]);
        });
  }

  void desocuparVaga(String key) {
    TextEditingController placaController = new TextEditingController();
    TextEditingController rgController = new TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Preencha os dados'),
              content: Container(
                height: 400,
                child: Column(children: [
                  TextFormField(
                      controller: placaController,
                      decoration: InputDecoration(
                          labelText: 'Placa', border: OutlineInputBorder())),
                  SizedBox(height: 20),
                  TextFormField(
                      controller: rgController,
                      decoration: InputDecoration(
                          labelText: 'RG', border: OutlineInputBorder())),
                ]),
              ),
              actions: [
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('CANCELAR')),
                MaterialButton(
                    onPressed: () async {
                      String placa = placaController.text;
                      String rg = rgController.text;
                      print(placa);
                      print(rg);

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      List<dynamic> vagas =
                          jsonDecode(prefs.getString('vagas').toString());
                      List<dynamic> historico =
                          jsonDecode(prefs.getString('historico').toString());

                      int i = 0;
                      while (i < vagas.length) {
                        if (vagas[i]["key"] == key) {
                          if (vagas[i]["placa"] == placa &&
                              vagas[i]["rg"] == rg) {
                            vagas[i]["placa"] = "";
                            vagas[i]["rg"] = "";
                            vagas[i]["ocupado"] = false;
                            vagas[i]["horario_saida"] =
                                DateTime.now().millisecondsSinceEpoch;

                            var horarioEntradaDate =
                                new DateTime.fromMicrosecondsSinceEpoch(
                                    vagas[i]["horario_entrada"]);
                            var horarioSaidaDate =
                                new DateTime.fromMicrosecondsSinceEpoch(
                                    vagas[i]["horario_saida"]);

                            String dateEntradaSlug =
                                "${horarioEntradaDate.day.toString().padLeft(2, '0')}-${horarioEntradaDate.month.toString().padLeft(2, '0')}-${horarioEntradaDate.year.toString()}";
                            String dateSaidaSlug =
                                "${horarioSaidaDate.day.toString().padLeft(2, '0')}-${horarioSaidaDate.month.toString().padLeft(2, '0')}-${horarioSaidaDate.year.toString()}";

                            //TODO: Mudar aqui e fazer o calculo de horas de permancencia no estacionamento
                            final difference = horarioSaidaDate
                                .difference(horarioEntradaDate)
                                .inMinutes;

                            historico.add({
                              'titulo':
                                  'Placa: $placa, RG: $rg, permanecendo $difference horas na vaga : ${vagas[i]["title"]}'
                            });
                          }
                        }
                        i++;
                      }

                      prefs.setString('vagas', jsonEncode(vagas));
                      prefs.setString('historico', jsonEncode(historico));
                      listarVagasDoBancoDeDados();
                      Navigator.pop(context);
                    },
                    child: Text('SALVAR')),
              ]);
        });
  }

  void listarVagasDoBancoDeDados() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<dynamic> vagasBanco = jsonDecode(prefs.getString('vagas').toString());
    setState(() {
      vagas = vagasBanco;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Estacionamento'), actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HistoricPage()));
              // SharedPreferences prefs = await SharedPreferences.getInstance();
              // print(prefs.getString('vagas'));
            },
          )
        ]),
        body: ListView.builder(
          itemCount: vagas.length,
          itemBuilder: (context, index) {
            return ListTile(
                onTap: () {
                  if (vagas[index]["ocupado"] == true) {
                    desocuparVaga(vagas[index]["key"]);
                  } else {
                    ocuparVaga(vagas[index]["key"]);
                  }
                },
                subtitle: Text(
                    vagas[index]["ocupado"] == true ? 'Ocupado' : 'Disponivel'),
                leading: Icon(Icons.car_rental),
                title: Text('${vagas[index]["title"]}'),
                trailing: Text('${index + 1}'));
          },
        ));
  }
}
