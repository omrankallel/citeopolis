import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/assets.dart';
import '../../../../core/extensions/num.dart';

class AtomErrorConnexion extends StatelessWidget {
  const AtomErrorConnexion({this.onTap, super.key});

  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F8FD),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(Assets.assetsImageDisconnected),
                const Text(
                  'Connexion nécessaire !',
                  style: TextStyle(
                    color: Color(0xFF1D1B20),
                    fontFamily: 'Roboto',
                    fontSize: 28.0,
                    fontWeight: FontWeight.w400,
                    height: 36 / 28.0,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                20.ph,
                const Text(
                  'Il semble que l’application rencontre des difficultés à se connecter au serveur. Veuillez vérifier la connexion Internet de votre smartphone, s’il vous plaît.',
                  style: TextStyle(
                    color: Color(0xFF1D1B20),
                    fontFamily: 'Roboto',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    height: 24 / 16.0,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                20.ph,
                InkWell(
                  onTap: () {
                    if (onTap != null) {
                      onTap!.call();
                    }
                  },
                  child: Container(
                    width: 130,
                    height: 40,
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Color(0XFF214FAB),
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                        10.pw,
                        const Text(
                          'Actualiser',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            height: 20 / 14.0,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
