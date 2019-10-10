import AudioKitPlaygrounds
import AudioKit
let oscillatorNode = AKOperationGenerator { _ in
    // Let's set up the volume to be changing in the shape of a sine wave
    let volume = AKOperation.sineWave(frequency: 0.2).scale(minimum: 0, maximum: 0.5)

    // And lets make the frequency move around to make sure it doesn't affect the amplitude tracking
    let frequency = AKOperation.jitter(amplitude: 200, minimumFrequency: 10, maximumFrequency: 30) + 200

    // So our oscillator will move around randomly in frequency and have a smoothly varying amplitude
    return AKOperation.sineWave(frequency: frequency, amplitude: volume)
}

let trackedAmplitude = AKAmplitudeTracker(oscillatorNode)
AudioKit.output = trackedAmplitude
try AudioKit.start()
oscillatorNode.start()
