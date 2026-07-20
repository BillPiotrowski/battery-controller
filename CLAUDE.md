
macOS app (Swift, NSDocument) that makes a Maschine controller a hands-on editor for Battery 4, bypassing Maschine software. Virtual MIDI ports in/out; app holds the kit state (16 BatteryCell models) and translates controller CCs to Battery CCs.

This project began ~2020 and originally used CocoaPods architecture. ReactiveSwift has been migrated to be managed as a package. `MIKMIDI` still exists as a Pod and is baked in to the repo.

The goal is to allow for full control of Battery 4 from the source controller and provide a classic sampler user experience. The only limitation is the actual sample selection which must be done from Battery.

## Process

Any device can be used as input, but this was built specifically with Maschine Studio in mind, in MIDI Controller mode with CC mapped using Native Instruments Controller Editor.

`Battery Instrument.nbkt`: a Battery 4 template file with proper MIDI mappings.
`Maschine Studio Config.ncc`: a Controller Editor config file for Maschine mappings.

The graphical UI has 3 choices for MIDI inputs / outputs:
- `Controller Source`: the input that will be interpretted to control Battery 4
- `To Controller`: the optional output back to the controller. This is used so the MIDI controller can update state.
- `To Sampler`: the output to Battery.

MIDI CC inputs will come from the source MIDI control surface – usually all from the same channel. Then will be processed and stored by the middleware file, and converted to CC controls for Battery. Each cell in Battery is given its own channel (1-16). The input and output CC mappings are not necessarily the same integer parameters.

## Sync

There are two contracts:
- input CC -> middleware
- middleware -> output CC

Because of this, each contract needs to be kept in sync.


## Kit Files

Each new kit will need to save a copy of the `Battery Instrument.nbkt` with the desired samples. Ideally, each kit will be a repository where the middleware file is stored alongside the Battery 4 `.nbkt` file and possibly the samples depending on if they are baked in. Otherwise, it should save a manifest of the audio files.


## Notes
- Battery 4 is unmaintained.