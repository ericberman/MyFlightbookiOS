/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2023 MyFlightbook, LLC
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  SunriseSunset.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/4/23.
//

import Foundation

@objc public class SunriseSunset : NSObject {
    
    // MARK: Solar functions from NOAA
    // Code below adapted from http://www.srrb.noaa.gov/highlights/sunrise/sunrise.html and http://www.srrb.noaa.gov/highlights/sunrise/calcdetails.html
    
    /// <summary>
    /// Convert radian angle to degrees
    /// </summary>
    /// <param name="angleRad">Angle, in radians</param>
    /// <returns>Angle, in degres</returns>
    static private func radToDeg(_ angleRad : Double) -> Double {
        return (180.0 * angleRad / Double.pi);
    }
    
    // Convert degree angle to radians
    /// <summary>
    /// Convert degrees to radians
    /// </summary>
    /// <param name="angleDeg">Angle, in degrees</param>
    /// <returns>Angle, in Radians</returns>
    static private func degToRad(_ angleDeg : Double) -> Double {
        return (Double.pi * angleDeg / 180.0);
    }
    
    /// <summary>
    /// calculate the hour angle of the sun at sunrise for the latitude
    /// </summary>
    /// <param name="lat">Latitude of observer in degrees</param>
    /// <param name="solarDec">declination angle of sun in degrees</param>
    /// <returns>hour angle of sunrise in radians</returns>
    static private func calcHourAngleSunrise(_ lat : Double, _ solarDec : Double) -> Double {
        let latRad = degToRad(lat);
        let sdRad = degToRad(solarDec);
        
        let HA = (acos(cos(degToRad(90.833)) / (cos(latRad) * cos(sdRad)) - tan(latRad) * tan(sdRad)));
        
        return HA;        // in radians
    }
    
    /// <summary>
    /// calculate the hour angle of the sun at sunset for the latitude
    /// </summary>
    /// <param name="lat">latitude of observer in degrees</param>
    /// <param name="solarDec">declination angle of sun in degrees</param>
    /// <returns>hour angle of sunset in radians</returns>
    static private func calcHourAngleSunset(_ lat : Double, _ solarDec : Double) -> Double {
        let latRad = degToRad(lat);
        let sdRad = degToRad(solarDec);
        
        // double HAarg = (cos(degToRad(90.833)) / (cos(latRad) * cos(sdRad)) - tan(latRad) * tan(sdRad));
        
        let HA = (acos(cos(degToRad(90.833)) / (cos(latRad) * cos(sdRad)) - tan(latRad) * tan(sdRad)));
        
        return -HA;        // in radians
    }
    
    /// <summary>
    /// calculate the Universal Coordinated Time (UTC) of solar noon for the given day at the given location on earth
    /// </summary>
    /// <param name="t">number of Julian centuries since J2000.0</param>
    /// <param name="longitude">longitude of observer in degrees</param>
    /// <returns>time in minutes from zero Z</returns>
    static private func calcSolNoonUTC(_ t : Double, _ longitude : Double) -> Double {
        // First pass uses approximate solar noon to calculate eqtime
        let tnoon = calcTimeJulianCent(calcJDFromJulianCent(t) + longitude / 360.0);
        var eqTime = calcEquationOfTime(tnoon);
        var solNoonUTC = 720 + (longitude * 4) - eqTime; // min
        
        let newt = calcTimeJulianCent(calcJDFromJulianCent(t) - 0.5 + solNoonUTC / 1440.0);
        
        eqTime = calcEquationOfTime(newt);
        // double solarNoonDec = calcSunDeclination(newt);
        solNoonUTC = 720 + (longitude * 4) - eqTime; // min
        
        return solNoonUTC;
    }
    
    //***********************************************************************/
    //***********************************************************************/
    //*                                                */
    //*This section contains subroutines used in calculating solar position */
    //*                                                */
    //***********************************************************************/
    //***********************************************************************/
    
    /// <summary>
    /// Julian day from calendar day
    /// </summary>
    /// <param name="year">Year</param>
    /// <param name="month">Month (1-12)</param>
    /// <param name="day">Day (1-31)</param>
    /// <returns>The Julian day corresponding to the date.  Number is returned for start of day.  Fractional days should be added later.</returns>
    static private func calcJD(_ y : Int, _ m : Int, _ day : Int) -> Double {
        var year = y
        var month = m
        if (month <= 2)
        {
            year -= 1;
            month += 12;
        }
        let A = Int(floor(Double(year) / 100.0))
        let B = 2 - A + Int(floor(Double(A) / 4.0))
        
        let JD = floor(365.25 * Double(year + 4716)) + floor(30.6001 * Double(month + 1)) + Double(day + B) - 1524.5;
        return JD;
    }
    
    /// <summary>
    /// Convert Julian Day to centuries since J2000.0
    /// </summary>
    /// <param name="jd">Julian day to convert</param>
    /// <returns>The T value corresponding to the Julian Day</returns>
    static private func calcTimeJulianCent(_ jd : Double) -> Double {
        let T = (jd - 2451545.0) / 36525.0;
        return T;
    }
    
    /// <summary>
    /// convert centuries since J2000.0 to Julian Day
    /// </summary>
    /// <param name="t">number of Julian centuries since J2000.0</param>
    /// <returns>the Julian Day corresponding to the t value</returns>
    static private func calcJDFromJulianCent(_ t : Double) -> Double {
        let JD = t * 36525.0 + 2451545.0;
        return JD;
    }
    
    /// <summary>
    /// calculate the Geometric Mean Longitude of the Sun
    /// </summary>
    /// <param name="t">number of Julian centuries since J2000.0</param>
    /// <returns>the Geometric Mean Longitude of the Sun in degrees</returns>
    static private func calcGeomMeanLongSun(_ t : Double) -> Double {
        var L0 = 280.46646 + t * (36000.76983 + 0.0003032 * t);
        while (L0 > 360.0) {
            L0 -= 360.0;
        }
        while (L0 < 0.0) {
            L0 += 360.0;
        }
        return L0;        // in degrees
    }
    
    /// <summary>
    /// calculate the Geometric Mean Anomaly of the Sun
    /// </summary>
    /// <param name="t">number of Julian centuries since J2000.0</param>
    /// <returns>the Geometric Mean Anomaly of the Sun in degrees</returns>
    static private func calcGeomMeanAnomalySun(_ t : Double) -> Double {
        let M = 357.52911 + t * (35999.05029 - 0.0001537 * t);
        return M;        // in degrees
    }
    
    /// <summary>
    /// calculate the eccentricity of earth's orbit
    /// </summary>
    /// <param name="t">number of Julian centuries since J2000.0</param>
    /// <returns>the unitless eccentricity</returns>
    static private func calcEccentricityEarthOrbit(_ t : Double) -> Double
    {
        let e = 0.016708634 - t * (0.000042037 + 0.0000001267 * t);
        return e;        // unitless
    }
    
    /// <summary>
    /// calculate the equation of center for the sun
    /// </summary>
    /// <param name="t">number of Julian centuries since J2000.0</param>
    /// <returns>in degrees</returns>
    static private func calcSunEqOfCenter(_ t : Double) -> Double {
        let m = calcGeomMeanAnomalySun(t);
        
        let mrad = degToRad(m);
        let sinm = sin(mrad);
        let sin2m = sin(mrad + mrad);
        let sin3m = sin(mrad + mrad + mrad);
        
        let C = sinm * (1.914602 - t * (0.004817 + 0.000014 * t)) + sin2m * (0.019993 - 0.000101 * t) + sin3m * 0.000289;
        return C;        // in degrees
    }
    
    /// <summary>
    /// calculate the true longitude of the sun
    /// </summary>
    /// <param name="t">number of Julian centuries since J2000.0</param>
    /// <returns>sun's true longitude in degrees</returns>
    static private func calcSunTrueLong(_ t : Double) -> Double {
        let l0 = calcGeomMeanLongSun(t);
        let c = calcSunEqOfCenter(t);
        
        let O = l0 + c;
        return O;        // in degrees
    }
    
    /*
     /// <summary>
     /// calculate the true anamoly of the sun
     /// </summary>
     /// <param name="t">number of Julian centuries since J2000.</param>
     /// <returns>sun's true anamoly in degrees</returns>
     static double calcSunTrueAnomaly(_ t : Double)
     {
     double m = calcGeomMeanAnomalySun(t);
     double c = calcSunEqOfCenter(t);
     
     double v = m + c;
     return v;        // in degrees
     }
     */
    
    /*
     /// <summary>
     /// calculate the distance to the sun in AU
     /// </summary>
     /// <param name="t"> t : number of Julian centuries since J2000.0</param>
     /// <returns>sun radius vector in AUs</returns>
     static double calcSunRadVector(_ t : Double)
     {
     double v = calcSunTrueAnomaly(t);
     double e = calcEccentricityEarthOrbit(t);
     
     double R = (1.000001018 * (1 - e * e)) / (1 + e * cos(degToRad(v)));
     return R;        // in AUs
     }
     */
    
    /// <summary>
    /// calculate the apparent longitude of the sun
    /// </summary>
    /// <param name="t"> t : number of Julian centuries since J2000.0</param>
    /// <returns>sun's apparent longitude in degrees</returns>
    static private func calcSunApparentLong(_ t : Double) -> Double {
        let o = calcSunTrueLong(t);
        
        let omega = 125.04 - 1934.136 * t;
        let lambda = o - 0.00569 - 0.00478 * sin(degToRad(omega));
        return lambda;        // in degrees
    }
    
    /// <summary>
    /// calculate the mean obliquity of the ecliptic
    /// </summary>
    /// <param name="t"> t : number of Julian centuries since J2000.0</param>
    /// <returns>mean obliquity in degrees</returns>
    static private func calcMeanObliquityOfEcliptic(_ t : Double) -> Double {
        let seconds = 21.448 - t * (46.8150 + t * (0.00059 - t * (0.001813)));
        let e0 = 23.0 + (26.0 + (seconds / 60.0)) / 60.0;
        return e0;        // in degrees
    }
    
    /// <summary>
    /// calculate the corrected obliquity of the ecliptic
    /// </summary>
    /// <param name="t"> t : number of Julian centuries since J2000.0</param>
    /// <returns>corrected obliquity in degrees</returns>
    static private func calcObliquityCorrection(_ t : Double) -> Double {
        let e0 = calcMeanObliquityOfEcliptic(t);
        
        let omega = 125.04 - 1934.136 * t;
        let e = e0 + 0.00256 * cos(degToRad(omega));
        return e;        // in degrees
    }
    
    /*
     /// <summary>
     /// calculate the right ascension of the sun
     /// </summary>
     /// <param name="t"> t : number of Julian centuries since J2000.0</param>
     /// <returns>sun's right ascension in degrees</returns>
     static private func calcSunRtAscension(_ t : Double)
     {
     double e = calcObliquityCorrection(t);
     double lambda = calcSunApparentLong(t);
     
     double tananum = (cos(degToRad(e)) * sin(degToRad(lambda)));
     double tanadenom = (cos(degToRad(lambda)));
     double alpha = radToDeg(atan2(tananum, tanadenom));
     return alpha;        // in degrees
     }
     */
    
    /// <summary>
    /// calculate the declination of the sun
    /// </summary>
    /// <param name="t"> t : number of Julian centuries since J2000.0</param>
    /// <returns>sun's declination in degrees</returns>
    static private func calcSunDeclination(_ t : Double) -> Double {
        let e = calcObliquityCorrection(t);
        let lambda = calcSunApparentLong(t);
        
        let sint = sin(degToRad(e)) * sin(degToRad(lambda));
        let theta = radToDeg(asin(sint));
        return theta;        // in degrees
    }
    
    /// <summary>
    /// Solar angle - reverse engineered from http://www.usc.edu/dept-00/dept/architecture/mbs/tools/thermal/sun_calc.html
    /// </summary>
    /// <param name="lat">The Latitude, in degrees</param>
    /// <param name="lon">The Longitude, in degrees</param>
    /// <param name="minutes">Minutes into the day (UTC)</param>
    /// <param name="JD">The Julian Date</param>
    /// <returns>Angle of the sun, in degrees</returns>
    static private func calcSolarAngle(_ lat : Double, _ lon : Double, _ JD : Double, _ minutes : Double) ->  Double {
        let julianCentury = calcTimeJulianCent(JD + minutes / 1440.0);
        
        let sunDeclinationRad = degToRad(calcSunDeclination(julianCentury));
        let latRad = degToRad(lat);
        
        let eqOfTime = calcEquationOfTime(julianCentury);
        
        let trueSolarTimeMin =  (Int(minutes + eqOfTime + 4 * lon)) % 1440;
        let hourAngleDeg = trueSolarTimeMin / 4 < 0 ? trueSolarTimeMin / 4 + 180 : trueSolarTimeMin / 4 - 180;
        let zenith = radToDeg(acos(sin(latRad) * sin(sunDeclinationRad) + cos(latRad) * cos(sunDeclinationRad) * cos(degToRad(Double(hourAngleDeg)))));
        let solarElevation = 90 - zenith;
        let atmRefractionDeg = solarElevation > 85 ? 0 :
            (solarElevation > 5 ? 58.1 / tan(degToRad(solarElevation)) - 0.07 / pow(tan(degToRad(solarElevation)), 3) + 0.000086 / pow(tan(degToRad(solarElevation)), 5) :
            solarElevation > -0.575 ? 1735 + solarElevation * (-518.2 + solarElevation * (103.4 + solarElevation * (-12.79 + solarElevation * 0.711))) : -20.772 / tan(degToRad(solarElevation))) / 3600;
        return solarElevation + atmRefractionDeg;
    }
    
    /// <summary>
    /// calculate the difference between true solar time and mean solar time
    /// </summary>
    /// <param name="t">number of Julian centuries since J2000.0</param>
    /// <returns>equation of time in minutes of time</returns>
    static private func calcEquationOfTime(_ t : Double) -> Double {
        let epsilon = calcObliquityCorrection(t);
        let l0 = calcGeomMeanLongSun(t);
        let e = calcEccentricityEarthOrbit(t);
        let m = calcGeomMeanAnomalySun(t);
        
        var y = tan(degToRad(epsilon) / 2.0);
        y *= y;
        
        let sin2l0 = sin(2.0 * degToRad(l0));
        let sinm = sin(degToRad(m));
        let cos2l0 = cos(2.0 * degToRad(l0));
        let sin4l0 = sin(4.0 * degToRad(l0));
        let sin2m = sin(2.0 * degToRad(m));
        
        let Etime = y * sin2l0 - 2.0 * e * sinm + 4.0 * e * y * sinm * cos2l0
        - 0.5 * y * y * sin4l0 - 1.25 * e * e * sin2m;
        
        return radToDeg(Etime) * 4.0;    // in minutes of time
    }
    
    /// <summary>
    /// Calculate the UTC Time of sunrise for the given day at the given location on earth
    /// </summary>
    /// <param name="JD">Julian day</param>
    /// <param name="latitude">Latitude of observer</param>
    /// <param name="longitude">Longitude of observer</param>
    /// <returns>Time in minutes from zero Z</returns>
    static private func calcSunriseUTC(_ JD : Double, _ latitude : Double, _ longitude : Double) -> Double {
        let t = calcTimeJulianCent(JD);
        
        // *** Find the time of solar noon at the location, and use
        //     that declination. This is better than start of the
        //     Julian day
        let noonmin = calcSolNoonUTC(t, longitude);
        let tnoon = calcTimeJulianCent(JD + noonmin / 1440.0);
        
        // *** First pass to approximate sunrise (using solar noon)
        var eqTime = calcEquationOfTime(tnoon);
        var solarDec = calcSunDeclination(tnoon);
        var hourAngle = calcHourAngleSunrise(latitude, solarDec);
        
        var delta = longitude - radToDeg(hourAngle);
        var timeDiff = 4 * delta;    // in minutes of time
        var timeUTC = 720 + timeDiff - eqTime;    // in minutes
        
        // *** Second pass includes fractional jday in gamma calc
        let newt = calcTimeJulianCent(calcJDFromJulianCent(t) + timeUTC / 1440.0);
        eqTime = calcEquationOfTime(newt);
        solarDec = calcSunDeclination(newt);
        hourAngle = calcHourAngleSunrise(latitude, solarDec);
        delta = longitude - radToDeg(hourAngle);
        timeDiff = 4 * delta;
        timeUTC = 720 + timeDiff - eqTime; // in minutes
        
        return timeUTC;
    }
    
    /// <summary>
    /// calculate the Universal Coordinated Time (UTC) of sunset for the given day at the given location on earth
    /// </summary>
    /// <param name="JD">Julian Day</param>
    /// <param name="latitude">latitude of observer in degrees</param>
    /// <param name="longitude">longitude of observer in degrees</param>
    /// <returns>time in minutes from zero Z</returns>
    static private func calcSunsetUTC(_ JD : Double, _ latitude : Double, _ longitude : Double) -> Double {
        let t = calcTimeJulianCent(JD);
        
        // *** Find the time of solar noon at the location, and use
        //     that declination. This is better than start of the
        //     Julian day
        let noonmin = calcSolNoonUTC(t, longitude);
        let tnoon = calcTimeJulianCent(JD + noonmin / 1440.0);
        
        // First calculates sunrise and approx length of day
        var eqTime = calcEquationOfTime(tnoon);
        var solarDec = calcSunDeclination(tnoon);
        var hourAngle = calcHourAngleSunset(latitude, solarDec);
        
        var delta = longitude - radToDeg(hourAngle);
        var timeDiff = 4 * delta;
        var timeUTC = 720 + timeDiff - eqTime;
        
        // first pass used to include fractional day in gamma calc
        let newt = calcTimeJulianCent(calcJDFromJulianCent(t) + timeUTC / 1440.0);
        eqTime = calcEquationOfTime(newt);
        solarDec = calcSunDeclination(newt);
        hourAngle = calcHourAngleSunset(latitude, solarDec);
        
        delta = longitude - radToDeg(hourAngle);
        timeDiff = 4 * delta;
        timeUTC = 720 + timeDiff - eqTime; // in minutes
        
        return timeUTC;
    }
    
#if DEBUG
    private static let m_df = DateFormatter()
#endif
    
    // Code below adapted from http://www.srrb.noaa.gov/highlights/sunrise/sunrise.html and http://www.srrb.noaa.gov/highlights/sunrise/calcdetails.html
    
    @objc public var Sunrise : NSDate?
    @objc public var Sunset : NSDate?
    @objc private var Latitude = 0.0
    @objc private var Longitude = 0.0
    @objc private var Date : Date
    @objc public var isNight = false
    @objc public var isFAANight = false
    @objc public var isCivilNight = false
    @objc public var isWithinNightOffset = false
    @objc private var NightLandingOffset = 60
    @objc private var NightFlightOffset = 0
    @objc private var solarAngle = 0.0
    
    
    // MARK: Initializaiton
    @objc(initWithDate:Latitude:Longitude:nightOffset:) public init(dt : Date, latitude: Double, longitude : Double, nightOffset : Int) {
#if DEBUG
        m_df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        m_df.timeZone = TimeZone(identifier: "UTC")
#endif
        self.Date = dt
        Latitude = latitude
        Longitude = longitude
        NightFlightOffset = nightOffset
        super.init()
        ComputeTimesAtLocation(dt)
    }
        
    /// <summary>
    /// Returns the UTC time for the minutes into the day.  Note that it could be a day forward or backward from the requested day!!!
    /// </summary>
    /// <param name="dt">Requested day (only m/d/y matter)</param>
    /// <param name="minutes"></param>
    /// <returns></returns>
    private func MinutesToDateTime(_ dt : Date, forMinutes minutes : Double) -> Date {
        var cal = Calendar(identifier: .gregorian)
        let tzSave = cal.timeZone
        cal.timeZone = TimeZone(identifier: "UTC")!
        var comps = cal.dateComponents([.year, .month, .day], from: dt)
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        
        let dtRef = cal.date(from: comps)!
        cal.timeZone = tzSave
        
        let tRef = dtRef.timeIntervalSinceReferenceDate
        return Foundation.Date(timeIntervalSinceReferenceDate: tRef + (minutes * 60))
    }
    
    /// <summary>
    /// Returns the sunrise/sunset times at the given location on the specified day
    /// </summary>
    /// <param name="dt">The requested date/time, utc.  Day/night will be computed based on the time</param>
    private func ComputeTimesAtLocation(_ dt : Date) {
        if (Latitude > 90 || Latitude < -90 || Longitude > 180 || Longitude < -180) {
            NSLog("Bad lat/lon: %f, %f", Latitude, Longitude)
            return
        }
        
        var cal = Calendar.current
        let tzSave = cal.timeZone
        cal.timeZone = TimeZone(identifier: "UTC")!
        var comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: dt)
        var JD = SunriseSunset.calcJD(comps.year!, comps.month!, comps.day!)
        
        solarAngle = SunriseSunset.calcSolarAngle(Latitude, Longitude, JD, Double(comps.hour! * 60 + comps.minute!))
        isCivilNight = solarAngle <= -6.0
        var nosunrise = false
        let riseTimeGMT = SunriseSunset.calcSunriseUTC(JD, Latitude, -Longitude)
        if (riseTimeGMT.isNaN) {
            nosunrise = true
        }
        
        // Calculate sunset for this date
        // if no sunset is found, set flag nosunset
        var nosunset = false
        let setTimeGMT = SunriseSunset.calcSunsetUTC(JD, Latitude, -Longitude)
        if (setTimeGMT.isNaN) {
            nosunset = true
        }
        
        // we now know the UTC # of minutes for each. Return the UTC sunrise/sunset times
        if (!nosunrise) {
            Sunrise = MinutesToDateTime(dt, forMinutes: riseTimeGMT) as NSDate
        }
        
        if (!nosunset) {
            Sunset = MinutesToDateTime(dt, forMinutes: setTimeGMT) as NSDate
        }
        
#if xDEBUG
        NSLog("%@: Sunrise=%@, Sunset=%@, solarAngle=%.1f", m_df.string(from: dt), m_df.string(from: Sunrise), m_df.string(from: Sunset), solarAngle);
#endif
        
        // Update daytime/nighttime
        // 3 possible scenarios:
        // (a) time is between sunrise/sunset as computed - it's daytime or FAA daytime.
        // (b) time is after the sunset - figure out the next sunrise and compare to that
        // (c) time is before sunrise - figure out the previous sunset and compare to that
        isNight = isCivilNight
        isFAANight = false
        isWithinNightOffset = false
        
        if (Sunrise == nil || Sunset == nil) {
            // One or the other is nil - we're in the land of the midnight sun.  Just test for night.
            isNight = isCivilNight
            isFAANight = isCivilNight
        }
        else if (Sunrise!.compare(dt) == .orderedAscending && Sunset!.compare(dt) == .orderedDescending) {
            // between sunrise and sunset - it's daytime no matter how you slice it; use default values (set above)
        }
        else if (Sunset!.compare(dt) == .orderedAscending) {
            // get the next sunrise.  It is night if the time is between sunset and the next sunrise
            let dtTomorrow = dt.addingTimeInterval(24 * 60 * 60)
            comps = cal.dateComponents([.year, .month, .day], from: dtTomorrow)
            JD = SunriseSunset.calcJD(comps.year!, comps.month!, comps.day!)
            let nextSunrise = SunriseSunset.calcSunriseUTC(JD, Latitude, -Longitude)
            if (!nextSunrise.isNaN) {
                let dtNextSunrise = MinutesToDateTime(dtTomorrow, forMinutes: nextSunrise)
#if DEBUG
                NSLog("NextSunrise = %@", m_df.string(from: dtNextSunrise))
#endif
                isNight = dtNextSunrise.compare(dt) == .orderedDescending   // we've already determined that we're after sunset, we just need to be before sunrise
                isFAANight = dtNextSunrise.addingTimeInterval(Double(-NightLandingOffset * 60)).compare(dt) == .orderedDescending &&
                    Sunset!.addingTimeInterval(Double(NightLandingOffset * 60)).compare(dt) == .orderedAscending
                isWithinNightOffset = dtNextSunrise.addingTimeInterval(Double(-NightFlightOffset * 60)).compare(dt) == .orderedDescending &&
                    Sunset!.addingTimeInterval(Double(NightFlightOffset * 60)).compare(dt) == .orderedAscending
            }
        }
        else if (Sunrise!.compare(dt) == .orderedDescending) {
            // get the previous sunset.  It is night if the time is between that sunset and the sunrise
            let dtYesterday = dt.addingTimeInterval(-24 * 60 * 60)
            comps = cal.dateComponents([.year, .month, .day], from: dtYesterday)
            JD = SunriseSunset.calcJD(comps.year!, comps.month!, comps.day!)
            let prevSunset = SunriseSunset.calcSunsetUTC(JD, Latitude, -Longitude)
            if (!prevSunset.isNaN) {
                let dtPrevSunset = MinutesToDateTime(dtYesterday, forMinutes: prevSunset)
                
                isNight = dtPrevSunset.compare(dt) == .orderedAscending // we've already determined that we're before sunrise, we just need to be after sunset.
                isFAANight = dtPrevSunset.addingTimeInterval(Double(NightLandingOffset * 60)).compare(dt) == .orderedAscending &&
                    Sunrise!.addingTimeInterval(Double(-NightLandingOffset * 60)).compare(dt) == .orderedDescending
                isWithinNightOffset = dtPrevSunset.addingTimeInterval(Double(NightFlightOffset * 60)).compare(dt) == .orderedAscending &&
                    Sunrise!.addingTimeInterval(Double(-NightFlightOffset * 60)).compare(dt) == .orderedDescending
            }
        }
        cal.timeZone = tzSave
    }
}
