import 'package:flutter/material.dart';
import 'package:moneyboys/app/route.dart';

class CustomScaffoldManager extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const CustomScaffoldManager({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 254, 254, 254),
        elevation: 0,
        centerTitle: true,
        leadingWidth: 120,
        leading: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.blueAccent,
                  size: 22,
                ),
                onPressed: () {
                  final commonState = context
                      .findAncestorStateOfType<RoutesState>();
                  if (commonState != null) {
                    commonState.setState(() {
                      if (commonState.previousSubPage != null) {
                        commonState.subPage = commonState.previousSubPage;
                        commonState.previousSubPage = null;
                      } else {
                        commonState.subPage = null;
                      }
                    });
                  }
                },
              ),
              const Text(
                'Quay lại',
                style: TextStyle(
                  color: Colors.blueAccent, // Xanh dương sáng
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.blueAccent, // Xanh dương sáng
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: actions,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade300),
        ),
      ),
      body: Stack(children: [child]),
    );
  }
}
