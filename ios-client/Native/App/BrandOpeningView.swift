import CalendarCore
import SwiftUI

struct BrandOpeningView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize: CGFloat = 49
    @ScaledMetric(relativeTo: .body) private var bodySize: CGFloat = 19

    private let isChinese = ContentLanguagePreference.system.resolvedLanguage() == "zh-Hans"
    private let cardAspectRatio: CGFloat = 971.0 / 1619.0
    private var title: String { isChinese ? "毛选日历" : "Mao Quotes" }
    private var message: String {
        isChinese
            ? "同志，每日一页，\n非时光重复，是平凡坚守，\n终凝不凡力量！"
            : "Comrade, one page a day—\nnot merely marking time,\nbut a quiet act of perseverance\nthat builds extraordinary strength!"
    }
    private var reflowedMessage: String {
        message.replacingOccurrences(of: "\n", with: isChinese ? "" : " ")
    }

    var body: some View {
        GeometryReader { geometry in
            let compact = geometry.size.width <= 375
            Group {
                if dynamicTypeSize.isAccessibilitySize || geometry.size.height < 300 {
                    ScrollView {
                        VStack(spacing: 16) {
                            heading(compact: compact)
                            messageText(reflowedMessage, compact: compact)
                            cardImage
                        }
                        .frame(width: min(460, max(0, geometry.size.width - 32)))
                        .frame(maxWidth: .infinity)
                    }
                } else if geometry.size.width >= 600 {
                    wideOpening(in: geometry.size)
                } else {
                    VStack(spacing: 0) {
                        heading(compact: compact)
                            .padding(.bottom, 8)
                        GeometryReader { available in
                            let width = min(available.size.width, available.size.height * cardAspectRatio)
                            let height = width / cardAspectRatio
                            ZStack(alignment: .top) {
                                cardImage
                                ViewThatFits(in: .vertical) {
                                    messageText(message, compact: compact)
                                    messageText(reflowedMessage, compact: compact)
                                    ScrollView {
                                        messageText(reflowedMessage, compact: compact)
                                    }
                                }
                                .frame(width: max(0, width - 36), height: height * 0.27)
                                .offset(y: height * 0.15)
                            }
                            .frame(width: width, height: height)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 8)
                    }
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color("LaunchPaper").ignoresSafeArea())
    }

    private func wideOpening(in size: CGSize) -> some View {
        let width = min(size.width - 56, 1020)
        let spacing: CGFloat = 32
        let cardWidth = min(width * 0.47, (size.height - 48) * cardAspectRatio, 460)
        let copyWidth = min(width - spacing - cardWidth, 430)

        return HStack(spacing: spacing) {
            VStack(spacing: 20) {
                heading(compact: false)
                messageText(isChinese ? message : reflowedMessage, compact: false)
            }
            .frame(width: copyWidth)

            cardImage
                .frame(width: cardWidth)
                #if DEBUG
                .overlay(alignment: .top) {
                    openingQuote(cardWidth: cardWidth)
                }
                #endif
        }
    }

    #if DEBUG
    private func openingQuote(cardWidth: CGFloat) -> some View {
        let cardHeight = cardWidth / cardAspectRatio
        let text = isChinese
            ? "读书是学习，\n使用也是学习，\n而且是更重要的学习。"
            : "Reading is learning, but applying is also learning and the more important kind of learning at that."

        return Text(text)
            .font(CalendarTypography.font(
                isChinese ? .chineseQuote : .englishQuote,
                size: min(cardWidth * 0.09, isChinese ? 27 : 22)
            ))
            .foregroundStyle(CalendarPalette.ink)
            .multilineTextAlignment(.center)
            .lineSpacing(5)
            .lineLimit(isChinese ? 3 : 4)
            .minimumScaleFactor(0.72)
            .frame(width: cardWidth * 0.80, height: cardHeight * 0.27)
            .padding(.top, cardHeight * 0.14)
    }
    #endif

    private var cardImage: some View {
        Image(decorative: "BrandOpeningCard")
            .resizable()
            .aspectRatio(cardAspectRatio, contentMode: .fit)
    }

    private func heading(compact: Bool) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(CalendarTypography.font(isChinese ? .chineseTitle : .englishTitle,
                                              size: titleSize - (compact ? 7 : 0)))
                .foregroundStyle(CalendarPalette.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Rectangle()
                .fill(CalendarPalette.vermilion)
                .frame(width: 24, height: 1)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 12)
    }

    private func messageText(_ value: String, compact: Bool) -> some View {
        Text(value)
            .font(CalendarTypography.font(isChinese ? .chineseQuote : .englishQuote,
                                          size: bodySize - (compact ? 3 : 0)))
            .foregroundStyle(CalendarPalette.vermilion)
            .multilineTextAlignment(.center)
            .lineSpacing(5)
            .fixedSize(horizontal: false, vertical: true)
    }
}
