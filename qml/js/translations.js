function trName(id) {
    switch (id) {
    case "awake":      return qsTr("Awake")
    case "sigh":       return qsTr("Physiological Sigh")
    case "box":        return qsTr("Box Breathing")
    case "resonance":  return qsTr("Resonance Breathing")
    case "samavritti": return qsTr("Sama Vritti")
    case "ujjayi":     return qsTr("Ujjayi")
    case "478":        return qsTr("Deep Calm")
    case "pranayama":  return qsTr("Pranayama")
    case "pursed":     return qsTr("Pursed-Lip Breathing")
    default:           return ""
    }
}

function trBenefit(id) {
    switch (id) {
    case "awake":      return qsTr("Energizing")
    case "sigh":       return qsTr("Stress relief")
    case "box":        return qsTr("Focus, calm, stress control")
    case "resonance":  return qsTr("HRV optimisation, daily calm")
    case "samavritti": return qsTr("Steady baseline, pranayama")
    case "ujjayi":     return qsTr("Vagal tone, baroreflex")
    case "478":        return qsTr("Sleep, wind-down")
    case "pranayama":  return qsTr("HRV, cardiorespiratory")
    case "pursed":     return qsTr("Breathlessness, COPD")
    default:           return qsTr("Custom")
    }
}
