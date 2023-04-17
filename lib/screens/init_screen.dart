import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  int _currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Willkommen ',
            style: TextStyle(
                fontWeight: FontWeight.w400, fontSize: 20, height: 2)),
        Container(
          // height 80% of screen
          height: MediaQuery.of(context).size.height * 0.80,

          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: 3,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            SvgPicture.asset(
                              'assets/Bull.svg',
                              semanticsLabel: 'My SVG Image',
                            ),
                            Text(
                                'Der "Passive Income Tracker" App ist eine großartige Möglichkeit für Menschen, ihr passives Einkommen zu verfolgen, zu visualisieren und Ziele zu setzen. ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    height: 1.7)),
                          ],
                        );
                      },
                      onPageChanged: (int index) {
                        setState(() {
                          _currentPageIndex = index;
                        });
                      },
                    ),
                    Positioned(
                      bottom: 10.0,
                      left: 0.0,
                      right: 0.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(3, (int index) {
                          return Container(
                            width: 10.0,
                            height: 10.0,
                            margin: EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPageIndex == index
                                  ? Colors.lightBlue
                                  : Colors.grey,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.90,
            child: ElevatedButton(
                onPressed: () {
                  // AuthService().anonLogin();
                },
                child: Text('Los gehts')),
          ),
        ),
      ],
    );
  }
}
