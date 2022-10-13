//
//  HomeController.swift
//  Demo
//
//  Created by JJ on 07/10/22.
//

import UIKit
import Charts
import HealthKit
import CoreLocation
import Kingfisher

let cellHeight = 114.0
var imageBaseUrl = String()

class HomeController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var lblTotalUserSteps: UILabel!
    @IBOutlet weak var viewUserProgressBar: CircularProgressBar!
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var constraintTblListHeight: NSLayoutConstraint!
    
    // MARK: - Variables
    var currentCount = 9832
    var arrChartData : [UserActivity] = [UserActivity]()
    private let healthStore = HKHealthStore()
    private let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    var arrStaticGymData : [Gym] = [Gym]()
    var pageNumber = 1
    let locationManager = CLLocationManager()
    var myLocation : CLLocation? = nil
    
    // MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getHealthKitPermission()
        setUpProgressBar()
        setUpTableView()
        getGym(page: pageNumber) { arrGym, error in
            DispatchQueue.main.async {
                if let error = error {
                    print(error.localizedDescription)
                }else {
                    if self.pageNumber == 1 {
                        self.arrStaticGymData.removeAll()
                    }
                    for gym in arrGym ?? [Gym]() {
                        self.arrStaticGymData.append(gym)
                    }
                    self.constraintTblListHeight.constant = CGFloat(Double(self.arrStaticGymData.count) * cellHeight)
                    self.tblList.reloadData()
                }
            }
        }
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

    }

    // MARK: - Create Progess Bar
    func setUpProgressBar() {
        
        lblTotalUserSteps.text = "\(currentCount)"
        
        let progress = Double(currentCount) / 12000
        
        viewUserProgressBar.safePercent = 100
        viewUserProgressBar.lineColor = UIColor(red: 251/255, green: 208/255, blue: 108/255, alpha: 1.0)
        viewUserProgressBar.lineBackgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)
        viewUserProgressBar.setProgress(to: progress, withAnimation: true)
    }
    
    // MARK: - setUpTableView
    func setUpTableView() {
        tblList.register(UINib(nibName: "HomeCell", bundle: nil), forCellReuseIdentifier: "HomeCell")
        
        tblList.dataSource = self
        tblList.delegate = self
    }
    
    // MARK: - API Call
    func getGym(page: Int,completion: @escaping ([Gym]?,Error?) -> Void) {
        let urlReq = URLRequest(url: URL(string: "http://65.20.69.210:4000/api/v1/gym?limit=10&page=\(page)")!)
        URLSession.shared.perform(urlReq, decode: GymResponse.self) { result in
            switch result {
            case .success(let objGymresponse):
                imageBaseUrl = objGymresponse.imageBaseURL ?? ""
                completion(objGymresponse.data, nil)
            case .failure(let error):
                completion([Gym](),error)
            }
        }
    }
    
    // MARK: - Create Graph
    func createGraph(){
        var lineChartEntry  = [ChartDataEntry]()
        
        arrChartData = arrChartData.reversed()
        
        for i in 0..<arrChartData.count {
            let value = ChartDataEntry(x: Double(i), y: arrChartData[i].steps)
            lineChartEntry.append(value)
        }

        let line1 = LineChartDataSet(entries: lineChartEntry, label: "Steps")
        line1.highlightLineWidth = 0
        line1.mode = .linear// Change mode as per requirement - Jatin
        line1.circleRadius = 4.5
        line1.circleColors = [NSUIColor.white.withAlphaComponent(0.8)]
        line1.circleHoleRadius = 4.0
        line1.circleHoleColor = NSUIColor.init(red: 0.145, green: 0.55, blue: 0.955, alpha: 1)
        line1.lineWidth = 4.0
        line1.colors = [NSUIColor.init(red: 217/255, green: 206/255, blue: 95/255, alpha: 1.0)]
        let data = LineChartData()
        data.append(line1)
        
        lineChart.backgroundColor = .white
        
        lineChart.leftAxis.axisMinimum = 0
        
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.drawGridLinesBehindDataEnabled = false
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.xAxis.drawAxisLineEnabled = false
        lineChart.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(index, _) in
            return self.formattedDateFromString(dateString: "\(self.arrChartData[Int(index)].date)", inputFormat: "yyyy-MM-dd hh:mm:ss Z", outputFormat: "EEE") ?? "Mon"
        })
        
//        var yAxisMaxValue = 23532 //get the min and max values from your data
//        var yAxisMinValue = -7633 //get the min and max values from your data
//
//        let roundedYAxisMaxValue = roundUp(Double(yAxisMaxValue), to: 2)
//        let roundedYAxisMinValue = roundUp(Double(yAxisMinValue), to: 2)
//        let strideValue = max(abs(roundedYAxisMaxValue), abs(roundedYAxisMinValue)) / 3.0 //max 3 axis marks above and max 3 below
//        AxisMarks(values: .stride(by: strideValue)) {
//            let value = $0.as(Double.self)!
//            AxisGridLine()
//            AxisTick()
//            AxisValueLabel {
//                Text("\(self.abbreviateAxisValue(string: "\(value)"))")
//            }
//        }
        
//        let leftAxisFormatter = NumberFormatter()
//        leftAxisFormatter.minimumFractionDigits = 0
//        leftAxisFormatter.maximumFractionDigits = 0
//        leftAxisFormatter.negativeSuffix = " K"
//        leftAxisFormatter.positiveSuffix = " K"
        
        lineChart.leftAxis.gridLineWidth = 0.2
        lineChart.leftAxis.drawGridLinesBehindDataEnabled = false
        lineChart.leftAxis.drawAxisLineEnabled = false
//        lineChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
       
        
        lineChart.rightAxis.drawGridLinesBehindDataEnabled = false
        lineChart.rightAxis.drawGridLinesEnabled = false
        lineChart.rightAxis.drawLabelsEnabled = false
        lineChart.rightAxis.drawAxisLineEnabled = false
        
        lineChart.data = data
        
        setUpProgressBar()
    }
    
    // MARK: - Healthkit Permission
    func getHealthKitPermission() {
        guard HKHealthStore.isHealthDataAvailable() else {
            if self.arrChartData.isEmpty {
                print("Staic Data")
                for i in 1...7 {
                    let n = Int.random(in: 10000...99999)
                    self.arrChartData.append(UserActivity(steps: Double(n), date: Calendar.current.date(byAdding: .day, value: -i, to: Date())!))
                }
            }
            self.createGraph()
            return
        }
        
        self.healthStore.requestAuthorization(toShare: [], read: [stepsQuantityType]) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    print("Permission accept.")
                    self.fetchStepsHistory()
                }
                else {
                    if error != nil {
                        print(error ?? "")
                    }
                    print("Permission denied.")
                    if self.arrChartData.isEmpty {
                        print("Staic Data")
                        for i in 1...7 {
                            let n = Int.random(in: 10000...99999)
                            self.arrChartData.append(UserActivity(steps: Double(n), date: Calendar.current.date(byAdding: .day, value: -i, to: Date())!))
                        }
                    }
                    self.createGraph()
                }
                
            }
        }
    }
    
    // MARK: - Fetch Step Count From HealthKit
    func fetchStepsHistory() {
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: now)!

        var interval = DateComponents()
        interval.day = 1

        var anchorComponents = Calendar.current.dateComponents([.day, .month, .year], from: now)
        anchorComponents.hour = 0
        let anchorDate = Calendar.current.date(from: anchorComponents)!

        let query = HKStatisticsCollectionQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: nil,
            options: [.cumulativeSum],
            anchorDate: anchorDate,
            intervalComponents: interval
        )
        query.initialResultsHandler = { _, results, error in
            guard let results = results else {
                print("Error returned form resultHandler = \(String(describing: error?.localizedDescription))")
                return
            }
        
            results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let steps = sum.doubleValue(for: HKUnit.count())
                    print("Amount of steps: \(steps), date: \(statistics.startDate)")
                    self.arrChartData.append(UserActivity(steps: steps, date: statistics.startDate))
                    self.currentCount += Int(steps)
                }
            }
            self.createGraph()
        }
        healthStore.execute(query)
    }
    
    // MARK: - Date To String Conversion
    func formattedDateFromString(dateString: String, inputFormat: String, outputFormat: String) -> String? {

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputFormat

        if let date = inputFormatter.date(from: dateString) {

            let outputFormatter = DateFormatter()
          outputFormatter.dateFormat = outputFormat

            return outputFormatter.string(from: date)
        }
        return nil
    }
    
    // MARK: - Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        myLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
    }
}

// MARK: - UITableView DataSource & Delegate
extension HomeController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.arrStaticGymData.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeCell = tableView.dequeueReusableCell(withIdentifier: "HomeCell") as! HomeCell
        if let imgGym = arrStaticGymData[indexPath.row].label, imgGym != "" {
            let url = URL(string: imageBaseUrl + imgGym)
            cell.imgMain.kf.setImage(with: url)
        }else {
            cell.imgMain.image = UIImage(named: "A")!
        }
        cell.lblGymName.text = arrStaticGymData[indexPath.row].name ?? ""
        if let imgLogo = arrStaticGymData[indexPath.row].logo, imgLogo != "" {
            let url = URL(string: imageBaseUrl + imgLogo)
            cell.imgGymLogo.kf.setImage(with: url)
        }else {
            cell.imgGymLogo.image = UIImage(named: "C")!
        }
        var address = String()
        if let add = arrStaticGymData[indexPath.row].address{
            address.append(add)
        }
        if let city = arrStaticGymData[indexPath.row].city{
            address.append(",")
            address.append(city)
        }
        if let state = arrStaticGymData[indexPath.row].state{
            address.append(",")
            address.append(state)
        }
        if let country = arrStaticGymData[indexPath.row].country{
            address.append(",")
            address.append(country)
        }
        cell.lblGymAddress.text = address
        
        //let gymCoordinate = CLLocation(latitude: 37.905834, longitude: -122.826417) // Static Right lat long
        let gymCoordinate = CLLocation(latitude: arrStaticGymData[indexPath.row].lat ?? 0.0, longitude: arrStaticGymData[indexPath.row].long ?? 0.0)
        if myLocation != nil {
            let distanceInMeters = myLocation?.distance(from: gymCoordinate) ?? 0.0
            
            if(distanceInMeters < 1000)
            {
                // under 1 Km
                cell.lblGymDistance.text = "\(Float(distanceInMeters)) m"
            }
            else
            {
                // out of 1 Km
                cell.lblGymDistance.text = "\(Float(distanceInMeters/1000)) Km"
            }
        }else {
            cell.lblGymDistance.text = "#NA"
        }
        
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        guard let gymDetailVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GymDetailController") as? GymDetailController else { return }
        gymDetailVc.objGym = arrStaticGymData[indexPath.row]
        self.navigationController?.pushViewController(gymDetailVc, animated: true)
    }
}

// MARK: - UserActivity Model
struct UserActivity {
    let steps : Double
    let date : Date
}

//// MARK: - Gym Model
//struct Gym {
//    let img : UIImage
//    let name : String
//    let logo : UIImage
//    let address : String
//    let distance : String
//}


// MARK: - GymResponse
struct GymResponse: Codable {
    let code: Int?
    let status, message: String?
    let data: [Gym]?
    let imageBaseURL: String?
    let page, limit, totalRecords: Int?
}

// MARK: - Gym
struct Gym: Codable {
    let id: Int?
    let name, gymType, city, state: String?
    let country, address: String?
    let lat, long: Double?
    let amenities, createdOn, modifiedOn, imageType: String?
    let label, type, logo: String?

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case gymType = "GymType"
        case city = "City"
        case state = "State"
        case country = "Country"
        case address = "Address"
        case lat = "Lat"
        case long = "Long"
        case amenities = "Amenities"
        case createdOn = "CreatedOn"
        case modifiedOn = "ModifiedOn"
        case imageType = "ImageType"
        case label = "Label"
        case type = "Type"
        case logo = "Logo"
    }
}

extension URLSession {
    func perform<T: Decodable>(_ request: URLRequest,
                               decode decodable: T.Type,
                               result: @escaping (Result<T, Error>) -> Void) {
        let decoder = JSONDecoder()
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data
                else {
                    result(.failure(NSError.nilData))
                    return
                }
            guard let object = try? decoder.decode(decodable.self, from: data) else {
                debugPrint(String(decoding: data, as: UTF8.self))
                result(.failure(NSError.badResponse))
                return
            }
            debugPrint(String(decoding: data, as: UTF8.self))
            result(.success(object))
        }.resume()
    }
}

extension NSError {
    static let nilData = NSError(domain: "com.jj.Demo",
                                 code: 404,
                                 userInfo: [NSLocalizedDescriptionKey : "Data is nil"])
    static let badResponse = NSError(domain: "com.jj.Demo",
                                     code: 400,
                                     userInfo: [NSLocalizedDescriptionKey : "Unable to decode response"])
}

extension Double {
    var kmFormatted: String {

        if self >= 10000, self <= 999999 {
            return String(format: "%.1fK", locale: Locale.current,self/1000).replacingOccurrences(of: ".0", with: "")
        }

        if self > 999999 {
            return String(format: "%.1fM", locale: Locale.current,self/1000000).replacingOccurrences(of: ".0", with: "")
        }

        return String(format: "%.0f", locale: Locale.current,self)
    }
}

func abbreviateAxisValue(string: String) -> String {
        let decimal = Decimal(string: string)
        if decimal == nil {
            return string
        } else {
            if abs(decimal!) > 1000000000000.0 {
                return "\(decimal! / 1000000000000.0)t"
            } else if abs(decimal!) > 1000000000.0 {
                return "\(decimal! / 1000000000.0)b"
            } else if abs(decimal!) > 1000000.0 {
                return "\(decimal! / 1000000.0)m"
            } else if abs(decimal!) > 1000.0 {
                return "\(decimal! / 1000.0)k"
            } else {
                return "\(decimal!)"
            }
        }
}

//round up to x significant digits
func roundUp(_ num: Double, to places: Int) -> Double {
    let p = log10(abs(num))
    let f = pow(10, p.rounded(.up) - Double(places) + 1)
    let rnum = (num / f).rounded(.up) * f
    return rnum
}
