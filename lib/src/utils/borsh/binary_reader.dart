

binaryReader(cursor, bytes) {
    var result = "";
    for (var i = 0; i < bytes; i++) {
        result += String.fromCharCode(cursor.readUInt8());
    }
    return result;
}
