import 'dart:io';

Future? exponentialBackoff(startWaitTime, retryNumber, waitBackoff, Function getResult) {
  var waitTime = startWaitTime;

  for (var i = 0; i < retryNumber; i++) {
    try {
      return getResult();
    } catch (e) {
      if (i == retryNumber - 1) {
        rethrow;
      } else {
        print("Retrying in $waitTime seconds");
        sleep(Duration(seconds: waitTime));
        waitTime = waitTime * waitBackoff;
      }
    }
  }
  return null;
}
