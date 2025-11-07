import 'package:flutter/material.dart';
import 'package:moneyboys/Modules/Setting/View/AccountManager.dart';
import 'package:moneyboys/app/route.dart';

class SimpleHeaderLayout extends StatelessWidget {
  final Widget child;

  const SimpleHeaderLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Stack(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "Mở rộng",
                    style: TextStyle(
                      color: Colors.blueAccent, // Xanh dương sáng
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    final commonState = context
                        .findAncestorStateOfType<RoutesState>();
                    commonState?.setState(() {
                      commonState.subPage = const AccountManager();
                    });
                  },
                  child: Row(
                    children: [
                      const Text(
                        'Hỗ trợ',
                        style: TextStyle(
                          color: Colors.blueAccent, // Xanh dương sáng
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blueAccent, // Xanh dương sáng
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 0.7,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Expanded(child: child),
      ],
    );
  }
}
