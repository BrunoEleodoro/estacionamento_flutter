import 'dart:convert';

import 'package:estacionamento/historico_page.dart';
import 'package:estacionamento/models/vagas.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:estacionamento/widgets/themes.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';

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
  String? nome;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString('vagas') == null) {
        prefs.setString('vagas', jsonEncode(VagaModelo.vagas));
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
          double valorGlobal = 0;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Preencha os dados',
                  style: TextStyle(
                      color: MyTheme.darkBluishColor,
                      fontWeight: FontWeight.bold)),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
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
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                        style: ElevatedButton.styleFrom(
                            side: BorderSide(
                                width: 2.0, color: MyTheme.darkBluishColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('CANCELAR',
                            style: TextStyle(
                                color: MyTheme.darkBluishColor,
                                fontWeight: FontWeight.bold))),
                    OutlinedButton(
                        style: ElevatedButton.styleFrom(
                            side: BorderSide(
                                width: 2.0, color: MyTheme.darkBluishColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0))),
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
                        child: Text(
                          'SALVAR',
                          style: TextStyle(
                              color: MyTheme.darkBluishColor,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
                SizedBox(height: 15)
              ],
              elevation: 12.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(color: MyTheme.darkBluishColor, width: 8)),
            );
          });
        });
  }

  void desocuparVaga(String key) {
    final snackBar = SnackBar(
      content: Text('Pago!, Vaga Liberada.',
          style: TextStyle(fontSize: 20, color: MyTheme.darkBluishColor)),
      backgroundColor: MyTheme.vagaGreen,
      shape: StadiumBorder(),
      behavior: SnackBarBehavior.floating,
    );
    TextEditingController placaController = new TextEditingController();
    TextEditingController rgController = new TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          double valorGlobal = 0;
          GlobalKey<FormState> formState = GlobalKey<FormState>();

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Pagamento:',
                  style: TextStyle(
                      color: MyTheme.darkBluishColor,
                      fontWeight: FontWeight.bold)),
              content: Form(
                key: formState,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Confirmar dados',
                      style: TextStyle(
                          color: MyTheme.darkBluishColor,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  TextFormField(
                      controller: placaController,
                      validator: (valor) {
                        if (valor!.isEmpty) {
                          return "Preencha a placa";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'Placa', border: OutlineInputBorder())),
                  SizedBox(height: 20),
                  TextFormField(
                      controller: rgController,
                      validator: (valor) {
                        if (valor!.isEmpty) {
                          return "Preencha o RG";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'RG', border: OutlineInputBorder())),
                  SizedBox(height: 10),
                  Text('Valor a ser pago:',
                      style: TextStyle(
                          color: MyTheme.darkBluishColor,
                          fontWeight: FontWeight.bold)),
                  OutlinedButton(
                      style: ElevatedButton.styleFrom(
                          side: BorderSide(
                              width: 2.0, color: MyTheme.darkBluishColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                      onPressed: () async {
                        if (formState.currentState!.validate() == false) {
                          return;
                        }
                        String placa = placaController.text;
                        String rg = rgController.text;
                        //if ('$placa' != "" && '$rg' != "") {
                        //****
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
                                  new DateTime.fromMillisecondsSinceEpoch(
                                      vagas[i]["horario_entrada"]);
                              var horarioSaidaDate =
                                  new DateTime.fromMillisecondsSinceEpoch(
                                      vagas[i]["horario_saida"]);

                              String dateEntradaSlug =
                                  "${horarioEntradaDate.day.toString().padLeft(2, '0')}-${horarioEntradaDate.month.toString().padLeft(2, '0')}-${horarioEntradaDate.year.toString()}";
                              String dateSaidaSlug =
                                  "${horarioSaidaDate.day.toString().padLeft(2, '0')}-${horarioSaidaDate.month.toString().padLeft(2, '0')}-${horarioSaidaDate.year.toString()}";

                              //TODO: Mudar aqui e fazer o calculo de horas de permancencia no estacionamento

                              //https://stackoverflow.com/questions/52713115/flutter-find-the-number-of-days-between-two-dates
                              final difference = horarioSaidaDate
                                  .difference(horarioEntradaDate)
                                  .inMinutes;
                              final valor = difference * 0.167;

                              setState(() {
                                valorGlobal = valor;
                              });
                              print(valor);
                            }
                          }
                          i++;
                        }
                      },
                      child: Text('CALCULAR',
                          style: TextStyle(
                              color: MyTheme.darkBluishColor,
                              fontWeight: FontWeight.bold))),
                  Text('${valorGlobal.toString()}',
                      style: TextStyle(
                          color: MyTheme.darkBluishColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 25)),
                ]),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                        style: ElevatedButton.styleFrom(
                            side: BorderSide(
                                width: 2.0, color: MyTheme.darkBluishColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('CANCELAR',
                            style: TextStyle(
                                color: MyTheme.darkBluishColor,
                                fontWeight: FontWeight.bold))),
                    OutlinedButton(
                        style: ElevatedButton.styleFrom(
                            side: BorderSide(
                                width: 2.0, color: MyTheme.darkBluishColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        onPressed: () async {
                          if (formState.currentState!.validate() == false) {
                            return;
                          }
                          String placa = placaController.text;
                          String rg = rgController.text;
                          //if ('$placa' != "" && '$rg' != "") {
                          //****
                          print(placa);
                          print(rg);

                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          List<dynamic> vagas =
                              jsonDecode(prefs.getString('vagas').toString());
                          List<dynamic> historico = jsonDecode(
                              prefs.getString('historico').toString());

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
                                    new DateTime.fromMillisecondsSinceEpoch(
                                        vagas[i]["horario_entrada"]);
                                var horarioSaidaDate =
                                    new DateTime.fromMillisecondsSinceEpoch(
                                        vagas[i]["horario_saida"]);

                                String dateEntradaSlug =
                                    "${horarioEntradaDate.day.toString().padLeft(2, '0')}-${horarioEntradaDate.month.toString().padLeft(2, '0')}-${horarioEntradaDate.year.toString()}";
                                String dateSaidaSlug =
                                    "${horarioSaidaDate.day.toString().padLeft(2, '0')}-${horarioSaidaDate.month.toString().padLeft(2, '0')}-${horarioSaidaDate.year.toString()}";

                                //TODO: Mudar aqui e fazer o calculo de horas de permancencia no estacionamento

                                //https://stackoverflow.com/questions/52713115/flutter-find-the-number-of-days-between-two-dates
                                final difference = horarioSaidaDate
                                    .difference(horarioEntradaDate)
                                    .inMinutes;
                                final valor = difference * 0.167;

                                setState(() {
                                  valorGlobal = valor;
                                });
                                print(valor);

                                historico.add({
                                  'titulo':
                                      'Placa: $placa, RG: $rg, permanecendo $difference minutos na vaga : ${vagas[i]["title"]}'
                                });
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            }
                            i++;
                          }

                          prefs.setString('vagas', jsonEncode(vagas));
                          prefs.setString('historico', jsonEncode(historico));
                          listarVagasDoBancoDeDados();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'PAGAR',
                          style: TextStyle(
                              color: MyTheme.darkBluishColor,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
                SizedBox(height: 15)
              ],
              elevation: 12.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(color: MyTheme.darkBluishColor, width: 8)),
            );
          });
        });
  }

  void listarVagasDoBancoDeDados() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<dynamic> vagasBanco = jsonDecode(prefs.getString('vagas').toString());
    setState(() {
      VagaModelo.vagas = vagasBanco;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: MyTheme.darkBluishColor,
          title: Text('Estacionamento do João',
              style: TextStyle(fontSize: 22, color: Colors.white)),
          //actions: [IconButton(icon: Icon(Icons.add),onPressed: () async {Navigator.push(context,MaterialPageRoute(builder: (context) => HistoricPage()));},)]
        ),
        body: SafeArea(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EstacionamentoHeader(),
                SizedBox(height: 15),
                ListView.builder(
                  itemCount: VagaModelo.vagas.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                          tileColor: getDynamicColor(
                              VagaModelo.vagas[index]["ocupado"]),
                          onTap: () {
                            if (VagaModelo.vagas[index]["ocupado"] == true) {
                              desocuparVaga(VagaModelo.vagas[index]["key"]);
                            } else {
                              ocuparVaga(VagaModelo.vagas[index]["key"]);
                            }
                          },
                          leading: Icon(Icons.directions_car,
                              size: 50, color: MyTheme.darkBluishColor),
                          title: Text('RG: ${VagaModelo.vagas[index]["rg"]}',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: MyTheme.darkBluishColor)),
                          subtitle: Text(
                              'PLACA: ${VagaModelo.vagas[index]["placa"]}',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: MyTheme.darkBluishColor)),
                          trailing: Text('${VagaModelo.vagas[index]["title"]}',
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: MyTheme.darkBluishColor))),
                    );
                  },
                ).expand(),
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 15),
                      OutlinedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.resolveWith<OutlinedBorder>(
                                  (_) {
                            return RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20));
                          }),
                          side:
                              MaterialStateProperty.all<BorderSide>(BorderSide(
                            color: MyTheme.darkBluishColor,
                            width: 3,
                          )),
                          alignment: Alignment.center,
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed))
                                return Colors.blueGrey;
                              return Colors.transparent;
                            },
                          ),
                        ),
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HistoricPage()));
                          // SharedPreferences prefs = await SharedPreferences.getInstance();
                          // print(prefs.getString('vagas'));
                        },
                        child: Text(
                          "Histórico",
                          style: TextStyle(
                              color: MyTheme.darkBluishColor, fontSize: 25),
                        ),
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Color getDynamicColor(bool ocupado) {
    if (ocupado == true) {
      return MyTheme.vagaRed;
    }
    return MyTheme.vagaGreen; //default color.
  }
}

class EstacionamentoHeader extends StatelessWidget {
  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('dd-MM-yyyy');
  final String formatted = formatter.format(now);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        "$formatted"
            .text
            .xl3
            .bold
            .color(MyTheme.darkBluishColor)
            .make()
            .centered(),
        SizedBox(height: 5),
        VxBox(
                child: ("Vagas disponíveis em verde"
                        .text
                        .size(3)
                        .bold
                        .xl2
                        .color(MyTheme.darkBluishColor))
                    .make()
                    .centered())
            .green200
            .width(340)
            .border(color: Vx.green400, width: 2, style: BorderStyle.solid)
            .make()
            .centered(),
        SizedBox(height: 5),
        VxBox(
                child: "Vagas ocupada em vermelho"
                    .text
                    .size(3)
                    .bold
                    .xl2
                    .color(MyTheme.darkBluishColor)
                    .make()
                    .centered())
            .width(340)
            .border(color: Vx.red400, width: 2, style: BorderStyle.solid)
            .red200
            .make()
            .centered()
      ],
    );
  }
}
