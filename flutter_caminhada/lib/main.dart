
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

const Color roxo = Color(0xFF7652C8);
const Color roxoClaro = Color(0xFFB9A1F2);
const Color fundoClaro = Color(0xFFF8F6FC);

void main() {
  runApp(const CaminhadasApp());
}

class Caminhada {
  String id;
  String titulo;
  double latInicio;
  double lngInicio;
  double latDestino;
  double lngDestino;
  double distancia;
  double calorias;
  int minutos;
  String? foto;
  List<LatLng> trajeto;

  Caminhada({
    required this.id,
    required this.titulo,
    required this.latInicio,
    required this.lngInicio,
    required this.latDestino,
    required this.lngDestino,
    required this.distancia,
    required this.calorias,
    required this.minutos,
    this.foto,
    this.trajeto = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'latInicio': latInicio,
        'lngInicio': lngInicio,
        'latDestino': latDestino,
        'lngDestino': lngDestino,
        'distancia': distancia,
        'calorias': calorias,
        'minutos': minutos,
        'foto': foto,
        'trajeto': trajeto
            .map((p) => {
                  'lat': p.latitude,
                  'lng': p.longitude,
                })
            .toList(),
      };

  factory Caminhada.fromJson(Map<String, dynamic> j) {
    final pontos = (j['trajeto'] as List?) ?? [];

    return Caminhada(
      id: j['id'].toString(),
      titulo: j['titulo'].toString(),
      latInicio: (j['latInicio'] as num).toDouble(),
      lngInicio: (j['lngInicio'] as num).toDouble(),
      latDestino: (j['latDestino'] as num).toDouble(),
      lngDestino: (j['lngDestino'] as num).toDouble(),
      distancia: (j['distancia'] as num).toDouble(),
      calorias: (j['calorias'] as num).toDouble(),
      minutos: (j['minutos'] as num).toInt(),
      foto: j['foto'] as String?,
      trajeto: pontos.map<LatLng>((p) {
        return LatLng(
          (p['lat'] as num).toDouble(),
          (p['lng'] as num).toDouble(),
        );
      }).toList(),
    );
  }
}

class CaminhadasApp extends StatefulWidget {
  const CaminhadasApp({super.key});

  @override
  State<CaminhadasApp> createState() => _CaminhadasAppState();
}

class _CaminhadasAppState extends State<CaminhadasApp> {
  bool escuro = true;
  bool splash = true;
  Timer? timerSplash;

  @override
  void initState() {
    super.initState();
    timerSplash = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => splash = false);
    });
  }

  void mostrarSplash() {
    timerSplash?.cancel();
    setState(() => splash = true);
    timerSplash = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => splash = false);
    });
  }

  @override
  void dispose() {
    timerSplash?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Caminhadas',
      themeMode: escuro ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: roxo,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: fundoClaro,
        appBarTheme: const AppBarTheme(
          backgroundColor: fundoClaro,
          elevation: 0,
          foregroundColor: Color(0xFF292235),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFECE6F5)),
          ),
        ),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
          backgroundColor: roxo,
          foregroundColor: Colors.white,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: roxo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF3EFFA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: roxoClaro,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF15121C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF15121C),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF211C2B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
          backgroundColor: roxoClaro,
          foregroundColor: Color(0xFF211633),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: roxoClaro,
            foregroundColor: const Color(0xFF211633),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: splash
          ? const TelaSplash()
          : HomeScreen(
              key: const ValueKey('home'),
              escuro: escuro,
              mudarTema: (v) => setState(() => escuro = v),
              mostrarSplash: mostrarSplash,
            ),
    );
  }
}

class TelaSplash extends StatelessWidget {
  const TelaSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                color: roxo.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.route_rounded,
                size: 46,
                color: roxo,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Caminhadas',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore. Caminhe. Registre.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool escuro;
  final ValueChanged<bool> mudarTema;
  final VoidCallback mostrarSplash;

  const HomeScreen({
    super.key,
    required this.escuro,
    required this.mudarTema,
    required this.mostrarSplash,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Caminhada> caminhadas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dados =
          jsonDecode(prefs.getString('caminhadas') ?? '[]') as List;

      final lista = dados
          .map((e) => Caminhada.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList();

      if (!mounted) return;

      setState(() {
        caminhadas = lista;
        carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => carregando = false);
    }
  }

  Future<void> salvar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'caminhadas',
      jsonEncode(caminhadas.map((c) => c.toJson()).toList()),
    );
  }

  Future<void> novaCaminhada() async {
    final resultado = await Navigator.push<Caminhada>(
      context,
      MaterialPageRoute(
        builder: (_) => const NovaCaminhadaScreen(),
      ),
    );

    if (!mounted || resultado == null) return;

    setState(() => caminhadas.insert(0, resultado));
    await salvar();
  }

  Future<void> atualizarFoto(Caminhada c, String caminho) async {
    if (!mounted) return;
    setState(() => c.foto = caminho);
    await salvar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas caminhadas',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: roxo.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: const Icon(
                        Icons.route_rounded,
                        color: roxo,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Caminhadas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: Icon(
                  widget.escuro
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  color: roxo,
                ),
                title: const Text('Tema escuro'),
                value: widget.escuro,
                onChanged: widget.mudarTema,
              ),
              ListTile(
                leading: const Icon(
                  Icons.auto_awesome_outlined,
                  color: roxo,
                ),
                title: const Text('Ver splash'),
                onTap: () {
                  Navigator.pop(context);
                  widget.mostrarSplash();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.exit_to_app_rounded,
                  color: roxo,
                ),
                title: const Text('Sair do app'),
                onTap: () => SystemNavigator.pop(),
              ),
            ],
          ),
        ),
      ),
      body: carregando
          ? const Center(
              child: CircularProgressIndicator(color: roxo),
            )
          : caminhadas.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: roxo.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Icon(
                            Icons.route_rounded,
                            size: 52,
                            color: roxo,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Comece por aqui',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Registre seu primeiro percurso '
                          'e acompanhe suas caminhadas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.5,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: novaCaminhada,
                          child: const Text('Nova caminhada'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [roxo, Color(0xFF9678DD)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SEU PROGRESSO',
                            style: TextStyle(
                              color: Colors.white70,
                              letterSpacing: 1.3,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${caminhadas.length} '
                            '${caminhadas.length == 1 ? 'caminhada' : 'caminhadas'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Distância total: '
                            '${caminhadas.fold<double>(0, (s, c) => s + c.distancia).toStringAsFixed(2)} km',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Tempo total: '
                            '${caminhadas.fold<int>(0, (s, c) => s + c.minutos)} min',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Histórico',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...caminhadas.map(
                      (c) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: c.foto != null &&
                                    File(c.foto!).existsSync()
                                ? Image.file(
                                    File(c.foto!),
                                    width: 58,
                                    height: 58,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 58,
                                    height: 58,
                                    color: roxo.withValues(alpha: 0.10),
                                    child: const Icon(
                                      Icons.route_rounded,
                                      color: roxo,
                                    ),
                                  ),
                          ),
                          title: Text(
                            c.titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            '${c.distancia.toStringAsFixed(2)} km • '
                            '${c.minutos} min • '
                            '${c.calorias.toStringAsFixed(0)} kcal',
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: roxo,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalhesScreen(
                                  caminhada: c,
                                  salvarFoto: (path) =>
                                      atualizarFoto(c, path),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: novaCaminhada,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class NovaCaminhadaScreen extends StatefulWidget {
  const NovaCaminhadaScreen({super.key});

  @override
  State<NovaCaminhadaScreen> createState() =>
      _NovaCaminhadaScreenState();
}

class _NovaCaminhadaScreenState extends State<NovaCaminhadaScreen> {
  final MapController mapa = MapController();

  LatLng inicio = const LatLng(-22.9068, -47.0616);
  LatLng? destino;
  List<LatLng> trajeto = [];

  StreamSubscription<Position>? assinaturaLocalizacao;

  bool localizando = true;
  bool mapaPronto = false;
  bool localizacaoObtida = false;
  bool solicitandoLocalizacao = false;
  bool calculandoRota = false;
  bool salvandoCaminhada = false;

  double distanciaKm = 0;
  double duracaoMinutos = 0;
  String? erroLocalizacao;
  String? erroRota;

  double get calorias => distanciaKm * 60;
  int get tempo => duracaoMinutos.round();

  @override
  void initState() {
    super.initState();
    iniciarLocalizacao();
  }

  @override
  void dispose() {
    assinaturaLocalizacao?.cancel();
    super.dispose();
  }

  Future<void> iniciarLocalizacao() async {
    if (!mounted || solicitandoLocalizacao) return;

    solicitandoLocalizacao = true;

    await assinaturaLocalizacao?.cancel();
    assinaturaLocalizacao = null;

    if (!mounted) {
      solicitandoLocalizacao = false;
      return;
    }

    setState(() {
      localizando = true;
      erroLocalizacao = null;
    });

    try {
      final servicoAtivo =
          await Geolocator.isLocationServiceEnabled();

      if (!servicoAtivo) {
        throw Exception('Ative a localização do dispositivo.');
      }

      LocationPermission permissao =
          await Geolocator.checkPermission();

      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied ||
          permissao == LocationPermission.deniedForever) {
        throw Exception(
          'Permita o acesso à localização nas configurações.',
        );
      }

      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      final pontoAtual = LatLng(
        posicao.latitude,
        posicao.longitude,
      );

      setState(() {
        inicio = pontoAtual;
        localizacaoObtida = true;
        localizando = false;
      });

      if (mapaPronto) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !mapaPronto || destino != null) return;
          mapa.move(inicio, 16);
        });
      }

      assinaturaLocalizacao = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen(
        (posicaoAtual) {
          if (!mounted || destino != null) return;

          final novoInicio = LatLng(
            posicaoAtual.latitude,
            posicaoAtual.longitude,
          );

          setState(() {
            inicio = novoInicio;
          });
        },
        onError: (_) {
          if (!mounted) return;
          setState(() {
            erroLocalizacao =
                'Não foi possível atualizar sua localização.';
          });
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        localizando = false;
        erroLocalizacao =
            e.toString().replaceFirst('Exception: ', '');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erroLocalizacao!)),
      );
    } finally {
      solicitandoLocalizacao = false;
    }
  }

  Future<void> calcularRota(LatLng pontoDestino) async {
    if (!localizacaoObtida || calculandoRota) return;

    await assinaturaLocalizacao?.cancel();
    assinaturaLocalizacao = null;

    final pontoInicio = inicio;

    setState(() {
      destino = pontoDestino;
      trajeto = [];
      distanciaKm = 0;
      duracaoMinutos = 0;
      calculandoRota = true;
      erroRota = null;
    });

    try {
      final url = Uri.parse(
        'https://routing.openstreetmap.de/routed-foot/route/v1/driving/'
        '${pontoInicio.longitude},${pontoInicio.latitude};'
        '${pontoDestino.longitude},${pontoDestino.latitude}'
        '?overview=full&geometries=geojson&steps=false',
      );

      final resposta = await http.get(url).timeout(
            const Duration(seconds: 30),
          );

      if (resposta.statusCode != 200) {
        throw Exception('O serviço de rotas está indisponível.');
      }

      final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
      final rotas = dados['routes'] as List?;

      if (rotas == null || rotas.isEmpty) {
        throw Exception('Não foi encontrado um trajeto a pé.');
      }

      final rota = Map<String, dynamic>.from(rotas.first as Map);
      final geometria =
          Map<String, dynamic>.from(rota['geometry'] as Map);
      final coordenadas = geometria['coordinates'] as List;

      final pontos = coordenadas.map<LatLng>((p) {
        return LatLng(
          (p[1] as num).toDouble(),
          (p[0] as num).toDouble(),
        );
      }).toList();

      if (pontos.isEmpty) {
        throw Exception('A rota retornada não contém coordenadas.');
      }

      if (!mounted) return;

      setState(() {
        trajeto = pontos;
        distanciaKm = (rota['distance'] as num).toDouble() / 1000;
        duracaoMinutos = (rota['duration'] as num).toDouble() / 60;
        calculandoRota = false;
      });

      if (mapaPronto) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !mapaPronto) return;
          try {
            mapa.fitCamera(
              CameraFit.coordinates(
                coordinates: pontos,
                padding: const EdgeInsets.all(45),
                maxZoom: 17,
              ),
            );
          } catch (_) {}
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        calculandoRota = false;
        erroRota = e.toString().replaceFirst('Exception: ', '');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erroRota!)),
      );
    }
  }

  Future<void> salvarCaminhada() async {
    if (salvandoCaminhada) return;

    if (!localizacaoObtida) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aguarde sua localização ser obtida.'),
        ),
      );
      return;
    }

    if (destino == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toque no mapa para escolher o destino.'),
        ),
      );
      return;
    }

    if (calculandoRota || trajeto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            erroRota ??
                'Aguarde o cálculo do trajeto real antes de salvar.',
          ),
        ),
      );
      return;
    }

    setState(() => salvandoCaminhada = true);

    final controller = TextEditingController();

    try {
      final titulo = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Salvar caminhada'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 60,
            decoration: const InputDecoration(
              labelText: 'Título da caminhada',
              hintText: 'Ex.: Caminhada no parque',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                controller.text.trim(),
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      );

      if (!mounted || titulo == null || titulo.isEmpty) return;

      final pontoDestino = destino;
      if (pontoDestino == null || trajeto.isEmpty) return;

      final caminhada = Caminhada(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titulo: titulo,
        latInicio: inicio.latitude,
        lngInicio: inicio.longitude,
        latDestino: pontoDestino.latitude,
        lngDestino: pontoDestino.longitude,
        distancia: distanciaKm,
        calorias: calorias,
        minutos: tempo,
        trajeto: List<LatLng>.from(trajeto),
      );

      await assinaturaLocalizacao?.cancel();
      assinaturaLocalizacao = null;

      if (!mounted) return;
      Navigator.pop(context, caminhada);
    } finally {
      controller.dispose();
      if (mounted) {
        setState(() => salvandoCaminhada = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova caminhada'),
        actions: [
          IconButton(
            tooltip: 'Atualizar localização',
            onPressed:
                solicitandoLocalizacao ? null : iniciarLocalizacao,
            icon: const Icon(
              Icons.my_location_rounded,
              color: roxo,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  calculandoRota
                      ? Icons.route_outlined
                      : localizacaoObtida
                          ? Icons.gps_fixed_rounded
                          : Icons.location_searching_rounded,
                  color: calculandoRota
                      ? Colors.orange
                      : localizacaoObtida
                          ? roxo
                          : Colors.orange,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    localizando
                        ? 'Obtendo sua localização...'
                        : calculandoRota
                            ? 'Calculando rota para caminhada...'
                            : erroRota != null
                                ? erroRota!
                                : localizacaoObtida
                                    ? destino == null
                                        ? 'Sua localização está sendo atualizada'
                                        : 'Trajeto a pé calculado'
                                    : erroLocalizacao ??
                                        'Localização indisponível',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: mapa,
              options: MapOptions(
                initialCenter: inicio,
                initialZoom: 14,
                onMapReady: () {
                  mapaPronto = true;

                  if (localizacaoObtida && destino == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted || !mapaPronto || destino != null) {
                        return;
                      }
                      mapa.move(inicio, 16);
                    });
                  }
                },
                onTap: (tapPosition, ponto) {
                  if (localizando ||
                      !localizacaoObtida ||
                      calculandoRota) {
                    return;
                  }
                  calcularRota(ponto);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.flutter_caminhada',
                ),
                if (trajeto.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: trajeto,
                        strokeWidth: 6,
                        color: roxo,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: inicio,
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: roxo,
                        size: 32,
                      ),
                    ),
                    if (destino != null)
                      Marker(
                        point: destino!,
                        width: 44,
                        height: 44,
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: roxo,
                          size: 36,
                        ),
                      ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
                if (calculandoRota)
                  const SimpleAttributionWidget(
                    source: Text('Calculando rota a pé...'),
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumo do percurso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _Metrica(
                        icone: Icons.route_rounded,
                        titulo: 'Distância',
                        valor: '${distanciaKm.toStringAsFixed(2)} km',
                      ),
                    ),
                    Expanded(
                      child: _Metrica(
                        icone: Icons.local_fire_department_outlined,
                        titulo: 'Calorias',
                        valor: '${calorias.toStringAsFixed(0)} kcal',
                      ),
                    ),
                    Expanded(
                      child: _Metrica(
                        icone: Icons.timer_outlined,
                        titulo: 'Tempo',
                        valor: '$tempo min',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: localizando ||
                            calculandoRota ||
                            salvandoCaminhada
                        ? null
                        : salvarCaminhada,
                    child: Text(
                      calculandoRota
                          ? 'Calculando trajeto...'
                          : salvandoCaminhada
                              ? 'Salvando...'
                              : 'Salvar caminhada',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;

  const _Metrica({
    required this.icone,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: roxo, size: 23),
        const SizedBox(height: 8),
        Text(
          titulo,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class DetalhesScreen extends StatefulWidget {
  final Caminhada caminhada;
  final ValueChanged<String> salvarFoto;

  const DetalhesScreen({
    super.key,
    required this.caminhada,
    required this.salvarFoto,
  });

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  Future<void> tirarFoto() async {
    try {
      final imagem = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (imagem != null && mounted) {
        widget.salvarFoto(imagem.path);
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir a câmera: $e')),
      );
    }
  }

  Widget informacao(
    IconData icone,
    String titulo,
    String valor,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: roxo.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icone, color: roxo),
        ),
        title: Text(titulo),
        subtitle: Text(
          valor,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.caminhada;
    final inicio = LatLng(c.latInicio, c.lngInicio);
    final destino = LatLng(c.latDestino, c.lngDestino);
    final pontos = c.trajeto.length > 1
        ? c.trajeto
        : [inicio, destino];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da caminhada'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            c.titulo,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: tirarFoto,
            borderRadius: BorderRadius.circular(18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: c.foto != null && File(c.foto!).existsSync()
                  ? Image.file(
                      File(c.foto!),
                      height: 210,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 170,
                      color: roxo.withValues(alpha: 0.10),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 42,
                            color: roxo,
                          ),
                          SizedBox(height: 10),
                          Text('Toque para adicionar uma foto'),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Mapa do percurso',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    (inicio.latitude + destino.latitude) / 2,
                    (inicio.longitude + destino.longitude) / 2,
                  ),
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.flutter_caminhada',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: pontos,
                        strokeWidth: 5,
                        color: roxo,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: inicio,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: roxo,
                          size: 30,
                        ),
                      ),
                      Marker(
                        point: destino,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: roxo,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          informacao(
            Icons.route_rounded,
            'Distância',
            '${c.distancia.toStringAsFixed(2)} km',
          ),
          informacao(
            Icons.local_fire_department_outlined,
            'Calorias estimadas',
            '${c.calorias.toStringAsFixed(0)} kcal',
          ),
          informacao(
            Icons.timer_outlined,
            'Tempo estimado',
            '${c.minutos} minutos',
          ),
          informacao(
            Icons.trip_origin_rounded,
            'Ponto de partida',
            '${c.latInicio.toStringAsFixed(5)}, '
                '${c.lngInicio.toStringAsFixed(5)}',
          ),
          informacao(
            Icons.location_on_outlined,
            'Destino',
            '${c.latDestino.toStringAsFixed(5)}, '
                '${c.lngDestino.toStringAsFixed(5)}',
          ),
        ],
      ),
    );
  }
}