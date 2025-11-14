import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;

  final Widget body;
  final bool showBackButton;

  const AppScaffold({
    super.key,
    required this.title,

    required this.body,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 222, 234, 248),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 222, 234, 248),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: showBackButton,
        leading: showBackButton ? const BackButton(color: Colors.black) : null,

        title: Column(
          children: [
            // LOGO
            const SizedBox(height: 4),

            // TITLE
            Text(
              title,
              style: const TextStyle(
                color: Color.fromARGB(255, 3, 74, 133),
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 50),
          SafeArea(child: body),
        ],
      ),
    );
  }
}
