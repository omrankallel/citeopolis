import 'package:flutter/material.dart';

import '../../core/core.dart';

class AtomAppBarWithSearch extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final TextEditingController? searchController;
  final String searchHint;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchCleared;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool showSearchInitially;
  final bool isDarkMode;
  final Widget? leading;
  final Widget Function(BuildContext context, Animation<double> animation)? leadingBuilder;

  const AtomAppBarWithSearch({
    required this.isDarkMode,
    this.searchHint = 'Rechercher...',
    this.searchController,
    this.title,
    this.onSearchChanged,
    this.onSearchCleared,
    this.actions,
    this.backgroundColor,
    this.showSearchInitially = false,
    this.leading,
    this.leadingBuilder,
    super.key,
  });

  @override
  State<AtomAppBarWithSearch> createState() => _AtomAppBarWithSearchState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AtomAppBarWithSearchState extends State<AtomAppBarWithSearch> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late FocusNode _searchFocusNode;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _isSearching = widget.showSearchInitially;
    _searchFocusNode = FocusNode();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.searchController != null) {
      widget.searchController!.addListener(() {
        setState(() {});
      });
    }

    if (_isSearching) {
      _animationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch({bool clearText = true}) {
    setState(() {
      _isSearching = !_isSearching;
    });

    if (_isSearching) {
      _animationController.duration = const Duration(milliseconds: 400);
      _animationController.forward();

      Future.delayed(const Duration(milliseconds: 300), () {
        _searchFocusNode.requestFocus();
      });
    } else {
      _animationController.duration = const Duration(milliseconds: 800);
      _animationController.reverse();
      _searchFocusNode.unfocus();
      if (clearText) {
        _clearSearch();
      }
    }
  }

  void _clearSearch() {
    if (widget.searchController != null) {
      widget.searchController!.clear();
    }
    widget.onSearchCleared?.call();
  }

  void _onSearchChanged(String value) {
    widget.onSearchChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => AppBar(
          backgroundColor: widget.backgroundColor ?? Theme.of(context).primaryColor,
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: _buildLeading(context),
          title: _buildTitle(),
          actions: _buildActions(context),
        ),
      );

  Widget? _buildLeading(BuildContext context) {
    if (_isSearching) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () {
            _toggleSearch(clearText: false);
          },
          child: const Icon(Icons.arrow_back, size: 24),
        ),
      );
    }

    if (widget.leadingBuilder != null) {
      return widget.leadingBuilder!(context, _animation);
    }

    if (widget.leading != null) {
      return widget.leading;
    }

    return null;
  }

  Widget? _buildTitle() {
    if (_isSearching) {
      return SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _animation,
          child: TextField(
            focusNode: _searchFocusNode,
            controller: widget.searchController,
            onChanged: _onSearchChanged,
            onSubmitted: (_) {
              _toggleSearch(clearText: false);
            },
            decoration: InputDecoration(
              hintText: widget.searchHint,
              hintStyle: TextStyle(
                color: Colors.grey.withValues(alpha: .7),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            ),
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: widget.isDarkMode ? onPrimaryLight : onPrimaryDark,
                ),
          ),
        ),
      );
    }

    if (widget.title != null) {
      return FadeTransition(
        opacity: _opacityAnimation,
        child: Text(
          widget.title!,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    return null;
  }

  List<Widget> _buildActions(BuildContext context) {
    if (_isSearching) {
      return [
        ScaleTransition(
          scale: _animation,
          child: GestureDetector(
            onTap: () {
              if (widget.searchController != null && widget.searchController!.text.isEmpty) {
                _toggleSearch(clearText: false);
              } else {
                _clearSearch();
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.close, size: 24),
            ),
          ),
        ),
      ];
    }

    final List<Widget> actionsList = [];

    actionsList.addAll({
      ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.8).animate(_animation),
        child: GestureDetector(
          onTap: _toggleSearch,
          child: Container(
            decoration: widget.searchController != null && widget.searchController!.text.isNotEmpty
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.red,
                  )
                : null,
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: widget.searchController != null && widget.searchController!.text.isNotEmpty ? 12.0 : 0),
            child: Icon(widget.searchController != null && widget.searchController!.text.isNotEmpty ? Icons.search_off : Icons.search, size: 24),
          ),
        ),
      ),
      20.pw,
    });

    if (widget.actions != null) {
      for (var i = 0; i < widget.actions!.length; i++) {
        actionsList.add(
          ScaleTransition(
            scale: Tween<double>(begin: 1, end: 0.9).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(0.1 * i, 1.0),
              ),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 1, end: 0.5).animate(_animation),
              child: widget.actions![i],
            ),
          ),
        );
      }
    }

    return actionsList;
  }
}
