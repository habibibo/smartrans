import 'dart:convert';

String username = 'base64';
String password = 'email';

String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));

String apiKey =
    'key=AAAA6aaLav4:APA91bFvl-M6_aJ203ILj-nvJzvbP2w9w46aISycMVjnjEI1WYZrcXRJ-hLrj7C7HlL0pmYRShiPnuAZnHlkiMR7e2rOH0I1av9Nwk1g2BUv8O0HV4b4A4xrxN-sCF8ii4ifr5NZbFf-';
