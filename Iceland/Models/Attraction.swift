import CoreLocation
import Foundation

enum Category: String, CaseIterable, Identifiable {
    case waterfall = "瀑布"
    case iceAndCoast = "冰與海"
    case geothermal = "地熱"
    case mountain = "山岳"
    case city = "城市"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .waterfall: "drop.fill"
        case .iceAndCoast: "snowflake"
        case .geothermal: "flame.fill"
        case .mountain: "mountain.2.fill"
        case .city: "building.columns.fill"
        }
    }

    var identifier: String {
        switch self {
        case .waterfall: "waterfall"
        case .iceAndCoast: "ice"
        case .geothermal: "geothermal"
        case .mountain: "mountain"
        case .city: "city"
        }
    }
}

struct Attraction: Identifiable, Hashable {
    /// Also the name of the photo in the asset catalog.
    let id: String
    let name: String
    let localName: String
    let region: String
    let category: Category
    let tagline: String
    let summary: String
    let highlights: [String]
    let bestSeason: String
    let duration: String
    let distance: Int
    let rating: Double
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Attraction {
    static let featured: [Attraction] = ["jokulsarlon", "kirkjufell", "skogafoss", "seljalandsfoss"]
        .compactMap { id in all.first { $0.id == id } }

    static let all: [Attraction] = [
        Attraction(
            id: "skogafoss",
            name: "斯科加瀑布",
            localName: "Skógafoss",
            region: "南岸",
            category: .waterfall,
            tagline: "晴天必見雙彩虹的水簾",
            summary: "斯科加瀑布寬 25 公尺、落差 60 公尺，河水從昔日的海岸懸崖筆直落下，形成一道厚實的白色水幕。因為水氣充沛，晴天時幾乎都能看到彩虹，有時甚至是雙彩虹。傳說維京人 Þrasi 把一箱黃金藏在瀑布後方的洞穴裡。",
            highlights: ["沿 527 級階梯登上瀑布頂端觀景台", "從瀑布頂端出發的 Fimmvörðuháls 健行步道", "附近的斯科加民俗博物館"],
            bestSeason: "全年",
            duration: "1–2 小時",
            distance: 155,
            rating: 4.9,
            latitude: 63.5321,
            longitude: -19.5114
        ),
        Attraction(
            id: "seljalandsfoss",
            name: "塞里雅蘭瀑布",
            localName: "Seljalandsfoss",
            region: "南岸",
            category: .waterfall,
            tagline: "可以走到瀑布背後的奇景",
            summary: "塞里雅蘭瀑布從 60 公尺高的懸崖垂落，最特別的是瀑布後方有一條環形小徑，可以從水簾背後欣賞夕陽穿過水霧的景色。步行幾分鐘還能找到藏在峽谷裡的「隱藏瀑布」Gljúfrabúi。",
            highlights: ["走進瀑布後方的環形步道", "夏季午夜陽光穿透水幕", "隔壁峽谷中的秘境瀑布 Gljúfrabúi"],
            bestSeason: "5–9 月",
            duration: "1 小時",
            distance: 125,
            rating: 4.8,
            latitude: 63.6156,
            longitude: -19.9886
        ),
        Attraction(
            id: "gullfoss",
            name: "黃金瀑布",
            localName: "Gullfoss",
            region: "黃金圈",
            category: .waterfall,
            tagline: "兩段式奔流的冰河之水",
            summary: "黃金瀑布是黃金圈最壯觀的一站。源自朗格冰川的 Hvítá 河在此分成兩段落差，總高 32 公尺，衝入 70 公尺深的峽谷。夏季時每秒水量可達 140 立方公尺，陽光下水霧閃耀著金色光芒，因而得名。",
            highlights: ["上下兩層觀景步道", "冬季結冰的瀑布奇景", "紀念守護瀑布的女英雄 Sigríður"],
            bestSeason: "全年",
            duration: "1 小時",
            distance: 115,
            rating: 4.8,
            latitude: 64.3271,
            longitude: -20.1199
        ),
        Attraction(
            id: "jokulsarlon",
            name: "傑古沙龍冰河湖",
            localName: "Jökulsárlón",
            region: "東南部",
            category: .iceAndCoast,
            tagline: "千年冰山緩緩漂向大海",
            summary: "傑古沙龍是冰島最深的湖泊，由瓦特納冰川融化形成。從冰川斷裂的藍色冰山在湖面上緩緩漂流，最後經由短短的河道流入大西洋。湖中常見海豹悠游，是冰島最具代表性的風景之一。",
            highlights: ["搭乘水陸兩用船近距離看冰山", "對面的鑽石沙灘", "湖畔休憩的海豹"],
            bestSeason: "全年",
            duration: "2–3 小時",
            distance: 375,
            rating: 5.0,
            latitude: 64.0784,
            longitude: -16.2306
        ),
        Attraction(
            id: "kirkjufell",
            name: "草帽山",
            localName: "Kirkjufell",
            region: "斯奈山半島",
            category: .mountain,
            tagline: "冰島出鏡率最高的山",
            summary: "草帽山高 463 公尺，獨特的圓錐外型讓它成為冰島最常被拍攝的山峰，也曾出現在《權力遊戲》中。山前的 Kirkjufellsfoss 小瀑布與山形構成經典構圖，冬季夜晚更是拍攝極光的熱門地點。",
            highlights: ["與 Kirkjufellsfoss 瀑布同框的經典角度", "冬季極光攝影", "環斯奈山半島自駕"],
            bestSeason: "全年（冬季看極光）",
            duration: "1 小時",
            distance: 180,
            rating: 4.9,
            latitude: 64.9419,
            longitude: -23.3053
        ),
        Attraction(
            id: "reynisfjara",
            name: "黑沙灘",
            localName: "Reynisfjara",
            region: "南岸",
            category: .iceAndCoast,
            tagline: "玄武岩柱與怒濤的黑色海岸",
            summary: "維克小鎮旁的黑沙灘由火山熔岩冷卻碎裂而成，海灘旁是如管風琴般排列的六角玄武岩柱，海面上矗立著傳說由巨魔化成的 Reynisdrangar 海蝕柱。這裡的「瘋狗浪」非常危險，請務必遠離海水。",
            highlights: ["Hálsanefshellir 玄武岩洞穴", "Reynisdrangar 海蝕柱", "夏季可見海鸚築巢"],
            bestSeason: "全年",
            duration: "1 小時",
            distance: 180,
            rating: 4.8,
            latitude: 63.4044,
            longitude: -19.0447
        ),
        Attraction(
            id: "bluelagoon",
            name: "藍湖溫泉",
            localName: "Bláa lónið",
            region: "雷克雅內斯半島",
            category: .geothermal,
            tagline: "熔岩原中的乳藍色溫泉",
            summary: "藍湖位於黑色熔岩原中，富含矽、藻類與礦物質的地熱海水呈現夢幻的乳藍色，水溫常年維持在 37–39°C。距離凱夫拉維克機場只要 20 分鐘，很適合安排在抵達或離開冰島的那天。",
            highlights: ["白色矽泥面膜", "湖中酒吧的飲品", "Retreat 熔岩洞穴 Spa"],
            bestSeason: "全年",
            duration: "2–4 小時",
            distance: 50,
            rating: 4.6,
            latitude: 63.8804,
            longitude: -22.4495
        ),
        Attraction(
            id: "hallgrimskirkja",
            name: "哈爾格林姆教堂",
            localName: "Hallgrímskirkja",
            region: "雷克雅維克",
            category: .city,
            tagline: "以玄武岩柱為靈感的地標",
            summary: "高 74.5 公尺的哈爾格林姆教堂是雷克雅維克的天際線地標，外型靈感來自冰島常見的玄武岩柱。登上鐘樓可俯瞰整座城市色彩繽紛的屋頂，教堂內的巨型管風琴擁有超過 5,000 根音管。",
            highlights: ["鐘樓頂端的 360° 城市景觀", "5,275 根音管的 Klais 管風琴", "門前的萊夫·艾瑞克森雕像"],
            bestSeason: "全年",
            duration: "1 小時",
            distance: 0,
            rating: 4.7,
            latitude: 64.1417,
            longitude: -21.9266
        ),
        Attraction(
            id: "thingvellir",
            name: "辛格韋德利國家公園",
            localName: "Þingvellir",
            region: "黃金圈",
            category: .mountain,
            tagline: "站在兩大板塊之間",
            summary: "辛格韋德利是聯合國世界遺產，北美板塊與歐亞板塊在這裡每年分離約 2 公分，形成壯觀的裂谷。西元 930 年，世界上最早的議會之一 Alþingi 就在此召開，是冰島歷史與地質的雙重聖地。",
            highlights: ["Almannagjá 大裂谷步道", "在 Silfra 裂縫浮潛兩大板塊之間", "Öxarárfoss 瀑布"],
            bestSeason: "全年",
            duration: "2–3 小時",
            distance: 45,
            rating: 4.7,
            latitude: 64.2559,
            longitude: -21.1299
        ),
        Attraction(
            id: "strokkur",
            name: "史托克間歇泉",
            localName: "Strokkur",
            region: "黃金圈",
            category: .geothermal,
            tagline: "每 10 分鐘噴發一次的地球心跳",
            summary: "史托克是冰島最活躍的間歇泉，每隔 5 到 10 分鐘就會把滾燙的水柱噴向 15 到 20 公尺高的天空，偶爾甚至高達 40 公尺。英文「geyser」一詞就是來自旁邊已較少噴發的大間歇泉 Geysir。",
            highlights: ["噴發前藍色水泡隆起的瞬間", "Haukadalur 地熱區散步", "大間歇泉 Geysir"],
            bestSeason: "全年",
            duration: "1 小時",
            distance: 105,
            rating: 4.7,
            latitude: 64.3127,
            longitude: -20.3022
        ),
        Attraction(
            id: "dettifoss",
            name: "黛提瀑布",
            localName: "Dettifoss",
            region: "北部",
            category: .waterfall,
            tagline: "歐洲水量最大的瀑布",
            summary: "黛提瀑布寬 100 公尺、落差 44 公尺，灰白色的冰河水以每秒數百立方公尺的水量轟然落入 Jökulsárgljúfur 峽谷，被譽為歐洲最具威力的瀑布。電影《普羅米修斯》的開場就在這裡拍攝。",
            highlights: ["震耳欲聾的水聲與水霧", "上游的 Selfoss 瀑布", "Ásbyrgi 馬蹄形峽谷"],
            bestSeason: "6–9 月",
            duration: "1–2 小時",
            distance: 540,
            rating: 4.8,
            latitude: 65.8147,
            longitude: -16.3846
        ),
        Attraction(
            id: "myvatn",
            name: "米湖",
            localName: "Mývatn",
            region: "北部",
            category: .geothermal,
            tagline: "火山地貌的露天博物館",
            summary: "米湖是 2,300 年前火山噴發形成的淺湖，周圍遍布假火山口、熔岩迷宮 Dimmuborgir、冒著硫磺煙的 Hverir 地熱區，以及比藍湖更寧靜的米湖溫泉，是冰島北部最精彩的區域。",
            highlights: ["Hverir 泥漿滾滾的地熱區", "Dimmuborgir 熔岩迷宮", "米湖天然溫泉"],
            bestSeason: "5–9 月",
            duration: "半天–1 天",
            distance: 480,
            rating: 4.7,
            latitude: 65.6039,
            longitude: -16.9961
        ),
        Attraction(
            id: "landmannalaugar",
            name: "蘭德曼勞卡",
            localName: "Landmannalaugar",
            region: "高地",
            category: .mountain,
            tagline: "彩色流紋岩山與野溪溫泉",
            summary: "蘭德曼勞卡位於冰島內陸高地，流紋岩山脈呈現紅、黃、綠、藍等繽紛色彩，宛如畫家的調色盤。這裡也是著名的 Laugavegur 健行步道起點，健行後還能泡在天然野溪溫泉裡。僅在夏季開放 F 路通行。",
            highlights: ["Brennisteinsalda 彩色山健行", "天然野溪溫泉", "Laugavegur 四日健行步道"],
            bestSeason: "6 月底–9 月",
            duration: "1 天",
            distance: 180,
            rating: 4.9,
            latitude: 63.9830,
            longitude: -19.0670
        ),
    ]
}
