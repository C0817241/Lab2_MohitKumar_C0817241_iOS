//
//  ViewController.swift
//  Lab2_MohitKumar_C0817241_iOS
//
//  Created by Mohit Kumar on 24/01/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var lblResult: UILabel!
    var initialState = [0,0,0,0,0,0,0,0,0]
    var gf = true
    var player = 1
    @IBOutlet weak var crossResult: UILabel!
    @IBOutlet weak var circleResult: UILabel!
    let combinations_to_win = [[0,1,2],[3,4,5],[6,7,8],[0,4,8],[2,4,6],[0,3,6],[1,4,7],[2,5,8]]
    
    
    var shake_state = 0
    var sf = false
    var count = 1
    var cross_win_count = 0
    var circle_win_count = 0
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let newGame = NSEntityDescription.insertNewObject(forEntityName: "Mohit", into: context)
        
        let hasLaunchedKey = "HasLaunched"
        let defaults = UserDefaults.standard
        let hasLaunched = defaults.bool(forKey: hasLaunchedKey)
        if !hasLaunched {
            newGame.setValue(cross_win_count, forKey: "scoreX")
            newGame.setValue(circle_win_count, forKey: "scoreO")
            newGame.setValue(player, forKey: "lastTurnTag")
            newGame.setValue("0,0,0,0,0,0,0,0", forKey: "gameState")
            
            saveCoreData()
            defaults.set(true, forKey: hasLaunchedKey)
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Mohit")
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let gameState = result.value(forKey: "gameState") {
                        let gamePState = gameState as! String
                        print(gamePState)
                    }
                    if let scoreX = result.value(forKey: "scoreX") {
                        let scorex = scoreX as! Int
                        print(scorex)
                        cross_win_count = scorex
                        crossResult.text = "\(cross_win_count)";
                    }
                    if let scoreO = result.value(forKey: "scoreO") {
                        let score0 = scoreO as! Int
                        print(score0)
                        circle_win_count = score0
                        circleResult.text = "\(circle_win_count)";
                    }
                    if let lastTurnTag = result.value(forKey: "lastTurnTag") {
                        let lastPlayer = lastTurnTag as! Int
                        print(lastPlayer)
                        player = lastPlayer
                    }
                }
            }
        } catch {
            print(error)
        }
        
        
        lblResult.isHidden = true
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(swipeRight)
        
    }
    
    func saveCoreData() {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    
    @objc func swiped(gesture: UISwipeGestureRecognizer) {
        let swipeGesture = gesture as UISwipeGestureRecognizer
        switch swipeGesture.direction {
        case UISwipeGestureRecognizer.Direction.left:
            lblResult.isHidden = true
            resetBoard()
        case UISwipeGestureRecognizer.Direction.right:
            lblResult.isHidden = true
            resetBoard()
        default:
            break
        }
    }
    
    

    
    @IBAction func btnPressed(_ sender: AnyObject) {
        print("Ongoing game")
        sf = true
        lblResult.isHidden = true
        shake_state = sender.tag
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Mohit")
        
               if initialState[sender.tag-1] == 0 && gf == true {
            initialState[sender.tag-1] = player
            if player == 1 {
                sender.setImage(UIImage(named: "cross.png"), for: UIControl.State())
                player = 2
            } else {
                sender.setImage(UIImage(named: "circle.png"), for: UIControl.State())
                player = 1
            }
        }
        print(initialState)
        
        for combination in combinations_to_win {
            if initialState[combination[0]] != 0 && initialState[combination[0]] == initialState[combination[1]] && initialState[combination[1]] == initialState[combination[2]] {
                if initialState[combination[0]] == 1 {
                    cross_win_count += 1;
                    crossResult.text = "\(cross_win_count)";
                    lblResult.text = "Cross win!"
                } else if initialState[combination[0]] == 2{
                    circle_win_count += 1;
                    circleResult.text = "\(circle_win_count)";
                    lblResult.text = "Circle win!"
                }
                
                        
                
                print("Game over")
                gf = false
                lblResult.isHidden = false
                resetBoard()
            }

            
            if gf == true {
                count = 1
                for i in initialState {
                    count = i*count
                }

                if count != 0 {
                    print("Game over")
                    lblResult.text = "Draw!"
                    lblResult.isHidden = false
                    resetBoard()
                }
            }
            
            do {
                let results = try context.fetch(request)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        result.setValue(cross_win_count, forKey: "scoreX")
                        result.setValue(circle_win_count, forKey: "scoreO")
                        result.setValue(player, forKey: "lastTurnTag")
                        let currentState = (initialState.map{String($0)}).joined(separator: ",")
                        result.setValue(currentState, forKey: "gameState")
                    }
                }
            } catch {
                print(error)
            }
            
            saveCoreData()
            
        }
    }
    
    
    func resetBoard() {
        initialState = [0,0,0,0,0,0,0,0,0]
        gf = true
        player = 1
        
        for i in 1...9 {
            let button = view.viewWithTag(i) as! UIButton
            button.setImage(nil, for: UIControl.State())
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEvent.EventSubtype.motionShake {
            if sf {
                let button = view.viewWithTag(shake_state) as! UIButton
                button.setImage(nil, for: UIControl.State())
                initialState[shake_state-1] = 0
                if player == 1 {
                    player = 2
                } else {
                    player = 1
                }
                sf = false
            }
        }
    }
        
   
}


