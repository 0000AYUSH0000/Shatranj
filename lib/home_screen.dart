import 'package:chess/game_board.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'SHATRANJ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            //add a lottie animation here
            SizedBox(
                height: 400,
                child: Lottie.network(
                    'https://lottie.host/674bf596-d61c-4d59-aa4b-4c5c8bfd134c/4Xri2D6jjn.json')),
            const SizedBox(
              height: 60,
            ),

            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.black),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameBoard()),
                );
              },
              child: const Text('Start Game',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),


          const SizedBox(height: 40),
            const Text('Created By Ayush Dixit',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
