// lib/widgets/signature_pad.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../theme/app_theme.dart';

class SignaturePadDialog extends StatefulWidget {
  final String? clientName;
  const SignaturePadDialog({super.key, this.clientName});

  static Future<Uint8List?> show(BuildContext context, {String? clientName}) =>
      showDialog<Uint8List>(
        context: context,
        barrierDismissible: false,
        builder: (_) => SignaturePadDialog(clientName: clientName),
      );

  @override
  State<SignaturePadDialog> createState() => _SignaturePadDialogState();
}

class _SignaturePadDialogState extends State<SignaturePadDialog> {
  final List<List<Offset?>> _strokes = [];
  List<Offset?> _current = [];
  final _repaintKey = GlobalKey();
  bool _hasSignature = false;
  bool _exporting = false;

  void _onPanStart(DragStartDetails d) {
    _current = [d.localPosition];
    setState(() {
      _strokes.add(_current);
      _hasSignature = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails d) =>
      setState(() => _current.add(d.localPosition));

  void _onPanEnd(DragEndDetails _) =>
      setState(() => _current.add(null)); // null = levantar caneta

  void _clear() => setState(() {
        _strokes.clear();
        _current = [];
        _hasSignature = false;
      });

  Future<void> _confirm() async {
    setState(() => _exporting = true);
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (!mounted) return;
      Navigator.of(context).pop(byteData?.buffer.asUint8List());
    } catch (_) {
      if (mounted) Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
            child: Row(children: [
              const Icon(Icons.draw_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Assinatura Digital',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    if (widget.clientName != null)
                      Text(widget.clientName!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(null),
              ),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Assine no espaço abaixo com o dedo ou caneta',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 12),

          // ── Canvas ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: RepaintBoundary(
                key: _repaintKey,
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(children: [
                      // Linha guia
                      Positioned(
                        bottom: 44,
                        left: 20,
                        right: 20,
                        child: Container(height: 1, color: Colors.grey.shade200),
                      ),
                      // Ícone de caneta (hint quando vazio)
                      if (!_hasSignature)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.draw_outlined,
                                  size: 40,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 6),
                              Text('Assine aqui',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade400)),
                            ],
                          ),
                        ),
                      // Traços da assinatura
                      CustomPaint(
                        painter: _SignaturePainter(_strokes),
                        size: Size.infinite,
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('Assinatura do Cliente',
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade400)),
              ),
              const Expanded(child: Divider()),
            ]),
          ),
          const SizedBox(height: 8),

          // ── Botões ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(children: [
              OutlinedButton.icon(
                onPressed: _exporting ? null : _clear,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Limpar'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      (_hasSignature && !_exporting) ? _confirm : null,
                  icon: _exporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Confirmar'),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset?>> strokes;
  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A2332)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      final path = Path();
      bool penDown = false;
      for (final point in stroke) {
        if (point == null) {
          penDown = false;
        } else if (!penDown) {
          path.moveTo(point.dx, point.dy);
          penDown = true;
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) => true;
}
