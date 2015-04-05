//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Paul Bruno on 3/25/15.
//  Copyright (c) 2015 Emergent Ink. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class PlaySoundsViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer!
    var echoAudioPlayer: AVAudioPlayer!
    var audioEngine: AVAudioEngine!
    var receivedAudio: RecordedAudio!
    var audioFile: AVAudioFile!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        
        // This is the second audioPlayer for the echo effect
        echoAudioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playFastAudio(sender: UIButton) {
        playAudioWithVariableRate(2.0)
    }

    @IBAction func playSlowAudio(sender: UIButton) {
        playAudioWithVariableRate(0.5)
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playSithLordAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func playEchoAudio(sender: UIButton) {
        stopAndResetAudio()
        audioPlayer.play()
        
        // Now set up and start the echo effect
        let delay: NSTimeInterval = 1.0 // this is 1 second
        var echoPlayTime = echoAudioPlayer.deviceCurrentTime + delay
        echoAudioPlayer.volume = 0.8
        echoAudioPlayer.playAtTime(echoPlayTime)
    }
    
    @IBAction func playReverbAudio(sender: UIButton) {
        stopAndResetAudio()
        
        // Make a player node and attach it to the audio engine
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // Set up the reverb effect and attach it to the audio engine
        var reverb = AVAudioUnitReverb()
        reverb.wetDryMix = 0.75
        reverb.loadFactoryPreset(AVAudioUnitReverbPreset.Cathedral)
        audioEngine.attachNode(reverb)
        
        // Add some delay and attach it to the audio engine
        var delay = AVAudioUnitDelay()
        delay.delayTime = 0.25
        delay.feedback = 0.8
        audioEngine.attachNode(delay)
        
        // Connect player node to delay, delay to reverb, reverb to output
        audioEngine.connect(audioPlayerNode, to: delay, format: nil)
        audioEngine.connect(delay, to: reverb, format: nil)
        audioEngine.connect(reverb, to: audioEngine.outputNode, format: nil)
        
        // Add the file to the player node, start the engine, and start the player
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        stopAndResetAudio()
    }
    
    func stopAndResetAudio() {
        // not all of this needs to be stopped or reset after every effect
        // but doing this in one place makes it easier to fix
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        audioPlayer.currentTime = 0.0
        
        // reset the rate (may have been changed by the last effect)
        audioPlayer.rate = 1.0
        
        // stopping and resetting echoAudioPlayer in case it was the last effect
        echoAudioPlayer.stop()
        echoAudioPlayer.currentTime = 0.0
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        stopAndResetAudio()
        
        // Make a player node and attach it to the audio engine
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // Make a time unit pitch object and attach it to the audio engine
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        // Connect player node to pitch, pitch to output
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        // Add the file to the player node, start the engine, and start the player
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
    
    func playAudioWithVariableRate(rate: Float) {
        // Make sure nothing is playing
        stopAndResetAudio()
        
        // Set the rate
        audioPlayer.rate = rate
        
        // Play the audio
        audioPlayer.play()
    }
    
}
