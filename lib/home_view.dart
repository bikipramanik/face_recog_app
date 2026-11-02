import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Face Recognition App"), backgroundColor: const Color.fromARGB(255, 223, 99, 245)),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Get.snackbar("Face Register", "Openning the camera for face registration");
                },
                child: Container(
                  height: MediaQuery.sizeOf(context).height * 0.18,
                  width: MediaQuery.sizeOf(context).width * 0.3,
                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                  child: Icon(Icons.camera, size: MediaQuery.sizeOf(context).height * 0.18 / 2),
                ),
              ),
              Text("Register", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25)),
            ],
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Get.snackbar("Face Verify", "Openning the camera for face verification");
                },
                child: Container(
                  height: MediaQuery.sizeOf(context).height * 0.18,
                  width: MediaQuery.sizeOf(context).width * 0.3,
                  decoration: BoxDecoration(color: Colors.lightBlueAccent, borderRadius: BorderRadius.circular(20)),
                  child: Icon(Icons.face, size: MediaQuery.sizeOf(context).height * 0.18 / 2),
                ),
              ),
              Text("Verify", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25)),
            ],
          ),
        ],
      ),
    );
  }
}
