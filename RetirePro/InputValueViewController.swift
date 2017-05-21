//
//  InputValueViewController.swift
//  RetirePro
//
//  Created by dvluong on 5/21/17.
//  Copyright © 2017 Stanford Graduate School of Education. All rights reserved.
//

import UIKit
import RealmSwift
import SubmitButton
import TextFieldEffects

typealias ReturnRate = (key: String, value:(Double))

class InputValueViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var beginTextField: KaedeTextField!
    
    @IBOutlet weak var savedTextField: KaedeTextField!
    
    @IBOutlet weak var returnRateField: KaedeTextField!
    
    @IBOutlet weak var yearTextField: KaedeTextField!
    
    @IBOutlet weak var beginCalculation: SubmitButton!
    
    let yearPicker = UIPickerView()
    
    let returnPicker = UIPickerView()
    
    let years = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50]
    
    let returnRate: [ReturnRate] = [ReturnRate(key: "VB (13%)", value: 0.13), ReturnRate(key: "VOO (11%)", value: 0.11), ReturnRate(key: "VNQ (11%)", value: 0.11)]
    
    var currentYear: Int = 0
    
    var currentPercent: Double = 0.0
    
    var currentRow = 0
    
    var totalMoney: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentYear()
        
        beginCalculation.taskCompletion { (_) in
            
            if !self.getData().isEmpty {
                let compoundChart = CompoundChart()
                compoundChart.delete()
                self.getCurrentYear()
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
        // Do any additional setup after loading the view.
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
    
    func getData() -> Results<CompoundChart> {
        do {
            let realm = try Realm()
            print(realm.objects(CompoundChart.self))
            return realm.objects(CompoundChart.self)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    private func calculateMoola() {
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
            
            performSegue(withIdentifier: "goToCharts", sender: nil)
            
//            updateChartWithData()
//            updatePieChart()
            print(totalMoney)
        }
    }
    
    private func algorithm(began: Int, saving: Int, rate: Double) -> Int {
        let result = round((Double(began) + round(Double(began) * rate)) + Double(saving))
        return Int(result)
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
