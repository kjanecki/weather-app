//
//  SearchViewController.swift
//  WeatherAppExtended
//
//  Created by Bartłomiej Zachariasz on 04/11/2019.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var urlComponents : URLComponents?
    let urlSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    var locations: [Location] = [Location]()
    
    @IBOutlet weak var searchOutlet: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        cell.textLabel!.text = locations[indexPath.row].title
        return cell
    }
    
    @IBAction func beginSearch(_ sender: Any) {
        urlComponents!.queryItems = [URLQueryItem(name: "query", value: searchOutlet.text)]
        print("beginSearch: " + searchOutlet.text!)
        getLocationData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlComponents = URLComponents()
        urlComponents!.scheme = "https"
        urlComponents!.host = "www.metaweather.com"
        urlComponents!.path = "/api/location/search/"
        
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func getLocationData() {
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
            print("Hello")
            self?.parseLocationData(data)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
          }
        }
        dataTask?.resume()
    }
    
    func parseLocationData(_ data : Data?) {
        locations.removeAll()
        if let data = data {
            do {
                // make sure this JSON is in the format we expect
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]] {
                    for location in jsonArray {
                        locations.append(Location(title: location["title"] as! String, woeid: location["woeid"] as! Int))
                    }
                }
            } catch let error as NSError {
                print("Failed to download data. Error: \(error.code)")
            }
        }
    }


}
