//
//  BatteryCellParameterTests.swift
//  NI MIDI InterfaceTests
//
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import XCTest
@testable import NI_MIDI_Interface

/// Guards `BatteryCell.parameters(of:)`, the one parameter list the compiler can
/// not check for completeness.
class BatteryCellParameterTests: XCTestCase {

    private func makeCell(data: SampleCellData) -> BatteryCell {
        return BatteryCell(
            sampleCellData: data
        )
    }

    /// If `parameters(of:)` omits a case, that field is never written and keeps
    /// its non-default value, so this fails.
    func testDefaultParametersResetEveryParameter() {
        let cell = makeCell(data: .everyParameterChanged)

        _ = cell.apply(BatteryCell.defaultParameters)

        XCTAssertEqual(cell.sampleCellData, .default)
    }

    /// The reverse direction: a full batch must carry every parameter across, so
    /// `allParameters` is a complete copy of the cell.
    func testAllParametersCarryEveryParameter() {
        let source = makeCell(data: .everyParameterChanged)
        let target = makeCell(data: .default)

        _ = target.apply(source.allParameters)

        XCTAssertEqual(target.sampleCellData, source.sampleCellData)
    }

    /// The fixture is itself hand maintained, so prove it actually differs from
    /// the default everywhere before trusting the two tests above. A field left
    /// at its default would silently stop guarding its parameter.
    func testFixtureDiffersFromDefaultInEveryParameter() {
        let changed = SampleCellData.everyParameterChanged
        let `default` = SampleCellData.default

        // Both arrays come from the same function, so they are in the same order.
        for (changed, unchanged) in zip(
            BatteryCell.parameters(of: changed),
            BatteryCell.parameters(of: `default`)
        ) {
            XCTAssertNotEqual(
                String(describing: changed),
                String(describing: unchanged),
                "Fixture leaves this parameter at its default, so it guards nothing."
            )
        }
    }
}

// MARK: FIXTURE
extension SampleCellData {

    /// Every parameter set to a value that differs from `default`.
    ///
    /// `tune` and `stateData` stay at their defaults on purpose – neither is a
    /// `BatteryCell.Parameter`, so `apply` can not write them and including them
    /// here would break the round trip.
    static var everyParameterChanged: SampleCellData {
        let property = SampleCellPropertyData(
            start1: 0.11,
            start2: 0.12,
            volume: 0.13,
            pan: 0.14,
            speed: Speed(course: 0.15, fine: 0.16),
            filterLow: 0.17,
            filterHigh: 0.18,
            transientAttack: 0.19,
            transientSustain: 0.21,
            enableTransientMaster: true,
            tune: SampleCellPropertyData.default.tune,
            fineTune: 0.22,
            reverbSend: 0.23,
            delaySend: 0.24,
            velocity: 0.25,
            envOrder: 0.26,
            formant: 0.27,
            loopStart: 0.28,
            loopStartFine: 0.29,
            loopLength: 0.31,
            loopLengthFine: 0.32
        )
        let ampEnvelope = SampleCellAmpEnvelopeData(
            attack: 0.41,
            hold: 0.42,
            decay: 0.43,
            sustain: 0.44,
            release: 0.45,
            enableAttackEnvelope: false
        )
        let loFi = SampleCellLoFiData(
            bits: 0.51,
            hertz: 0.52,
            noise: 0.53,
            color: 0.54,
            out: 0.55,
            enable: true
        )
        let sample = SampleCellSampleData(
            pitch: Pitch(noteNumber: 48)
        )
        return SampleCellData(
            propertyData: property,
            ampEnvelopeData: ampEnvelope,
            loFiData: loFi,
            sampleData: sample,
            stateData: SampleCellStateData.default
        )
    }
}
