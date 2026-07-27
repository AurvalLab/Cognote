import 'package:flutter/material.dart';

import '../observation/domain/observation_search_result.dart';

class ObservationSearchPage extends StatefulWidget {
  const ObservationSearchPage({
    required this.watchSearch,
    required this.onOpenObservation,
    super.key,
  });

  final Stream<List<ObservationSearchResult>> Function(String query)
  watchSearch;
  final ValueChanged<String> onOpenObservation;

  @override
  State<ObservationSearchPage> createState() => _ObservationSearchPageState();
}

class _ObservationSearchPageState extends State<ObservationSearchPage> {
  final _controller = TextEditingController();
  String? _submittedQuery;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text;
    setState(() {
      _submittedQuery = text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _submittedQuery;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(hintText: '请输入关键词'),
          onSubmitted: (_) => _submit(),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              tooltip: '清空',
              onPressed: () => setState(() {
                _controller.clear();
                _submittedQuery = null;
              }),
              icon: const Icon(Icons.clear),
            ),
          IconButton(
            tooltip: '搜索',
            onPressed: _submit,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: query == null || query.isEmpty
          ? const Center(child: Text('请输入关键词'))
          : StreamBuilder<List<ObservationSearchResult>>(
              stream: widget.watchSearch(query),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('搜索失败，请重试'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final results = snapshot.data!;
                if (results.isEmpty) {
                  return const Center(child: Text('没有找到匹配记录'));
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return ListTile(
                      title: Text(result.snippet),
                      subtitle: Text(
                        '${result.observation.inputType.name} · '
                        '${result.observation.capturedAt.toIso8601String()}',
                      ),
                      onTap: () =>
                          widget.onOpenObservation(result.observation.id),
                    );
                  },
                );
              },
            ),
    );
  }
}
