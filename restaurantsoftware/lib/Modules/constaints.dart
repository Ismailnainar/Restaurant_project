import 'package:flutter/material.dart';

bool isDarkTheme = true;
const textColor = Color(0xff585858);
const primary = Color(0xff89B5A2);
const primaryLight = Color(0xffCCECDF);
const primaryAncient = Color(0xff618777);
// const maincolor = Color.fromARGB(255, 12, 21, 38);
const maincolor = Color.fromRGBO(5, 5, 5, 1);

const subcolor = Colors.blue;
// main const subcolor = Color.fromARGB(255, 112, 99, 216);

const sidebarselect = Color.fromARGB(255, 145, 197, 246);
Color sidebartext = Colors.grey.shade300;
ThemeData currentTheme = isDarkTheme
    ? ThemeData.dark().copyWith(
        // Manually set dark theme colors if needed
        )
    : ThemeData.light().copyWith();

// breakpoint
const double screenSm = 576;
const double screenMd = 768;
const double screenLg = 992;
const double screenXl = 1200;
const double screenXxl = 1400;

// component
const double newsPageWidth = 400;
const double topBarHeight = 80;
const double sideBarDesktopWidth = 220;
const double sideBarMobileWidth = 70;
const double componentPadding = 24.0;
