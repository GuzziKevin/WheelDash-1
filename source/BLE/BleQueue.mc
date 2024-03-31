using Toybox.System as Sys;
using Toybox.BluetoothLowEnergy as Ble;
using Toybox.WatchUi as Ui;

class BleQueue {
  var commDelay = 200;
  var delayTimer = null;
  var run_id = 0;
  enum {
    D_READ,
    D_WRITE,
    C_READ,
    C_WRITER,
    C_WRITENR,
    UPDATE,
  }

  var queue = [];
  var isRunning = false;
  var reqLiveData;
  var reqStats;
  var reqBatStats;
  var lastPacketType;
  var UUID;
  var reqStatsTiming = 0;
  var reqBatStatsTiming = 3;
  var batStatsCounter = 0;
  function initialize() { delayTimer = new Timer.Timer(); }

  function add(data, uuid) {
    try {
      if (data[0] != null || data[1] == UPDATE) {
        queue.add(data);
      }
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }

  function run() {
    try {
      if (queue.size() == 0) {
        if (eucData.wheelBrand == 4 || eucData.wheelBrand == 5) {
          if (eucData.wheelBrand == 4) {
            if (reqLiveData != null && UUID != null && reqStats != null) {
              reqStatsTiming = reqStatsTiming - 1;
              if (reqBatStats != null) {
                reqBatStatsTiming = reqBatStatsTiming - 1;
              }
              if (reqStatsTiming <= 0 && reqBatStatsTiming <= 0) {
                reqBatStatsTiming = 256;
              }
              if (reqStatsTiming < 0) {
                lastPacketType = "stats";
                add(reqStats, UUID);
                reqStatsTiming = 48;
              }
              if (reqBatStatsTiming < 0) {
                lastPacketType = "batStats";
                add(reqBatStats, UUID);
                reqBatStatsTiming = 256;
                batStatsCounter = batStatsCounter + 1;
              }
              if (queue.size() == 0) {
                lastPacketType = "live";
                add(reqLiveData, UUID);
              }
            }
            autoRestart();
          }
          if (eucData.wheelBrand == 5) {
            if (reqLiveData != null && UUID != null) {
              if (queue.size() == 0) {
                lastPacketType = "live";
                add(reqLiveData, UUID);
              }
            }
            autoRestart();
          }
        } else {
          isRunning = false;
          delayTimer.stop();
          return;
        }
      }

      isRunning = true;
      var char = queue[0][0];
      if (queue[0][1] == D_READ) {
        var cccd = char.getDescriptor(Ble.cccdUuid());
        cccd.requestRead();
      } else if (queue[0][1] == D_WRITE) {
        var cccd = char.getDescriptor(Ble.cccdUuid());
        cccd.requestWrite(queue[0][2]);
      } else if (queue[0][1] == C_READ) {
        char.requestRead();
      } else if (queue[0][1] == C_WRITER) {
        char.requestWrite(queue[0][2], {
          : writeType => Ble.WRITE_TYPE_WITH_RESPONSE,
        });
      } else if (queue[0][1] == C_WRITENR) {
        char.requestWrite(queue[0][2],
                          { : writeType => Ble.WRITE_TYPE_DEFAULT});
        run_id = run_id + 1;
      }

      if (queue.size() > 0) {
        queue = queue.slice(1, queue.size());
      }

    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }

  function autoRestart() { delayTimer.start(method( : run), commDelay, false); }

  function flush() {
    if (queue.size() != 0) {
      queue = [];
      delayTimer.stop();
    }
  }

  function delayedExec(delay) {}
}
