import 'package:flutter/material.dart';

class ViewAccessKeyList extends StatelessWidget {
  final Map<String, dynamic> accessKeyListData;
  const ViewAccessKeyList(this.accessKeyListData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return accessKeyListData != null ? Container(
      height: MediaQuery.of(context).size.height*0.6,
      width: MediaQuery.of(context).size.width*0.9,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Public Key: ', style: TextStyle(fontWeight: FontWeight.bold),),
              Container(
                height: 80,
                width: MediaQuery.of(context).size.width*0.7,
                child: Column(
                  children: [
                    Expanded(
                      child: Text(
                        accessKeyListData['keys'][0]['public_key'].toString(),
                        overflow: TextOverflow.visible,
                        ),
                    ),
                        SizedBox(height: 10),
                    Text(
                      accessKeyListData['keys'][1]['public_key'].toString(),
                      overflow: TextOverflow.visible,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Nounce: ', style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(width: 30),
              Column(
                children: [
                  Text(
                    accessKeyListData['keys'][0]['access_key']['nonce'].toString(),
                    overflow: TextOverflow.visible,
                    ),
                      SizedBox(height: 10),
                  Text(
                    accessKeyListData['keys'][1]['access_key']['nonce'].toString(),
                    overflow: TextOverflow.visible,
                    ),
                ],
              ),            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Permission: ', style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(width: 30),
              Column(
                children: [
                  Text(
                    accessKeyListData['keys'][0]['access_key']['permission'].toString(),
                    overflow: TextOverflow.visible,
                    ),
                      SizedBox(height: 10),
                  Text(
                    accessKeyListData['keys'][1]['access_key']['permission'].toString(),
                    overflow: TextOverflow.visible,
                    ),
                ],
              ),             ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Block Height: ', style: TextStyle(fontWeight: FontWeight.bold),),
              Text(accessKeyListData['block_height'].toString()),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Block Hash: ', style: TextStyle(fontWeight: FontWeight.bold),),
              Expanded(child: Text(accessKeyListData['block_hash'].toString())),
            ],
          ),
        ],
      ),
    ) : Container();
  }
}
