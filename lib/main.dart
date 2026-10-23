
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MainApp());
}

const Color rosa = Color(0xFFE879A9);
const Color rosaClaro = Color(0xFFFFE4EF);
const Color fundo = Color(0xFFFFF5F9);
const Color rosaEscuro = Color(0xFFAD416F);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meu Perfil',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: fundo,
        colorScheme: ColorScheme.fromSeed(seedColor: rosa),
        appBarTheme: const AppBarTheme(
          backgroundColor: rosaClaro,
          foregroundColor: rosaEscuro,
          centerTitle: true,
        ),
      ),
      home: const TelaPerfil(),
    );
  }
}

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final TextEditingController nomeController =
      TextEditingController();

  final ImagePicker picker = ImagePicker();

  File? foto;

  String localizacao = 'Toque no botão para obter sua localização.';
  String ultimaAtualizacao = '';

  bool localizacaoObtida = false;
  bool buscandoLocalizacao = false;

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  Future<void> escolherFoto(ImageSource origem) async {
    try {
      final imagem = await picker.pickImage(
        source: origem,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (imagem == null || !mounted) return;

      setState(() {
        foto = File(imagem.path);
      });
    } catch (e) {
      debugPrint('Erro ao abrir imagem: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir a imagem.'),
        ),
      );
    }
  }

  void mostrarOpcoesFoto() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Foto do perfil 💗',
                style: TextStyle(
                  color: rosaEscuro,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: rosa),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.pop(context);
                escolherFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: rosa),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(context);
                escolherFoto(ImageSource.gallery);
              },
            ),
            if (foto != null)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                title: const Text('Remover foto'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => foto = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> obterLocalizacao() async {
    if (buscandoLocalizacao) return;

    setState(() {
      buscandoLocalizacao = true;
      localizacaoObtida = false;
      localizacao = 'Buscando sua localização...';
    });

    try {
      final servicoAtivo =
          await Geolocator.isLocationServiceEnabled();

      if (!servicoAtivo) {
        atualizarErro(
          'A localização está desativada. Ative o GPS do dispositivo.',
        );
        return;
      }

      LocationPermission permissao =
          await Geolocator.checkPermission();

      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied) {
        atualizarErro(
          'Permissão negada. Autorize o acesso à localização.',
        );
        return;
      }

      if (permissao == LocationPermission.deniedForever) {
        atualizarErro(
          'Permissão bloqueada. Abra as configurações do aplicativo '
          'e autorize a localização.',
        );
        return;
      }

      final Position posicao =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );

      if (!mounted) return;

      final agora = DateTime.now();

      final horario =
          '${agora.day.toString().padLeft(2, '0')}/'
          '${agora.month.toString().padLeft(2, '0')}/'
          '${agora.year} às '
          '${agora.hour.toString().padLeft(2, '0')}:'
          '${agora.minute.toString().padLeft(2, '0')}';

      setState(() {
        localizacao =
            'Latitude: ${posicao.latitude.toStringAsFixed(4)}\n'
            'Longitude: ${posicao.longitude.toStringAsFixed(4)}';

        ultimaAtualizacao = horario;
        localizacaoObtida = true;
        buscandoLocalizacao = false;
      });
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');

      atualizarErro(
        'Não foi possível obter a localização. '
        'Verifique o GPS e tente novamente.',
      );
    }
  }

  void atualizarErro(String mensagem) {
    if (!mounted) return;

    setState(() {
      localizacao = mensagem;
      localizacaoObtida = false;
      buscandoLocalizacao = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nome = nomeController.text.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meu Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Alterar foto',
            onPressed: mostrarOpcoesFoto,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Bem-vinda! 🎀',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: rosaEscuro,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Personalize seu perfil',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // PERFIL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: rosa.withAlpha(35),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 65,
                          backgroundColor: rosaClaro,
                          backgroundImage: foto != null
                              ? FileImage(foto!)
                              : null,
                          child: foto == null
                              ? const Icon(
                                  Icons.person,
                                  size: 72,
                                  color: rosa,
                                )
                              : null,
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: rosa,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: mostrarOpcoesFoto,
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // CAMPO DO NOME RESTAURADO
                    TextField(
                      controller: nomeController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Seu nome',
                        hintText: 'Digite seu nome',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: rosa,
                        ),
                        filled: true,
                        fillColor: fundo,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      nome.isEmpty ? 'Meu perfil 💕' : nome,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: rosaEscuro,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: mostrarOpcoesFoto,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Alterar foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: rosa,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // LOCALIZAÇÃO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: rosaClaro, width: 2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Icon(
                      localizacaoObtida
                          ? Icons.location_on
                          : Icons.location_searching,
                      size: 38,
                      color: localizacaoObtida ? Colors.green : rosa,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Minha localização',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: rosaEscuro,
                      ),
                    ),
                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: localizacaoObtida
                            ? const Color(0xFFE8F5E9)
                            : fundo,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          if (buscandoLocalizacao)
                            const CircularProgressIndicator(
                              color: rosa,
                            )
                          else
                            Icon(
                              localizacaoObtida
                                  ? Icons.check_circle
                                  : Icons.location_off,
                              size: 32,
                              color: localizacaoObtida
                                  ? Colors.green
                                  : rosa,
                            ),
                          const SizedBox(height: 12),
                          Text(
                            localizacao,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              height: 1.7,
                              color: localizacaoObtida
                                  ? Colors.green.shade800
                                  : rosaEscuro,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (localizacaoObtida) ...[
                            const SizedBox(height: 10),
                            Text(
                              'Atualizada em $ultimaAtualizacao',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: buscandoLocalizacao
                            ? null
                            : obterLocalizacao,
                        icon: const Icon(Icons.my_location),
                        label: Text(
                          buscandoLocalizacao
                              ? 'Obtendo localização...'
                              : localizacaoObtida
                                  ? 'Atualizar localização'
                                  : 'Usar minha localização',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: rosa,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Feito com carinho 💗',
                style: TextStyle(
                  color: rosaEscuro,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}