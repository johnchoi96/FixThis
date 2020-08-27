//
//  ViewController.swift
//  FixThis
//
//  Created by John Choi on 8/23/20.
//  Copyright © 2020 John Choi. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var table: UITableView!
    var manager = FixThisManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        table.dataSource = self
        table.delegate = self
        manager.delegate = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = UITableView.automaticDimension
        table.register(UINib(nibName: K.Cells.requestCellNibName, bundle: nil), forCellReuseIdentifier: K.Cells.requestCellIdent)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.requestCellIdent, for: indexPath) as! RequestTableViewCell
        cell.cellLabel.text = manager.requests[indexPath.row].original
        cell.isComplete = manager.requests[indexPath.row].isComplete
        cell.submitterEmail.text = manager.requests[indexPath.row].submitterEmail
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: K.Segues.mainToRequestDetail, sender: manager.requests[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try manager.deleteRequest(id: manager.requests[indexPath.row].documentId, index: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch let error as NSError {
                let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func actionPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Choose", message: "You can submit request or view app information", preferredStyle: .actionSheet)
        let addAction = UIAlertAction(title: "Submit Request", style: .default) { (action) in
            self.addRequest()
        }
        let appInfoAction = UIAlertAction(title: "View App Info", style: .default) { (action) in
            self.performSegue(withIdentifier: K.Segues.mainToAppinfo, sender: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(addAction)
        alert.addAction(appInfoAction)
        alert.addAction(cancelAction)
        // for iPadOS and macOS
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func addRequest() {
        performSegue(withIdentifier: K.Segues.mainToSubmitRequest, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.mainToSubmitRequest {
            let vc = segue.destination as! SubmitRequestViewController
            vc.manager = self.manager
        }
        if segue.identifier == K.Segues.mainToRequestDetail {
            let vc = segue.destination as! RequestDetailViewController
            vc.request = sender as? Request
        }
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension MainViewController: FirebaseDataUpdateDelegate {
    func dataUpdated() {
        table.reloadData()
    }
}
