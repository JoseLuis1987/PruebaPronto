//
//  DatosCell.swift
//  Prueba
//
//  Created by Pronto on 10/14/19.
//  Copyright © 2019 Pronto. All rights reserved.
//

import UIKit

class DatosCell: UITableViewCell {
    @IBOutlet weak var nombre: UILabel!
    @IBOutlet weak var icono: UIImageView!
    var miDataCell : DatosToSetTable? {
            didSet {
                   guard let miDataCell = miDataCell else {
                       return
                   }
                     //Set values to cell properties
                    nombre.text = miDataCell.name
                getData(from: NSURL(string: miDataCell.icono) as! URL) { data, response, error in
                         guard let data = data, error == nil else { return }
                       //  print(response?.suggestedFilename ?? url.lastPathComponent)
                        // print("Download Finished")
                         DispatchQueue.main.async() {
                            self.icono!.image = UIImage(data: data)
                         }
                     }
                
               }
         }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
          URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
      }
}
