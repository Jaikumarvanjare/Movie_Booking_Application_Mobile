import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../theatres/presentation/theatre_list_screen.dart';
import '../data/movie.dart';
import '../data/movie_repository.dart';

class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({required this.movie, super.key});

  final Movie movie;

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late Future<Movie> _movieFuture;

  @override
  void initState() {
    super.initState();
    _movieFuture = context.read<MovieRepository>().fetchMovieById(
      widget.movie.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Movie>(
      future: _movieFuture,
      builder: (context, snapshot) {
        final movie = snapshot.data ?? widget.movie;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF020617),
                  Color(0xFF0F172A),
                  Color(0xFF020617),
                ],
              ),
            ),
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _DetailsHero(movie: movie, theme: theme),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (snapshot.hasError)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _InlineInfoCard(
                                text:
                                    'Showing cached details. ${snapshot.error}',
                              ),
                            ),
                          Text(
                            movie.name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: const Color(0xFFE2E8F0),
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${movie.language} - ${movie.releaseDateLabel}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF94A3B8),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _InfoGrid(movie: movie),
                          if (movie.trailerUrl.trim().isNotEmpty) ...[
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: () => _openTrailer(context, movie),
                              icon: const Icon(
                                Icons.play_circle_outline_rounded,
                              ),
                              label: const Text('Watch trailer'),
                            ),
                          ],
                          const SizedBox(height: 24),
                          _SectionTitle(title: 'Story', theme: theme),
                          const SizedBox(height: 8),
                          Text(
                            movie.description.isEmpty
                                ? 'Description will appear here when the backend provides it.'
                                : movie.description,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF94A3B8),
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _ChipSection(
                            title: 'Cast',
                            values: movie.casts.isEmpty
                                ? const ['Cast data unavailable']
                                : movie.casts,
                            theme: theme,
                          ),
                          const SizedBox(height: 24),
                          _ChipSection(
                            title: 'Movie details',
                            values: [movie.releaseStatusLabel, movie.language],
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TheatreListScreen(movie: movie),
                  ),
                );
              },
              icon: const Icon(Icons.event_seat_rounded),
              label: const Text('Book seats'),
            ),
          ),
        );
      },
    );
  }

  void _openTrailer(BuildContext context, Movie movie) {
    final trailerUrl = movie.trailerUrl.trim();
    final uri = Uri.tryParse(trailerUrl);
    if (uri == null || !uri.isAbsolute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trailer link is not available.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrailerScreen(movie: movie, trailerUri: uri),
      ),
    );
  }
}

class TrailerScreen extends StatefulWidget {
  const TrailerScreen({
    required this.movie,
    required this.trailerUri,
    super.key,
  });

  final Movie movie;
  final Uri trailerUri;

  @override
  State<TrailerScreen> createState() => _TrailerScreenState();
}

class _TrailerScreenState extends State<TrailerScreen> {
  late final WebViewController _controller;
  var _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF020617))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() => _progress = progress);
            }
          },
        ),
      );

    final videoId = _youtubeVideoId(widget.trailerUri);
    if (videoId == null) {
      _controller.loadRequest(widget.trailerUri);
    } else {
      _controller.loadHtmlString(
        _youtubeEmbedHtml(videoId),
        baseUrl: _youtubeEmbedOrigin,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020617),
        foregroundColor: const Color(0xFFE2E8F0),
        title: Text(
          widget.movie.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFFE2E8F0),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          ColoredBox(
            color: Colors.black,
            child: SafeArea(
              top: false,
              bottom: false,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    if (_progress < 100)
                      LinearProgressIndicator(
                        value: _progress == 0 ? null : _progress / 100,
                        minHeight: 3,
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: _TrailerDetailsPanel(movie: widget.movie)),
        ],
      ),
    );
  }
}

class _TrailerDetailsPanel extends StatelessWidget {
  const _TrailerDetailsPanel({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = movie.description.trim();

    return ColoredBox(
      color: const Color(0xFF020617),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Text(
            '${movie.name} - Official Trailer',
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(0xFFF8FAFC),
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${movie.language} • ${movie.releaseDateLabel}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: movie.primaryColor,
                child: const Icon(
                  Icons.local_movies_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CineBook Trailers',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFFF8FAFC),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      movie.director.trim().isEmpty
                          ? 'Movie trailer'
                          : 'Directed by ${movie.director}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TheatreListScreen(movie: movie),
                    ),
                  );
                },
                child: const Text('Book'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TrailerActionChip(
                  icon: Icons.thumb_up_alt_outlined,
                  label: 'Like',
                  onPressed: () {},
                ),
                _TrailerActionChip(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onPressed: () {},
                ),
                _TrailerActionChip(
                  icon: Icons.event_seat_rounded,
                  label: 'Shows',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TheatreListScreen(movie: movie),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TrailerMetaChip(label: movie.releaseStatusLabel),
                    _TrailerMetaChip(label: movie.language),
                    _TrailerMetaChip(label: movie.releaseDateLabel),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description.isEmpty
                      ? 'Story details will appear here when available.'
                      : description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFD1D5DB),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          if (movie.casts.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Cast',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFFF8FAFC),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final cast in movie.casts.take(6))
                  _TrailerMetaChip(label: cast),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TrailerActionChip extends StatelessWidget {
  const _TrailerActionChip({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onPressed: onPressed,
        backgroundColor: const Color(0xFF1F2937),
        labelStyle: const TextStyle(
          color: Color(0xFFF8FAFC),
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide.none,
      ),
    );
  }
}

class _TrailerMetaChip extends StatelessWidget {
  const _TrailerMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFFE2E8F0),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

const _youtubeEmbedOrigin = 'https://cinebook.local';

String _youtubeEmbedHtml(String videoId) {
  final src = Uri.https('www.youtube.com', '/embed/$videoId', {
    'autoplay': '1',
    'enablejsapi': '1',
    'fs': '1',
    'iv_load_policy': '3',
    'rel': '0',
    'modestbranding': '1',
    'playsinline': '1',
    'origin': _youtubeEmbedOrigin,
  });
  final escapedSrc = const HtmlEscape().convert(src.toString());

  return '''
<!doctype html>
<html>
  <head>
    <meta name="referrer" content="strict-origin-when-cross-origin">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
      html, body {
        margin: 0;
        width: 100%;
        height: 100%;
        overflow: hidden;
        background: #020617;
      }
      iframe {
        border: 0;
        width: 100%;
        height: 100%;
        display: block;
      }
    </style>
  </head>
  <body>
    <iframe
      src="$escapedSrc"
      title="YouTube video player"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
      allowfullscreen
      referrerpolicy="strict-origin-when-cross-origin">
    </iframe>
  </body>
</html>
''';
}

String? _youtubeVideoId(Uri uri) {
  final host = uri.host.toLowerCase().replaceFirst('www.', '');
  if (host == 'youtu.be') {
    return uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
  }
  if (host != 'youtube.com' && host != 'm.youtube.com') {
    return null;
  }

  final queryId = uri.queryParameters['v'];
  if (queryId != null && queryId.isNotEmpty) {
    return queryId;
  }

  if (uri.pathSegments.length >= 2 &&
      (uri.pathSegments.first == 'embed' ||
          uri.pathSegments.first == 'shorts')) {
    return uri.pathSegments[1];
  }

  return null;
}

class _DetailsHero extends StatelessWidget {
  const _DetailsHero({required this.movie, required this.theme});

  final Movie movie;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.poster.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: SizedBox(
        height: 420,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (posterUrl.isNotEmpty)
              Image.network(
                posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _DetailsHeroFallback(movie: movie),
              )
            else
              _DetailsHeroFallback(movie: movie),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x77020617),
                    Color(0x22020617),
                    Color(0xF2020617),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const Spacer(),
                      _HeroBadge(label: movie.releaseStatusLabel),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    movie.language,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.releaseDateLabel,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsHeroFallback extends StatelessWidget {
  const _DetailsHeroFallback({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [movie.primaryColor, movie.accentColor],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.movie_creation_outlined,
          color: Colors.white.withValues(alpha: 0.74),
          size: 72,
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _InfoPill(label: 'Director', value: movie.director),
        _InfoPill(label: 'Release', value: movie.releaseDateLabel),
        _InfoPill(
          label: 'Trailer',
          value: movie.trailerUrl.trim().isEmpty ? 'Unavailable' : 'Available',
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFE2E8F0),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.title,
    required this.values,
    required this.theme,
  });

  final String title;
  final List<String> values;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title, theme: theme),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final value in values)
              Chip(
                label: Text(value),
                avatar: const Icon(Icons.local_movies_rounded, size: 18),
              ),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.theme});

  final String title;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        color: const Color(0xFFE2E8F0),
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InlineInfoCard extends StatelessWidget {
  const _InlineInfoCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(14), child: Text(text)),
    );
  }
}
