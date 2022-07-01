// A screen that allows users to take a picture using a given camera.
import 'package:flutter/material.dart';
import 'package:wanderbar/views/utils/AppColor.dart';
import 'package:image_picker/image_picker.dart';

class TakePictureScreen extends StatefulWidget {
  final bool isMulti;
  const TakePictureScreen({
    Key key,
    this.isMulti = false,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  Color appBarColor = Colors.transparent;
  final imageQuality = 50;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Visibility(
          visible: isLoading,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: LinearProgressIndicator(
                color: AppColor.primaryExtraSofter,
                backgroundColor: AppColor.primaryExtraSoft,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            try {
              setState(() {
                this.isLoading = true;
              });
              // await _initializeControllerFuture;
              // // Attempt to take a picture and get the file `image`
              // // where it was saved.
              final image = await ImagePicker().pickImage(
                  source: ImageSource.camera, imageQuality: imageQuality);
              //final image = await _controller.takePicture();

              Navigator.pop(context, [image]);
            } catch (e) {
              print(e);
            }
          },
          child: Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]))),
            child: ListTileTheme(
              textColor: AppColor.primary,
              child: ListTile(
                leading: Icon(
                  Icons.camera,
                  color: AppColor.primary,
                ),
                title: Text('Camera',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            try {
              setState(() {
                this.isLoading = true;
              });
              // await _initializeControllerFuture;
              // Attempt to take a picture and get the file `image`
              // where it was saved.
              List<XFile> image = [];
              if (widget.isMulti) {
                image = await ImagePicker().pickMultiImage();
              } else {
                image = [
                  await ImagePicker().pickImage(source: ImageSource.gallery)
                ];
              }
              Navigator.pop(context, image);
            } catch (e) {
              print(e);
              print("error take a pic");
            }
          },
          child: Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]))),
            child: ListTileTheme(
              textColor: AppColor.primary,
              child: ListTile(
                leading: Icon(Icons.image, color: AppColor.primary),
                title: Text('Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class MediaBottomAddNavigationBar extends StatefulWidget {
  Function onItemTapped;
  MediaBottomAddNavigationBar({@required this.onItemTapped});

  @override
  _MediaBottomAddNavigationBarState createState() =>
      _MediaBottomAddNavigationBarState();
}

class _MediaBottomAddNavigationBarState
    extends State<MediaBottomAddNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 60, right: 60, bottom: 20),
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 70,
          child: BottomNavigationBar(
            currentIndex: 0,
            onTap: widget.onItemTapped,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 5,
            backgroundColor: AppColor.primaryExtraSoft,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.image, color: AppColor.primary, size: 15),
                  label: ''),
              BottomNavigationBarItem(
                  icon: Icon(Icons.radio_button_checked,
                      color: AppColor.primary, size: 25),
                  label: ''),
              BottomNavigationBarItem(
                  icon: Icon(Icons.map, color: AppColor.primary, size: 15),
                  label: '')
            ],
          ),
        ),
      ),
    );
  }
}
