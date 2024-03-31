using Toybox.BluetoothLowEnergy as Ble;
using Toybox.System as Sys;

class eucPM {
  var EUC_SERVICE;
  var EUC_CHAR;
  var EUC_CHAR2;
  var EUC_SERVICE_W;
  var EUC_CHAR_W;
  var OLD_KS_ADV_SERVICE;
 private
  var eucProfileDef;

  function init() {
    try {
      eucProfileDef = {
      :uuid => EUC_SERVICE,
      :characteristics => [
        {
          :uuid => EUC_CHAR,
          :descriptors => [Ble.cccdUuid()],
        },
      ],
    };
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }

  function initKS() {
    try {
      eucProfileDef = {
      :uuid => EUC_SERVICE,
      :characteristics => [
        {
          :uuid => EUC_CHAR, 
          :descriptors => [Ble.cccdUuid()],
        },
        {
          :uuid => EUC_CHAR2, 
          :descriptors => [Ble.cccdUuid()],
        },
      ],
    };
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }

  function initInmotionV2orVESC() {
    try {
      eucProfileDef = {
      :uuid => EUC_SERVICE,
      :characteristics => [
        {
          :uuid => EUC_CHAR_W, 
          :descriptors => [Ble.cccdUuid()],
        },
        {
          :uuid => EUC_CHAR, 
          :descriptors => [Ble.cccdUuid()],
        },
      ],
    };
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }

  function registerProfiles() {
    try {
      Ble.registerProfile(eucProfileDef);
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }

  function setGotwayOrVeteran() {
    try {
      EUC_SERVICE = Ble.longToUuid(0x0000ffe000001000l, 0x800000805f9b34fbl);
      EUC_CHAR = Ble.longToUuid(0x0000ffe100001000l, 0x800000805f9b34fbl);
      self.init();
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }

  function setKingsong() {
    try {
      EUC_SERVICE = Ble.longToUuid(0x0000ffe000001000l, 0x800000805f9b34fbl);
      EUC_CHAR = Ble.longToUuid(0x0000ffe100001000l, 0x800000805f9b34fbl);
      EUC_CHAR2 = Ble.longToUuid(0x0000ffe200001000l, 0x800000805f9b34fbl);
      self.initKS();
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }

  function setOldKingsong() {
    try {
      EUC_SERVICE = Ble.longToUuid(0x0000ffe000001000l, 0x800000805f9b34fbl);
      EUC_CHAR = Ble.longToUuid(0x0000ffe100001000l, 0x800000805f9b34fbl);
      OLD_KS_ADV_SERVICE =
          Ble.longToUuid(0x0000fff000001000l, 0x800000805f9b34fbl);
      self.init();
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }
  function setInmotionV2orVESC() {
    try {
      EUC_SERVICE = Ble.longToUuid(0x6e400001b5a3f393l, 0xe0a9e50e24dcca9el);
      EUC_CHAR = Ble.longToUuid(0x6e400003b5a3f393l, 0xe0a9e50e24dcca9el);
      EUC_CHAR_W = Ble.longToUuid(0x6e400002b5a3f393l, 0xe0a9e50e24dcca9el);

      self.initInmotionV2orVESC();
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }
  function setManager() {
    try {
      if (eucData.wheelBrand == 0 || eucData.wheelBrand == 1) {
        setGotwayOrVeteran();
      }
      if (eucData.wheelBrand == 2) {
        setKingsong();
      }
      if (eucData.wheelBrand == 3) {
        setOldKingsong();
      }
      if (eucData.wheelBrand == 4 || eucData.wheelBrand == 5) {
        setInmotionV2orVESC();
      } else {
      }

    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }
}