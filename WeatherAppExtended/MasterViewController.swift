//
//  MasterViewController.swift
//  WeatherAppExtended
//
//  Created by Bartłomiej Zachariasz on 04/11/2019.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Location]()
    var weathers = [String:[WeatherForDay]]()
    
    let urlSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    var urlComponents : URLComponents?
    var images = [String: UIImage]()
    var imageNames = ["c", "h", "hc", "hr", "lc", "lr", "s", "sl", "sn", "t"]
    
    func initImages() {
        for imageName in imageNames {
            images[imageName] = UIImage(named: imageName)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        urlComponents = URLComponents()
        urlComponents!.scheme = "https"
        urlComponents!.host = "www.metaweather.com"
        
        initImages()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem
        objects.append(Location(title: "Warsaw", woeid: 523920))
        
        for location in objects {
            getWeatherData(title: location.title, woeid: location.woeid)
        }
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        performSegue(withIdentifier: "searchSegue", sender: nil)
//        objects.insert(NSDate(), at: 0)
//        let indexPath = IndexPath(row: 0, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.weathers = weathers
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let location = objects[indexPath.row]
        cell.textLabel!.text = location.title
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func getWeatherData(title: String, woeid : Int) {
        
        urlComponents!.path = "/api/location/\(woeid)/"
        dataTask?.cancel()
        guard let url = urlComponents?.url else {
            return
        }
        print(url)
        dataTask =
          urlSession.dataTask(with: url) { [weak self] data, response, error in
          defer {
            self?.dataTask = nil
          }
          if let error = error {
            print(error)
          } else if
            let data = data,
            let response = response as? HTTPURLResponse,
            response.statusCode == 200 {
            let weatherForWeek = self?.parseWeatherData(data)
            DispatchQueue.main.async {
                self?.updateTableView(title: title, weatherForWeek: weatherForWeek!)
            }
          }
        }
        dataTask?.resume()
        
    }
    
    func updateTableView(title: String, weatherForWeek: [WeatherForDay]) {
        print("DUPA")
        weathers[title] = weatherForWeek
        for cell in tableView.visibleCells {
            print(weatherForWeek[0].condition)
            cell.imageView?.image = images[weatherForWeek[0].weatherAbbr]
            cell.detailTextLabel?.text = weatherForWeek[0].condition
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    func parseWeatherData(_ data : Data?) -> [WeatherForDay]{
        var weatherForWeek = [WeatherForDay]()
        if let data = data {
            do {
                // make sure this JSON is in the format we expect
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let consolidatedWeather = json["consolidated_weather"] as? [[String: Any]] {
                        for weather in consolidatedWeather {
                            let weatherForDay = createWeatherDay(weather)
                            weatherForWeek.append(weatherForDay)
                        }
                    }
                }
            } catch let error as NSError {
                print("Failed to download data. Error: \(error.code)")
            }
        }
        return weatherForWeek
    }
    
    func createWeatherDay(_ weather: [String: Any]) -> WeatherForDay {
        return WeatherForDay(date: weather["applicable_date"] as! String,
            minTemp: weather["min_temp"] as! Double,
            maxTemp: weather["max_temp"] as! Double,
            wind: weather["wind_speed"] as! Double,
            windDirection: weather["wind_direction_compass"] as! String,
            condition: weather["weather_state_name"] as! String,
            pressure: weather["air_pressure"] as! Double,
            humidity: weather["humidity"] as! Int,
            weatherAbbr: weather["weather_state_abbr"] as! String)
    }
}

