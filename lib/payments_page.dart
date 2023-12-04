import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:debit_card_payments_form/UserManager.dart';
import 'package:debit_card_payments_form/enums.dart';

List subscriptionPriceIds = [
  "price_1N0i8YFgbU2VtDqvQcL5SW5P"
];

Map subscriptionPriceIdsTest = {
  "FR":["eur","€","price_1N0lRXFgbU2VtDqv31BA6LWX"],//EUROPE
  "SN":["xof","CFA","price_1NrFekFgbU2VtDqv9sW7eQmN"],//XOF
  "CD":["cdf","F","price_1NrFg1FgbU2VtDqvSBaC7PYq"],//CDF
};

Color smartSubscriptionColor = Color(0xffe1fff3);
Color smartSubscriptionUnderlineColor = Color(0xff38b6ff);
Color basicSubscriptionColor = Color(0xffefede4);


class PaymentsPage extends StatefulWidget {

  final String countryCode;
  final String currency;
  final String priceId;

  PaymentsPage(this.countryCode,this.currency,this.priceId);

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}


class _PaymentsPageState extends State<PaymentsPage> {

  UserManager _userManager = UserManager();
  Map<String, dynamic>? paymentIntentData;
  bool isDeletingSubscription = false;
  late TextEditingController userMailController = TextEditingController();
  String currentUserMail = "";
  String currentSubscription = "";
  String pseudo = "";
  String countryCode = "";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forfaits',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.yellow,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded ,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                child: Row(
                  children: [

                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          String currentSubscription = await _userManager.getValue("allUsers", "subscriptionId");
                          if(currentSubscription.isEmpty){
                            //AlertDialogManager.shortDialog(context, "Tu possèdes déjà ce forfait.");
                          }else{
                            selectBasicSubscription();
                          }
                        },
                        child: Container(
                          color: basicSubscriptionColor,//Color(0xff38b6ff),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  color: basicSubscriptionColor,//Color(0xff38b6ff),
                                  child: Image.asset((widget.countryCode == "TN") ? "images/currencies_subscriptions/free/eur_free.gif" : "images/currencies_subscriptions/free/${widget.currency}_free.gif"),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                  child: InkWell(
                                    onTap: (){
                                      //AlertDialogManager.displayMoreInformationBasicSubscription(context);
                                    },
                                    child: Container(
                                      height: MediaQuery.of(context).size.height / 40,
                                      padding: EdgeInsets.only(left: 8,right: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey,
                                                blurRadius: 4,
                                                offset: Offset(0,3)
                                            ),
                                          ]
                                      ),
                                      child: FittedBox(
                                        child: Text(
                                            "+ d'infos",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                              fontStyle: FontStyle.italic
                                            )
                                        ),
                                      ),
                                    ),
                                  )
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: smartSubscriptionColor,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height / 41,
                                color: smartSubscriptionUnderlineColor,
                              ),
                            ),
                            Container(
                              child: InkWell(
                                onTap: () async {
                                  selectSubscription(context,111600, smartSubscriptionUnderlineColor, "SMART"); //TODO: Use subscriptionPriceIds or subscriptionPriceIdsTest ==> production / test
                                },
                                child: Container(
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          color: smartSubscriptionColor,
                                          child: Image.asset((widget.countryCode == "TN") ? "images/currencies_subscriptions/paid/tnd_sub.gif" : "images/currencies_subscriptions/paid/${widget.currency}_sub.gif"),
                                        ),
                                      ),
                                      Align(
                                          alignment: Alignment.bottomCenter,
                                          child: InkWell(
                                            onTap: (){
                                              //AlertDialogManager.displayMoreInformationSmartSubscription(context);
                                            },
                                            child: Container(
                                              height: MediaQuery.of(context).size.height / 40,
                                              padding: EdgeInsets.only(left: 8,right: 8),
                                              decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius: BorderRadius.circular(5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.grey,
                                                        blurRadius: 4,
                                                        offset: Offset(0,3)
                                                    ),
                                                  ]
                                              ),
                                              child: FittedBox(
                                                child: Text(
                                                    "+ d'infos",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        decoration: TextDecoration.underline,
                                                        fontStyle: FontStyle.italic
                                                    )
                                                ),
                                              ),
                                            ),
                                          )
                                      )
                                    ],
                                  ),
                                ),

                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Container()
                    )
                  ],
                ),
              ),
            ),
          ],
        )

    );

  }

  /*Future<void> makePayment(
      {required String amount, required String currency, required int coins}) async {
    try {

      HttpsCallable stripePaymentIntentCallable = await FirebaseFunctions.instanceFor(app: FirebaseFunctions.instance.app, region: "europe-west1").httpsCallable('stripePaymentIntent');
      final resp = await stripePaymentIntentCallable.call(<String, dynamic>{
        "amount":calculateAmount(amount),
        "currency":currency,
        "userId":_userManager.userId
      });

      //debugPrint("DEBUG_LOG DATA:" + resp.data.toString());
      paymentIntentData = resp.data;

      //paymentIntentData =await createPaymentIntent(amount, currency);
      if (paymentIntentData != null) {

        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              //applePay: PaymentSheetApplePay(merchantCountryCode: 'FR'), //false, //TODO: Put TRUE + add/configure merchantIdentifier with Apple then put it in main file.
              //googlePay: PaymentSheetGooglePay(merchantCountryCode: 'FR'), //false,//TODO: Put TRUE when applePay config is OK
              //testEnv: false,//TRUE: only for tests
              //merchantCountryCode: 'FR',
              merchantDisplayName: 'Hamadoo',
              customerId: paymentIntentData!['customer'],
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
            ));
        displayPaymentSheet(coins);


      }else{
        debugPrint("DEBUG_LOG Le paiement ne peut se faire.");
      }
    } catch (e, s) {
      print('exception:$e$s');
    }
  }*/

  void selectBasicSubscription(){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: EdgeInsets.all(10),
            actionsPadding: EdgeInsets.only(bottom: 10.0,),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Text(
                    'Es-tu sûr(e) de vouloir changer de forfait ?',
                    style: GoogleFonts.inter(
                      color: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    primary: Colors.green,
                  ),
                ),
              ],
            ),
            content: Text(
              "En choissant ce forfait, tu perdras la totalité des avantages liés à ton forfait actuel: Forfait SMART.",
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatefulBuilder(
                      builder: (BuildContext context, StateSetter changeState) {
                        return ElevatedButton(
                            onPressed:() async {

                              changeState((){
                                isDeletingSubscription = true;
                              });

                              List listOfNeededParams = ["subscriptionId","subscriptionName","customerId"];
                              Map tmpValues = await _userManager.getMultipleValues("allUsers", listOfNeededParams);

                              String subscriptionId = tmpValues[listOfNeededParams[0]];
                              String subscriptionName = tmpValues[listOfNeededParams[1]];
                              String customerId = tmpValues[listOfNeededParams[2]];

                              HttpsCallable callable = await FirebaseFunctions.instanceFor(app: FirebaseFunctions.instance.app, region: "europe-west1").httpsCallable('deleteSubscription');
                              final resp = await callable.call(<String, dynamic> {
                                "subscriptionId":subscriptionId,
                                "subscriptionName":subscriptionName,
                                "userId":_userManager.userId,
                                "customerId":customerId
                              });

                              String finalStatus = resp.data["status"];
                              if ("success" == finalStatus){
                                Navigator.of(context)..pop()..pop();
                              }else{
                                Navigator.pop(context);
                                //AlertDialogManager.shortDialog(context, "Echec lors du changement.");
                              }

                              changeState((){
                                isDeletingSubscription = false;
                              });

                            },
                            child:
                            isDeletingSubscription ?
                            SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: const CircularProgressIndicator(
                                  backgroundColor: Colors.yellow,
                                )
                            )
                                :
                            Text(
                              "Oui",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                        );
                      }
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      child: Text("Non",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),)
                  ),
                ],
              ),
            ],
          );
        });
  }

  Future<void> makePaymentSubscription(
      {required String priceId, required String currency, required int coins, required String subscriptionName, required String email}) async {
    try {

      HttpsCallable stripeSubscriptionIntentCallable = await FirebaseFunctions.instanceFor(app: FirebaseFunctions.instance.app, region: "europe-west1").httpsCallable('stripeSubscriptionIntent');
      final resp = await stripeSubscriptionIntentCallable.call(<String, dynamic>{
        "priceId":priceId, //TODO:production:priceId // test:subscriptionPriceIdsTest["FR][2]
        "currency":currency, //TODO:production:currency // test:subscriptionPriceIdsTest["FR"][0]
        "userId":_userManager.userId,
        "email":email
      });

      //debugPrint("DEBUG_LOG DATA:" + resp.data.toString());
      paymentIntentData = resp.data;

      if (paymentIntentData != null) {

        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              merchantDisplayName: 'Oskour',
              customerId: paymentIntentData!['customer'],
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              billingDetails: BillingDetails(
                email: currentUserMail.isNotEmpty ? currentUserMail : userMailController.text.trim().toLowerCase()
              )
            ),
        );
        displayPaymentSheet(coins,subscriptionName,paymentIntentData!['subscriptionId']);


      }else{
        debugPrint("DEBUG_LOG Le paiement ne peut se faire.");
      }
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(int p_coins, String subscriptionName, String subscriptionId) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      /*The part below is triggered only if "Stripe.instance.presentPaymentSheet()" has succeedeed,
      that means the user has successfully paid ! */


      /*NotificationApi.createNormalNotificationBasicChannel(
        CommonFunctionsManager.createUniqueNotificationId(),
        "Confirmation d'achat #" + DateTime.now().millisecondsSinceEpoch.toString(),
        "1 x Forfait " + subscriptionName.toUpperCase(),
      );*/

      if(currentUserMail.isEmpty){
        await _userManager.updateMultipleValues(
            "allUsers",
            {
              'is_new_user': false,
              'customerEmail':userMailController.text.trim().toLowerCase()
            });
      }

      Navigator.pop(context);

    } on Exception catch (e) {
      if (e is StripeException) {
        print("Error from Stripe: ${e.error.localizedMessage}");
      } else {
        print("Unforeseen error: ${e}");
      }
    } catch (e) {
      print("exception:$e");
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        //'payment_method_types[]': 'card'
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer sk_test_51KoAXGFgbU2VtDqvIOheOcGJqsLG3iV2xaT6lZiK9XmzRrcnfLa0y6UaRDB1RqWmlduWEh8KEof6FNtVAgkTAesz002Xn9uMJe',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (double.parse(amount)) * 100;
    return a.toInt().toString();
  }

  Future<void> selectSubscription(BuildContext context, int coinsAmount, Color color, String subscriptionName) async {

    bool shouldPop = false;
    bool selectedOption = false;
    //String priceId = "";

    List listOfNeededParams = ["subscriptionId","customerEmail","pseudo","countryCode"];
    Map tmpValues = await _userManager.getMultipleValues("allUsers", listOfNeededParams);
    currentSubscription = tmpValues[listOfNeededParams[0]];
    currentUserMail = tmpValues[listOfNeededParams[1]];
    pseudo = tmpValues[listOfNeededParams[2]];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter changeState) {
                return WillPopScope(
                  onWillPop: () {
                    return Future.value(shouldPop);
                  },
                  child: AlertDialog(
                    titlePadding: EdgeInsets.all(10),
                    actionsPadding: EdgeInsets.only(bottom: 10.0,),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Récapitulatif d'achat",
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: (){
                            changeState(() {
                              shouldPop = true;
                            });
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close),
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            primary: color,
                          ),
                        ),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 80,
                              child: Text(
                                  "Forfait: "
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration:
                              BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 145,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: Colors.white),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        subscriptionName.toUpperCase(),
                                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 80,
                              child: Text(
                                  "Pack: "
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration:
                              BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 145,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: Colors.white),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "illimité"/*coinsAmount.toString()*/,
                                        style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (currentUserMail.isEmpty) SizedBox(height: 10),
                        if (currentUserMail.isEmpty)
                        Row(
                          children: [
                            Container(
                              width: 80,
                              child: Text(
                                  "Ton adresse mail: "
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration:
                              BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 145,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(3),
                                            color: Colors.white),
                                        child: TextField(
                                          controller: userMailController,
                                          decoration: InputDecoration(
                                            hintText: "john@gmail.com",
                                            hintMaxLines: 2,
                                            hintStyle: TextStyle(
                                                fontSize: 15,
                                                fontStyle: FontStyle.italic
                                            ),
                                            contentPadding: EdgeInsets.all(10),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                            onPressed:() async {
                              changeState((){
                                selectedOption = true;
                              });

                              if(currentUserMail.isNotEmpty){
                                if (currentSubscription.isEmpty){
                                  await makePaymentSubscription(priceId: widget.priceId, currency: widget.currency, coins: coinsAmount, subscriptionName: subscriptionName,email: currentUserMail);
                                  Navigator.pop(context);
                                }else{
                                  Navigator.pop(context);
                                  //AlertDialogManager.showSubscriptionAlert(context, "Tu possèdes déjà ce forfait");
                                }
                              }else{
                                if(userMailController.text.trim().isNotEmpty && userMailController.text.trim().contains("@")){
                                  if (currentSubscription.isEmpty){
                                    await makePaymentSubscription(priceId: widget.priceId, currency: widget.currency, coins: coinsAmount, subscriptionName: subscriptionName,email: userMailController.text.trim());
                                    Navigator.pop(context);
                                  }else{
                                    Navigator.pop(context);
                                    //AlertDialogManager.showSubscriptionAlert(context, "Tu possèdes déjà ce forfait");
                                  }
                                }else{
                                  changeState((){
                                    selectedOption = false;
                                  });
                                  //AlertDialogManager.shortDialog(context, "Il y'a une erreur avec ton adresse mail.");
                                }
                              }




                            },
                            style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                              primary: color,
                            ),
                            child:
                            selectedOption ?
                            SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: const CircularProgressIndicator(
                                  backgroundColor: Colors.yellow,
                                )
                            )
                                :
                            Text(
                              "Valider",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                        ),
                      ],
                    ),

                  ),
                );
              }
          );
        });
  }

}
