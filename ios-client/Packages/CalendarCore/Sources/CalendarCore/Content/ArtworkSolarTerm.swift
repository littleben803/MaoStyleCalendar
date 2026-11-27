import Foundation

/// The date on which the Sun's apparent ecliptic longitude crosses a multiple of 15°.
public enum ArtworkSolarTerm {
    private static let names = [
        "春分", "清明", "谷雨", "立夏", "小满", "芒种", "夏至", "小暑", "大暑", "立秋", "处暑", "白露",
        "秋分", "寒露", "霜降", "立冬", "小雪", "大雪", "冬至", "小寒", "大寒", "立春", "雨水", "惊蛰"
    ]

    public static func name(year: Int, month: Int, day: Int, timeZone: TimeZone = .autoupdatingCurrent) -> String? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let components = DateComponents(year: year, month: month, day: day)
        guard let start = calendar.date(from: components),
              calendar.dateComponents([.year, .month, .day], from: start) == components,
              let next = calendar.date(byAdding: .day, value: 1, to: start) else { return nil }

        let first = apparentSolarLongitude(at: start)
        var last = apparentSolarLongitude(at: next)
        if last < first { last += 360 }
        let boundary = (floor(first / 15) + 1) * 15
        guard boundary <= last else { return nil }
        return names[Int(boundary / 15) % names.count]
    }

    private static func apparentSolarLongitude(at date: Date) -> Double {
        let julianDay = date.timeIntervalSince1970 / 86_400 + 2_440_587.5
        let centuries = (julianDay - 2_451_545) / 36_525
        let meanLongitude = 280.46646 + centuries * (36_000.76983 + 0.0003032 * centuries)
        let meanAnomaly = (357.52911 + centuries * (35_999.05029 - 0.0001537 * centuries)) * .pi / 180
        let equationOfCenter = (1.914602 - centuries * (0.004817 + 0.000014 * centuries)) * sin(meanAnomaly)
            + (0.019993 - 0.000101 * centuries) * sin(2 * meanAnomaly)
            + 0.000289 * sin(3 * meanAnomaly)
        let omega = (125.04 - 1934.136 * centuries) * .pi / 180
        let longitude = meanLongitude + equationOfCenter - 0.00569 - 0.00478 * sin(omega)
        let normalized = longitude.truncatingRemainder(dividingBy: 360)
        return normalized < 0 ? normalized + 360 : normalized
    }
}
