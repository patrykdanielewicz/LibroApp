//
//  OrderCell.swift
//  Libro
//
//  Created by Patryk Danielewicz on 03.05.2024.
//

import UIKit

protocol OrderCellDelegate: AnyObject {
    func modifiedTextInCell(cell: OrderCell, text: String?)
    
    func addNewCell(_ input: AddNewCellArguments)
    
    func removeCell(cell: OrderCell)
}

class OrderCell: UITableViewCell, UITextViewDelegate {
   
    private var customImageView = UIImageView()
    var customText              = UITextView()
    
    weak var delegate: OrderCellDelegate?
    var initialText: String?
    
    required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
    
}
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        

    }
    
    private func setupViews() {
        contentView.addSubview(customImageView)
        contentView.addSubview(customText)
        
        customImageView.contentMode                               = .scaleAspectFit
        customImageView.translatesAutoresizingMaskIntoConstraints = false
        
    
        customText.translatesAutoresizingMaskIntoConstraints      = false
        customText.font                                           = UIFont.preferredFont(forTextStyle: .headline)
        customText.adjustsFontForContentSizeCategory              = true
        customText.isScrollEnabled                                = false
        customText.delegate                                       = self
        
        
        
        NSLayoutConstraint.activate([
            customImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            customImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            customImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            customImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            customText.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            customText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1)
        ])
    
        backgroundColor                         = UIColor.systemBackground
        selectedBackgroundView?.backgroundColor = UIColor(red: 0.93, green: 0.13, blue: 0.46, alpha: 0.50)
    }
    
    func configure(image: UIImage?, text: String?) {
        if let image = image {
            customImageView.image    = image
            customImageView.isHidden = false
            customText.isHidden      = true
        }
        else if let text = text {
            customText.isHidden      = false
            customImageView.isHidden = true
            customText.text = text
        }
        else {
            customText.isHidden      = true
            customImageView.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customText.text        = nil
        customImageView.image  = nil
        self.layoutIfNeeded()
    }
            
    func textViewDidBeginEditing(_ textView: UITextView) {
        initialText = customText.text
    }
  
    func textViewDidEndEditing(_ textView: UITextView) {
        if customText.text == "" {
            delegate?.removeCell(cell: self)
        }
        else if initialText != customText.text {
                delegate?.modifiedTextInCell(cell: self, text: customText.text)
            }
    
        else {
            
            delegate?.addNewCell(.cell(self))
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            customText.resignFirstResponder()
            
            return false
        }
        return true
    }
    
}
