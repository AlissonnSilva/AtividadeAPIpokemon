import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const AtlasApp());

const ink = Color(0xFF252A32);
const red = Color(0xFFDA4B4B);
const paper = Color(0xFFF7F5F0);

class AtlasApp extends StatelessWidget {
  const AtlasApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Poké Atlas',
        theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: paper,
          colorScheme: ColorScheme.fromSeed(seedColor: red), fontFamily: 'Roboto'),
        home: const DexPage(),
      );
}

class Pokemon {
  const Pokemon({required this.id, required this.name, required this.image,
    required this.height, required this.weight, required this.types, required this.stats});
  final int id, height, weight;
  final String name;
  final String? image;
  final List<String> types;
  final Map<String, int> stats;

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final artwork = json['sprites']['other']['official-artwork']['front_default'] as String?;
    final sprite = json['sprites']['front_default'] as String?;
    return Pokemon(id: json['id'] as int, name: json['name'] as String,
      image: artwork ?? sprite, height: json['height'] as int, weight: json['weight'] as int,
      types: (json['types'] as List).map((e) => e['type']['name'] as String).toList(),
      stats: {for (final s in json['stats'] as List) s['stat']['name'] as String: s['base_stat'] as int});
  }
}

class PokemonService {
  Future<Pokemon> find(String query) async {
    final response = await http.get(Uri.https('pokeapi.co', '/api/v2/pokemon/${query.trim().toLowerCase()}'))
      .timeout(const Duration(seconds: 12));
    if (response.statusCode == 404) throw const PokemonNotFound();
    if (response.statusCode != 200) throw Exception('A PokéAPI está indisponível.');
    return Pokemon.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}

class PokemonNotFound implements Exception { const PokemonNotFound(); }

const names = {'hp': 'HP', 'attack': 'Ataque', 'defense': 'Defesa',
  'special-attack': 'Ataque especial', 'special-defense': 'Defesa especial', 'speed': 'Velocidade'};
const typeLabels = {'normal': 'Normal', 'fire': 'Fogo', 'water': 'Água', 'electric': 'Elétrico',
  'grass': 'Planta', 'ice': 'Gelo', 'fighting': 'Lutador', 'poison': 'Veneno', 'ground': 'Terra',
  'flying': 'Voador', 'psychic': 'Psíquico', 'bug': 'Inseto', 'rock': 'Pedra', 'ghost': 'Fantasma',
  'dragon': 'Dragão', 'dark': 'Sombrio', 'steel': 'Aço', 'fairy': 'Fada'};

String titleCase(String value) => value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

Color typeColor(String type) => switch (type) {
  'fire' => const Color(0xFFE98462), 'water' => const Color(0xFF69A6D7),
  'grass' => const Color(0xFF75B98B), 'electric' => const Color(0xFFE8C45A),
  'psychic' => const Color(0xFFD982A2), 'ice' => const Color(0xFF76C4C6),
  'poison' => const Color(0xFFAA83C4), 'ground' || 'rock' => const Color(0xFFC59D69),
  'bug' => const Color(0xFF9BAF4A), 'ghost' || 'dark' => const Color(0xFF80779C),
  'dragon' => const Color(0xFF7772C7), 'fairy' => const Color(0xFFD994BC),
  'fighting' => const Color(0xFFC97059), 'steel' => const Color(0xFF9DA9B7),
  _ => const Color(0xFF9A9FA5),
};

class DexPage extends StatefulWidget {
  const DexPage({super.key});
  @override
  State<DexPage> createState() => _DexPageState();
}

class _DexPageState extends State<DexPage> {
  final _service = PokemonService();
  final _search = TextEditingController();
  Pokemon? _pokemon;
  bool _loading = false;
  String? _error;

  @override
  void initState() { super.initState(); _load('pikachu', unfocus: false); }
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load(String query, {bool unfocus = true}) async {
    if (query.trim().isEmpty) return;
    if (unfocus) FocusScope.of(context).unfocus();
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _service.find(query);
      if (mounted) { setState(() { _pokemon = result; _search.clear(); }); }
    } on PokemonNotFound {
      if (mounted) setState(() => _error = 'Não encontrei esse Pokémon. Confira o nome ou número da Pokédex.');
    } catch (_) {
      if (mounted) setState(() => _error = 'Não consegui carregar os dados agora. Tente de novo em instantes.');
    } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final p = _pokemon;
    return Scaffold(body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 660),
      child: ListView(padding: const EdgeInsets.fromLTRB(22, 24, 22, 28), children: [
        Row(children: [
          const Text('poké atlas', style: TextStyle(color: ink, fontWeight: FontWeight.w800, fontSize: 23, letterSpacing: -.5)),
          const Spacer(), Text('Nº ${p == null ? '---' : p.id.toString().padLeft(3, '0')}', style: const TextStyle(color: Color(0xFF858991), fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
        const SizedBox(height: 6), const Text('Uma pequena enciclopédia Pokémon.', style: TextStyle(color: Color(0xFF858991), fontSize: 13)),
        const SizedBox(height: 21),
        TextField(controller: _search, textInputAction: TextInputAction.search,
          onSubmitted: _load, decoration: InputDecoration(hintText: 'Nome ou número do Pokémon',
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF777C83)),
            suffixIcon: IconButton(tooltip: 'Buscar', onPressed: () => _load(_search.text), icon: const Icon(Icons.arrow_forward_rounded, color: red)),
            filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
        if (_error != null) ...[const SizedBox(height: 12), _errorMessage()],
        if (_loading) const SizedBox(height: 440, child: Center(child: CircularProgressIndicator(color: red))),
        if (!_loading && p != null) ...[
          const SizedBox(height: 18), _pokemonCard(p),
          const SizedBox(height: 14), _facts(p),
          const SizedBox(height: 14), _stats(p),
          const SizedBox(height: 20),
          const Center(child: Text('Informações fornecidas pela PokéAPI', style: TextStyle(color: Color(0xFF96999D), fontSize: 11))),
        ],
      ]),
    ))));
  }

  Widget _pokemonCard(Pokemon p) {
    final color = typeColor(p.types.first);
    return Container(padding: const EdgeInsets.fromLTRB(20, 18, 20, 20), decoration: BoxDecoration(
      color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(24)), child: Column(children: [
        Align(alignment: Alignment.centerRight, child: Text('#${p.id.toString().padLeft(3, '0')}', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13))),
        SizedBox(height: 178, child: p.image == null
          ? Icon(Icons.catching_pokemon_rounded, size: 110, color: color)
          : Image.network(p.image!, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.catching_pokemon_rounded, size: 110, color: color))),
        Text(titleCase(p.name), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink)),
        const SizedBox(height: 11), Wrap(spacing: 8, children: p.types.map((type) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6), decoration: BoxDecoration(color: typeColor(type), borderRadius: BorderRadius.circular(20)),
          child: Text(typeLabels[type] ?? titleCase(type), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)))).toList()),
      ]));
  }

  Widget _facts(Pokemon p) => Container(padding: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Row(children: [
      Expanded(child: _fact(Icons.height_rounded, 'Altura', '${(p.height / 10).toStringAsFixed(1)} m')),
      Container(width: 1, height: 42, color: const Color(0xFFE9E7E1)),
      Expanded(child: _fact(Icons.fitness_center_rounded, 'Peso', '${(p.weight / 10).toStringAsFixed(1)} kg')),
    ]));

  Widget _fact(IconData icon, String label, String value) => Column(children: [
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: red), const SizedBox(width: 6), Text(label, style: const TextStyle(color: Color(0xFF888B90), fontSize: 12))]),
    const SizedBox(height: 5), Text(value, style: const TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 15)),
  ]);

  Widget _stats(Pokemon p) => Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Atributos básicos', style: TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 15)),
      const SizedBox(height: 14), for (final key in ['hp', 'attack', 'defense']) _statRow(key, p.stats[key] ?? 0)]));

  Widget _statRow(String key, int value) => Padding(padding: const EdgeInsets.only(bottom: 11), child: Row(children: [
    SizedBox(width: 88, child: Text(names[key] ?? key, style: const TextStyle(color: Color(0xFF777C83), fontSize: 12))),
    SizedBox(width: 34, child: Text('$value', style: const TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 12))),
    Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (value / 150).clamp(0, 1), minHeight: 7, backgroundColor: const Color(0xFFECEAE5), color: red))),
  ]));

  Widget _errorMessage() => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFFFEDEA), borderRadius: BorderRadius.circular(14)),
    child: Text(_error!, style: const TextStyle(color: Color(0xFF8D4841), fontSize: 13)));
}
