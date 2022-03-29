import 'package:flutter/material.dart';
import 'package:near_flutter/near_flutter.dart';

class MintNft extends StatefulWidget {
  const MintNft({Key? key}) : super(key: key);

  @override
  _MintNftState createState() => _MintNftState();
}

class _MintNftState extends State<MintNft> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: InkWell(
              onTap: () {
                RestApiProvider().mintNftApiProvider(
                    '1',
                    'https://bafkreigmdhxrb2qs6sufhea55jxgpljz2zxj42mo7kyny2el6iq5ll2bva.ipfs.nftstorage.link/',
                    'nearyonas.testnet',
                    '2Wjwq5xTaRii9mGaUZSZJcKBZhsa4HadLfUjuaZwnPtDgn57a46JT3JwSudxavAtSowqk41SWRsLa3g4LwJSUumL',
                    '');
              },
              child: Text('MintNft')),
        ),
      ),
    );
  }
}
