# Undo Manager & Threading — Deferred Design Note

Status: **deferred.** This documents a known limitation and the design work required
to resolve it, so we can pick it up later without re-deriving the analysis. Nothing
here is urgent — the app works correctly as-is.

## Current state

The engine uses a **standalone `UndoManager`** owned by `Document` (`engineUndoManager`,
see the note in `Document.swift`) rather than the document's own `self.undoManager`.
`UndoCoordinator` drives it with manual, cross-event grouping (`groupsByEvent = false`),
which lets a continuous knob sweep on one parameter collapse into a single undo step.
This has been tested and behaves as designed.

The tradeoff of the standalone manager: edits do **not** mark the `NSDocument` dirty
(no unsaved-changes prompt), and `Cmd-Z` / the Edit menu are not wired to it. Both are
consumer-app conveniences we can live without for this tool.

## The challenge

Adopting the document's own undo manager (`self.undoManager`) would give us the dirty
prompt and standard Edit-menu / `Cmd-Z` undo for free. The blocker is threading.

All MIDI arrives through a single CoreMIDI input port (`MIDI.swift`,
`MIDIInputPortCreateWithBlock`), and CoreMIDI invokes that callback on one dedicated
MIDI thread. Notes *and* CC therefore flow through the same thread, so **all `Kit`
access currently happens on exactly one thread** — it is race-free by construction, and
that is why the current design works without locks.

The document's undo manager, however, is bound to the main thread: registering an undo
marks the document dirty, which touches window/AppKit state, and that must happen on
the main thread. Registering undo off-main currently crashes
(`NSInternalInconsistencyException: NSWindow geometry should only be modified on the
main thread`), and running `NSUndoManager` off its home thread also makes grouping
behavior undefined.

Critically, **undo/redo mutate `Kit`** (they re-apply previous parameter values). If
undo/redo must run on the main thread while note-on continues to run on the CoreMIDI
thread, then `Kit` is suddenly accessed from two threads. There is no arrangement that
adopts the document manager *and* keeps notes off-main without making `Kit` itself
thread-safe.

## Latency constraint

Note-on (pad performance) is latency- and jitter-sensitive and should **stay off the
main thread**. A `DispatchQueue.main.async` hop is ~0.1–0.5 ms when main is idle, which
is fine for knob edits, but when main is mid-redraw the hop stretches unpredictably —
audible as jitter on pads. Knob edits tolerate this; pads do not.

## Candidate solution

1. **Make `Kit` the synchronization point** — an internal lock serializing every read
   and write. Uncontended lock acquisition is nanosecond-scale and adds no thread hop,
   so pad latency is effectively unchanged.
2. **Route the CC/edit path and undo/redo through the main thread**, where the document
   undo manager and dirty-marking live. This is where the (acceptable, subtle) knob-edit
   latency lands.
3. **Keep note-on playback on the CoreMIDI thread** — zero added latency, now safe
   because `Kit` is locked.

A secondary consequence to handle: once the document manager is live, `Cmd-Z` / the Edit
menu call `undoManager.undo()` directly, bypassing `UndoCoordinator.undo()` — so its
`close()` and `rerender()` never run and the coordinator's group state goes stale. The
fix is to observe `.NSUndoManagerDidUndoChange` / `.NSUndoManagerDidRedoChange` and drive
`rerender()` + group reset from there, so both the controller undo button and `Cmd-Z`
funnel through the same refresh.

## Consequences / open questions

- **Scope:** this is a non-trivial change (thread-safe `Kit`, main-thread edit routing,
  Edit-menu integration) for a benefit that is a convenience, not a requirement.
- **Worth exploring later:** how reliable the main-thread hop latency actually is in
  practice vs. the cost/complexity of the internal lock. That empirical comparison is
  the interesting part of the problem.
- **Also worth confirming when we revisit:** concurrent MIDI *output* from two threads
  (note handler and edit handler both calling `updateController()` / broadcasters) may
  need its own attention once notes and edits live on different threads.

## Decision

Deferred. Keep the standalone `engineUndoManager`. Revisit if the dirty-save prompt or
standard `Cmd-Z` becomes worth the threading work.
