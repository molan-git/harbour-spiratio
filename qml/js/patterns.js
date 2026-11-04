.pragma library

/*
 * A pattern is: { id, name, tag, benefit, phases: [ {t: "in"|"hold"|"out", s: seconds} ] }
 * "hold" keeps the volume flat, "in" rises, "out" falls.
 * The physiological sigh uses two consecutive "in" phases (double inhale).
 */
var patterns = [
    { id: "box", name: "Box Breathing", tag: "4-4-4-4", benefit: "Focus, acute stress",
      phases: [ {t:"in", s:4}, {t:"hold", s:4}, {t:"out", s:4}, {t:"hold", s:4} ] },

    { id: "478", name: "4-7-8 Breathing", tag: "4-7-8", benefit: "Sleep, wind-down",
      phases: [ {t:"in", s:4}, {t:"hold", s:7}, {t:"out", s:8} ] },

    { id: "resonance", name: "Resonance Breathing", tag: "5-5", benefit: "HRV, emotional balance",
      phases: [ {t:"in", s:5}, {t:"out", s:5} ] },

    { id: "sigh", name: "Physiological Sigh", tag: "2+1-6", benefit: "Fastest stress relief",
      phases: [ {t:"in", s:2}, {t:"in", s:1}, {t:"out", s:6} ] },

    { id: "pursed", name: "Pursed-Lip Breathing", tag: "2-4", benefit: "Breathlessness, COPD",
      phases: [ {t:"in", s:2}, {t:"out", s:4} ] },

    { id: "nadi", name: "Alternate Nostril", tag: "4-4-4-4", benefit: "Balance, meditation",
      phases: [ {t:"in", s:4}, {t:"hold", s:4}, {t:"out", s:4}, {t:"hold", s:4} ] },

    { id: "samavritti", name: "Sama Vritti", tag: "4-4", benefit: "Steady baseline, pranayama",
      phases: [ {t:"in", s:4}, {t:"out", s:4} ] }
];

function tagFromPhases(phases) {
    var parts = []
    for (var i = 0; i < phases.length; i++) parts.push(phases[i].s)
    return parts.join("-")
}