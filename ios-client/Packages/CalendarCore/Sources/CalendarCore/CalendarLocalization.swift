import Foundation

public extension Locale {
    var calendarIsChinese: Bool { identifier.lowercased().hasPrefix("zh") }

    func calendarText(_ chinese: String, _ english: String) -> String {
        calendarIsChinese ? chinese : english
    }

    func calendarMonth(_ month: Int) -> String {
        guard (1...12).contains(month) else { return "—" }
        return calendarIsChinese ? "\(month)月" : ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][month - 1]
    }
}

public extension CalendarDate {
    func displayDate(locale: Locale, template: String = "yMMMd") -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12)) else { return "—" }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale.calendarIsChinese ? Locale(identifier: "zh_Hans") : Locale(identifier: "en_US")
        formatter.timeZone = calendar.timeZone
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter.string(from: date)
    }
}

public extension DailyContentPack {
    /// Never silently substitute Chinese when English is requested.
    func localizedQuote(locale: Locale) -> String {
        let tag = locale.calendarIsChinese ? "zh" : "en"
        return quoteTexts.first { $0.languageTag.hasPrefix(tag) }?.text
            ?? locale.calendarText("语录待内容审核", "English translation unavailable")
    }

    func localizedEditorialSections(locale: Locale) -> [EditorialSection] {
        let tag = locale.calendarIsChinese ? "zh" : "en"
        return editorialSections.filter { $0.languageTag.hasPrefix(tag) }
            .sorted { $0.displayOrder < $1.displayOrder }
    }
}
