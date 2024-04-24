import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class SimpleTab extends StatefulWidget {
   SimpleTab({super.key,
     required this.tabTitles,
     required this.tabViews,
     this.tabBarScrollable,});
   List<String> tabTitles;
   List<Widget> tabViews;
   bool? tabBarScrollable;
  @override
  State<SimpleTab> createState() => _SimpleTabState();
}

class _SimpleTabState extends State<SimpleTab> with TickerProviderStateMixin{
  TabController? _tabController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.tabTitles.length, vsync: this);
    _tabController?.addListener(() {
      // if (_tabController?.index == _tabController?.animation?.value) {
      // 通过判断当前索引是否等同于动画的偏移量,否则点击的时候，会执行2次
      //logic.updateCategoryIndex(_tabController?.index ?? 0);
      currentIndex = _tabController?.index ?? 0;
      // }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: DefaultTabController(
        length: widget.tabTitles.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      labelPadding: const EdgeInsets.only(left: 16),
                      isScrollable: widget.tabBarScrollable??true,
                      labelColor: Color(0xffF0463C),
                      labelStyle:  const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      unselectedLabelColor: Color(0xff333333),
                      unselectedLabelStyle:  const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: _tabBuilder(context),
                      indicator:  UnderlineTabIndicator(),
                      controller: _tabController,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Color(0xffF0F2F5),
              height: 1.0,
            ),
           TabBarView(
                  controller: _tabController,
                  children: widget.tabViews.map((e) {
                    return e;
                  }).toList()
                //_subCategoryViewBuilder(),
              ).height(300).border(all: 0.5,color: Colors.green),

          ],
        ),
      ),
    );
  }
  List<Widget> _tabBuilder(BuildContext context) {
    if (widget.tabTitles.isNotEmpty) {
      return widget.tabTitles.map((info) {
        return SizedBox(
          height: 40,
          child: Center(
            child: Text(
              info,
              textAlign: TextAlign.center,
            ),
          ),
          //.decorated(border: Border.all(color:Colors.lightBlueAccent))
        );
      }).toList();
    }
    return [];
  }
}
