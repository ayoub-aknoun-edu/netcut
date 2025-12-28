import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_providers.dart';
import '../../core/platform/firewall_platform.dart';

class AppPickerScreen extends ConsumerStatefulWidget {
  final String groupId;
  const AppPickerScreen({super.key, required this.groupId});

  @override
  ConsumerState<AppPickerScreen> createState() => _AppPickerScreenState();
}

class _AppPickerScreenState extends ConsumerState<AppPickerScreen> {
  List<InstalledApp> _apps = const [];
  bool _loading = true;
  String _query = '';
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final groups = ref.read(groupsControllerProvider).groups;
    final g = groups.where((x) => x.id == widget.groupId).firstOrNull;
    if (g != null) _selected.addAll(g.packageNames);

    final apps = await FirewallPlatform.listLaunchableApps();
    if (!mounted) return;
    setState(() {
      _apps = apps;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final filtered = _apps.where((a) {
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      return a.label.toLowerCase().contains(q) ||
          a.packageName.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick apps'),
        actions: [
          FilledButton(
            onPressed: () async {
              await ref
                  .read(groupsControllerProvider.notifier)
                  .setGroupApps(widget.groupId, _selected.toList());
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search apps…',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                  ? Center(child: Text('No apps found', style: text.bodyLarge))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final app = filtered[i];
                        final selected = _selected.contains(app.packageName);
                        return Card(
                          child: ListTile(
                            leading: app.iconPng == null
                                ? const Icon(Icons.apps_rounded)
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      app.iconPng!,
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                            title: Text(app.label),
                            subtitle: Text(app.packageName),
                            trailing: Checkbox(
                              value: selected,
                              onChanged: (v) {
                                setState(() {
                                  if (v == true) {
                                    _selected.add(app.packageName);
                                  } else {
                                    _selected.remove(app.packageName);
                                  }
                                });
                              },
                            ),
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  _selected.remove(app.packageName);
                                } else {
                                  _selected.add(app.packageName);
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
