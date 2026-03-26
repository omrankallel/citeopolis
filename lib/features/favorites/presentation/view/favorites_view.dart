import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/core.dart';
import '../../../../core/extensions/tile_extension.dart';
import '../../../../core/memory/local_storage_list_service.dart';
import '../../../../core/services/injector.dart';
import '../../../../design_system/atoms/atom_text.dart';
import '../../../../router/navigation_service.dart';
import '../../../../router/routes.dart';
import '../../../map/domain/modals/tile_map.dart';
import '../../../map/domain/modals/xml_map.dart';
import '../../../tile/domain/modals/tile.dart';
import '../../../tile/domain/modals/xml/xml_article.dart';
import '../../../tile/domain/modals/xml/xml_directory.dart';
import '../../../tile/domain/modals/xml/xml_event.dart';
import '../../../tile/domain/modals/xml/xml_publication.dart';
import '../../domain/modals/favorite.dart';
import '../../domain/repositories/favorite_domain_module.dart';
import '../viewmodel/favorites_view_model.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  String? _selectedType;
  String _searchQuery = '';
  final bool _isGridView = false;

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widget) {
          ref.watch(favoritesProvider);
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                20.ph,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AtomText(
                    data: 'Vous avez 10 pages dans vos favoris',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                        ),
                  ),
                ),
                20.ph,
                SizedBox(
                  height: Helpers.getResponsiveHeight(context) * .6,
                  child: _buildFavoritesList(),
                ),
              ],
            ),
          );
        },
      );

  Widget _buildFavoritesList() => Consumer(
        builder: (context, ref, child) {
          // Watcher en fonction du filtre sélectionné
          final favoritesAsync = _selectedType != null
              ? ref.watch(favoritesByTypeProvider(_selectedType!))
              : _searchQuery.isNotEmpty
                  ? ref.watch(searchFavoritesProvider)
                  : ref.watch(allFavoritesProvider);

          return favoritesAsync.when(
            data: (favorites) => _buildFavoritesContent(ref, favorites),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(ref, error),
          );
        },
      );

  Widget _buildErrorState(WidgetRef ref, Object error) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur lors du chargement',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                //ref.refresh(allFavoritesProvider);
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );

  Widget _buildLoadingState() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des favoris...'),
          ],
        ),
      );

  Widget _buildFavoritesContent(WidgetRef ref, List<dynamic> favorites) {
    if (favorites.isEmpty) {
      return _buildEmptyState(ref);
    }

    if (_isGridView) {
      return _buildGridView(favorites);
    } else {
      return _buildListView(ref, favorites);
    }
  }

  Widget _buildEmptyState(WidgetRef ref) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedType != null
                  ? 'Aucun favori de ce type'
                  : _searchQuery.isNotEmpty
                      ? 'Aucun résultat trouvé'
                      : 'Aucun favori pour le moment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedType != null || _searchQuery.isNotEmpty ? 'Essayez de modifier vos filtres' : 'Appuyez sur ❤️ pour ajouter des éléments à vos favoris',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
            if (_selectedType != null || _searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedType = null;
                    _searchQuery = '';
                  });
                  ref.read(selectedFavoriteType.notifier).state = null;
                  ref.read(favoriteSearchQuery.notifier).state = '';
                },
                child: const Text('Effacer les filtres'),
              ),
            ],
          ],
        ),
      );

  Widget _buildListView(WidgetRef ref, List<dynamic> favorites) => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final favorite = favorites[index] as Favorite;
          if (favorite.type == 'fo_tul') {
            return _buildFavoriteUrlOrQuickAccess(ref, favorite);
          } else if (favorite.type == 'fo_tuc' ||favorite.type == 'fo_tup' || favorite.type == 'fo_tux' || favorite.type == 'fo_tux_article' || favorite.type == 'fo_tux_directory' || favorite.type == 'fo_tux_publication' || favorite.type == 'fo_tux_event') {
            return _buildFavoritePublication(ref, favorite);
          }
          return _buildFavoriteUrlOrQuickAccess(ref, favorite);
        },
      );

  Widget _buildGridView(List<dynamic> favorites) => GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final favorite = favorites[index] as Favorite;
          return _buildFavoriteGridCard(favorite);
        },
      );

  Widget _buildFavoriteUrlOrQuickAccess(WidgetRef ref, Favorite favorite) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () async {
            if (favorite.type == 'fo_tua') {
              await context.redirectToTile(ref, favorite.id.split('_').last, true);
            } else {
              NavigationService.go(context, ref, Paths.urlTileWithScaffold, extra: favorite.id.split('_').last);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 83,
                  height: 82,
                  decoration: BoxDecoration(
                    color: ref.watch(themeProvider).isDarkMode ? primaryLight : primaryDark,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Icon(
                    favorite.type == 'fo_tua' ? Icons.dashboard : Icons.link,
                    size: 36,
                    color: ref.watch(themeProvider).isDarkMode ? primaryDark : primaryLight,
                  ),
                ),
                16.pw,
                Expanded(
                  child: AtomText(
                    data: favorite.title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                        ),
                    maxLines: 4,
                  ),
                ),
                FloatingActionButton.small(
                  heroTag: favorite.id,
                  onPressed: () async {
                    final useCase = ref.read(favoriteUseCaseProvider);
                    final result = await useCase.removeFromFavorites(favorite.id);
                    result.fold(
                      (error) => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur lors de la suppression: $error'),
                          backgroundColor: Colors.red,
                        ),
                      ),
                      (success) {
                        if (success) {
                          ref.invalidate(allFavoritesProvider);
                          if (_selectedType != null) {
                            ref.invalidate(favoritesByTypeProvider(_selectedType!));
                          }
                          if (_searchQuery.isNotEmpty) {
                            ref.invalidate(searchFavoritesProvider);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${favorite.title} supprimé des favoris'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Échec de la suppression'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                    );
                  },
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  backgroundColor: ref.watch(themeProvider).isDarkMode ? primaryDark : primaryLight,
                  child: SvgPicture.asset(
                    ref.watch(themeProvider).isDarkMode ? Assets.assetsImageSaveDark : Assets.assetsImageSaveLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildFavoritePublication(WidgetRef ref, Favorite favorite) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            if (favorite.type == 'fo_tux_article') {
              final String tileXmlId = favorite.originalData['tileXmlId'];
              final projectId = ProdConfig().projectId;

              final storage = getIt<LocalStorageListService<Tile>>();
              final tiles = storage.get(projectId.toString()) ?? <Tile>[];
              final tile = tiles.firstWhere((t) => t.id.toString() == tileXmlId);
              final tileXml = tile.xmlDetails;
              final article = Article.fromJson(favorite.originalData['article']);
              NavigationService.push(
                context,
                ref,
                Paths.detailArticleXml,
                extra: {
                  'tileXml': tileXml,
                  'articleXml': article,
                },
              );
            } else if (favorite.type == 'fo_tux_directory') {
              final String tileXmlId = favorite.originalData['tileXmlId'];
              final projectId = ProdConfig().projectId;

              final storage = getIt<LocalStorageListService<Tile>>();
              final tiles = storage.get(projectId.toString()) ?? <Tile>[];
              final tile = tiles.firstWhere((t) => t.id.toString() == tileXmlId);
              final tileXml = tile.xmlDetails;
              final directory = Directory.fromJson(favorite.originalData['directory']);
              NavigationService.push(
                context,
                ref,
                Paths.detailDirectoryXml,
                extra: {
                  'tileXml': tileXml,
                  'directoryXml': directory,
                },
              );
            } else if (favorite.type == 'fo_tux_publication') {
              final String tileXmlId = favorite.originalData['tileXmlId'];
              final projectId = ProdConfig().projectId;

              final storage = getIt<LocalStorageListService<Tile>>();
              final tiles = storage.get(projectId.toString()) ?? <Tile>[];
              final tile = tiles.firstWhere((t) => t.id.toString() == tileXmlId);
              final tileXml = tile.xmlDetails;
              final publication = Publication.fromJson(favorite.originalData['publication']);
              NavigationService.push(
                context,
                ref,
                Paths.detailPublicationXml,
                extra: {
                  'tileXml': tileXml,
                  'publicationXml': publication,
                },
              );
            } else if (favorite.type == 'fo_tux_event') {
              final String tileXmlId = favorite.originalData['tileXmlId'];
              final projectId = ProdConfig().projectId;

              final storage = getIt<LocalStorageListService<Tile>>();
              final tiles = storage.get(projectId.toString()) ?? <Tile>[];
              final tile = tiles.firstWhere((t) => t.id.toString() == tileXmlId);
              final tileXml = tile.xmlDetails;
              final event = Event.fromJson(favorite.originalData['event']);
              NavigationService.push(
                context,
                ref,
                Paths.detailEventsXml,
                extra: {
                  'tileXml': tileXml,
                  'eventXml': event,
                },
              );
            } else if (favorite.type == 'fo_tuc') {
              final TileMap tileMap = TileMap.fromJson(favorite.originalData['tileMap']);
              final MapXml mapXml = MapXml.fromJson(favorite.originalData['mapXml']);
              NavigationService.push(
                context,
                ref,
                Paths.detailCarte,
                extra: {
                  'tileMap': tileMap,
                  'map': mapXml,
                },
              );
            } else {
              context.redirectToTile(ref, favorite.id.split('_').last, true);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 83,
                  height: 82,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: favorite.imageUrl ?? '',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                16.pw,
                Expanded(
                  child: AtomText(
                    data: favorite.title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                        ),
                    maxLines: 4,
                  ),
                ),
                FloatingActionButton.small(
                  heroTag: favorite.id,
                  onPressed: () async {
                    final useCase = ref.read(favoriteUseCaseProvider);
                    final result = await useCase.removeFromFavorites(favorite.id);
                    result.fold(
                      (error) => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur lors de la suppression: $error'),
                          backgroundColor: Colors.red,
                        ),
                      ),
                      (success) {
                        if (success) {
                          ref.invalidate(allFavoritesProvider);
                          if (_selectedType != null) {
                            ref.invalidate(favoritesByTypeProvider(_selectedType!));
                          }
                          if (_searchQuery.isNotEmpty) {
                            ref.invalidate(searchFavoritesProvider);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${favorite.title} supprimé des favoris'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Échec de la suppression'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                    );
                  },
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  backgroundColor: ref.watch(themeProvider).isDarkMode ? primaryDark : primaryLight,
                  child: SvgPicture.asset(
                    ref.watch(themeProvider).isDarkMode ? Assets.assetsImageSaveDark : Assets.assetsImageSaveLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildFavoriteGridCard(Favorite favorite) => Card(
        child: InkWell(
          onTap: () => _handleFavoriteTap(favorite),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec icône et menu
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getTypeColor(favorite.type).withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTypeIcon(favorite.type),
                        color: _getTypeColor(favorite.type),
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (action) => _handleFavoriteAction(action, favorite),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'open', child: Text('Ouvrir')),
                        const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Titre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        favorite.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (favorite.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          favorite.subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Footer
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      label: Text(
                        _getTypeLabel(favorite.type),
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: _getTypeColor(favorite.type).withValues(alpha: .1),
                      side: BorderSide.none,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(favorite.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  void _handleFavoriteTap(Favorite favorite) {
    // Navigation vers le détail selon le type
    switch (favorite.type) {
      case 'notification':
        _navigateToNotification(favorite);
        break;
      case 'fo_tup':
        _navigateToTileContent(favorite);
        break;
      case 'fo_tux':
        _navigateToTileXml(favorite);
        break;
      default:
        _showFavoriteDetails(favorite);
    }
  }

  void _navigateToNotification(Favorite favorite) {}

  void _navigateToTileContent(Favorite favorite) {}

  void _navigateToTileXml(Favorite favorite) {}

  void _showFavoriteDetails(Favorite favorite) {}

  Color _getTypeColor(String type) {
    switch (type) {
      case 'notification':
        return Colors.blue;
      case 'fo_tup':
        return Colors.green;
      case 'fo_tua':
        return Colors.orange;
      case 'fo_tuc':
        return Colors.red;
      case 'fo_tux':
        return Colors.purple;
      case 'fo_tux_article':
        return Colors.indigo;
      case 'fo_tul':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'notification':
        return 'Notification';
      case 'fo_tup':
        return 'Contenu';
      case 'fo_tua':
        return 'Accès rapide';
      case 'fo_tuc':
        return 'Carte';
      case 'fo_tux':
        return 'XML';
      case 'fo_tux_article':
        return 'Article';
      case 'fo_tul':
        return 'URL';
      default:
        return 'Favori';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _handleFavoriteAction(String action, Favorite favorite) {
    switch (action) {
      case 'open':
        _handleFavoriteTap(favorite);
        break;
      case 'share':
        _shareFavorite(favorite);
        break;
      case 'delete':
        _deleteFavorite(favorite);
        break;
    }
  }

  void _shareFavorite(Favorite favorite) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Partage de "${favorite.title}" (à implémenter)')),
    );
  }

  void _deleteFavorite(Favorite favorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le favori'),
        content: Text('Voulez-vous vraiment supprimer "${favorite.title}" de vos favoris ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {},
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'notification':
        return Icons.notifications;
      case 'fo_tup':
        return Icons.article;
      case 'fo_tua':
        return Icons.dashboard;
      case 'fo_tuc':
        return Icons.map;
      case 'fo_tux':
        return Icons.code;
      case 'fo_tux_article':
        return Icons.description;
      case 'fo_tul':
        return Icons.insert_drive_file_outlined;
      default:
        return Icons.favorite;
    }
  }
}
