//
//  SoundViewController.swift
//  FloresEnaoSoundBar1
//
//  Created by Flores Enao Eduardo Andre on 13/05/24.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var volumenSlider: UISlider!
    @IBOutlet weak var tiempoGrabacionLabel: UILabel!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var timer:Timer?
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio?.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            timer?.invalidate() // Detener el temporizador cuando se detiene la grabación
            tiempoGrabacionLabel.text = "0.00" // Reiniciar el label de duración
        }else {
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
            startTimer() // Iniciar el temporizador cuando comienza la grabación
        }
    }
    @IBAction func reproducirTapped(_ sender: Any) {
    do{
        try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
        reproducirAudio?.play()
        reproducirAudio?.volume = volumenSlider.value
        startTimer() 
        print("Reproduciendo")
    }catch{}
    }
        
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        grabacion.duracion = grabarAudio?.currentTime ?? 0
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func volumenSliderChanged(_ sender: Any) {
        reproducirAudio?.volume = (sender as AnyObject).value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuracionGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
    }
    
    func configuracionGrabacion(){
        do{
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath,"audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            print("*********************")
            print(audioURL!)
            print("*********************")
            
            
            
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio?.prepareToRecord()
        }catch let error as NSError{
            print(error)
        }
    }
    
    
    func startTimer() {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if let currentTime = self.grabarAudio?.currentTime {
                    self.tiempoGrabacionLabel.text = String(format: "%.2f", currentTime)
                }
            }
        }
        
//    @objc func updateRecordingTime() {
//        if let tiempo = grabarAudio?.currentTime {
//            tiempoGrabacionLabel.text = String(format: "%.2f", tiempo)
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
