//
//  CalculatorVC.swift
//  valueinvest
//
//  Created by Dzmitry on 2022-12-29.
//

import UIKit
import CoreData

class SimpleDCFCalcVC: UIViewController {
    
    @IBOutlet weak var StockTicker: UITextField!
    @IBOutlet weak var EPS: UITextField!
    @IBOutlet weak var GrowthRate10YearsOut: UITextField!
    @IBOutlet weak var TerminalGrowthRate: UITextField!
    @IBOutlet weak var DesiredROI: UITextField!
    @IBOutlet weak var FairValue: UILabel!
    @IBOutlet weak var Errors: UILabel!
    
    var stockTicker: String = ""
    var eps: Double = 0
    var eps10YearsInTheFuture: Double = 0
    var growthRate10YearsOut: Double = 0
    var terminalGrowthRate: Double = 0
    var desiredROI: Double = 0
    var fairValue: Double = 0
    var growthValue: Double = 0
    var terminalValue: Double = 0
    var a: Double = 0
    var b: Double = 0
    
    var itemIndex: Int = 0
    var newCalc: Bool = false
    var itemArray = [SimplifiedDCF]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - UIView Management
    override func viewDidLoad() {
        
        //super.viewDidLoad()
        StockTicker.delegate = self
        
        LoadItems()
        
        if newCalc == false {
            StockTicker.text = (itemArray[itemIndex].ticker)!
            stockTicker = (itemArray[itemIndex].ticker)!
            
            EPS.text = String(itemArray[itemIndex].freeCashFlow)
            eps = itemArray[itemIndex].freeCashFlow
            
            GrowthRate10YearsOut.text = String(itemArray[itemIndex].gr10year)
            growthRate10YearsOut = itemArray[itemIndex].gr10year
            
            TerminalGrowthRate.text = String(itemArray[itemIndex].grTerminal)
            terminalGrowthRate = itemArray[itemIndex].grTerminal
            
            DesiredROI.text = String(itemArray[itemIndex].discountRate)
            desiredROI = itemArray[itemIndex].discountRate
            
            FairValue.text = "$\(itemArray[itemIndex].fairValue)"
            fairValue = itemArray[itemIndex].fairValue
        }
    }
    
    //MARK: - Buttons
    
    @IBAction func Calculate(_ sender: UIButton) {
        view.endEditing(true)
        fairValueCalculation()
    }
    
    @IBAction func Save(_ sender: UIButton) {
        
        SaveItems()
        navigationController?.popViewController(animated: true)
        
    }
    
    //MARK:- Calculation Methods
    
    func fairValueCalculation() {
        Double(EPS.text!) != nil ? eps = Double(EPS.text!)! : (eps = 0.0)
        Double(GrowthRate10YearsOut.text!) != nil ? growthRate10YearsOut = Double(GrowthRate10YearsOut.text!)! : (growthRate10YearsOut = 0.0)
        Double(TerminalGrowthRate.text!) != nil ? terminalGrowthRate = Double(TerminalGrowthRate.text!)! : (terminalGrowthRate = 0.0)
        Double(DesiredROI.text!) != nil ? desiredROI = Double(DesiredROI.text!)! : (desiredROI = 0.0)
        
        (desiredROI <= terminalGrowthRate) ? Errors.text = "Discount Shall be Higher than Terminal Growth Rate!" : (Errors.text = "")
        
        a=(1+growthRate10YearsOut/100)/(1+desiredROI/100)
        growthValue = eps*a*(1-pow(a,10))/(1-a)
        eps10YearsInTheFuture = eps*pow((1+growthRate10YearsOut/100),10)/pow((1+desiredROI/100),10)
        terminalValue = eps10YearsInTheFuture*(1+terminalGrowthRate/100)/(desiredROI/100-terminalGrowthRate/100)
        fairValue = growthValue+terminalValue
        
        FairValue.text =  ("$\(round(fairValue*100)/100)")
    }
    
    //MARK: - Model Manupulation Methods
    
    func SaveItems()  {
        do {
            if newCalc == true {
                let newItem = SimplifiedDCF(context: context)
                newItem.fairValue = round(fairValue*100)/100
                newItem.discountRate = desiredROI
                newItem.freeCashFlow = eps
                newItem.gr10year = growthRate10YearsOut
                newItem.grTerminal = terminalGrowthRate
                newItem.ticker = StockTicker.text
                newItem.date = Date()
            } else {
                itemArray[itemIndex].fairValue = round(fairValue*100)/100
                itemArray[itemIndex].discountRate = desiredROI
                itemArray[itemIndex].freeCashFlow = eps
                itemArray[itemIndex].gr10year = growthRate10YearsOut
                itemArray[itemIndex].grTerminal = terminalGrowthRate
                itemArray[itemIndex].ticker = StockTicker.text
                itemArray[itemIndex].date = Date()
            }
            try context.save()
        }
        catch {print("error saving context \(error)")}
    }
    
    func LoadItems() {
        let request : NSFetchRequest<SimplifiedDCF> = SimplifiedDCF.fetchRequest()
        do {
            itemArray = try context.fetch(request)
        } catch {
            print ("Error fetching data from context \(error)")
        }
    }
}

extension SimpleDCFCalcVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(#function)
        StockTicker.resignFirstResponder()
        //Do something...
        return true
    }
}

