import 'package:flutter/material.dart';
import 'package:wanderbar/views/utils/AppColor.dart';

class SearchFilterModal extends StatelessWidget {
  final int activeOption;
  final Function(int) optionSelected;

  const SearchFilterModal({Key key, this.activeOption, this.optionSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        // Section 1 - Header
        Container(
          width: MediaQuery.of(context).size.width,
          height: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: AppColor.primaryExtraSoft,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sort by',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'inter'),
              ),
            ],
          ),
        ),
        // Sort By Option
        GestureDetector(
            onTap: (() => this.optionSelected(0)),
            child: Container(
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[300]))),
              child: ListTileTheme(
                selectedColor: AppColor.primary,
                textColor: Colors.grey,
                child: ListTile(
                  selected: this.activeOption == 0,
                  title: Text('Newest',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
              ),
            )),
        // Sort By Option
        GestureDetector(
            onTap: (() => this.optionSelected(1)),
            child: Container(
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[300]))),
              child: ListTileTheme(
                selectedColor: AppColor.primary,
                textColor: Colors.grey,
                child: ListTile(
                  selected: this.activeOption == 1,
                  title: Text('Oldest',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
              ),
            )),
      ],
    );
  }
}
