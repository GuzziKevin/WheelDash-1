class VESCDecoder {
  function decodeint16(byte1, byte2) { return (byte1 << 8) | byte2; }

  function decodeint32(byte1, byte2, byte3, byte4) {
    return (byte1 << 24) | (byte2 << 16) | (byte3 << 8) | byte4;
  }

  var packetID = 0x2f;
  var packetEnd = 0x03;
  var frame = [0]b;
  var status = "unknown";
  var startDistance = null;

  function frameBuilder(bleDelegate, value) {
    try {
      if (value[0] == packetID) {
        status = "append";
        frame = value;
      } else {
        if (status.equals("append")) {
          frame.addAll(value);
        }
      }

      if (value[value.size() - 1] == 0x03) {
        status = "complete";
        var transmittedFrame = frame;
        System.println(transmittedFrame);
        if (transmittedFrame.size() >= 66) {  
          frameBuffer(bleDelegate, transmittedFrame);
        }
        frame = [0]b;
        status = "unknown";
      }
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }

  function frameBuffer(bleDelegate, transmittedFrame) {
    try {
      var size = transmittedFrame.size();

      eucData.temperature =
          transmittedFrame.decodeNumber(Lang.NUMBER_FORMAT_SINT16, {
            : offset => 1, : endianness => Lang.ENDIAN_BIG,
          }) /
          10.0;

      eucData.current =
          transmittedFrame.decodeNumber(Lang.NUMBER_FORMAT_SINT32, {
            : offset => 9, : endianness => Lang.ENDIAN_BIG,
          }) /
          100.0;

      eucData.hPWM = transmittedFrame
                         .decodeNumber(Lang.NUMBER_FORMAT_SINT16, {
                           : offset => 13, : endianness => Lang.ENDIAN_BIG,
                         })
                         .abs() /
                     10.0;

      eucData.speed = transmittedFrame
                          .decodeNumber(Lang.NUMBER_FORMAT_SINT32, {
                            : offset => 19, : endianness => Lang.ENDIAN_BIG,
                          })
                          .abs() /
                      1000.0;

      eucData.voltage =
          transmittedFrame.decodeNumber(Lang.NUMBER_FORMAT_SINT16, {
            : offset => 23, : endianness => Lang.ENDIAN_BIG,
          }) /
          10.0;

      eucData.battery =
          transmittedFrame.decodeNumber(Lang.NUMBER_FORMAT_SINT16, {
            : offset => 25, : endianness => Lang.ENDIAN_BIG,
          }) /
          10.0;

      eucData.totalDistance =
          transmittedFrame.decodeNumber(Lang.NUMBER_FORMAT_UINT32, {
            : offset => 62, : endianness => Lang.ENDIAN_BIG,
          }) /
          1000.0;  
      if (startDistance == null) {
        startDistance = eucData.totalDistance;
      }
      eucData.tripDistance = eucData.totalDistance - startDistance;
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }
}
