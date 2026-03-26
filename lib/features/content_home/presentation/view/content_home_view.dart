import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/atoms/atom_empty.dart';
import '../../../home/domain/modals/content_home/section.dart';
import '../viewmodel/content_home_view_model.dart';
import 'widget/organism_carousel.dart';
import 'widget/organism_events.dart';
import 'widget/organism_news.dart';
import 'widget/organism_publications.dart';
import 'widget/template_quick_access.dart';

class ContentHomeView extends ConsumerStatefulWidget {
  const ContentHomeView({super.key});

  @override
  ConsumerState<ContentHomeView> createState() => _ContentHomeViewState();
}

class _ContentHomeViewState extends ConsumerState<ContentHomeView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final sections = ref.watch(ref.watch(contentHomeProvider).buildPageFiltered).sections ?? [];

    if (sections.isEmpty) {
      return const AtomEmpty();
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        if (index >= sections.length) return const SizedBox.shrink();

        return RepaintBoundary(
          child: _buildSection(sections, index),
        );
      },
    );
  }

  Widget _buildSection(List<Section> sections, int index) {
    final bool isLast = (sections.length - 1) == index;
    final bool isFirst = index == 0;
    final type = sections[index].type ?? '';

    switch (type) {
      case 'carousel':
        return OrganismCarousel(
          selectedIndex: index,
          carrousel: sections[index].carrousel,
          isFirst: isFirst,
        );
      case 'quick_access':
        return TemplateQuickAccess(
          quickAccess: sections[index].quickAccess,
          isLast: isLast,
        );
      case 'news':
        return OrganismNews(
          selectedIndex: index,
          news: sections[index].news,
          isLast: isLast,
        );
      case 'event':
        return OrganismEvents(
          selectedIndex: index,
          event: sections[index].event,
          isLast: isLast,
        );
      case 'publication':
        return OrganismPublications(
          selectedIndex: index,
          publication: sections[index].publication,
          isLast: isLast,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
