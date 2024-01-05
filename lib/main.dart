// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

@immutable
class Film {
  final String id;
  final String title;
  final String description;
  final bool isFavorite;
  const Film({
    required this.id,
    required this.title,
    required this.description,
    required this.isFavorite,
  });
  Film copy({required bool isFavorite}) => Film(
        id: id,
        title: title,
        description: description,
        isFavorite: isFavorite,
      );

  @override
  String toString() {
    return 'title: $title, description: $description, isFavorite: $isFavorite';
  }

  @override
  bool operator ==(covariant Film other) =>
      id == other.id && isFavorite == other.isFavorite;

  @override
  int get hashCode => Object.hashAll([
        id,
        isFavorite,
      ]);
}

const allFilms = [
  Film(
    id: '1',
    title: 'The Dark Knight',
    description: 'Superhero film directed by Christopher Nolan.',
    isFavorite: false,
  ),
  Film(
    id: '2',
    title: 'The Shawshank Redemption',
    description: 'American drama film written and directed by Frank Darabont.',
    isFavorite: false,
  ),
  Film(
    id: '3',
    title: 'The Godfather',
    description: 'American crime film directed by Francis Ford Coppola.',
    isFavorite: false,
  ),
  Film(
    id: '4',
    title: 'The Godfather: Part II',
    description:
        'American epic crime film produced and directed by Francis Ford Coppola.',
    isFavorite: false,
  ),
  Film(
    id: '5',
    title: 'The Dark Knight Rises',
    description: 'Superhero film directed by Christopher Nolan.',
    isFavorite: false,
  ),
];

class FilmsNotifier extends StateNotifier<List<Film>> {
  FilmsNotifier() : super(allFilms);

  void update(Film film, bool isFavorite) {
    state = state
        .map((thisFilm) => thisFilm.id == film.id
            ? film.copy(isFavorite: isFavorite)
            : thisFilm)
        .toList();
  }
}

enum FavoriteStatus {
  all,
  favorite,
  notFavorite,
}

final favoriteStatusProvider = StateProvider<FavoriteStatus>((ref) {
  return FavoriteStatus.all;
});
final allFilmsProvider =
    StateNotifierProvider<FilmsNotifier, List<Film>>((ref) {
  return FilmsNotifier();
});

final favoriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allFilmsProvider).where((film) => film.isFavorite),
);
final notFavoriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allFilmsProvider).where((film) => !film.isFavorite),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Films'),
        ),
        body: Column(
          children: [
            const FilterWidget(),
            Consumer(
              builder: (context, ref, child) {
                final filter = ref.watch(favoriteStatusProvider);
                switch (filter) {
                  case FavoriteStatus.all:
                    return FilmsWidget(provider: allFilmsProvider);
                  case FavoriteStatus.favorite:
                    return FilmsWidget(provider: favoriteFilmsProvider);
                  case FavoriteStatus.notFavorite:
                    return FilmsWidget(provider: notFavoriteFilmsProvider);
                }
              },
            )
          ],
        ));
  }
}

class FilmsWidget extends ConsumerWidget {
  final AlwaysAliveProviderBase<Iterable<Film>> provider;
  const FilmsWidget({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(provider);
    return Expanded(
      child: ListView.builder(
        itemCount: films.length,
        itemBuilder: (context, index) {
          final film = films.elementAt(index);
          final favoriteIcon = film.isFavorite
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_border);
          return ListTile(
            title: Text(film.title),
            subtitle: Text(film.description),
            trailing: IconButton(
              icon: favoriteIcon,
              onPressed: () {
                ref
                    .read(allFilmsProvider.notifier)
                    .update(film, !film.isFavorite);
              },
            ),
          );
        },
      ),
    );
  }
}

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return DropdownButton(
          value: ref.watch(favoriteStatusProvider),
          items: FavoriteStatus.values
              .map(
                (fs) => DropdownMenuItem(
                  value: fs,
                  child: Text(
                    fs.toString().split('.').last,
                  ),
                ),
              )
              .toList(),
          onChanged: (fs) {
            ref
                .read(
                  favoriteStatusProvider.state,
                )
                .state = fs!;
          },
        );
      },
    );
  }
}
