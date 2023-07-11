import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/selection_vault.dart';

class FilterChooserScreen extends StatefulWidget {
  final Map<String, dynamic> filters;
  const FilterChooserScreen({super.key, required this.filters});

  @override
  State<FilterChooserScreen> createState() => _FilterChooserScreenState();
}

class _FilterChooserScreenState extends State<FilterChooserScreen> {
  @override
  Widget build(BuildContext context) {
    final filterWidgets = [
      CreatedWithin(
          dateRange: widget.filters['createdWithin'],
          onChange: (dateRange) {
            widget.filters['createdWithin'] = dateRange;
          }),
      ResolvedChoose(
          resolved: widget.filters['resolved'],
          onChange: (resolved) {
            setState(() {
              widget.filters['resolved'] = resolved;
            });
            // TODO: when resolved == false remove the resolved filter and show it only if resolved == true
          }),
      if (widget.filters['resolved'] == true)
        ResolvedWithin(
            dateRange: widget.filters['resolvedWithin'],
            onChange: (dateRange) {
              widget.filters['resolvedWithin'] = dateRange;
            }),
      ScopeChooser(
          scope: widget.filters['scope'],
          onChange: (scope) {
            widget.filters['scope'] = scope;
          }),
      CategoriesBuilder(
        src: Source.cache,
        loadingWidget: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: circularProgressIndicator(),
          ),
        ),
        builder: (ctx, categories) => CategoryChooser(
            onChange: ((chosenCategories) {
              widget.filters['categories'] = chosenCategories;
            }),
            allCategories: categories.map((e) => e.id).toList(),
            chosenCategories: widget.filters['categories'] ?? []),
      ),
      UsersBuilder(
        src: Source.cache,
        loadingWidget: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: circularProgressIndicator(),
          ),
        ),
        builder: (ctx, users) => ComplainantChooser(
          allUsers: users,
          onChange: (users) {
            widget.filters['complainants'] = users;
          },
          chosenUsers: widget.filters['complainants'] ?? [],
        ),
      ),
      UsersBuilder(
        provider: fetchComplainees,
        src: Source.cache,
        loadingWidget: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: circularProgressIndicator(),
          ),
        ),
        builder: (ctx, users) => ComplaineeChooser(
          allUsers: users,
          onChange: (users) {
            widget.filters['complainees'] = users;
          },
          chosenUsers: widget.filters['complainees'] ?? [],
        ),
      ),
      // TODO: add more filters here
    ];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Filters'),
        actions: [
          TextButton(
            onPressed: () {
              widget.filters.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchAllUserEmails();
          await fetchAllCategories();
          await fetchComplainees();
        },
        child: ListView.separated(
          itemCount: filterWidgets.length,
          separatorBuilder: (ctx, index) => const Divider(),
          itemBuilder: (ctx, index) => Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8),
            child: filterWidgets[index],
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String txt;
  const _Title(this.txt);

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final bool isSelected;
  final void Function() onPressed;
  final String label;
  const _OutlinedButton({
    required this.isSelected,
    required this.onPressed,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton(
      style: isSelected
          ? OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onPrimary,
              backgroundColor: theme.colorScheme.primary,
              side: BorderSide(color: theme.colorScheme.primary),
            )
          : null,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

// ignore: must_be_immutable
class CreatedWithin extends StatefulWidget {
  final void Function(DateTimeRange? dateRange) onChange;
  DateTimeRange? dateRange;
  CreatedWithin({
    super.key,
    required this.onChange,
    this.dateRange,
  });

  @override
  State<CreatedWithin> createState() => _CreatedWithinState();
}

class _CreatedWithinState extends State<CreatedWithin> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    int i = 0;
    int selectedIndex = 0;

    if (widget.dateRange == null) {
      selectedIndex = 4;
    } else if (widget.dateRange!.end.day == DateTime.now().day) {
      final duration =
          widget.dateRange!.end.difference(widget.dateRange!.start);
      if (duration.inDays == 7) {
        selectedIndex = 1;
      } else if (duration.inDays == 30) {
        selectedIndex = 2;
      } else if (duration.inDays == 365) {
        selectedIndex = 3;
      } else {
        selectedIndex = 5;
      }
    } else if (widget.dateRange!.end == DateTime(now.year, now.month, 1) &&
        widget.dateRange!.start == DateTime(now.year, now.month - 1, 1)) {
      selectedIndex = 0;
    } else {
      selectedIndex = 5;
    }

    /// The items in this filter
    final items = [
      _OutlinedButton(
        label: 'Last month',
        isSelected: selectedIndex == i++,
        onPressed: () {
          setState(() {
            widget.dateRange = DateTimeRange(
              start: DateTime(now.year, now.month - 1, 1),
              end: DateTime(now.year, now.month, 1),
            );
          });
          widget.onChange(widget.dateRange);
        },
      ),
      _OutlinedButton(
        label: 'Last 7 Days',
        isSelected: selectedIndex == i++,
        onPressed: () {
          setState(() {
            widget.dateRange = DateTimeRange(
              end: DateTime(now.year, now.month, now.day),
              start: DateTime(now.year, now.month, now.day - 7),
            );
          });
          widget.onChange(widget.dateRange);
        },
      ),
      _OutlinedButton(
        label: 'Last 30 Days',
        isSelected: selectedIndex == i++,
        onPressed: () {
          setState(() {
            widget.dateRange = DateTimeRange(
              end: DateTime(now.year, now.month, now.day),
              start: DateTime(now.year, now.month, now.day - 30),
            );
          });
          widget.onChange(widget.dateRange);
        },
      ),
      _OutlinedButton(
        label: 'Last 365 Days',
        isSelected: selectedIndex == i++,
        onPressed: () {
          setState(() {
            widget.dateRange = DateTimeRange(
              end: DateTime(now.year, now.month, now.day),
              start: DateTime(now.year, now.month, now.day - 365),
            );
          });
          widget.onChange(widget.dateRange);
        },
      ),
      _OutlinedButton(
        label: 'All Time',
        isSelected: selectedIndex == i++,
        onPressed: () {
          setState(() {
            widget.dateRange = null;
          });
          widget.onChange(widget.dateRange);
        },
      ),
      _OutlinedButton(
        label: (selectedIndex == i
            ? '${ddmmyyyy(widget.dateRange!.start)} - ${ddmmyyyy(widget.dateRange!.end)}'
            : 'Custom'),
        isSelected: selectedIndex == i++,
        onPressed: () async {
          final dateRange = await showDateRangePicker(
            context: context,
            initialDateRange: widget.dateRange,
            helpText: 'Select 2 dates',
            firstDate: DateTime.utc(1997),
            lastDate: DateTime.now(),
          );
          if (dateRange != null) {
            setState(() {
              widget.dateRange = dateRange;
            });
            widget.onChange(widget.dateRange);
          }
        },
      ),
    ];

    final children = [
      Row(
        children: [
          const _Title('Created within'),
          IconButton(
            onPressed: () {
              setState(() {
                expanded = !expanded;
              });
            },
            icon: Icon(expanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded),
          ),
        ],
      ),
      if (expanded)
        Wrap(children: items)
      else
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (ctx, index) => const SizedBox(width: 5),
            itemBuilder: (ctx, index) => items[index],
            itemCount: items.length,
          ),
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

// ignore: must_be_immutable
class ResolvedWithin extends StatefulWidget {
  final void Function(DateTimeRange? dateRange) onChange;
  DateTimeRange? dateRange;
  ResolvedWithin({
    super.key,
    required this.onChange,
    this.dateRange,
  });

  @override
  State<ResolvedWithin> createState() => _ResolvedWithinState();
}

class _ResolvedWithinState extends State<ResolvedWithin> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    int i = 0;
    int selectedIndex = 0;

    if (widget.dateRange == null) {
      selectedIndex = 4;
    } else if (widget.dateRange!.end.day == DateTime.now().day) {
      final duration =
          widget.dateRange!.end.difference(widget.dateRange!.start);
      if (duration.inDays == 7) {
        selectedIndex = 1;
      } else if (duration.inDays == 30) {
        selectedIndex = 2;
      } else if (duration.inDays == 365) {
        selectedIndex = 3;
      } else {
        selectedIndex = 5;
      }
    } else if (widget.dateRange!.end == DateTime(now.year, now.month, 1) &&
        widget.dateRange!.start == DateTime(now.year, now.month - 1, 1)) {
      selectedIndex = 0;
    } else {
      selectedIndex = 5;
    }

    /// The items in this filter
    final items = [
      _OutlinedButton(
        label: 'Last month',
        isSelected: selectedIndex == i++,
        onPressed: () {
          setState(() {
            widget.dateRange = DateTimeRange(
              start: DateTime(now.year, now.month - 1, 1),
              end: DateTime(now.year, now.month, 1),
            );
          });
          widget.onChange(widget.dateRange);
        },
      ),
      _OutlinedButton(
        label: 'Last 7 Days',
        isSelected: selectedIndex == i++,
        onPressed: () {
          setState(() {
            widget.dateRange = DateTimeRange(
              end: DateTime(now.year, now.month, now.day),
              start: DateTime(now.year, now.month, now.day - 7),
            );
          });
          widget.onChange(widget.dateRange);
        },
      ),
      _OutlinedButton(
        label: 'Last 30 Days',
        isSelected: selectedIndex == i++,
        onPressed: () {
          setState(() {
            widget.dateRange = DateTimeRange(
              end: DateTime(now.year, now.month, now.day),
              start: DateTime(now.year, now.month, now.day - 30),
            );
          });
          widget.onChange(widget.dateRange);
        },
      ),
      _OutlinedButton(
        label: 'Last 365 Days',
        isSelected: selectedIndex == i++,
        onPressed: () {
          setState(() {
            widget.dateRange = DateTimeRange(
              end: DateTime(now.year, now.month, now.day),
              start: DateTime(now.year, now.month, now.day - 365),
            );
          });
          widget.onChange(widget.dateRange);
        },
      ),
      _OutlinedButton(
        label: 'All Time',
        isSelected: selectedIndex == i++,
        onPressed: () {
          setState(() {
            widget.dateRange = null;
          });
          widget.onChange(widget.dateRange);
        },
      ),
      _OutlinedButton(
        label: (selectedIndex == i
            ? '${ddmmyyyy(widget.dateRange!.start)} - ${ddmmyyyy(widget.dateRange!.end)}'
            : 'Custom'),
        isSelected: selectedIndex == i++,
        onPressed: () async {
          final dateRange = await showDateRangePicker(
            context: context,
            initialDateRange: widget.dateRange,
            helpText: 'Select 2 dates',
            firstDate: DateTime.utc(1997),
            lastDate: DateTime.now(),
          );
          if (dateRange != null) {
            setState(() {
              widget.dateRange = dateRange;
            });
            widget.onChange(widget.dateRange);
          }
        },
      ),
    ];

    final children = [
      Row(
        children: [
          const _Title('Resolved before'),
          IconButton(
            onPressed: () {
              setState(() {
                expanded = !expanded;
              });
            },
            icon: Icon(expanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded),
          ),
        ],
      ),
      if (expanded)
        Wrap(children: items)
      else
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (ctx, index) => const SizedBox(width: 5),
            itemBuilder: (ctx, index) => items[index],
            itemCount: items.length,
          ),
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

// ignore: must_be_immutable
class ScopeChooser extends StatefulWidget {
  Scope? scope;
  final void Function(Scope? scope) onChange;
  ScopeChooser({super.key, this.scope, required this.onChange});

  @override
  State<ScopeChooser> createState() => _ScopeChooserState();
}

class _ScopeChooserState extends State<ScopeChooser> {
  @override
  Widget build(BuildContext context) {
    /// The items in this filter
    final items = [
      _OutlinedButton(
        label: 'Private',
        isSelected: widget.scope == Scope.private,
        onPressed: () {
          setState(() {
            widget.scope = Scope.private;
          });
          widget.onChange(widget.scope);
        },
      ),
      _OutlinedButton(
        label: 'Public',
        isSelected: widget.scope == Scope.public,
        onPressed: () {
          setState(() {
            widget.scope = Scope.public;
          });
          widget.onChange(widget.scope);
        },
      ),
      _OutlinedButton(
        label: 'Any',
        isSelected: widget.scope == null,
        onPressed: () {
          setState(() {
            widget.scope = null;
          });
          widget.onChange(widget.scope);
        },
      ),
    ];

    final children = [
      const SizedBox(height: 8),
      const _Title('Scope'),
      const SizedBox(height: 8),
      SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          separatorBuilder: (ctx, index) => const SizedBox(width: 5),
          itemBuilder: (ctx, index) => items[index],
          itemCount: items.length,
        ),
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

// ignore: must_be_immutable
class ResolvedChoose extends StatefulWidget {
  bool? resolved;
  final void Function(bool? resolved) onChange;
  ResolvedChoose({super.key, this.resolved, required this.onChange});

  @override
  State<ResolvedChoose> createState() => _ResolvedChooseState();
}

class _ResolvedChooseState extends State<ResolvedChoose> {
  @override
  Widget build(BuildContext context) {
    /// The items in this filter
    final items = [
      _OutlinedButton(
        label: 'Resolved',
        isSelected: widget.resolved == true,
        onPressed: () {
          setState(() {
            widget.resolved = true;
          });
          widget.onChange(widget.resolved);
        },
      ),
      _OutlinedButton(
        label: 'Pending',
        isSelected: widget.resolved == false,
        onPressed: () {
          setState(() {
            widget.resolved = false;
          });
          widget.onChange(widget.resolved);
        },
      ),
      _OutlinedButton(
        label: 'Any',
        isSelected: widget.resolved == null,
        onPressed: () {
          setState(() {
            widget.resolved = null;
          });
          widget.onChange(widget.resolved);
        },
      ),
    ];

    final children = [
      const SizedBox(height: 8),
      const _Title('Status'),
      const SizedBox(height: 8),
      SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          separatorBuilder: (ctx, index) => const SizedBox(width: 5),
          itemBuilder: (ctx, index) => items[index],
          itemCount: items.length,
        ),
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class ComplainantChooser extends StatelessWidget {
  final void Function(List<String> chosenUsers) onChange;
  final List<String> allUsers;
  final List<String> chosenUsers;
  const ComplainantChooser({
    super.key,
    required this.onChange,
    required this.allUsers,
    required this.chosenUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const _Title('Complainants'),
        const SizedBox(height: 8),
        SelectionVault(
          helpText: 'Select a Complainant',
          onChange: onChange,
          allItems: allUsers,
          chosenItems: chosenUsers,
        ),
      ],
    );
  }
}

class ComplaineeChooser extends StatelessWidget {
  final void Function(List<String> chosenUsers) onChange;
  final List<String> allUsers;
  final List<String> chosenUsers;
  const ComplaineeChooser({
    super.key,
    required this.onChange,
    required this.allUsers,
    required this.chosenUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const _Title('Complainees'),
        const SizedBox(height: 8),
        SelectionVault(
          helpText: 'Select a Complainee',
          onChange: onChange,
          allItems: allUsers,
          chosenItems: chosenUsers,
        ),
      ],
    );
  }
}

class CategoryChooser extends StatelessWidget {
  final void Function(List<String> chosenCategories) onChange;
  final List<String> allCategories;
  final List<String> chosenCategories;
  const CategoryChooser({
    super.key,
    required this.onChange,
    required this.allCategories,
    required this.chosenCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const _Title('Categories'),
        const SizedBox(height: 8),
        SelectionVault(
          helpText: 'Select a Category',
          onChange: onChange,
          allItems: allCategories,
          chosenItems: chosenCategories,
        ),
      ],
    );
  }
}
