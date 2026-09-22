import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_spec.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({required this.onStart, super.key});
  final Future<void> Function() onStart;

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: OnboardingSpec.floatCycle,
  );
  bool _pressed = false;
  bool _hovered = false;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _float.stop();
      _float.value = 0;
    } else if (!_float.isAnimating) {
      _float.repeat();
    }
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onStart();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 760;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: OnboardingColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = math.min(constraints.maxWidth, 390.0);
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: SizedBox(
                      width: width,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: math.max(0, constraints.maxHeight - 32),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _busy ? null : _start,
                                  style: TextButton.styleFrom(
                                    foregroundColor: OnboardingColors.gray,
                                    textStyle: const TextStyle(
                                      fontFamily: OnboardingSpec.font,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: const Text(OnboardingSpec.skip),
                                ),
                              ),
                              SizedBox(
                                height: compact ? 330 : 410,
                                child: Center(
                                  child: AnimatedBuilder(
                                    animation: _float,
                                    child: Image.asset(
                                      OnboardingSpec.image,
                                      width: math.min(
                                        compact
                                            ? 292
                                            : OnboardingSpec.imageWidth,
                                        width - 40,
                                      ),
                                      fit: BoxFit.contain,
                                      excludeFromSemantics: true,
                                    ),
                                    builder: (context, child) {
                                      final progress = reducedMotion
                                          ? 0.0
                                          : (1 -
                                                    math.cos(
                                                      _float.value *
                                                          2 *
                                                          math.pi,
                                                    )) /
                                                2;
                                      return Transform.translate(
                                        offset: Offset(0, -14 * progress),
                                        child: Transform.rotate(
                                          angle:
                                              (-1 + 2.5 * progress) *
                                              math.pi /
                                              180,
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 12),
                                  Text(
                                    OnboardingSpec.title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: OnboardingSpec.font,
                                      fontSize: compact ? 31 : 35,
                                      height: 1.16,
                                      fontWeight: FontWeight.w700,
                                      color: OnboardingColors.navy,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    OnboardingSpec.subtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: OnboardingSpec.font,
                                      fontSize: 16,
                                      height: 1.58,
                                      color: OnboardingColors.gray,
                                    ),
                                  ),
                                  const SizedBox(height: 26),
                                  MouseRegion(
                                    onEnter: (_) =>
                                        setState(() => _hovered = true),
                                    onExit: (_) =>
                                        setState(() => _hovered = false),
                                    child: Listener(
                                      onPointerDown: (_) =>
                                          setState(() => _pressed = true),
                                      onPointerUp: (_) =>
                                          setState(() => _pressed = false),
                                      onPointerCancel: (_) =>
                                          setState(() => _pressed = false),
                                      child: AnimatedContainer(
                                        duration: reducedMotion
                                            ? Duration.zero
                                            : const Duration(milliseconds: 180),
                                        transformAlignment: Alignment.center,
                                        transform: Matrix4.identity()
                                          ..translateByDouble(
                                            0,
                                            _pressed
                                                ? 1
                                                : _hovered
                                                ? -2
                                                : 0,
                                            0,
                                            1,
                                          )
                                          ..scaleByDouble(
                                            _pressed ? .99 : 1,
                                            _pressed ? .99 : 1,
                                            1,
                                            1,
                                          ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              OnboardingColors.blue,
                                              OnboardingColors.deepBlue,
                                            ],
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x4D006BFF),
                                              offset: Offset(0, 18),
                                              blurRadius: 32,
                                            ),
                                          ],
                                        ),
                                        child: FilledButton(
                                          onPressed: _busy ? null : _start,
                                          style: FilledButton.styleFrom(
                                            minimumSize: const Size(
                                              OnboardingSpec.buttonWidth,
                                              OnboardingSpec.buttonHeight,
                                            ),
                                            backgroundColor: Colors.transparent,
                                            disabledBackgroundColor:
                                                Colors.transparent,
                                            foregroundColor: Colors.white,
                                            disabledForegroundColor:
                                                Colors.white,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            textStyle: const TextStyle(
                                              fontFamily: OnboardingSpec.font,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          child: Text(
                                            _busy
                                                ? '잠시만요'
                                                : OnboardingSpec.button,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
