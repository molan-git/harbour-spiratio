.pragma library

function trName(id) {
    switch (id) {
    case "awake":      return qsTr("Awake")
    case "sigh":       return qsTr("Physiological Sigh")
    case "box":        return qsTr("Box Breathing")
    case "resonance":  return qsTr("Resonance Breathing")
    case "samavritti": return qsTr("Sama Vritti")
    case "nadi":       return qsTr("Alternate Nostril")
    case "ujjayi":     return qsTr("Ujjayi")
    case "478":        return qsTr("4-7-8 Breathing")
    case "deepcalm":   return qsTr("Deep Calm")
    case "pranayama":  return qsTr("Pranayama")
    case "pursed":     return qsTr("Pursed-Lip Breathing")
    default:           return ""
    }
}

function trBenefit(id) {
    switch (id) {
    case "awake":      return qsTr("Energy, alertness")
    case "sigh":       return qsTr("Fastest stress relief")
    case "box":        return qsTr("Focus, acute stress")
    case "resonance":  return qsTr("HRV, emotional balance")
    case "samavritti": return qsTr("Steady baseline, pranayama")
    case "nadi":       return qsTr("Balance, meditation")
    case "ujjayi":     return qsTr("Vagal tone, baroreflex")
    case "478":        return qsTr("Sleep, wind-down")
    case "deepcalm":   return qsTr("Parasympathetic, anxiety")
    case "pranayama":  return qsTr("HRV, cardiorespiratory")
    case "pursed":     return qsTr("Breathlessness, COPD")
    default:           return qsTr("Custom")
    }
}
