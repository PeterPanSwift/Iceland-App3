import SwiftUI

struct InfoView: View {
    private let facts: [(symbol: String, title: String, value: String)] = [
        ("building.2.fill", "首都", "雷克雅維克"),
        ("person.3.fill", "人口", "約 39 萬人"),
        ("square.dashed", "面積", "10.3 萬 km²"),
        ("creditcard.fill", "貨幣", "冰島克朗 ISK"),
        ("character.bubble.fill", "語言", "冰島語"),
        ("clock.fill", "時區", "UTC+0（比台灣慢 8 小時）"),
    ]

    private let seasons: [(symbol: String, title: String, months: String, text: String, color: Color)] = [
        ("sun.max.fill", "夏季", "6–8 月", "午夜太陽、高地 F 路開放，最適合自駕環島與健行。", .orange),
        ("sparkles", "冬季", "11–3 月", "漫長黑夜是追極光的最佳時機，還能探訪藍冰洞。", .aurora),
        ("leaf.fill", "春秋", "4–5、9–10 月", "遊客較少、價格較低，有機會同時看到極光與綠意。", .glacier),
    ]

    private let tips = [
        ("car.side.fill", "自駕請留意天氣與路況，出發前查看 road.is 與 vedur.is。"),
        ("water.waves", "黑沙灘的瘋狗浪非常危險，請與海水保持距離。"),
        ("drop.fill", "冰島自來水可直接生飲，不需要買瓶裝水。"),
        ("leaf", "請勿踩踏青苔，冰島的青苔需要數十年才能長回來。"),
        ("tshirt.fill", "洋蔥式穿搭＋防風防水外套，一天可能經歷四季。"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    hero
                    VStack(alignment: .leading, spacing: 14) {
                        SectionTitle(text: "基本資訊")
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            ForEach(facts, id: \.title) { fact in
                                HStack(spacing: 12) {
                                    Image(systemName: fact.symbol)
                                        .font(.title3)
                                        .foregroundStyle(Color.glacier)
                                        .frame(width: 28)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(fact.title)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(fact.value)
                                            .font(.subheadline.weight(.semibold))
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.8)
                                    }
                                    Spacer(minLength: 0)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, minHeight: 70)
                                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 14) {
                        SectionTitle(text: "什麼時候去？")
                        ForEach(seasons, id: \.title) { season in
                            HStack(alignment: .top, spacing: 14) {
                                Image(systemName: season.symbol)
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .frame(width: 50, height: 50)
                                    .background(season.color.gradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(season.title).font(.headline)
                                        Text(season.months).font(.subheadline).foregroundStyle(.secondary)
                                    }
                                    Text(season.text)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 14) {
                        SectionTitle(text: "旅遊小提醒")
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(tips, id: \.1) { tip in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: tip.0)
                                        .foregroundStyle(Color.glacier)
                                        .frame(width: 24)
                                    Text(tip.1)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .padding(.horizontal, 20)

                    if !PhotoCredit.all.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionTitle(text: "照片來源")
                            Text("本 App 的照片皆來自 Wikimedia Commons，依各自的創用 CC 授權使用。")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            ForEach(PhotoCredit.all) { credit in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(credit.title)
                                        .font(.caption.weight(.semibold))
                                    Text("\(credit.artist) · \(credit.license)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 30)
            }
            .accessibilityIdentifier("infoScroll")
            .background(Color(.systemGroupedBackground))
            .ignoresSafeArea(edges: .top)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var hero: some View {
        PhotoView(name: "aurora")
            .frame(height: 380)
            .overlay {
                LinearGradient(colors: [.black.opacity(0.1), .black.opacity(0.65)], startPoint: .top, endPoint: .bottom)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("ÍSLAND")
                        .font(.caption.weight(.bold))
                        .tracking(4)
                        .foregroundStyle(Color.aurora)
                    Text("認識冰島")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                    Text("位於北極圈邊緣的火山島，擁有冰川、火山、地熱與極光，是地球上最年輕的土地之一。")
                        .font(.subheadline)
                        .opacity(0.9)
                }
                .foregroundStyle(.white)
                .padding(20)
            }
    }
}
