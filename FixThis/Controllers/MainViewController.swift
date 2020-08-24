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
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.Segues.mainToSubmitRequest, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.mainToSubmitRequest {
            let vc = segue.destination as! SubmitRequestViewController
            vc.manager = self.manager
        }
    }
}

extension MainViewController: FirebaseDataUpdateDelegate {
    func dataUpdated() {
        table.reloadData()
    }
}
