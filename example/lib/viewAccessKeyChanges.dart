import 'package:flutter/material.dart';

class ViewAccessKeyChanges extends StatelessWidget {
  final Map<String, dynamic> accessKeyListData;
  const ViewAccessKeyChanges(this.accessKeyListData, {Key? key}) : super(key: key);

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
              const Text('Block Hash: ', style: TextStyle(fontWeight: FontWeight.bold),),
              Container(
                height: 80,
                width: MediaQuery.of(context).size.width*0.6,
                child: Column(
                  children: [
                    Expanded(
                      child: Text(
                        accessKeyListData['block_hash'].toString(),
                        overflow: TextOverflow.visible,
                        ),
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
              const Text('Changes: ', style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(width: 30),
              Column(
                children: [
                  Text(
                    accessKeyListData['changes'].toString(),
                    overflow: TextOverflow.visible,
                    ),
                    
                 
                ],
              ),            ],
          ),
                 ],
      ),
    ) : Container();
  }
}
