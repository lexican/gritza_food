import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gritzafood/screens/location/location.dart';
import 'package:gritzafood/screens/welcome/widget/walk_through.dart';
import 'package:gritzafood/utils/utils.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final PageController _pageController = PageController();
  int currentIndexPage;
  int pageLength;

  void setIndex(value) {
    setState(() => currentIndexPage = value);
  }

  void next() {
    _pageController.nextPage(
        duration: const Duration(seconds: 3),
        curve: Curves.fastLinearToSlowEaseIn);
  }

  @override
  void initState() {
    currentIndexPage = 0;
    pageLength = 3;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utils.backgroundColor,
      body: Container(
        color: Utils.backgroundColor,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            SvgPicture.asset(
              "assets/svg/logo.svg",
              height: 120,
              width: 120,
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: SizedBox(
                height: 250,
                child: PageView(
                  controller: _pageController,
                  children: [
                    Walkthrough(
                      textContent: "Choose Preferred restaurant close to you.",
                      title: "Choose Restaurant",
                      url: "assets/images/choose_restaurant.png",
                      index: currentIndexPage,
                      pageLength: pageLength,
                      next: next,
                    ),
                    Walkthrough(
                      textContent:
                          "You can easily select from our wide range of mothwathering dishes",
                      title: "Choose Your Food",
                      url: "assets/images/meal.png",
                      index: currentIndexPage,
                      pageLength: pageLength,
                      next: next,
                    ),
                    Walkthrough(
                      textContent:
                          "Place your order and get it delivered to you at your own preferred time.",
                      title: "Schedule Delivery",
                      url: "assets/images/delivery.png",
                      index: currentIndexPage,
                      pageLength: pageLength,
                      next: next,
                    ),
                  ],
                  onPageChanged: (value) {
                    setIndex(value);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: DotsIndicator(
                dotsCount: 3,
                position: currentIndexPage,
                decorator: DotsDecorator(
                  size: const Size.square(9.0),
                  activeSize: const Size(33.0, 9.0),
                  activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  color: Colors.grey, // Inactive color
                  activeColor: Utils.primaryColor,
                ),
              ),
            ),
            currentIndexPage < pageLength - 1
                ? Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20.0),
                    color: Utils.primaryColor,
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      onPressed: () {
                        next();
                      },
                      child: const Text(
                        "Next",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ))
                : Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20.0),
                    color: Utils.primaryColor,
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Location(
                                      nextRoute: "Home",
                                    )));
                      },
                      child: const Text(
                        "Get Started",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
