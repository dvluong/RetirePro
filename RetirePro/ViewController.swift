//
//  ViewController.swift
//  RetirePro
//
//  Created by David Luong on 3/20/17.
//  Copyright © David Luong. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet weak var tfValue: UITextField!
    
    @IBOutlet weak var barView: BarChartView!
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        axisFormatDelegate = self
        
        updateChartWithData()
    }
    
    func updateChartWithData() {
        var dataEntries: [BarChartDataEntry] = []
        
        let compoundChart = getData()
        
        for i in 0..<compoundChart.count {
            let year: Int = compoundChart[i].year
            let dataEntry = BarChartDataEntry(x: Double(year), y: Double(compoundChart[i].money))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Money")
        chartDataSet.colors = ChartColorTemplates.colorful()
        let chartData = BarChartData(dataSet: chartDataSet)
        barView.data = chartData
        barView.animate(xAxisDuration: 1.5)
        
//        let xaxis = barView.xAxis
//        xaxis.valueFormatter = axisFormatDelegate
    }
    
    func getData() -> Results<CompoundChart> {
        do {
            let realm = try Realm()
            print(realm.objects(CompoundChart.self))
            return realm.objects(CompoundChart.self)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func getVisitorCountsFromDatabase() -> Results<VisitorCount> {
        do {
            let realm = try Realm()
            print(realm.objects(VisitorCount.self))
            return realm.objects(VisitorCount.self)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    @IBAction func addTapped(_ sender: Any) {
        if let value = tfValue.text, value != "" {
            let visitorCount = VisitorCount()
            visitorCount.count = (NumberFormatter().number(from: value)?.intValue)!
            visitorCount.save()
            tfValue.text = ""
        }
        updateChartWithData()
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        let visitorCount = VisitorCount()
        visitorCount.delete()
        updateChartWithData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

// MARK: axisFormatDelegate
extension ViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
