import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
using Toybox.Timer;
using Toybox.StringUtil;
class GarminEUCApp extends Application.AppBase {
 private
  var view;
 private
  var delegate;
  var timeOut = 10000;
  var activityRecordingDelay = 3000;
  var usePS;
  // private var updateDelay = 100;
 private
  var alarmsTimer;

 private
  var activityRecordingRequired = true;
 private
  var activityRecordView;

  function initialize() {
    try {
      eucData.limitedMemory = System.getSystemStats().totalMemory < 128000;
      AppBase.initialize();
      usePS = AppStorage.getSetting("useProfileSelector");
      alarmsTimer = new Timer.Timer();
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }

  function onStart(state as Dictionary?) as Void {
    try {
      setGlobalSettings();
      rideStatsInit();
      alarmsTimer.start(method( : onUpdateTimer), eucData.updateDelay, true);
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }

  function onStop(state as Dictionary?) as Void {
    try {
      if (eucData.activityAutorecording == true) {
        if (delegate != null && activityRecordView != null) {
          if (activityRecordView.isSessionRecording()) {
            activityRecordView.stopRecording();
          }
        }
      }
      if (eucData.activityAutosave == true && delegate != null) {
        activityRecordView = delegate.getActivityView();
        if (activityRecordView.isSessionRecording()) {
          activityRecordView.stopRecording();
        }
      }
      delegate.unpair();
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }

  function getInitialView() as Array<Views or InputDelegates> ? {
    try {
      view = profileSelector.createPSMenu();
      delegate = profileSelector.createPSDelegate();
      if (!usePS) {
        var profile = AppStorage.getSetting("defaultProfile");
        delegate.setSettings(profile);
        view = delegate.getView();
        delegate = delegate.getDelegate();
      }

      return [ view, delegate ] as Array < Views or InputDelegates > ;
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }

  function onUpdateTimer() {
    try {
      if (eucData.wheelName == null && delegate != null && usePS) {
        timeOut = timeOut - eucData.updateDelay;
        if (timeOut <= 0) {
          var profile = AppStorage.getSetting("defaultProfile");
          delegate.setSettings(profile);
        }
      }

      if (eucData.paired == true && eucData.wheelName != null) {
        if (eucData.activityAutorecording == true) {
          if (delegate != null && activityRecordView == null) {
            activityRecordView = delegate.getActivityView();
          }
          if (activityRecordView != null &&
              !activityRecordView.isSessionRecording() &&
              activityRecordingRequired == true) {
            activityRecordView.enableGPS();
            activityRecordingDelay =
                activityRecordingDelay - eucData.updateDelay;
            activityRecordView.initialize();
            if (activityRecordingDelay <= 0) {
              activityRecordView.startRecording();
              activityRecordingRequired = false;
            }
          }
        }
        eucData.correctedSpeed = eucData.getCorrectedSpeed();
        eucData.PWM = eucData.getPWM();
        EUCAlarms.speedAlarmCheck();
        if (delegate.getMenu2Delegate().requestSubLabelsUpdate == true) {
          delegate.getMenu2Delegate().updateSublabels();
        }
        var statsIndex = 0;
        if (rideStats.showAverageMovingSpeedStatistic) {
          rideStats.avgSpeed();
          rideStats.statsArray[statsIndex] =
              "Avg Spd: " +
              valueRound(eucData.avgMovingSpeed, "%.1f").toString();
          statsIndex++;
        }
        if (rideStats.showTopSpeedStatistic) {
          rideStats.topSpeed();
          rideStats.statsArray[statsIndex] =
              "Top Spd: " + valueRound(eucData.topSpeed, "%.1f").toString();
          statsIndex++;
        }
        if (rideStats.showWatchBatteryConsumptionStatistic) {
          rideStats.watchBatteryUsage();
          rideStats.statsArray[statsIndex] =
              "Wtch btry/h: " +
              valueRound(eucData.watchBatteryUsage, "%.1f").toString();
          statsIndex++;
        }
        if (rideStats.showTotalDistance) {
          rideStats.statsArray[statsIndex] =
              "Tot dist: " +
              valueRound(eucData.totalDistance, "%.1f").toString();
          statsIndex++;
        }
        if (rideStats.showTripDistance) {
          rideStats.statsArray[statsIndex] =
              "Trip dist: " +
              valueRound(eucData.tripDistance, "%.1f").toString();
          statsIndex++;
        }
        if (rideStats.showVoltage) {
          rideStats.statsArray[statsIndex] =
              "voltage: " + valueRound(eucData.getVoltage(), "%.2f").toString();
          statsIndex++;
        }
        if (rideStats.showWatchBatteryStatistic) {
          rideStats.statsArray[statsIndex] =
              "Wtch btry: " +
              valueRound(System.getSystemStats().battery, "%.1f").toString() +
              " %";
          statsIndex++;
        }
        if (rideStats.showProfileName) {
          rideStats.statsArray[statsIndex] = "EUC: " + eucData.wheelName;
          statsIndex++;
        }
      }
      WatchUi.requestUpdate();
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }

  function rideStatsInit() {
    try {
      rideStats.movingmsec = 0;
      rideStats.statsTimerReset();

      if (rideStats.showAverageMovingSpeedStatistic) {
        rideStats.statsNumberToDiplay++;
      }
      if (rideStats.showTopSpeedStatistic) {
        rideStats.statsNumberToDiplay++;
      }
      if (rideStats.showWatchBatteryConsumptionStatistic) {
        rideStats.statsNumberToDiplay++;
      }
      if (rideStats.showTotalDistance) {
        rideStats.statsNumberToDiplay++;
      }
      if (rideStats.showTripDistance) {
        rideStats.statsNumberToDiplay++;
      }
      if (rideStats.showVoltage) {
        rideStats.statsNumberToDiplay++;
      }
      if (rideStats.showWatchBatteryStatistic) {
        rideStats.statsNumberToDiplay++;
      }
      if (rideStats.showProfileName) {
        rideStats.statsNumberToDiplay++;
      }
      rideStats.statsArray = new[rideStats.statsNumberToDiplay];
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }
  function setGlobalSettings() {
    try {
      eucData.imHornSound = AppStorage.getSetting("imHornSound");
      eucData.updateDelay = AppStorage.getSetting("updateDelay");
      eucData.debug = AppStorage.getSetting("debugMode");
      eucData.activityAutorecording =
          AppStorage.getSetting("activityRecordingOnStartup");
      eucData.activityAutosave = AppStorage.getSetting("activitySavingOnExit");

      rideStats.showAverageMovingSpeedStatistic =
          AppStorage.getSetting("averageMovingSpeedStatistic");
      rideStats.showTopSpeedStatistic =
          AppStorage.getSetting("topSpeedStatistic");

      rideStats.showWatchBatteryConsumptionStatistic =
          AppStorage.getSetting("watchBatteryConsumptionStatistic");
      rideStats.showTripDistance =
          AppStorage.getSetting("tripDistanceStatistic");
      rideStats.showTotalDistance =
          AppStorage.getSetting("totalDistanceStatistic");

      rideStats.showVoltage = AppStorage.getSetting("voltageStatistic");
      rideStats.showWatchBatteryStatistic =
          AppStorage.getSetting("watchBatteryStatistic");
      rideStats.showProfileName = AppStorage.getSetting("profileName");
    } catch (e) {
      System.println("e=" + e.getErrorMessage());
    }
  }

  function getApp() as GarminEUCApp {
    return Application.getApp() as GarminEUCApp;
  }
}