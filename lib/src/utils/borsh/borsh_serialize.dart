

import 'dart:typed_data';

abstract class BorshSerialize{
  serialize (writer, data); 
}

abstract class Uint8 extends BorshSerialize {} 
abstract class Uint16 extends BorshSerialize {}
abstract class Uint32 extends BorshSerialize {}
abstract class Uint64 extends BorshSerialize {}
abstract class Uint128 extends BorshSerialize {}
abstract class Int8 extends BorshSerialize {}
abstract class Int16 extends BorshSerialize {}
abstract class Int32 extends BorshSerialize {}
abstract class Int64 extends BorshSerialize {}
abstract class Int128 extends BorshSerialize {}


class FixedWidthInteger {
  serialize(writer) {
    var byteData = writer.buffer.asByteData();
    byteData.setFloat32(0, 3.04, Endian.little);
    return byteData;
  }
}

class Float32 extends BorshSerialize {
   @override
  serialize(writer, data) {
    if (writer == double.nan) {
      throw ArgumentError("For portability reasons we do not allow to serialize NaNs.");
    }
    writer.writeFloat32(data);
  }
}

class Float64 extends BorshSerialize {
   @override
  serialize(writer, data) {
    if (writer == double.nan) {
      throw ArgumentError("For portability reasons we do not allow to serialize NaNs.");
    }
    writer.writeFloat64(data);

  }
}

// class Bool extends BorshSerialize {
//    serialize(writer) {
//     let intRepresentation: UInt8 = self ? 1 : 0
//     try intRepresentation.serialize(writer)
//   }
// }

// class Optional extends BorshSerialize {
//   @override
//   serialize(writer) {
//     switch (writer) {
//       case :
//         writer.writeUInt8(1);
//         break;
//       default:
//         writer.writeUInt8(0);
//     }
    
//     }
  
// }

class String extends BorshSerialize {
   @override
  serialize(writer, data) {
    writer.writeFloat32(data);
    
  }
}

class Array extends BorshSerialize {
   @override
  serialize(writer, data) {
     data.forEach((element) {
    writer.writeFloat32(element);
     });
  }
}

// class Set extends BorshSerialize {
//    serialize(writer) {
//     try sorted().serialize(to: &writer)
//   }
// }

// class Dictionary extends BorshSerialize {
//    serialize(writer)  {
//     let sortedByKeys = sorted(by: {$0.key < $1.key})
//     try UInt32(sortedByKeys.count).serialize(to: &writer)
//     try sortedByKeys.forEach { key, value in
//       try key.serialize(to: &writer)
//       try value.serialize(to: &writer)
//     }
//   }
// }