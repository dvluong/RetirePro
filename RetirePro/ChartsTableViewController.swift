//
//  ChartsTableViewController.swift
//  RetirePro
//
//  Created by David Luong on 3/21/17.
//  Copyright © 2017 David Luong. All rights reserved.
//

import UIKit
import Charts
import RealmSwift
import SubmitButton
import TextFieldEffects

//typealias ReturnRate = (key: String, value:(Double))

class ChartsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var beginTextField: KaedeTextField!
    
    @IBOutlet weak var savedTextField: KaedeTextField!
    
    @IBOutlet weak var returnRateField: KaedeTextField!
    
    @IBOutlet weak var yearTextField: KaedeTextField!
    
    @IBOutlet weak var beginCalculation: SubmitButton!
    
    @IBOutlet weak var horizontalChart: BarChartView!
    
    @IBOutlet weak var pieChart: PieChartView!
    
    let yearPicker = UIPickerView()
    
    let returnPicker = UIPickerView()
    
    let years = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50]
    
    let returnRate: [ReturnRate] = [ReturnRate(key: "VB (13%)", value: 0.13), ReturnRate(key: "VOO (11%)", value: 0.11), ReturnRate(key: "VNQ (11%)", value: 0.11)]
    
    var currentYear: Int = 0
    
    var currentPercent: Double = 0.0
    
    var currentRow = 0
    
    var totalMoney: [Int] = []
    
    weak var axisFormatDelegate: IAxisValueFormatter?

    override func viewDidLoad() {
        super.viewDidLoad()

        axisFormatDelegate = self
        
        getCurrentYear()

        beginCalculation.taskCompletion { (_) in
            
            if !self.getData().isEmpty {
                let compoundChart = CompoundChart()
                compoundChart.delete()
                self.getCurrentYear()
                self.updateChartWithData()
                self.updatePieChart()
            }
            
            if let began = self.beginTextField.text, began != "", let saved = self.savedTextField.text, saved != "", let year = self.yearTextField.text, year != "", let rate = self.returnRateField.text, rate != "" {
                
                self.beginCalculation.completeAnimation(status: .success)
                self.calculateMoola()
            } else {
                self.beginCalculation.completeAnimation(status: .failed)
            }
        }

        yearPicker.delegate = self
        yearPicker.dataSource = self
        
        returnPicker.delegate = self
        returnPicker.dataSource = self
        
        returnRateField.inputView = returnPicker
        yearTextField.inputView = yearPicker
        
        updateChartWithData()
        updatePieChart()
    }
    
    
    @IBAction func submitTapped(_ sender: Any) {
        
        
    }
    
    func getCurrentYear() {
        let date = Date()
        let calendar = Calendar.current
        
        currentYear = calendar.component(.year, from: date)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == returnPicker {
            return returnRate.count
        }
        return years.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == returnPicker {
            return returnRate[row].key
        }
        return String(years[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == returnPicker {
            currentRow = row
            returnRateField.text = returnRate[row].key
        } else {
            yearTextField.text = String(years[row])
        }
        self.view.endEditing(true)
    }

    func delay(seconds: Double, completion: @escaping () -> ()) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
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
    
    func updatePieChart() {
        var dataEntries: [PieChartDataEntry] = []
        
        let compoundChart = getData()
        
        
        for i in 0..<compoundChart.count {
            let year: Int = compoundChart[i].year
            let dataEntry = PieChartDataEntry(value: Double(year), label: Double(compoundChart[i].money).kFormatted)
            
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = PieChartDataSet(values: dataEntries, label: "Money")
        
        let format = NumberFormatter()
        format.positiveSuffix = "K"
        format.numberStyle = .currency
        format.multiplier = 0.001
        format.allowsFloats = true
        format.minimumIntegerDigits = 1
        format.minimumFractionDigits = 0
        format.maximumFractionDigits = 0
        
        chartDataSet.colors = ChartColorTemplates.colorful()
        chartDataSet.sliceSpace = 2.0
        chartDataSet.valueLinePart1OffsetPercentage = 0.8
        chartDataSet.valueLinePart1Length = 0.2
        chartDataSet.valueLinePart2Length = 0.4
//        chartDataSet.yValuePosition = .outsideSlice

        let chartData = PieChartData(dataSet: chartDataSet)
        
        pieChart.data = chartData
        pieChart.animate(xAxisDuration: 1.5, easingOption: .easeInBack)
        pieChart.centerText = returnRate[currentRow].key
        pieChart.chartDescription?.enabled = false
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
    
    func calculateMoola() {
        if let began = beginTextField.text, began != "", let saved = savedTextField.text, saved != "", let year = yearTextField.text, year != "", let rate = returnRateField.text, rate != "" {
            
            let totalYears = Int(year)
            var currBegan = Int(began)!
            
            for _ in 0...totalYears! {
                let compoundChart = CompoundChart()
                compoundChart.year = currentYear
                compoundChart.money = algorithm(began: currBegan, saving: Int(saved)!, rate: returnRate[currentRow].value)
                currentYear += 1
                currBegan = algorithm(began: currBegan, saving: Int(saved)!, rate: returnRate[currentRow].value)
                
                compoundChart.save()
            }
            
            
            updateChartWithData()
            updatePieChart()
            print(totalMoney)
        }
    }
    
    func algorithm(began: Int, saving: Int, rate: Double) -> Int {
        let result = round((Double(began) + round(Double(began) * rate)) + Double(saving))
        return Int(result)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
}

extension ChartsTableViewController: IAxisValueFormatter {
    
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

