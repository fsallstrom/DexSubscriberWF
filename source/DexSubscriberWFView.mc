import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class DexSubscriberWFView extends WatchUi.WatchFace {

    const DexGlucose_longname = "Dexcom Glucose";        // Publisher for Dexcom blood glucose: (mmol or mg/dl)
    const DexTrend_longname = "Dexcom Trend";       // Publisher for Dexcom trend: (7 = Double down, 6 = Down, 5 = 45% Down, 4 = Flat, 3 = 45% Up, 2 = Up, 1 = Double Up, 0 = Null)
    const DexSampleTime_longname = "Dexcom Sample Time";  // Publisher for Dexcom sample time: (32-bit integer representing the number of seconds since the UNIX epoch (January 1, 1970 at 00:00:00 UTC))

    var DexGlucose_id as Toybox.Complications.Id;
    var DexTrend_id as Toybox.Complications.Id;
    var DexSampleTime_id as Toybox.Complications.Id;
    var glucose as String;
    var glucose_unit as String;
    var trend as Number;
    var sampleTime as Number;
    var glucose_label as String;
    var trend_label as String;
    var sampleTime_label as String;
    var complicationsFound as Boolean;


    function initialize() {
        System.println("in initialize");
        WatchFace.initialize();
        DexGlucose_id = null;
        DexTrend_id = null;
        DexSampleTime_id = null;
        glucose = null;
        glucose_unit = "";
        trend = null;
        sampleTime = null;
        glucose_label = "";
        trend_label = "";
        sampleTime_label = "";
        complicationsFound = false;

        if (Toybox has :Complications) {
            subscribe();
        }
    }


    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }


    function onShow() as Void {
        if (Toybox has :Complications && !complicationsFound) {
            subscribe();
        }
    }


    function onUpdate(dc as Dc) as Void {

        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var timeView = View.findDrawableById("TimeLabel") as Text;
        var glucoseView = View.findDrawableById("glucose") as Text;
        var trendView = View.findDrawableById("trend") as Text;
        var elapsedTimeView = View.findDrawableById("elapsedTime") as Text;
        timeView.setText(timeString);
        
        if (glucose != null) {glucoseView.setText(glucose_label+ ": "+glucose+" "+glucose_unit);}
        if (trend != null) {trendView.setText(trend_label+ ": "+trend.toString());}
        if (sampleTime != null) {elapsedTimeView.setText(sampleTime_label+ ": "+getElapsedMins(sampleTime).toString()+" min");}

        View.onUpdate(dc);
    }


    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        if (Toybox has :Complications && !complicationsFound) {
            subscribe();
        }
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    // Look for Dexcom publishers and subscribe
    function subscribe() {
        var iter = Complications.getComplications();
        var complicationId = iter.next();

        while (complicationId != null) {
            if (complicationId.longLabel.equals(DexGlucose_longname)) {
                System.println("Found publisher: " + complicationId.longLabel);
                complicationsFound = true;
                DexGlucose_id = complicationId.complicationId;
                if (complicationId.value != null) {
                    glucose = complicationId.value;
                }
                glucose_label = complicationId.shortLabel;
                glucose_unit = complicationId.unit;
                Complications.subscribeToUpdates(DexGlucose_id);
            }
            if (complicationId.longLabel.equals(DexTrend_longname)) {
                System.println("Found publisher: " + complicationId.longLabel);
                complicationsFound = true;
                DexTrend_id = complicationId.complicationId;
                if (complicationId.value != null) {
                    trend = complicationId.value.toNumber();
                }
                trend_label = complicationId.shortLabel;
                Complications.subscribeToUpdates(DexTrend_id);
            }
            if (complicationId.longLabel.equals(DexSampleTime_longname)) {
                complicationsFound = true;
                DexSampleTime_id = complicationId.complicationId;
                if (complicationId.value != null) {
                    sampleTime = complicationId.value.toNumber();
                }
                sampleTime_label = complicationId.shortLabel;
                Complications.subscribeToUpdates(DexSampleTime_id);
                System.println("Found publisher: " + complicationId.longLabel);
            }
            complicationId = iter.next();
        }

        if (complicationsFound) {
            Complications.registerComplicationChangeCallback(method(:onCompChanged));    
        } else {
            glucose = "N/A";
            System.println("No Dexcom publishers found");
        }
    }

    function onCompChanged(id) {
        if(id.equals(DexGlucose_id)) {
            glucose = Complications.getComplication(id).value;
            glucose_unit = Complications.getComplication(id).unit;
            System.println("Data changed for publisher: " + Complications.getComplication(id).longLabel);
        }
        if(id.equals(DexTrend_id)) {
            trend = Complications.getComplication(id).value.toNumber();
            System.println("Data changed for publisher: " + Complications.getComplication(id).longLabel);
        }
        if(id.equals(DexSampleTime_id)) {
            sampleTime = Complications.getComplication(id).value.toNumber();
            System.println("Data changed for publisher: " + Complications.getComplication(id).longLabel);
        }
    }

    function getElapsedMins(sampleTime as Number) as Number {
        if (sampleTime != null && sampleTime > 0) { 
            var _sampleTime = new Time.Moment(sampleTime);
            return Math.floor(Time.now().subtract(_sampleTime).value() / 60);     
        } else { return -1; }
    }

}
