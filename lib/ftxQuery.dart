import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ftxQueryClasses.dart';

const String apiEndpointFutures = "https://ftx.com/api/expired_futures";
const String corsEndpoint = "https://lendfinex-cors.herokuapp.com/";

const String allowedOrigin ="https://wally869.github.io/FTX_MoveDisplay/#/";

//
//
/*     GETTING EXPIRED FUTURES         */
//
//
//

Future<ExpiredFutures> fetchExpiredContractsData() async {
  Map<String, String> headersRequest = new Map<String, String>();
  headersRequest["Access-Control-Allow-Origin"] = allowedOrigin;
  var response = await http.get(corsEndpoint + apiEndpointFutures,
      headers: headersRequest);

  if (response.statusCode == 200) {
    return ExpiredFutures.fromJson(json.decode(response.body));
  } else {
    throw Exception("Failed to fetch Expired Contracts Data. Status Code: " +
        response.statusCode.toString());
  }
}

List<String> weekDays = new List<String>.from({
  "",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
}); // padding to start at 1

List<String> months = new List<String>.from({
  "", // padding to start at 1
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
});

class PrunedDataContract {
  num expiryPrice;
  num underlyingPrice;
  String contractDay;
  String contractMonth;

  PrunedDataContract(Result apiRawData) {
    this.expiryPrice = apiRawData.mark;
    this.underlyingPrice = apiRawData.index;

    //print(apiRawData.expiry);
    var dateContract = DateTime.parse(apiRawData.expiry);
    this.contractDay = weekDays[dateContract.weekday];
    this.contractMonth = months[dateContract.month];
  }
}

List<PrunedDataContract> convertExpiredToPruned(
    ExpiredFutures expiredFuturesData) {
  List<PrunedDataContract> prunedDatas = new List<PrunedDataContract>();
  for (int i = 0; i < expiredFuturesData.result.length; i++) {
    if (expiredFuturesData.result[i].type == "move" &&
        expiredFuturesData.result[i].group == "daily") {
      prunedDatas.add(new PrunedDataContract(expiredFuturesData.result[i]));
    }
  }

  return prunedDatas;
}

//
//
//
/*        GETTING CURRENT PRICES        */
//
//
//

String apiFuturesEndpoint = "https://ftx.com/api/futures/BTC-MOVE-";

Future<MoveResult> fetchMoveData() async {
  var today = new DateTime.now();
  String contractDate = today.month.toString().padLeft(2, "0") +
      today.day.toString().padLeft(2, "0");

  Map<String, String> headersRequest = new Map<String, String>();
  headersRequest["Access-Control-Allow-Origin"] = allowedOrigin;

  var response = await http.get(
      corsEndpoint + apiFuturesEndpoint + contractDate,
      headers: headersRequest);

  //var response = await http.get(apiEndpoint);
  if (response.statusCode == 200) {
    return MoveResponseAPI.fromJson(json.decode(response.body)).result;
  } else {
    throw Exception("Failed to fetch Current Move Data. Status Code: " +
        response.statusCode.toString());
  }
}

main() {
  fetchMoveData().then((value) => print(value.name));
}
