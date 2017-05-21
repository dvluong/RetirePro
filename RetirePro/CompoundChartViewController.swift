//
//  CompoundChartViewController.swift
//  RetirePro
//
//  Created by dvluong on 5/21/17.
//  Copyright © 2017 Stanford Graduate School of Education. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class CompoundChartViewController: UIViewController {
    
    @IBOutlet weak var horizontalChart: BarChartView!
    
    weak var axisFormatDelegate: IAxisValueFormatter?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateChartWithData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
        
        let format = NumberFormatter()
        format.positiveSuffix = "K"
        format.numberStyle = .currency
        format.multiplier = 0.001
        format.allowsFloats = true
        format.minimumIntegerDigits = 1
        format.minimumFractionDigits = 0
        format.maximumFractionDigits = 0
        
        //        chartDataSet.valueFormatter = DefaultValueFormatter(formatter: format)
        
        let chartData = BarChartData(dataSet: chartDataSet)
        
        horizontalChart.data = chartData
        horizontalChart.barData?.setValueFormatter(DefaultValueFormatter(formatter: format))
        horizontalChart.animate(yAxisDuration: 1.5)
        horizontalChart.pinchZoomEnabled = false
        horizontalChart.chartDescription?.enabled = false
        
        let xformat = NumberFormatter()
        
        xformat.allowsFloats = false
        xformat.minimumFractionDigits = 0
        xformat.maximumFractionDigits = 0
        
        let yaxis = horizontalChart.leftAxis
        yaxis.valueFormatter = axisFormatDelegate
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CompoundChartViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        let numFormatter = NumberFormatter()
        
        let value = value
        if value > 1000 {
            numFormatter.positiveSuffix = "K"
        }
        
        numFormatter.numberStyle = .currency
        
        numFormatter.multiplier = 0.001
        numFormatter.allowsFloats = true
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 1
        
        return numFormatter.string(from: NSNumber (value:value))!
    }
}

extension Double {
    var kFormatted: String {
        return String(format: self >= 1000 ? "$%.0fK" : "$%.0f", self >= 1000 ? self/1000 : self)
    }
}
