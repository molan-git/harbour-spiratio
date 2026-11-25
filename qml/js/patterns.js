.pragma library

/*
 * A pattern is: { id, name, tag, benefit, phases: [ {t: "in"|"hold"|"out", s: seconds} ] }
 * "hold" keeps the volume flat, "in" rises, "out" falls.
 * The physiological sigh uses two consecutive "in" phases (double inhale).
 */
var patterns = [
    /* ── Stimulating ── */

    { id: "morning", name: "Morning Breathing", tag: "6-0-2-0", benefit: "Morning activation",
      phases: [ {t:"in", s:6}, {t:"out", s:2} ] },

    /* ── Acute / Focus ── */

    { id: "box", name: "Box Breathing", tag: "4-4-4-4", benefit: "Focus under pressure",
      phases: [ {t:"in", s:4}, {t:"hold", s:4}, {t:"out", s:4}, {t:"hold", s:4} ] },

    { id: "sigh", name: "Physiological Sigh", tag: "2-0-6-0", benefit: "Instant stress relief",
      phases: [ {t:"in", s:2}, {t:"out", s:6} ] },

    { id: "quickcalm", name: "Quick Calm", tag: "3-3-3-0", benefit: "Acute calming",
      phases: [ {t:"in", s:3}, {t:"hold", s:3}, {t:"out", s:3} ] },

    /* ── Balance / Steady ── */

    { id: "coherent", name: "Coherent Breathing", tag: "5-0-5-0", benefit: "HRV, daily balance",
      phases: [ {t:"in", s:5}, {t:"out", s:5} ] },

    { id: "triangle", name: "Triangle Breathing", tag: "4-0-4-0", benefit: "Simple grounding",
      phases: [ {t:"in", s:4}, {t:"out", s:4} ] },

    { id: "samavritti", name: "Sama Vritti", tag: "7-0-7-0", benefit: "Relaxation, slow heart rate",
      phases: [ {t:"in", s:7}, {t:"out", s:7} ] },

    /* ── Calm / Deep ── */

    { id: "weil", name: "Weil Hybrid", tag: "4-7-8-0", benefit: "Sleep, deep calm",
      phases: [ {t:"in", s:4}, {t:"hold", s:7}, {t:"out", s:8} ] },

    { id: "extendedexhale", name: "Extended Exhale", tag: "4-0-8-0", benefit: "Quick calming",
      phases: [ {t:"in", s:4}, {t:"out", s:8} ] },

    { id: "bhramari", name: "Bhramari", tag: "4-0-8-0", benefit: "Vagal tone, lower pulse",
      phases: [ {t:"in", s:4}, {t:"out", s:8} ] },
];
function tagFromPhases(phases) {
    var parts = []
    for (var i = 0; i < phases.length; i++) parts.push(phases[i].s)
    return parts.join("-")
}
