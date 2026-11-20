.pragma library

/*
 * A pattern is: { id, name, tag, benefit, phases: [ {t: "in"|"hold"|"out", s: seconds} ] }
 * "hold" keeps the volume flat, "in" rises, "out" falls.
 * The physiological sigh uses two consecutive "in" phases (double inhale).
 */
var patterns = [
    /* ── Stimulating ── */

    { id: "awake", name: "Awake", tag: "6-0-2-0", benefit: "Energizing",
      phases: [ {t:"in", s:6}, {t:"out", s:2} ] },

    /* ── Acute / Focus ── */

    { id: "sigh", name: "Physiological Sigh", tag: "2+1-6-0", benefit: "Stress relief",
      phases: [ {t:"in", s:2}, {t:"in", s:1}, {t:"out", s:6} ] },

    { id: "box", name: "Box Breathing", tag: "4-4-4-4", benefit: "Focus, calm, stress control",
      phases: [ {t:"in", s:4}, {t:"hold", s:4}, {t:"out", s:4}, {t:"hold", s:4} ] },

    /* ── Balance / Steady ── */

    { id: "resonance", name: "Resonance Breathing", tag: "5-0-5-0", benefit: "HRV optimisation, daily calm",
      phases: [ {t:"in", s:5}, {t:"out", s:5} ] },

    { id: "samavritti", name: "Sama Vritti", tag: "4-0-4-0", benefit: "Steady baseline, pranayama",
      phases: [ {t:"in", s:4}, {t:"out", s:4} ] },

    { id: "ujjayi", name: "Ujjayi", tag: "7-0-7-0", benefit: "Vagal tone, baroreflex",
      phases: [ {t:"in", s:7}, {t:"out", s:7} ] },

    /* ── Calm / Deep ── */

    { id: "478", name: "Deep Calm", tag: "4-7-8-0", benefit: "Sleep, wind-down",
      phases: [ {t:"in", s:4}, {t:"hold", s:7}, {t:"out", s:8} ] },

    { id: "pranayama", name: "Pranayama", tag: "7-4-8-4", benefit: "HRV, cardiorespiratory",
      phases: [ {t:"in", s:7}, {t:"hold", s:4}, {t:"out", s:8}, {t:"hold", s:4} ] },

    /* ── Clinical ── */

    { id: "pursed", name: "Pursed-Lip Breathing", tag: "2-0-4-0", benefit: "Breathlessness, COPD",
      phases: [ {t:"in", s:2}, {t:"out", s:4} ] }
];

function tagFromPhases(phases) {
    var parts = []
    for (var i = 0; i < phases.length; i++) parts.push(phases[i].s)
    return parts.join("-")
}
