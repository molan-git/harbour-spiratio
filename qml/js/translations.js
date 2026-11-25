function trName(id) {
    switch (id) {
    case "morning":         return qsTr("Morning Breathing")
    case "box":             return qsTr("Box Breathing")
    case "sigh":            return qsTr("Physiological Sigh")
    case "quickcalm":       return qsTr("Quick Calm")
    case "coherent":        return qsTr("Coherent Breathing")
    case "triangle":        return qsTr("Triangle Breathing")
    case "samavritti":      return qsTr("Sama Vritti")
    case "weil":            return qsTr("Weil Hybrid")
    case "extendedexhale":  return qsTr("Extended Exhale")
    case "bhramari":        return qsTr("Bhramari")
    default:                return ""
    }
}

function trBenefit(id) {
    switch (id) {
    case "morning":         return qsTr("Morning activation")
    case "box":             return qsTr("Focus under pressure")
    case "sigh":            return qsTr("Instant stress relief")
    case "quickcalm":       return qsTr("Acute calming")
    case "coherent":        return qsTr("HRV, daily balance")
    case "triangle":        return qsTr("Simple grounding")
    case "samavritti":      return qsTr("Relaxation, slow heart rate")
    case "weil":            return qsTr("Sleep, deep calm")
    case "extendedexhale":  return qsTr("Quick calming")
    case "bhramari":        return qsTr("Vagal tone, lower pulse")
    default:                return qsTr("Custom")
    }
}
