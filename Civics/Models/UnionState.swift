enum UnionState: String, CaseIterable {
  case ak = "Alaska"
  case al = "Alabama"
  case ar = "Arkansas"
  case az = "Arizona"
  case ca = "California"
  case co = "Colorado"
  case ct = "Connecticut"
  case de = "Delaware"
  case fl = "Florida"
  case ga = "Georgia"
  case hi = "Hawaii"
  case ia = "Iowa"
  case id = "Idaho"
  case il = "Illinois"
  case `in` = "Indiana"
  case ks = "Kansas"
  case ky = "Kentucky"
  case la = "Louisiana"
  case ma = "Massachusetts"
  case md = "Maryland"
  case me = "Maine"
  case mi = "Michigan"
  case mn = "Minnesota"
  case mo = "Missouri"
  case ms = "Mississippi"
  case mt = "Montana"
  case nc = "North Carolina"
  case nd = "North Dakota"
  case ne = "Nebraska"
  case nh = "New Hampshire"
  case nj = "New Jersey"
  case nm = "New Mexico"
  case nv = "Nevada"
  case ny = "New York"
  case oh = "Ohio"
  case ok = "Oklahoma"
  case or = "Oregon"
  case pa = "Pennsylvania"
  case ri = "Rhode Island"
  case sc = "South Carolina"
  case sd = "South Dakota"
  case tn = "Tennessee"
  case tx = "Texas"
  case ut = "Utah"
  case va = "Virginia"
  case vt = "Vermont"
  case wa = "Washington"
  case wi = "Wisconsin"
  case wv = "West Virginia"
  case wy = "Wyoming"

  var code: String {
    String(describing: self).uppercased()
  }
}

extension UnionState {
  var capital: String {
    switch self {
    case .ak: return "Juneau"
    case .al: return "Montgomery"
    case .ar: return "Little Rock"
    case .az: return "Phoenix"
    case .ca: return "Sacramento"
    case .co: return "Denver"
    case .ct: return "Hartford"
    case .de: return "Dover"
    case .fl: return "Tallahassee"
    case .ga: return "Atlanta"
    case .hi: return "Honolulu"
    case .ia: return "Des Moines"
    case .id: return "Boise"
    case .il: return "Springfield"
    case .in: return "Indianapolis"
    case .ks: return "Topeka"
    case .ky: return "Frankfort"
    case .la: return "Baton Rouge"
    case .ma: return "Boston"
    case .md: return "Annapolis"
    case .me: return "Augusta"
    case .mi: return "Lansing"
    case .mn: return "Saint Paul"
    case .mo: return "Jefferson City"
    case .ms: return "Jackson"
    case .mt: return "Helena"
    case .nc: return "Raleigh"
    case .nd: return "Bismarck"
    case .ne: return "Lincoln"
    case .nh: return "Concord"
    case .nj: return "Trenton"
    case .nm: return "Santa Fe"
    case .nv: return "Carson City"
    case .ny: return "Albany"
    case .oh: return "Columbus"
    case .ok: return "Oklahoma City"
    case .or: return "Salem"
    case .pa: return "Harrisburg"
    case .ri: return "Providence"
    case .sc: return "Columbia"
    case .sd: return "Pierre"
    case .tn: return "Nashville"
    case .tx: return "Austin"
    case .ut: return "Salt Lake City"
    case .va: return "Richmond"
    case .vt: return "Montpelier"
    case .wa: return "Olympia"
    case .wi: return "Madison"
    case .wv: return "Charleston"
    case .wy: return "Cheyenne"
    }
  }
}

extension UnionState {
  init(validating input: String) throws {
    guard let state = UnionState(rawValue: input) else {
      throw UnionStateError.invalidInput("Invalid input: \(input)")
    }
    self = state
  }
}

enum UnionStateError: Error {
  case invalidInput(String)
}
