import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wanderbar/views/utils/AppColor.dart';

enum WeatherInput { online, manual }

class WeatherControl extends StatefulWidget {
  const WeatherControl({Key key}) : super(key: key);

  @override
  State<WeatherControl> createState() => _WeatherControlState();
}

class _WeatherControlState extends State<WeatherControl> {
  WeatherInput _selectedSegment = WeatherInput.online;

  @override
  Widget build(BuildContext context) {
    return ListView(
        shrinkWrap: true,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        physics: BouncingScrollPhysics(),
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.3,
              margin: EdgeInsets.symmetric(vertical: 4),
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 72, right: 72, top: 8),
              child: CupertinoSlidingSegmentedControl(
                backgroundColor: CupertinoColors.systemGrey2,
                thumbColor: AppColor.whiteSoft,
                // This represents the currently selected segmented control.
                groupValue: _selectedSegment,
                // Callback that sets the selected segmented control.
                onValueChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSegment = value;
                    });
                  }
                },
                children: const <WeatherInput, Widget>{
                  WeatherInput.online: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'online',
                      style: TextStyle(color: CupertinoColors.white),
                    ),
                  ),
                  WeatherInput.manual: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'manual',
                      style: TextStyle(color: CupertinoColors.white),
                    ),
                  )
                },
              )),
          Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  WeatherTile(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 15),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.add_circle_rounded),
                        ),
                      ),
                    ],
                  )
                ],
              ))
        ]);
  }
}

class WeatherTile extends StatelessWidget {
  final bool manualInput;

  const WeatherTile({Key key, this.manualInput = false}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        margin: EdgeInsets.symmetric(vertical: 20),
        child: Material(
            clipBehavior: Clip.antiAlias,
            color: AppColor.whiteSoft,
            elevation: 0,
            borderRadius: BorderRadius.circular(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 22),
                  width: 75,
                  height: 75,
                  child: SvgPicture.asset("assets/icons/007-torch.svg"),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.transparent,

                    // image: DecorationImage(
                    //     image: AssetImage(widget.data.photo), fit: BoxFit.cover),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    getLogWeather(TextEditingController()),
                    Container(
                      margin: EdgeInsets.all(12),
                      child: Text(
                        "12 C",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontFamily: 'inter'),
                      ),
                    ),
                  ],
                )
              ],
            )));
  }

  Widget getLogWeather(TextEditingController controller) {
    return Container(
        width: 200,
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Focus(
          onFocusChange: ((value) {
            try {} catch (e) {
              print(e);
            }
          }),
          child: TextField(
              textAlign: TextAlign.start,
              controller: controller,
              autocorrect: true,
              style: TextStyle(
                  color: AppColor.primary.withAlpha(200),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'inter'),
              cursorColor: Colors.black,
              obscureText: false,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Weather description",
                hintStyle: TextStyle(
                    color: AppColor.primary.withAlpha(200),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'inter'),
                border: InputBorder.none,
              )),
        ));
  }
}
