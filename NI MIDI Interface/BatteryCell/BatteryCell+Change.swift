


// MARK: SET
extension BatteryCell {

    enum Change {
        // MARK: Property
        case start1(Double)
        case start2(Double)
        case volume(Double)
        case pan(Double)
        case speedCoarse(Double)
        case speedFine(Double)
        case filterLow(Double)
        case filterHigh(Double)
        case transientAttack(Double)
        case transientSustain(Double)
        case enableTransientMaster(Bool)
        case fineTune(Double)
        case reverbSend(Double)
        case delaySend(Double)
        case velocity(Double)
        case envOrder(Double)
        case formant(Double)
        case loopStart(Double)
        case loopStartFine(Double)
        case loopLength(Double)
        case loopLengthFine(Double)

        // MARK: Amp Envelope
        case attack(Double)
        case hold(Double)
        case decay(Double)
        case sustain(Double)
        case release(Double)
        case enableAmpEnvelope(Bool)

        // MARK: Lo-Fi
        case lofiBits(Double)
        case lofiHertz(Double)
        case lofiNoise(Double)
        case lofiColor(Double)
        case lofiOut(Double)
        case enableLofi(Bool)

        // MARK: Sample
        case pitch(Pitch)

        // MARK: State
        case mute(Bool)
        case solo(Bool)
        case lock(Bool)
    }

}
