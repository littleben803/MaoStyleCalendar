import Foundation

// Convert the card's civil date at local noon, rather than using today's date.
// Chinese-calendar year 1 is 甲子; the cycle changes at lunar New Year.
public enum ArtworkLunarDate {
    @available(iOS 17.0, macOS 14.0, *)
    public static func text(year: Int, month: Int, day: Int, timeZone: TimeZone = .autoupdatingCurrent) -> String? {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = timeZone
        guard let instant = gregorian.date(from: DateComponents(year: year, month: month, day: day, hour: 12)) else { return nil }
        var chinese = Calendar(identifier: .chinese)
        chinese.timeZone = timeZone
        let parts = chinese.dateComponents([.year, .month, .day, .isLeapMonth], from: instant)
        guard let cycleYear = parts.year, let lunarMonth = parts.month, let lunarDay = parts.day,
              cycleYear >= 1, (1...12).contains(lunarMonth), (1...30).contains(lunarDay) else { return nil }
        let stems = Array("甲乙丙丁戊己庚辛壬癸")
        let branches = Array("子丑寅卯辰巳午未申酉戌亥")
        let months = ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
        let days = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                    "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                    "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
        let ganzhi = "\(stems[(cycleYear - 1) % 10])\(branches[(cycleYear - 1) % 12])年"
        return "\(ganzhi) \(parts.isLeapMonth == true ? "闰" : "")\(months[lunarMonth - 1])\(days[lunarDay - 1])"
    }
}
