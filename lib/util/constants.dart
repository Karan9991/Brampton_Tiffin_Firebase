import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';


bool isRtl = false;

//Paypal Settings
const String paypalClientId =
    'ATKxCBB49G3rPw4DG_0vDmygbZeFKubzub7jGWpeUW5jzfElK9qOzqJOfrBTYvS7RuIhoPdWHB4DIdLJ';
const String paypalClientSecret =
    'EIDqVfraXlxDBMnswmhqP2qYv6rr_KPDgK269T-q1K9tB455OpPL_fc65irFiPBpiVXcoOQwpKqU3PAu';
const bool sandbox = true;
const String currency = 'USD';

//Onesignal Settings
const String oneSignalAppId = '5991efe6-21f5-4900-b8ba-2cf0e25f10e3';

const int bestSellingProduct = 29;
const int flashSale = 30;
const int newArrive = 31;
const String currencySign = '\$';
const String shippingCountry = 'India';



MaterialColor primarySwatch = MaterialColor(
  0xFF4C53A5,
  <int, Color>{
    50: Color(0xFFE8EAF6),
    100: Color(0xFFC5CAE9),
    200: Color(0xFF9FA8DA),
    300: Color(0xFF7986CB),
    400: Color(0xFF5C6BC0),
    500: Color(0xFF3F51B5),
    600: Color(0xFF394AAE),
    700: Color(0xFF3140A5),
    800: Color(0xFF29379D),
    900: Color(0xFF1B278D),
  },
);


MaterialColor lightGren = MaterialColor(0xff01dc9d, {
  50: Color(0xffe5f8f2),
  100: Color(0xffbfece2),
  200: Color(0xff99e0d1),
  300: Color(0xff72d4c0),
  400: Color(0xff51cbb3),
  500: Color(0xff01dc9d),
  600: Color(0xff26b78c),
  700: Color(0xff1a9176),
  800: Color(0xff126d5e),
  900: Color(0xff0a4a46),
});


const primaryColor = Color(0xFF4C53A5);
const secondaryColor1 = Color(0xFFE2396C);
const secondaryColor2 = Color(0xFFFBFBFB);
const secondaryColor3 = Color(0xFFE5E5E5);
const titleColors = Color(0xFF1A1A1A);
const textColors = Color(0xFF828282);
const ratingColor = Color(0xFFFFB03A);

const categoryColor1 = Color(0xFFFCF3D7);
const categoryColor2 = Color(0xFFDCF7E3);
// List<Wishlist> wishList = [];
int? wishListItems;
// Future<void> addToWishList(Wishlist wishLists) async {
//   wishList.add(wishLists);
//   String encodedData = Wishlist.encode(wishList);
//   final prefs = await SharedPreferences.getInstance();
//   prefs.setString('wishListProducts', encodedData);
//   //final getData = prefs.getString('wishListProducts');
//   //final decodedData = Wishlist.decode(getData!);
// }

final TextStyle kTextStyle = GoogleFonts.dmSans(
  textStyle: const TextStyle(
    color: textColors,
    fontSize: 16,
  ),
);

class MyGoogleText extends StatelessWidget {
  const MyGoogleText(
      {Key? key,
      required this.text,
      required this.fontSize,
      required this.fontColor,
      required this.fontWeight})
      : super(key: key);
  final String text;
  final double fontSize;
  final Color fontColor;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: fontColor,
        ),
      ),
      maxLines: 1,
    );
  }
}

class MyGoogleTextWhitAli extends StatelessWidget {
  const MyGoogleTextWhitAli({
    Key? key,
    required this.text,
    required this.fontSize,
    required this.fontColor,
    required this.fontWeight,
    required this.textAlign,
  }) : super(key: key);
  final String text;
  final double fontSize;
  final Color fontColor;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.dmSans(
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: fontColor,
        ),
      ),
    );
  }
}

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: const BorderSide(color: secondaryColor1),
  );
}

final otpInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);
