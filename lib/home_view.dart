import 'package:face_recog_app/handle_camera_access.dart';
import 'package:face_recog_app/register_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Face Recognition App"),
        backgroundColor: const Color.fromARGB(255, 223, 99, 245),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  bool granted = await handleCameraAccess("Face Registration");
                  if (granted) {
                    Get.to(() => const RegisterView());
                  }
                },
                child: Container(
                  height: MediaQuery.sizeOf(context).height * 0.18,
                  width: MediaQuery.sizeOf(context).width * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.camera,
                    size: MediaQuery.sizeOf(context).height * 0.18 / 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Register",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  handleCameraAccess("Face Verification");
                },
                child: Container(
                  height: MediaQuery.sizeOf(context).height * 0.18,
                  width: MediaQuery.sizeOf(context).width * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.face,
                    size: MediaQuery.sizeOf(context).height * 0.18 / 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Verify",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
