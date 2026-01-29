import * as Tone from 'tone';

export class SoundManager {
    constructor() {
        this.isInitialized = false;
        this.currentState = -1;

        // 1. Master Output (Limiter/Reverb)
        this.reverb = new Tone.Reverb({
            decay: 8,
            wet: 0.4 // Moderate reverb to keep sound distinct
        }).toDestination();

        this.limiter = new Tone.Limiter(-1).connect(this.reverb);

        // 2. The Drone (Base Layer)
        // Triangle wave for warmth and harmonics
        this.droneL = new Tone.Oscillator(110, "triangle").connect(this.limiter); // A2 (Audible Range)
        this.droneR = new Tone.Oscillator(111, "triangle").connect(this.limiter); // Slight detune

        // Start silent, ramp up in initialize
        this.droneL.volume.value = -Infinity;
        this.droneR.volume.value = -Infinity;

        // Filter for the drone
        this.droneFilter = new Tone.Filter(200, "lowpass").connect(this.limiter);
        this.droneL.connect(this.droneFilter);
        this.droneR.connect(this.droneFilter);

        this.droneL.connect(this.droneFilter);
        this.droneR.connect(this.droneFilter);

        // 3. The Ocean (Noise Layer) - "Liquid Texture"
        // Brown noise is deep and rumbling like distant surf
        this.oceanNoise = new Tone.Noise("brown").connect(this.reverb);
        this.oceanNoise.volume.value = -Infinity;

        // Lowpass Filter for the ocean (Simulating underwater vs surface)
        this.oceanFilter = new Tone.Filter(200, "lowpass").connect(this.reverb);
        this.oceanNoise.disconnect().connect(this.oceanFilter);

        // Ocean Panner (Slow drift left/right)
        this.oceanPanner = new Tone.Panner(0).connect(this.reverb);
        this.oceanFilter.connect(this.oceanPanner);

        // 4. The Harmonics (State Chords)
        this.synth = new Tone.PolySynth(Tone.Synth, {
            oscillator: { type: "triangle" },
            envelope: {
                attack: 2,
                decay: 2,
                sustain: 0.5,
                release: 3
            }
        }).connect(this.reverb);

        this.synth.volume.value = -20;

        // Chords Mappings
        this.chords = {
            0: ["C3", "E3", "G3", "B3"],     // Essence
            1: ["A2", "E3", "A3", "C4"],     // Pure
            2: ["F3", "A3", "C4", "E4"],     // Uplifting
            3: ["D3", "F3", "A3", "C4"],     // Universal
            4: ["G2", "D3", "G3", "B3"],     // Vital
            5: ["C3", "Eb3", "G3", "Bb3"],   // Deep Heal
        };
    }

    async initialize() {
        if (this.isInitialized) return;

        await Tone.start();
        console.log("Audio Engine Started 🎵");

        this.droneL.start();
        this.droneR.start();

        this.droneL.volume.rampTo(-20, 1);
        this.droneR.volume.rampTo(-20, 1);

        this.oceanNoise.start();
        this.oceanNoise.volume.rampTo(-15, 2); // Fade in ocean

        this.isInitialized = true;
    }

    update(breath, stateIndex) {
        if (!this.isInitialized) return;

        // --- A. Drone Modulation ---
        // Volume: Louder on Hold. Range: -25db to -15db
        const targetVol = -25 + (breath * 10);
        this.droneL.volume.rampTo(targetVol, 0.1);
        this.droneR.volume.rampTo(targetVol, 0.1);

        // Filter: Opens on Hold. Range: 100Hz -> 300Hz
        const targetFreq = 100 + (breath * 200);
        this.droneFilter.frequency.rampTo(targetFreq, 0.1);

        // --- B. Ocean Tide ---
        // Inhale: Ocean rises (Louder, Brighter)
        // Hold: High Tide
        // Exhale: Recedes (Quieter, Muffled)

        // Volume: -25db (Low Tide) to -12db (High Tide)
        const oceanVol = -25 + (breath * 13);
        this.oceanNoise.volume.rampTo(oceanVol, 0.2);

        // Filter: 100Hz (Underwater) to 600Hz (Surface crash)
        const oceanFreq = 100 + (breath * 500);
        this.oceanFilter.frequency.rampTo(oceanFreq, 0.2);

        // Pan: Gentle drift based on time (simple sine lfo simulation)
        // using breath as a makeshift LFO guide for now to save CPU
        this.oceanPanner.pan.rampTo(Math.sin(Tone.now() * 0.2), 0.1);

        // --- C. State Harmonics ---
        if (this.currentState !== stateIndex) {
            this.currentState = stateIndex;
            this.playStateChord(stateIndex);
        }
    }

    playStateChord(stateIndex) {
        this.synth.releaseAll();
        const notes = this.chords[stateIndex] || this.chords[0];
        this.synth.triggerAttack(notes);
    }
}
