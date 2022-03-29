import '../src/providers/json_rpc.dart';
import '../src/signer.dart';
import 'near.dart';
import 'providers/json_rpc_provider.dart';
import 'utils/web.dart';

/// config Contains connection info details
/// @returns {Provider}
getProvider(config) {
  ConnectionInfo conn = ConnectionInfo.fromJson(config['args']);
  print(config['args']);
  switch (config['type']) {
    // case undefined:
    //     return config;
    case 'JsonRpcProvider':
      return JsonRpcProvider(conn);
    default:
      throw Error();
  }
}

/// config Contains connection info details
/// @returns {Signer}
Signer getSigner(config) {
  print('uuuuuu');
  print(config);

  // switch (config.signer) {
    // case undefined:
    //     return config;
    // case InMemorySigner:
      return InMemorySigner(config.keyStore);

    // default:
      // throw Error();
  // }
}

class Connection {
  String? networkId;
  // Provider provider;
  dynamic provider;

  Signer? signer;

  Connection(
    this.networkId,
    this.provider,
    this.signer,
  );

  Connection fromConfig(Connection config) {
    print(config.signer);
    var provider = getProvider(config.provider);
    var signer = getSigner(config.signer);
    return Connection(config.networkId, provider, signer);
  }
}
