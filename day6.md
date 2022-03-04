# Experiment 06 - ReIgnition ideas

Discussed our Sound <-> Visual link.

On the Sound side we have VCVRack & BitWig, both are likely to output MIDI.

On the visual side I (currently) have a web frontend accepting strings as ID+VALUE

---

New plan is to change the light stack from using wifi (cons: latency, bandwith)
for a controller (on a computer) + serial (<5 ms updates, >50 updates per seconds).

The controller could technically be a website? but I think it's going to be easier as a python program.

Controller Goals:

 * Map MIDI channels (e.g. 18, 16) to effect types ("bass blink", "color shift")
 * Control "amount" of effect for each channel
 * Control Color more organically

Music Pattern Ideas

  * Ripples: add glitter for high hat, color shift for kick, attentuate or shift left right for bass
  * Rainbow: shift direction for each note, rotate for kick, color change on bass
  * Meteor Shower / Tinkle: Trigger (probabilstically on note)
  * More beatsin8 patterns

Setup ideas:

  * On the legs of a popup tent: They don't touch (unless I also do eves for 8x blades)
  * On the eves of a popup tent: Good visibility? touching?

Code ideas for Lights

  * Post Effects
    * addGlitter / addShimmer(amount)
    * reverse
    * rotate
    * swap strip (display strip 1 on output 2)
  * Non-Markov Post Effects:
    * Reverb: Mix "Current" * x + New * (1-x))
    * Shutter: updated 1/X LED e.g. evens then odds
    * Glitter: Add confetti or simmer
    * Ripple: duh
  * Try out shifting forward frames (or running a small number without drawing)
  * Beat based effects
    * Do COLLIDER without colliding
    * Use beat8 / beat16 + threshold to make several walking patterns
      * Then shift scew their timebase / phase_offset with beatsin8
      * Set Color with beatsin8(speed, 0, 255, 0, beatsin(3 * speed / 16))

