import 'package:flutter/material.dart';

class AnimationService {
  // Karesansui-inspired flow animations
  static const Duration _flowDuration = Duration(milliseconds: 800);
  static const Duration _quickFlowDuration = Duration(milliseconds: 400);
  static const Duration _slowFlowDuration = Duration(milliseconds: 1200);

  // Smooth curves inspired by flowing water in rock gardens
  static const Curve _flowCurve = Curves.easeInOutCubic;
  static const Curve _rippleCurve = Curves.easeOutQuart;
  static const Curve _gentleCurve = Curves.easeInOutSine;

  // Fade in with gentle flow
  static Animation<double> createFadeInFlow(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: _gentleCurve,
    ));
  }

  // Slide in with flowing motion
  static Animation<Offset> createSlideInFlow(AnimationController controller, {
    Offset begin = const Offset(0, 0.3),
    Offset end = Offset.zero,
  }) {
    return Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: _flowCurve,
    ));
  }

  // Scale with gentle ripple effect
  static Animation<double> createScaleFlow(AnimationController controller, {
    double begin = 0.8,
    double end = 1.0,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: _rippleCurve,
    ));
  }

  // Rotation with flowing motion
  static Animation<double> createRotationFlow(AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: _gentleCurve,
    ));
  }

  // Ripple effect for cards
  static Animation<double> createRippleFlow(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: _rippleCurve,
    ));
  }

  // Gentle bounce for interactive elements
  static Animation<double> createBounceFlow(AnimationController controller) {
    return Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    ));
  }

  // Flow durations
  static Duration get flowDuration => _flowDuration;
  static Duration get quickFlowDuration => _quickFlowDuration;
  static Duration get slowFlowDuration => _slowFlowDuration;
}
