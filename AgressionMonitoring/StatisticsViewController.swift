//
//  StatisticsViewController.swift
//  AggressionMonitoring
//
//  Created by admin on 6/21/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Charts

class StatisticsViewController: UIViewController {

    @IBOutlet weak var fromDate: UITextField!
    @IBOutlet weak var toDate: UITextField!
    var isStartDate: Bool?
    
    @IBOutlet weak var sensorChart: SensorChartView!
    
    @IBOutlet weak var obsChart: ObservedChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initFromDatePicker()
        self.initToDatePicker()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChart(dataPoints: [String], values: [Double], values2: [Double], values3: [Double], isSensorChart: Bool) {

        let formato:BarChartFormatter = BarChartFormatter()
        let xaxis:XAxis = XAxis()
        var endGroupGap: Double = 0
        var dataEntries: [BarChartDataEntry] = [BarChartDataEntry]()
        var dataEntries2: [BarChartDataEntry] = [BarChartDataEntry]()
        var dataEntries3: [BarChartDataEntry] = [BarChartDataEntry]()
        var totalHours: Double = 0
        formato.setWeek(fields: dataPoints)
        //var groupValues = [Double]()
        var i = 0
        for _ in dataPoints {
            /*groupValues.removeAll()
            groupValues.append(values[i])
            groupValues.append(values2[i])
            groupValues.append(values3[i])*/
            let dataEntry = BarChartDataEntry(x: Double(i) ,y: values[i])
            let dataEntry2 = BarChartDataEntry(x: Double(i) ,y: values2[i])
            let dataEntry3 = BarChartDataEntry(x: Double(i) ,y: values3[i])
            totalHours = totalHours + values[i]
            dataEntries.append(dataEntry)
            dataEntries2.append(dataEntry2)
            dataEntries3.append(dataEntry3)
            print("call from setChart")
            print("value: \(i)")
            _ = formato.stringForValue(Double(i), axis: xaxis)
            i = i+1
            
        }
        
        
        xaxis.valueFormatter = formato
        
        //tHoursTxtField.text = String(round((totalHours-values[values.count-1])*100)/100)
        
        //xaxis.drawGridLinesEnabled = false
        
        
        
        //xaxis.spaceMin = 0.8
        //xaxis.centerAxisLabelsEnabled = true
        //xaxis.labelCount = 8
        //setLabelsToSkip(0)
        
        let chartDataSet: BarChartDataSet = BarChartDataSet(values: dataEntries, label: "Total-Hours")
        chartDataSet.colors = [UIColor.orange]//ChartColorTemplates.material() //pastel()//colorful()
        let chartDataSet2: BarChartDataSet = BarChartDataSet(values: dataEntries2, label: "Aggression-Voice")
        chartDataSet2.colors = [UIColor.magenta]//ChartColorTemplates.colorful()
        let chartDataSet3: BarChartDataSet = BarChartDataSet(values: dataEntries3, label: "Aggression-Limbs")
        chartDataSet3.colors = [UIColor.purple]//ChartColorTemplates.pastel()//colorful()
        
        let chartData = BarChartData()
        chartData.addDataSet(chartDataSet)
        chartData.addDataSet(chartDataSet2)
        chartData.addDataSet(chartDataSet3)
        
        let bwidth = 0.5
        let bSpace = 0.05
        let gSpace = 0.6
        chartData.barWidth = bwidth
        let grpSpace = chartData.groupWidth(groupSpace: gSpace, barSpace: bSpace)
        //print("grpSpc :\(grpSpace)")
        chartData.groupBars(fromX: -0.5, groupSpace: gSpace, barSpace: bSpace)
        if ( values2[i-1] == 0 && values3[i-1] == 0) {
            endGroupGap = -(gSpace)-(bwidth)
        }
        
        if (isSensorChart) {
            //self.sensorChart.delegate = self
            self.sensorChart.chartDescription?.text = "Aggression-Status vs Hours"
            self.sensorChart.noDataText = "No chart data available for the date range"
            self.sensorChart.xAxis.valueFormatter = xaxis.valueFormatter
            //self.sensorChart.xAxis.setLabelCount(3, force: true)
            self.sensorChart.xAxis.avoidFirstLastClippingEnabled = true// wordWrapEnabled = true
            self.sensorChart.xAxis.drawGridLinesEnabled = true
            // Make sure that only 1 x-label per index is shown
            self.sensorChart.xAxis.granularityEnabled = true
            self.sensorChart.xAxis.granularity = bwidth+bSpace+gSpace
            self.sensorChart.xAxis.axisMaximum = -0.5
            self.sensorChart.xAxis.axisMaximum = (grpSpace * Double(dataPoints.count)) + endGroupGap//Double(dataPoints.count) + (3*gSpace) + (6*bSpace) + (3*bwidth)
            self.sensorChart.xAxis.centerAxisLabelsEnabled = true
            self.sensorChart.data = chartData
            //cell.availabilityChartView.drawValueAboveBarEnabled = true
            self.sensorChart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5, easingOption: .easeInBounce)
            //chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
            self.sensorChart.notifyDataSetChanged()
            self.sensorChart.clipsToBounds = true
        } else {
            self.obsChart.chartDescription?.text = "Aggression-Status vs Hours"
            self.obsChart.noDataText = "No chart data available for the date range"
            self.obsChart.xAxis.valueFormatter = xaxis.valueFormatter
            self.obsChart.xAxis.avoidFirstLastClippingEnabled = true
            self.obsChart.xAxis.drawGridLinesEnabled = true
            // Make sure that only 1 x-label per index is shown
            self.obsChart.xAxis.granularityEnabled = true
            self.obsChart.xAxis.granularity = bwidth+bSpace+gSpace
            self.obsChart.xAxis.axisMaximum = -0.5
            self.obsChart.xAxis.axisMaximum = (grpSpace * Double(dataPoints.count)) + endGroupGap//Double(dataPoints.count) - 0.5
            self.obsChart.xAxis.centerAxisLabelsEnabled = true
            self.obsChart.data = chartData
            self.obsChart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5, easingOption: .easeInBounce)
            self.obsChart.notifyDataSetChanged()
            self.obsChart.clipsToBounds = true
        }
    }
    
    func loadGraphData() {
        if (self.fromDate.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty) || (self.toDate.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty) {
            return
        } else {
           //call webservice with patient details, start and end date
           //for S.A get #hours for each voice and hands
            //cell.availabilityChartView.noDataText = "Availability Info Not Found"
            let xSensorData: [String] = ["Stable", "Slightly Aggressive", "Aggressive"]
            let ySensorData: [Double] = [10, 20, 5]
            let ySensorVoice: [Double] = [0,7,0]
            let ySensorLimbs: [Double] = [0,14,0]
        self.setChart(dataPoints: xSensorData, values: ySensorData, values2: ySensorVoice, values3: ySensorLimbs, isSensorChart: true)
            //for Agitated get #hours for each voice and hands
            let xObsData: [String] = ["Stable", "Agitated"]
            let yObsData: [Double] = [10, 20]
            let yObsVoice: [Double] = [0,15]
            let yObsLimbs: [Double] = [0,5]
            self.setChart(dataPoints: xObsData, values: yObsData, values2: yObsVoice, values3: yObsLimbs, isSensorChart:false)
        }
    }
    
    func donePressed(_ sender: UIBarButtonItem) {
        self.fromDate.resignFirstResponder()
        self.toDate.resignFirstResponder()
        self.loadGraphData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.loadGraphData()
    }
    
    func fromDatePickerValueChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        self.fromDate.text = formatter.string(from: sender.date)
    }
    
    func toDatePickerValueChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        self.toDate.text = formatter.string(from: sender.date)
    }

    
    func configToolbar(labelText: String) -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.blackTranslucent
        
        toolBar.tintColor = UIColor.white
        
        toolBar.backgroundColor = UIColor.black
        
        
        //let defaultButton = UIBarButtonItem(title: "Default", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddPatientViewController.tappedDateToolBarBtn))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(AddPatientViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = labelText
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([/*defaultButton,*/flexSpace,textBtn,flexSpace,doneButton], animated: true)
        return toolBar
    }
    
    func initFromDatePicker() {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.addTarget(self, action: #selector(fromDatePickerValueChanged(_:)), for: UIControlEvents.valueChanged)
        self.fromDate.inputView = datePickerView
        let toolBar = self.configToolbar(labelText: "Pick the start date")
        self.fromDate.inputAccessoryView = toolBar
    }
    
    func initToDatePicker() {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.addTarget(self, action: #selector(toDatePickerValueChanged(_:)), for: UIControlEvents.valueChanged)
        self.toDate.inputView = datePickerView
        let toolBar = self.configToolbar(labelText: "Pick the end date")
        self.toDate.inputAccessoryView = toolBar
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
