//
//  PlayerViewController.swift
//  Music
//
//  Created by praveen on 5/26/17.
//  Copyright © 2017 com.praveen.praveen. All rights reserved.
//

import UIKit
import MediaPlayer

class PlayerViewController: UIViewController,MPMediaPickerControllerDelegate {
    let player = MPMusicPlayerController.systemMusicPlayer()
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var songtitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var songAlbumTitle: UILabel!
    @IBOutlet weak var playerCurrentTime: UILabel!
    @IBOutlet weak var sliderVolume: UISlider!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    var time:TimeInterval?
    var timer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // if app killed and opened check whether playing still playing
        if player.playbackState == MPMusicPlaybackState.playing {
            self.updateUI()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initalization()
    }
    
    //Initalization MPMusicPlayerController
    
    func initalization() {
        //Init
        let mediaItems = MPMediaQuery.songs().items
        let query = MPMediaQuery.songs()
        let predicateByGenre = MPMediaPropertyPredicate(value: "", forProperty: MPMediaItemPropertyGenre)
        query.filterPredicates = NSSet(object: predicateByGenre) as? Set<MPMediaPredicate>
        let mediaCollection = MPMediaItemCollection(items: mediaItems!)
        print(mediaCollection);
        print(mediaItems ?? 0);
        player.setQueue(with: mediaCollection)
        
        
        player.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.songChanged), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
        
        let frame =  self.sliderVolume.frame
        let view1 = MPVolumeView.init(frame:frame)
        self.view.addSubview(view1)
    }
    
    //Upadte UI when Forword songs and song Changed
    
    func updateUI()  {
        self.songtitle.text =  player.nowPlayingItem?.title ?? ""
        timeLabel.text = self.stringFromTimeInterval(interval:(player.nowPlayingItem?.playbackDuration)!) as String
        slider.value = Float(player.currentPlaybackTime);
        slider.minimumValue = 0;
        slider.maximumValue = player.nowPlayingItem?.value(forProperty: MPMediaItemPropertyPlaybackDuration) as! Float
      timer =  Timer.scheduledTimer(timeInterval:1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true);
    }
    
    //UIAction Start Playing and Stop Playing
    
    @IBAction func didTapOnPlayBtn(_ sender: Any) {
        
        if player.playbackState == MPMusicPlaybackState.playing {
            player.pause()
            playButton.isSelected = false
            playButton.isEnabled = true
        }else if player.playbackState == MPMusicPlaybackState.paused {
            player.play()
            playButton.isSelected = false
            playButton.isSelected = true
        }else if player.playbackState == MPMusicPlaybackState.stopped {
            player.play()
            playButton.isSelected = false
            playButton.isSelected = true
        }
       self.updateUI()
        
    }
    
    //NotificationCenter didChanged Next Song
    
    func songChanged() {
        self.updateUI()
    }
    
    //IBAction Change Next Song
    
    @IBAction func didTapOnNextBtn(_ sender: Any) {
        player.skipToNextItem()
        playButton.isSelected = false
        playButton.isSelected = true
        self.updateUI()
    }
    
    //IBAction Change Previous Song
    
    @IBAction func didTapOnPreviousBtn(_ sender: Any) {
        player.skipToPreviousItem()
        playButton.isSelected = false
        playButton.isSelected = true
        self.updateUI()
    }
    
    // Did change Slider beginSeekingForward or beginSeekingBackward
 
    @IBAction func didChangeSliderValue(_ sender: Any) {
        if(slider.isTracking){
            timer = nil
            return
        }
        player.currentPlaybackTime = TimeInterval(slider.value);
        timer =  Timer.scheduledTimer(timeInterval:1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true);
    }
    
    
    // Update player slider every One sec using timer
    
    func updateSlider(){
        if timer == nil{
            return;
        }
        
        if player.playbackState == MPMusicPlaybackState.playing{
            slider.value = Float(player.currentPlaybackTime);
            playerCurrentTime.text = self.stringFromTimeInterval(interval: player.currentPlaybackTime) as String
        }
    }
   
    // Calculate song duration HH:MM:SS
    
    func stringFromTimeInterval(interval: TimeInterval) -> NSString {
        
        let ti = NSInteger(interval)
        let ms = Int((interval.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        if (hours == 0){
            return NSString(format: "%0.2d:%0.2d",minutes,seconds)
        }
        return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
 
}
