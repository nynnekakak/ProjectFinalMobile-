import 'package:flutter/material.dart';

class AIAssistantWidget extends StatefulWidget {
  final Future<String> Function() onGetAdvice;
  final String title;
  final IconData icon;

  const AIAssistantWidget({
    super.key,
    required this.onGetAdvice,
    this.title = 'Trợ lý AI',
    this.icon = Icons.psychology,
  });

  @override
  State<AIAssistantWidget> createState() => _AIAssistantWidgetState();
}

class _AIAssistantWidgetState extends State<AIAssistantWidget> {
  bool _isLoading = false;
  String? _advice;

  Future<void> _getAdvice() async {
    setState(() {
      _isLoading = true;
      _advice = null;
    });

    try {
      final result = await widget.onGetAdvice();
      if (mounted) {
        setState(() {
          _advice = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _advice = 'Có lỗi xảy ra: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _showAdviceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          if (_advice == null && !_isLoading) {
            // Tự động gọi khi mở dialog lần đầu
            Future.delayed(Duration.zero, () async {
              setDialogState(() => _isLoading = true);
              try {
                final result = await widget.onGetAdvice();
                setDialogState(() {
                  _advice = result;
                  _isLoading = false;
                });
              } catch (e) {
                setDialogState(() {
                  _advice = 'Có lỗi xảy ra: ${e.toString()}';
                  _isLoading = false;
                });
              }
            });
          }

          return AlertDialog(
            title: Row(
              children: [
                Icon(widget.icon, color: Colors.purple),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.title)),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: _isLoading
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Đang phân tích...'),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Text(
                        _advice ?? '',
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ),
            ),
            actions: [
              if (!_isLoading && _advice != null)
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      _advice = null;
                    });
                  },
                  child: const Text('Làm mới'),
                ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _advice = null;
                    _isLoading = false;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Đóng'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _showAdviceDialog,
      icon: Icon(widget.icon),
      label: const Text('Hỏi AI'),
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
    );
  }
}

// Widget đơn giản hơn - chỉ là button
class AIAssistantButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const AIAssistantButton({
    super.key,
    required this.onPressed,
    this.label = 'Hỏi AI',
    this.icon = Icons.psychology,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

// Dialog hiển thị lời khuyên AI
class AIAdviceDialog extends StatefulWidget {
  final Future<String> Function() onGetAdvice;
  final String title;
  final IconData icon;

  const AIAdviceDialog({
    super.key,
    required this.onGetAdvice,
    this.title = 'Trợ lý AI',
    this.icon = Icons.psychology,
  });

  @override
  State<AIAdviceDialog> createState() => _AIAdviceDialogState();
}

class _AIAdviceDialogState extends State<AIAdviceDialog> {
  bool _isLoading = true;
  String _advice = '';

  @override
  void initState() {
    super.initState();
    _loadAdvice();
  }

  Future<void> _loadAdvice() async {
    setState(() => _isLoading = true);
    try {
      final result = await widget.onGetAdvice();
      if (mounted) {
        setState(() {
          _advice = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _advice = 'Có lỗi xảy ra: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.icon, color: Colors.purple),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.title)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang phân tích...'),
                ],
              )
            : SingleChildScrollView(
                child: Text(
                  _advice,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
      ),
      actions: [
        if (!_isLoading)
          TextButton(onPressed: _loadAdvice, child: const Text('Làm mới')),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
