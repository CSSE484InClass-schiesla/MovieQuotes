//
//  MovieQuotesTableViewController.swift
//  MovieQuotes
//
//  Created by CSSE Department on 3/29/18.
//  Copyright © 2018 Rose-Hulman. All rights reserved.
//

import UIKit
import Firebase

class MovieQuotesTableViewController: UITableViewController {
    
    var quotesRef: CollectionReference!
    var quotesListener: ListenerRegistration!
    
    var cellIdentifier = "MovieQuoteCell"
    var noCellIdentifier = "NoMovieQuotesCell"
    var movieQuotes = [MovieQuote]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(showAddDialog))
        
        quotesRef = Firestore.firestore().collection("quotes")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        quotesListener = quotesRef.order(by:"created", descending: true).addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error man")
                return
            }
            snapshot.documentChanges.forEach {(docChange) in
                if (docChange.type == .added) {
                    print("New quote: \(docChange.document.data())")
                    self.quoteAdded(docChange.document)
                } else if (docChange.type == .modified) {
                    print("Modified quote: \(docChange.document.data())")
                    self.quoteUpdated(docChange.document)
                } else if (docChange.type == .removed) {
                    print("deleted quote")
                    self.quoteRemoved(docChange.document)
                }
            }
            //need sort function
            self.tableView.reloadData()
        })
    }
    
    func quoteAdded(_ document: DocumentSnapshot) {
        let newMovieQuote = MovieQuote(documentSnapshot: document)
        movieQuotes.append(newMovieQuote)
    }
    
    func quoteUpdated(_ document: DocumentSnapshot) {
        let modifiedMovieQuote = MovieQuote(documentSnapshot: document)
        for movieQuote in movieQuotes {
            if (movieQuote.id == modifiedMovieQuote.id) {
                movieQuote.quote = modifiedMovieQuote.quote
                movieQuote.movie = modifiedMovieQuote.movie
                break
            }
        }
    }
    
    func quoteRemoved(_ document: DocumentSnapshot) {
        for i in 0..<movieQuotes.count {
            if movieQuotes[i].id == document.documentID {
                movieQuotes.remove(at: i)
                break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        quotesListener.remove()
    }
    
    @objc func showAddDialog() {
        let alertController = UIAlertController(title: "create a new movie quote", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Quote"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Movie Title"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        let createQuoteAction = UIAlertAction(title: "Create Quote", style: UIAlertActionStyle.default) { (action) in
            let quoteTextField = alertController.textFields![0]
            let movieTextField = alertController.textFields![1]
            let movieQuote = MovieQuote(quote: quoteTextField.text!, movie: movieTextField.text!)
            self.quotesRef.addDocument(data: movieQuote.data)
            
        }
        
        alertController.addAction(createQuoteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if movieQuotes.count == 0 {
            super.setEditing(false, animated: animated)
        } else {
            super.setEditing(editing, animated: animated)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(movieQuotes.count, 1)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if movieQuotes.count == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: noCellIdentifier, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            // Configure the cell...
            cell.textLabel?.text = movieQuotes[indexPath.row].quote
            cell.detailTextLabel?.text = movieQuotes[indexPath.row].movie
        }
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return movieQuotes.count > 0
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movieQuoteToDelete = movieQuotes[indexPath.row]
            quotesRef.document(movieQuoteToDelete.id!).delete()
        }
    }
 

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == showDetailSegueIdentifier {
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destination as! MovieQuotesTableViewController).movieQuoteRef = quotesRef.document(movieQuotes[indexPath.row].id!)
            }
        }
    }
 */
 

}
