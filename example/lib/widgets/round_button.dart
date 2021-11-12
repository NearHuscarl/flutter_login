import 'package:flutter/material.dart';

class RoundButton extends StatefulWidget {
  const RoundButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.label,
    required this.loadingController,
    this.interval = const Interval(0, 1, curve: Curves.ease),
    this.size = 60,
  }) : super(key: key);

  final Widget? icon;
  final VoidCallback onPressed;
  final String? label;
  final AnimationController? loadingController;
  final Interval interval;
  final double size;

  @override
  _RoundButtonState createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleLoadingAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 500),
    );
    _scaleLoadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: widget.loadingController!,
        curve: widget.interval,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: .75).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOut,
        reverseCurve: const ElasticInCurve(0.3),
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor =
        Colors.primaries.where((c) => c == theme.primaryColor).first;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ScaleTransition(
        scale: _scaleLoadingAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ScaleTransition(
              scale: _scaleAnimation,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: FittedBox(
                  child: FloatingActionButton(
                    // allow more than 1 FAB in the same screen (hero tag cannot be duplicated)
                    heroTag: null,
                    backgroundColor: primaryColor.shade400,
                    onPressed: () {
                      _pressController.forward().then((_) {
                        _pressController.reverse();
                      });
                      widget.onPressed();
                    },
                    foregroundColor: Colors.white,
                    child: widget.icon,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.label!,
              style:
                  theme.textTheme.caption!.copyWith(color: theme.primaryColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
