import 'package:flutter/material.dart';

class ViewAccessKey extends StatelessWidget {
  Map<String, dynamic> accessKeyData;
   ViewAccessKey(this.accessKeyData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return accessKeyData != null ? Container(
      height: MediaQuery.of(context).size.height*0.4,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Nounce: '),
              Text(accessKeyData['nonce'].toString()),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Permission: '),
              Text(accessKeyData['permission'].toString()),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Block Height: '),
              Text(accessKeyData['block_height'].toString()),
            ],
          ),
        ],
      ),
    ) : Container();
  }
}
