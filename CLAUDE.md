CLAUDE.md

macOS app (Swift, NSDocument) that makes a Maschine controller a hands-on editor for Battery 4, bypassing Maschine software. Virtual MIDI ports in/out; app holds the kit state (16 BatteryCell models) and translates controller CCs to Battery CCs. Written ~2018; currently does not build (legacy CocoaPods).

### Rules

- Controller LED/display feedback is a core feature; preserve it in any refactor.
- MidiCCInterface and BatteryCell encode hand-tuned mappings verified against real hardware. Behavior-preserving changes only; ask first.
- No end-to-end testing without physical hardware + Battery 4. Work in small steps the user can smoke-test; unit-test pure logic.
- Pods/ is committed deliberately as the frozen record of original build inputs. Read-only; don't fix its build errors — it's being removed.
- Battery 4 is unmaintained; treat its MIDI behavior as fixed.