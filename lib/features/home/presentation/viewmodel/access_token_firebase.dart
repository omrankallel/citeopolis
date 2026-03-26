import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

const List<String> scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

Future<void> sendFcmMessage() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.subscribeToTopic('allDevices');

  final String? deviceToken = await messaging.getToken();

  final client = await clientViaServiceAccount(
    ServiceAccountCredentials.fromJson(
        {
          'type': 'service_account',
          'project_id': 'fmc-exmaple',
          'private_key_id': '8dc16c12837e938d2ec60d202796759e121d5511',
          'private_key': '-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC5FDbs3rqeyn+A\ntsQEpZbGBS7DQMNIYyvzQ2/AQHH3MJRU5Zs9ay4ABO4gnJ6ooEUaMkeyb4ePnp6L\nXhwIxupvuCEpRDvdhrvofEUG3OXpMG2jls7s9QBOHoFkpY2r8cmvw+iFW/GWvXPl\nZpEWJlEMekyFxh/HS95YA44dnQGN7aPY8MhGk05/ZrkOCWQUuhIxI0dJmSxJHnzG\n8QeLEduNDB9Pu4UDHCdoY4PpD7oPUceOaFHbSQtLHFcRRXWSst+a2sZrm2rTsY3z\nJQiTEvCPXbpOYEsAL5IwaIUTOPtu6wRb93x9Fhkr0W9RYjdwfNDFQP6qWWuKm2zQ\noxIovc/PAgMBAAECggEAAWdO11MFFUkx2FcKe4KJ9yx441AtavIdljWvtkSG2LoM\nlew71iZm7ecbqzGk3mCAxacV9ht0arloOGRZUBO6GWjLD5YN4iswZ53xpBCuyart\nWe092nwtKWp/zrSWs3Qc9HFG5SQCXANJyraRaRqXSMHwrJ8JBKjlocM9I6paJaph\nY4KOyolzECcUbskB8DBSzyZMOqQPdpLhh58B6KyROBxt7+lHwO49SKT+9xW2TufQ\np085R95hlBhzzGfgFiorHba9FPQmC8LCg0qUp83OccTXlipK+s6Q0nLCK8Xi7j+h\nisnXNMXff1TAuFMAF0MOTr6FYhfCKuU0Se3hwqE4YQKBgQDblQhIV0ttEPBwoJWI\nn5nLELznUWLEZYpVHrAAwKJ4gxaWT3TBIOD1hoBi6X7dHF8mcbpqLpTBulQVxG41\nJZOJDcJMgY7otVSN4qw4VCpo6T3D0p7T3uxJLX0h21f2S9ovk0g+rg0N9aT3aDTk\nh5vc2W0+MYL4JwoB4dUWdpg3nwKBgQDXxkDwsNS00tTCDvbVLODsOhlubHlQYh0d\nnKUyOO8vLjJKf+gpP3dZmqkf7TBWtRLKxS1X6rBzjrS8etoWruwzEhBXC+0Wgufv\nCj4e20IHGFPNyZiy1Du//Xg0Ej9vLRQHj9PQzv6aTTlRwSTeXTat+Mrt/7ftIO4K\nBu0Mbio50QKBgCv6j2wdv8eaau3D2+8/OAhJ0+voiwWW6Lvfp5SfAGtupel5BINh\n2GyUgcZNydDzS8NhZ9q4dabPcOPjMceHPSNoFBBKqprFJqg8TA4EHXJhtLMxzgnV\nTjHh4HwVeGqmCo8YypFzPr4bAu1ie6WB25/CFHUuaXLWLtTtrEYRfq81AoGBAKua\nf2EssS3SEuT287WcSJF2r20TlfOo5BD92J+1ifvS2KpJSUEsuWWoy+KZR31d6sEa\nybIG8ygkEXdomPO7UBxZvGcOFBN4Lq78TWVK6RstbNDYCLoIcjCBjEyVSp/HkQtm\nhoWlafUbf3+WhRTXuznnCLT5T7SmIMoWsgXVw31RAoGAQ6+4ezmdds7cAc9TrloQ\nmhJACDKg4lHA6dNv+iKjSIbkElkuL5aHeZAsJZ6GPLJ1yevGkN+d5lBgiHcaRfD+\nF/1UmjwHUna68C7lCCi1Q3GSrHHsMUQXvHrnMleONHCdRH0dFWR+gc9fbMkLZ2lV\nqriGI93UtKpZtKyoIHfPxZc=\n-----END PRIVATE KEY-----\n',
          'client_email': 'firebase-adminsdk-ujepx@fmc-exmaple.iam.gserviceaccount.com',
          'client_id': '100451616228385412840',
          'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
          'token_uri': 'https://oauth2.googleapis.com/token',
          'auth_provider_x509_cert_url': 'https://www.googleapis.com/oauth2/v1/certs',
          'client_x509_cert_url': 'https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-ujepx%40fmc-exmaple.iam.gserviceaccount.com',
          'universe_domain': 'googleapis.com'
        }

    ),
    scopes,
  );

  final accessToken = client.credentials.accessToken;

  /*final message = {
    'notification': {
      'title': 'note-Title',
      'body': 'note-Body',
    },
  };*/
  debugPrint('*******$accessToken***');

  final message = {
    'message': {
      'token': deviceToken,
      'notification': {'title': 'Hello', 'body': 'Hello'},
    },
  };

  //const url = 'https://fcm.googleapis.com/fcm/send';
  const url = 'https://fcm.googleapis.com/v1/projects/fmc-exmaple/messages:send';
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer ${accessToken.data}',
      'Content-Type': 'application/json',
    },
    body: json.encode(message),
  );

  if (response.statusCode == 200) {
    debugPrint('Notification envoyée avec succès !${response.body}');
  } else {
    debugPrint("Erreur lors de l'envoi de la notification : ${response.body}");
  }

  client.close();
}

class AccessTokenFirebase {
  static String firebaseMessagingScope = 'https://www.googleapis.com/auth/firebase.messaging';

  Future<String> getAccessToken() async {
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(
        {
          'type': 'service_account',
          'project_id': 'fmc-exmaple',
          'private_key_id': '756a09f7147c1d9009f3a1e7262a2b8dd2fa7cec',
          'private_key':
              '-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCjjVmk3RqyHccH\nK2WFNBsro/TcakZRput29nJ7gPPaOQvGPgtOnRmRtHGEruhqEVOWPDxs2qp7aoen\nkqd2xyB1WREHw2L0RS5OeY5aEhN1iwY9k0SrGajTAmSTOsyAx+rmSoHG5m4Hc/ne\ngrlQX/H3ccZEEO7KONHpPuvpjIZj+djXMa4EV8CzWIFdTNZGaUUQ1voKCQ4tnLqU\nCT54QyhQVL3bHNt0E77lCGQe1EaHpK1BIfrCl4k5SrjWCisndLUGPtwwWIlClweY\nuZJ+Zs13DPwBmwIe/0d+XivUn8dWxRiq8TtzsWWOrgkI/26Xe67tjWMPD/MSgUVW\ny8XxW/LlAgMBAAECggEACSOUddyqtEzAgBikm9tJRbiWmGbHhqJXPSbGHLtxhN5p\nV3AZ8CWMVfgOsX1s5xkQQhBxckYMFDOOoHvBUqcLsTBN/hB6MVBDUecYyqorabGg\nIo/d3K9lSmMzbQcHrI40mfPhtBRQuNG6Iuehmh7pCwIRyYsRA35GJoHZq2DVlUpR\ndkgNxDJ2bJvj5jSwSwiY0EAF0yGp2OZaVphOMvrA8fDZMrvHatTOm1DopmRwRG7t\nxOjBl4CikvZVxLggFTHzzP4TtqNDAf48GqILCXrGb8SvU6u+ozEIV0FyZ9xuXYm3\n/l93mFHNxjRcGFSOXnm/QqYxmjS4uSBL+jwdXfTOIQKBgQDXB1MFuTfGaavnjD5h\nh6GocGjDxWkV915oAvgD5j6OljDQxqP1VQl4kvLBEIo1N07UemqQsW9chPAHyTeG\nPd2wY9pwqNYdiplDyA6stwpXQyLXp5wEZKDuz5mdynbSTUhIULLzaks/w4NPvGWn\nuhmihzlT5REj2L20w7Sne5HCBQKBgQDCtxrHVliiLDLdlVbd2yPT9LsIcKSVt2LE\neEOatJ/gr2Un3uKqyXo+k2kB7P2Y5hamT1bbcQuxxM5PmRKNPRnvHPT4aLNHyXNh\nSt6jnI6hcq/o6ylfhMki9SSAJ090F7OeHPZPXk/tt5V+yt5jCBZRgjTXKMLRZ0Jo\nLzZNKGvjYQKBgHtC95SQWCik6qYQ/rFpzoF/7o5K27J72uJE0Wdq1PFnpxQGynYY\nCRXVJtMFaDSZP9cNVYkcLXobuny8G9gYHry+gLmUDylgCfuQ8tiPFJ5xHcgBjK34\nAUjkOGr7ZKGpK4ZIvExM4lXq/Zr3pE5Bn/BLE9HDvc+OrzCv/x8C9ssBAoGAVm20\nQzr+iK2ZvmVlc4Cr/I8q3eoyBAqsmozPZUI7nR39hp8WebyIuHHyMFqjjlTDRPr+\nkNUy3at/8DD/3RV8B3kQ+5ptybWPs2XqQTFi1iL0Fi0b5jwok43Ar+nDCMLkhZBR\nfJVeYSQWBXvDDq4uSevDzKVZJF3zSg96yPDiQsECgYEAn7yhmUY+JMm9uQF7CE9w\n+KvPjRPJkzF11SqZC4+jmBLxIUaXhDY5oEtWo2OKLnZCVgZntf2eDAFtxSiG2U1p\nJPPd3JC2GZGIQa5iE6YdqRSGwCDbmr/RX7enTvfqnQrxwsGRgSoSx4Upsep6WdQa\n70vLmK7qmoC5YhVQqJvocmA=\n-----END PRIVATE KEY-----\n',
          'client_email': 'firebase-adminsdk-ujepx@fmc-exmaple.iam.gserviceaccount.com',
          'client_id': '100451616228385412840',
          'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
          'token_uri': 'https://oauth2.googleapis.com/token',
          'auth_provider_x509_cert_url': 'https://www.googleapis.com/oauth2/v1/certs',
          'client_x509_cert_url': 'https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-ujepx%40fmc-exmaple.iam.gserviceaccount.com',
          'universe_domain': 'googleapis.com',
        },
      ),
      [firebaseMessagingScope],
    );
    final accessToken = client.credentials.accessToken.data;
    return accessToken;
  }
}
