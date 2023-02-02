//
//  ViewController.swift
//  valueinvest
//
//  Created by Dzmitry on 2022-12-29.
//

import UIKit
import CoreData
import SwipeCellKit

class TableVC: UITableViewController {
    /*----------------------------*/
    /*----------------------------*/
    /*----------------------------*/
    var dragInitialIndexPath: IndexPath?
    var dragCellSnapshot: UIView?
    
    
        
    
    
    // MARK: cell reorder / long press
    
    @objc func onLongPressGesture(sender: UILongPressGestureRecognizer) {
   
      let locationInView = sender.location(in: tableView)
      let indexPath = tableView.indexPathForRow(at: locationInView)

      if sender.state == .began {
        if indexPath != nil {
          dragInitialIndexPath = indexPath
          let cell = tableView.cellForRow(at: indexPath!)
          dragCellSnapshot = snapshotOfCell(inputView: cell!)
          var center = cell?.center
          dragCellSnapshot?.center = center!
          dragCellSnapshot?.alpha = 0.0
          tableView.addSubview(dragCellSnapshot!)

          UIView.animate(withDuration: 0.25, animations: { () -> Void in
            center?.y = locationInView.y
            self.dragCellSnapshot?.center = center!
            self.dragCellSnapshot?.transform = (self.dragCellSnapshot?.transform.scaledBy(x: 1.05, y: 1.05))!
            self.dragCellSnapshot?.alpha = 0.99
            cell?.alpha = 0.0
          }, completion: { (finished) -> Void in
            if finished {
              cell?.isHidden = true
            }
          })
        }
      } else if sender.state == .changed && dragInitialIndexPath != nil {
        var center = dragCellSnapshot?.center
        center?.y = locationInView.y
        dragCellSnapshot?.center = center!

        // to lock dragging to same section add: "&& indexPath?.section == dragInitialIndexPath?.section" to the if below
        if indexPath != nil && indexPath != dragInitialIndexPath {
          // update your data model
          let dataToMove = itemArray[dragInitialIndexPath!.row]
            itemArray.remove(at: dragInitialIndexPath!.row)
            itemArray.insert(dataToMove, at: indexPath!.row)

          tableView.moveRow(at: dragInitialIndexPath!, to: indexPath!)
          dragInitialIndexPath = indexPath
        }
      } else if sender.state == .ended && dragInitialIndexPath != nil {
        let cell = tableView.cellForRow(at: dragInitialIndexPath!)
        cell?.isHidden = false
        cell?.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
          self.dragCellSnapshot?.center = (cell?.center)!
          self.dragCellSnapshot?.transform = CGAffineTransform.identity
          self.dragCellSnapshot?.alpha = 0.0
          cell?.alpha = 1.0
        }, completion: { (finished) -> Void in
          if finished {
            self.dragInitialIndexPath = nil
            self.dragCellSnapshot?.removeFromSuperview()
            self.dragCellSnapshot = nil
          }
        })
      }
    }

    func snapshotOfCell(inputView: UIView) -> UIView {
      UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
      inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      let cellSnapshot = UIImageView(image: image)
      cellSnapshot.layer.masksToBounds = false
      cellSnapshot.layer.cornerRadius = 0.0
      cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
      cellSnapshot.layer.shadowRadius = 5.0
      cellSnapshot.layer.shadowOpacity = 0.4
      return cellSnapshot
    }
    /*----------------------------*/
    /*----------------------------*/
    /*----------------------------*/
    
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    var itemArray = [SimplifiedDCF]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - Managing Views
    override func viewDidLoad() {
        super.viewDidLoad()
        /*---------*/
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender:)))
        longPress.minimumPressDuration = 0.3 // optional
        tableView.addGestureRecognizer(longPress)
        /*---------*/
    }
    
    func tableBackground()
    {
        //  let img = UIImageView(image: UIImage(named: "Head.png"))
        
        if (tableView.numberOfRows(inSection: 0) == 0)
        {
            let labelView = UILabel()
            labelView.textAlignment = .center
            labelView.numberOfLines = 0
      
            labelView.font = UIFont(name:"Roboto-Light", size: 18)
            labelView.textColor = UIColor(rgb: 0x4A4956)
           
            labelView.text = "It's so Empty Here! \n  \n  1. Press the + At the Top \n 2. Fill out the Form \n 3. Push CALCULATE \n 4. SAVE \n 5. Edit Entries as Required \n 6. Delete by Swiping to the Left"
            
            let emptyView = UIView()
            
            
            let stackView = UIStackView(arrangedSubviews: [labelView, emptyView])
            
            stackView.axis = .vertical
            
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 100, leading: 40, bottom: 100, trailing: 40)
            
            stackView.spacing = 20
            stackView.distribution = .equalSpacing
           
            tableView.backgroundView = stackView
        }
        else
        {
            tableView.backgroundView = nil
        }
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        LoadItems()
        tableBackground()
    }
    
    //MARK: - TableView Delegate Methods
    
    var itemIndex: Int = 0
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemIndex = indexPath.row
        performSegue(withIdentifier: "EditSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBarOutlet.text = ""
        if segue.identifier == "EditSegue"
        {
            let destinationVC = segue.destination as! SimpleDCFCalcVC
            destinationVC.itemIndex = itemIndex
        }
        else if segue.identifier == "NewCalcSegue"
        {
            let destinationVC = segue.destination as! SimpleDCFCalcVC
            destinationVC.newCalc = true
        }
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        

        
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ValueInvestItemCell", for: indexPath) as! CustomTableViewCell
        cell.delegate = self
        let item = itemArray[indexPath.row]
        cell.cellViewTicker?.text = "\(item.ticker!)"
        cell.cellViewPriceTarget?.text = "$\(item.fairValue)"
        
        let localDateFormatter = DateFormatter()
        localDateFormatter.dateStyle = .medium
        localDateFormatter.timeStyle = .medium
        
        let date = itemArray[indexPath.row].date ?? Date()
        cell.cellViewDate.text = "Calculated on: \(localDateFormatter.string(from: date))"
        
        tableView.rowHeight = 80
        
        return cell
    }
    
    //MARK: - Model Manupulation Methods
    
    func LoadItems(with request: NSFetchRequest<SimplifiedDCF> = SimplifiedDCF.fetchRequest()) {
        
        do {
            itemArray = try context.fetch(request)
            self.tableView.reloadData()
        } catch {
            print ("Error fetching data from context \(error)")
        }
    }
    
    func saveItems()  {
        do {
            try context.save()
        }
        catch {
            print("error saving context \(error)")
        }
    }
}

//MARK: - Swipe Cell Delegate Method
extension TableVC: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.context.delete(self.itemArray[indexPath.row])
            self.itemArray.remove(at: indexPath.row)
            self.saveItems()
            self.tableView.reloadData()
        }
        deleteAction.image = UIImage(named: "delete-icon")
        deleteAction.backgroundColor = UIColor(rgb: 0x712CE2)
        return [deleteAction]
    }
}

//MARK: - Search Bar Methods

extension TableVC: UISearchBarDelegate {
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            LoadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            let request: NSFetchRequest<SimplifiedDCF> = SimplifiedDCF.fetchRequest()
            request.predicate = NSPredicate(format: "ticker CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "ticker", ascending: true)]
            LoadItems(with: request)
        }
    }
    
    //MARK:- Navigation Bar and Color Customizations
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}
