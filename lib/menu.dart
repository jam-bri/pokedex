import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/screens/signin.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokedex/services/auth.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();

  // Theme Colors
  final Color pokeRed = const Color(0xFFE3350D);
  final Color darkCharcoal = const Color(0xFF313131);
  final Color offWhite = const Color(0xFFF2F2F2);
  final Color oliveGreen = const Color(0xFF808000);

  Set<int> _favoritePokemonIds = {};
  List<dynamic> _allPokemon = [];
  List<dynamic> _filteredPokemon = [];
  bool _loading = true;
  bool _showingFavorites = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final auth = context.read<AuthService>();
    try {
      final pokemon = await auth.getPokemon();
      final favIds = auth.isLoggedIn ? await auth.getFavoriteIds() : <int>{};
      if (mounted) {
        setState(() {
          _allPokemon = pokemon;
          _filteredPokemon = pokemon;
          _favoritePokemonIds = favIds;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> fetchFavorites() async {
    final auth = context.read<AuthService>();
    final favIds = await auth.getFavoriteIds();
    if (mounted) setState(() => _favoritePokemonIds = favIds);
  }

  Future<void> toggleFavorite(int pokemonId, bool isAdding) async {
    final auth = context.read<AuthService>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add favorites.')),
      );
      return;
    }
    if (isAdding) {
      await auth.addFavorite(pokemonId);
    } else {
      await auth.removeFavorite(pokemonId);
    }
    setState(() {
      if (isAdding) {
        _favoritePokemonIds.add(pokemonId);
      } else {
        _favoritePokemonIds.remove(pokemonId);
      }

      // If showing favorites then remove card immediately when unfavorited
      if (_showingFavorites && !isAdding) {
        _filteredPokemon =
            _filteredPokemon.where((p) => p['id'] != pokemonId).toList();
      }
    });
  }

  void _filterPokemon(String query) {
    setState(() {
      _showingFavorites = false;
      final source = _allPokemon;
      _filteredPokemon = query.isEmpty
          ? source
          : source
              .where((p) => p['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
                  p['id'].toString().contains(query))
              .toList();
    });
  }

  void _showAllPokemon() {
    _searchController.clear();
    setState(() {
      _showingFavorites = false;
      _filteredPokemon = _allPokemon;
    });
  }

  void _showFavorites() {
    final auth = context.read<AuthService>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to see favorites.')),
      );
      return;
    }
    _searchController.clear();
    setState(() {
      _showingFavorites = true;
      _filteredPokemon = _allPokemon
          .where((p) => _favoritePokemonIds.contains(p['id']))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: offWhite,
      appBar: AppBar(
        backgroundColor: pokeRed,
        elevation: 4,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png',
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.catching_pokemon, color: Colors.white, size: 28),
          ),
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'POKÉ',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              TextSpan(
                text: 'DEX',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFDE00),
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // -Search bar- 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: SizedBox(
              width: 130,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                cursorColor: Colors.white,
                onChanged: _filterPokemon,
                decoration: InputDecoration(
                  hintText: 'ID / Name',
                  hintStyle: const TextStyle(color: Colors.white70, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // ─ All Pokemon ─
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
            tooltip: 'All Pokémon',
            onPressed: _showAllPokemon,
          ),

          // ─ Favorites ─
          IconButton(
            icon: Icon(
              _showingFavorites ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            tooltip: 'Favorites',
            onPressed: _showFavorites,
          ),

          // ─Login / Logout ─
          if (auth.isLoggedIn) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
              child: Text(
                auth.username ?? '',
                style: const TextStyle(
                    color: Colors.white, fontSize: 12),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Sign out',
              onPressed: () async {
                await auth.signout();
                setState(() {
                  _favoritePokemonIds = {};
                  _showingFavorites = false;
                  _filteredPokemon = _allPokemon;
                });
              },
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              tooltip: 'Trainer Login',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SigninPage()),
                );
                if (auth.isLoggedIn) await fetchFavorites();
              },
            ),
          const SizedBox(width: 4),
        ],
          bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Container(
            color:oliveGreen,
            height: 10,
          ),
        ),
      ),
      body: Container(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _filteredPokemon.isEmpty
                ? Center(
                    child: Text(
                      _showingFavorites
                          ? 'No favorites yet!'
                          : 'No Pokémon found',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredPokemon.length,
                    itemBuilder: (context, index) {
                      final pokemon = _filteredPokemon[index];
                      final isFavorite =
                          _favoritePokemonIds.contains(pokemon['id']);
                      return PokemonCard(
                        pokemon: pokemon,
                        isFavorite: isFavorite,
                        onFavoriteToggled: (isAdding) =>
                            toggleFavorite(pokemon['id'], isAdding),
                      );
                    },
                  ),
      ),
    );
  }
}

// =======================
// POKEMON CARD
// =======================

class PokemonCard extends StatefulWidget {
  final dynamic pokemon;
  final bool isFavorite;
  final Function(bool isAdding)? onFavoriteToggled;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.isFavorite,
    this.onFavoriteToggled,
  });

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: isHovered ? Colors.black26 : Colors.black12,
              blurRadius: isHovered ? 15 : 5,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.network(
                        widget.pokemon['sprite_url'],
                        fit: BoxFit.contain,
                        placeholderBuilder: (_) =>
                            const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "#${widget.pokemon['id'].toString().padLeft(3, '0')}",
                        style: const TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.pokemon['name'].toString().toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF313131)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            //  Favorite button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  if (auth.isLoggedIn) {
                    widget.onFavoriteToggled?.call(!widget.isFavorite);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please log in to add favorites.')),
                    );
                  }
                },
                child: Icon(
                  widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: widget.isFavorite
                      ? const Color(0xFFE3350D)
                      : Colors.grey,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}