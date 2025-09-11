import 'package:flutter/material.dart';

class ExpandingCounter extends StatefulWidget {
  const ExpandingCounter({
    super.key,
    this.initial,
    this.min = 0,
    this.max,
    this.onChanged,
    this.height = 36,
    this.collapsedWidth = 36,
    this.expandedWidth = 120,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 2,
  });

  final int? initial;
  final int min;
  final int? max;
  final ValueChanged<int>? onChanged;

  final double height;
  final double collapsedWidth;
  final double expandedWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  @override
  State<ExpandingCounter> createState() => _ExpandingCounterState();
}

class _ExpandingCounterState extends State<ExpandingCounter>
    with SingleTickerProviderStateMixin {
  late int _count;

  bool get _expanded => _count > 0;

  @override
  void initState() {
    super.initState();
    _count = widget.initial ?? widget.min;
  }

  void _notify() => widget.onChanged?.call(_count);

  void _inc() {
    if (widget.max != null && _count >= widget.max!) return;
    setState(() => _count++);
    _notify();
  }

  void _dec() {
    if (_count <= widget.min) return;
    setState(() => _count--);
    _notify();
  }

  void _tapCollapsed() {
    // From collapsed + to count=1
    if (_count < 1) {
      setState(() => _count = 1);
      _notify();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? Colors.white;
    final fg = widget.foregroundColor ?? Colors.black87;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: widget.height,
      width: _expanded ? widget.expandedWidth : widget.collapsedWidth,
      decoration: BoxDecoration(
        color: bg.withOpacity(0.95),
        borderRadius: BorderRadius.circular(widget.height),
        boxShadow: [
          if (widget.elevation > 0)
            BoxShadow(
              blurRadius: widget.elevation * 2,
              spreadRadius: 0,
              offset: const Offset(0, 1),
              color: Colors.black.withOpacity(0.25),
            ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _expanded
              ? _ExpandedControls(
            key: const ValueKey('expanded'),
            count: _count,
            onDecrement: _dec,
            onIncrement: _inc,
            fg: fg,
          )
              : _CollapsedPlus(
            key: const ValueKey('collapsed'),
            onTap: _tapCollapsed,
            fg: fg,
          ),
        ),
      ),
    );
  }
}

class _CollapsedPlus extends StatelessWidget {
  const _CollapsedPlus({super.key, required this.onTap, required this.fg});
  final VoidCallback onTap;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Icon(Icons.add, color: fg, size: 20),
      ),
    );
  }
}

class _ExpandedControls extends StatelessWidget {
  const _ExpandedControls({
    super.key,
    required this.count,
    required this.onDecrement,
    required this.onIncrement,
    required this.fg,
  });

  final int count;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBtn(icon: Icons.remove, onTap: onDecrement, fg: fg),
        Expanded(
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                '$count',
                key: ValueKey(count),
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        _IconBtn(icon: Icons.add, onTap: onIncrement, fg: fg),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    required this.fg,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: double.infinity,
        child: Icon(icon, size: 18, color: fg),
      ),
    );
  }
}
