import CoreMIDI
import Foundation

class MIDIRouter: ObservableObject {
    private var client = MIDIClientRef()
    private var inputPort = MIDIPortRef()
    private var outputPort: MIDIPortRef = 0
    private var inputSource: MIDIEndpointRef?
    private var outputDestination: MIDIEndpointRef?
    private var returnDestination: MIDIEndpointRef?
    var batteryController: BatteryController?
    private var midiClient = MIDIClientRef()
    
    func setup(batteryController: BatteryController){
        self.batteryController = batteryController
    }

    @Published var inputs: [Int32: MidiEndpoint] = [:]
    @Published var outputs: [Int32: MidiEndpoint] = [:]

    init() {
        MIDIClientCreate("MIDI Router" as CFString, nil, nil, &client)
        MIDIInputPortCreate(client, "Input Port" as CFString, midiReadCallback, Unmanaged.passUnretained(self).toOpaque(), &inputPort)
        MIDIOutputPortCreate(client, "Output Port" as CFString, &outputPort)
        refreshDevices()
        
        MIDIClientCreateWithBlock("MIDI Client" as CFString, &midiClient) { [weak self] notification in
            self?.handleMIDINotification(notification)
        }
    }
    
    private func handleMIDINotification(_ notification: UnsafePointer<MIDINotification>) {
        let messageID = notification.pointee.messageID

        switch messageID {
        case .msgObjectAdded, .msgObjectRemoved, .msgSetupChanged:
            print("MIDI device list changed.")
            DispatchQueue.main.async {
                self.refreshDevices()
            }
        default:
            break
        }
    }

    func refreshDevices() {
        inputs.removeAll()
        outputs.removeAll()
        for i in 0..<MIDIGetNumberOfSources() {
            let endpoint = MIDIGetSource(i)
            var uniqueID: MIDIUniqueID = 0
            if MIDIObjectGetIntegerProperty(endpoint, kMIDIPropertyUniqueID, &uniqueID) != noErr {
                continue
            }
            inputs[uniqueID] = MidiEndpoint(id: uniqueID, name: getMIDIName(endpoint), endpoint: endpoint)
        }

        for i in 0..<MIDIGetNumberOfDestinations() {
            let endpoint = MIDIGetDestination(i)
            var uniqueID: MIDIUniqueID = 0
            if MIDIObjectGetIntegerProperty(endpoint, kMIDIPropertyUniqueID, &uniqueID) != noErr {
                continue
            }
            outputs[uniqueID] = MidiEndpoint(id: uniqueID, name: getMIDIName(endpoint), endpoint: endpoint)
        }
    }

    // May want to change this to accept an id instead of endpoint. Then store here?
    // Currently using view to store state, which feels wrong.
    func selectInput(_ endpoint: MIDIEndpointRef) {
        if let inputSource = self.inputSource {
            MIDIPortDisconnectSource(inputPort, inputSource)
        }

        self.inputSource = endpoint
        MIDIPortConnectSource(inputPort, endpoint, nil)
    }
    
    func selectOutput(_ endpoint: MIDIEndpointRef) {
        self.outputDestination = endpoint
    }
    
    func selectReturnOutput(_ endpoint: MIDIEndpointRef) {
        self.returnDestination = endpoint
    }

    private func getMIDIName(_ obj: MIDIObjectRef) -> String {
        var name: Unmanaged<CFString>?
        MIDIObjectGetStringProperty(obj, kMIDIPropertyName, &name)
        return name?.takeRetainedValue() as String? ?? "Unknown"
    }

    func handle(packetList: UnsafePointer<MIDIPacketList>) {
        let previousChannelIndex = self.batteryController?.currentChannelIndex ?? 0
        let midiEvents = parseMIDIPacketList(packetList)
        let responseEvents = midiEvents.count > 0 ? self.batteryController?.getReturnPackets(events: midiEvents, startingChannelIndex: previousChannelIndex) ?? nil : nil
        
        if let dest = outputDestination {
            
            var newPacketList = MIDIPacketList()
            withUnsafeMutablePointer(to: &newPacketList) { packetListPtr in
                var packet = MIDIPacketListInit(packetListPtr)
                for event in midiEvents {
                    let bytes = event.midiBytes
                    packet = MIDIPacketListAdd(packetListPtr, 1024, packet, 0, bytes.count, bytes)
                }
                MIDISend(outputPort, dest, packetListPtr)
            }
        }
        
        
        if  let responseEvents = responseEvents,
            responseEvents.count > 0,
            let dest = returnDestination
        {
            var newPacketList = MIDIPacketList()
            withUnsafeMutablePointer(to: &newPacketList) { packetListPtr in
                var packet = MIDIPacketListInit(packetListPtr)
                for event in responseEvents {
                    let bytes = event.midiBytes
                    packet = MIDIPacketListAdd(packetListPtr, 1024, packet, 0, bytes.count, bytes)
                }
                MIDISend(outputPort, dest, packetListPtr)
            }
        }
        
        
    }
    
    static func getMidiEventsFromPacket(
        _ packet: MIDIPacket
    ) -> MidiEvent? {
        let bytes = Mirror(reflecting: packet.data).children
            .prefix(Int(packet.length))
            .compactMap { $0.value as? UInt8 }

        if let status = bytes.first {
            let type = status & 0xF0
            let channel = status & 0x0F
            
            switch type {
            case MidiNoteOffEvent.statusByte:
                return MidiNoteOffEvent(
                    noteNumber: bytes[1],
                    velocity: bytes[2],
                    channel: channel
                )
            case MidiNoteOnEvent.statusByte:
                let velocity = bytes[2]
                if velocity == 0 {
                    return MidiNoteOffEvent(noteNumber: bytes[1], velocity: 0, channel: channel)
                }
                return MidiNoteOnEvent(
                    noteNumber: bytes[1],
                    velocity: bytes[2],
                    channel: channel
                )
            case MidiControlChangeEvent.statusByte:
                return MidiControlChangeEvent(
                    controllerNumber: bytes[1],
                    value: bytes[2],
                    channel: channel
                )
            case 0xC0:
                break
            case 0xE0:
                break;
//                let lsb = Int(bytes[1])
//                let msb = Int(bytes[2])
//                let pitch = (msb << 7) | lsb
            default:
                break;
            }
        }
        return nil
    }
    
    
    func parseMIDIPacketList(_ packetList: UnsafePointer<MIDIPacketList>) -> [MidiEvent] {
        var processedEvents: [MidiEvent] = []
        var packet = packetList.pointee.packet
        for _ in 0..<packetList.pointee.numPackets {
            if let midiEvent = Self.getMidiEventsFromPacket(packet){
                if let e = self.batteryController?.processMidiEvent(midiEvent){
                    processedEvents.append(e)
                }
            }
            packet = MIDIPacketNext(&packet).pointee
        }
        return processedEvents
    }
}

private let midiReadCallback: MIDIReadProc = { packetList, refCon, _ in
    let router = Unmanaged<MIDIRouter>.fromOpaque(refCon!).takeUnretainedValue()
    router.handle(packetList: packetList)
}
