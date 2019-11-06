//
//  DetailViewController.swift
//  WeatherAppExtended
//
//  Created by Bartłomiej Zachariasz on 04/11/2019.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    
    var images = [String: UIImage]()
    var imageNames = ["c", "h", "hc", "hr", "lc", "lr", "s", "sl", "sn", "t"]
    var weatherForWeek : [WeatherForDay] = []
    var currentIndex = 0
    
    var maxIndex = 0;

    
    @IBOutlet weak var townLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var rainfallLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    
    func configureView() {
        // Update the user interface for the detail item.
//        if let detail = detailItem {
//            weatherForWeek = weathers![detail.title]!
//
//            townLabel.text = detail.title
//            prevButton.isHidden = true
//            if let label = detailDescriptionLabel {
//                label.text = detail.title
//            }
//            updateView()
//        }
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.title
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initImages()
        townLabel.text = detailItem?.title
        weatherForWeek = weathers![detailItem!.title]!
        currentIndex = 0
        maxIndex = weatherForWeek.count - 1
        prevButton.isHidden = true
        updateView()
        // Do any additional setup after loading the view.
    }

    var detailItem: Location?
    var weathers: [String:[WeatherForDay]]?

    func initImages() {
        for imageName in imageNames {
            images[imageName] = UIImage(named: imageName)
        }
    }
    
    func updateView() {
        let currentDay = weatherForWeek[self.currentIndex]
        dateLabel.text = currentDay.date
        temperatureLabel.text = String(format: "%.0f\u{00B0}C / %.0f\u{00B0}C", currentDay.minTemp, currentDay.maxTemp)
        conditionLabel.text = currentDay.condition
        windLabel.text = String(format: "%.2f ", currentDay.wind) + currentDay.windDirection
        rainfallLabel.text = String(currentDay.humidity)
        pressureLabel.text = String(format: "%.0f", currentDay.pressure)
        weatherImageView.image = images[currentDay.weatherAbbr]
    }
    
    @IBAction func previousDay(_ sender: Any) {
        if currentIndex != 0 {
            currentIndex -= 1
            updateView()
            if currentIndex == 0 {
                prevButton.isHidden = true
            } else if nextButton.isHidden {
                nextButton.isHidden = false
            }
        }
    }
    
    @IBAction func nextDay(_ sender: Any) {
        if currentIndex < maxIndex {
            currentIndex += 1
            updateView()
            if currentIndex == maxIndex {
                nextButton.isHidden = true
            } else if prevButton.isHidden {
                prevButton.isHidden = false
            }
        }
    }
}

