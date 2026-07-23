import Foundation

// MARK: MIDI NOTE CHANGE
extension Engine {
    func midiKeyboardNoteHandler(midiNote: MIDINote){
        do {
            try samplerBroadcaster.play(
                midiNote: midiNote,
                cellIndex: kit.editingCellIndex
            )
        } catch {
            print("ERROR SENDING TO SAMPLER: \(error).")
        }
    }
    func midiNoteHandler(midiNote: MIDINote){
        let isNoteOn = midiNote.velocity > 0 && midiNote.isNoteOn
        guard let cellIndex = midiNote.cellIndex
            else {
                // print("No cell index.")
                return
        }
        if isNoteOn {
            if kit.setEditingCellIndex(cellIndex) {
                updateController()
            }
        }
        guard kit.isPlayable(cellIndex: cellIndex)
            else {
                // print("CAN NOT PLAY")
                return
        }
        let pitch = kit.sampleCellData(cellIndex: cellIndex).sampleData.pitch
        let newMidiNote = MIDINote(
            noteNumber: pitch.noteNumber,
            velocity: midiNote.velocity, isNoteOn: isNoteOn
        )
        do {
            try samplerBroadcaster.play(
                midiNote: newMidiNote,
                cellIndex: cellIndex
            )
        } catch {
            print("ERROR SENDING TO SAMPLER: \(error).")
        }
    }
}
