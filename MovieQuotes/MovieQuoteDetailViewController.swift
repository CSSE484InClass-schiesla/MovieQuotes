//
//  MovieQuoteDetailViewController.swift
//  MovieQuotes
//
//  Created by CSSE Department on 4/3/18.
//  Copyright © 2018 Rose-Hulman. All rights reserved.
//

import UIKit
import Firebase

class MovieQuoteDetailViewController: UIViewController {
    
    @IBOutlet weak var quoteContentLabel: UILabel!
    @IBOutlet weak var movieContentLabel: UILabel!
    
    var movieQuote: MovieQuote?
    var movieQuoteRef: DocumentReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(showEditDialog))
    }
    
    @objc func showEditDialog() {
        let alertController = UIAlertController(title: "Edit movie quote", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Quote"
            textField.text = self.movieQuote?.quote
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Movie Title"
            textField.text = self.movieQuote?.movie
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        let editQuoteAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.default) { (action) in
            let quoteTextField = alertController.textFields![0]
            let movieTextField = alertController.textFields![1]
            self.movieQuote?.quote = quoteTextField.text!
            self.movieQuote?.movie = movieTextField.text!
            self.movieQuoteRef?.setData(self.movieQuote!.data)
        }
        
        alertController.addAction(editQuoteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        movieQuoteListener = movieQuoteRef?.addSnapshotListener({ (documentSnapshot, error) in
            if let error = error {
                return
            }
            if !documentSnapshot!.exists {
                return
            }
            self.
        })
        //updateView()
    }
    
    func updateView() {
        quoteContentLabel.text = movieQuote?.quote
        movieContentLabel.text = movieQuote?.movie
        
    }

}
