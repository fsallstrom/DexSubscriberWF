This is sampe code for a Garmin Watch Face that subscribes to Dexcom complication publishers (from the Dex CGM Widget) to display blood glocuse values in the watch face. 

It subscribes to three complication publishers:
1. Dexcom Glucose - Publisher for Dexcom blood glucose: (mmol or mg/dl)
2. Dexcom Trend -  Publisher for the Dexcom glucose trend: (7 = Double down, 6 = Down, 5 = 45% Down, 4 = Flat, 3 = 45% Up, 2 = Up, 1 = Double Up, 0 = Null)
3. Dexcom Sample Time - Publisher for Dexcom sample time: (Time of the blood glucose sample, a 32-bit integer representing the number of seconds since the UNIX epoch (January 1, 1970 at 00:00:00 UTC))
   
