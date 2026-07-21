


// MARK: SET
extension BatteryCell {

    enum Parameter {
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
    }

}

// MARK: ENUMERATE
extension BatteryCell {

    /// Every parameter of `data`, as a batch `apply` can write.
    ///
    /// This is the one parameter list the compiler can not check. `apply`, `getChange` and `samplerCCs` are exhaustive switches – omit a case and they will not build. This is an array literal, so an omission compiles and silently drops that parameter from full sync, reset and copy, permanently. `BatteryCellParameterTests` guards it.
    ///
    /// `tune` and `stateData` are deliberately absent: coarse tune is never used – only `fineTune` – and mute / solo / lock are performance state rather than parameters.
    static func parameters(of data: SampleCellData) -> [Parameter] {
        let property = data.propertyData
        let ampEnvelope = data.ampEnvelopeData
        let loFi = data.loFiData
        let sample = data.sampleData

        return [
            // Property
            .start1(property.start1),
            .start2(property.start2),
            .volume(property.volume),
            .pan(property.pan),
            .speedCoarse(property.speed.course),
            .speedFine(property.speed.fine),
            .filterLow(property.filterLow),
            .filterHigh(property.filterHigh),
            .transientAttack(property.transientAttack),
            .transientSustain(property.transientSustain),
            .enableTransientMaster(property.enableTransientMaster),
            .fineTune(property.fineTune),
            .reverbSend(property.reverbSend),
            .delaySend(property.delaySend),
            .velocity(property.velocity),
            .envOrder(property.envOrder),
            .formant(property.formant),
            .loopStart(property.loopStart),
            .loopStartFine(property.loopStartFine),
            .loopLength(property.loopLength),
            .loopLengthFine(property.loopLengthFine),

            // Amp Envelope
            .attack(ampEnvelope.attack),
            .hold(ampEnvelope.hold),
            .decay(ampEnvelope.decay),
            .sustain(ampEnvelope.sustain),
            .release(ampEnvelope.release),
            .enableAmpEnvelope(ampEnvelope.enableAmpEnv),

            // Lo-Fi
            .lofiBits(loFi.bits),
            .lofiHertz(loFi.hertz),
            .lofiNoise(loFi.noise),
            .lofiColor(loFi.color),
            .lofiOut(loFi.out),
            .enableLofi(loFi.enable),

            // Sample
            .pitch(sample.pitch)
        ]
    }

    /// The cell's current state as a batch. Full sync and copy.
    var allParameters: [Parameter] {
        return BatteryCell.parameters(of: sampleCellData)
    }

    /// A batch that returns any cell to its default state. Reset.
    static var defaultParameters: [Parameter] {
        return parameters(of: .default)
    }
}
