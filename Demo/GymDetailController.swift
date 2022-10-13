//
//  GymDetailController.swift
//  Demo
//
//  Created by JJ on 07/10/22.
//

import UIKit
import DGCollectionViewLeftAlignFlowLayout
import Kingfisher

let cellAmentiesHeight = 50.0

class GymDetailController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var imgGym: UIImageView!
    @IBOutlet weak var lblGymName: UILabel!
    @IBOutlet weak var imgGymLogo: UIImageView!
    @IBOutlet weak var lblGymSports: UILabel!
    @IBOutlet weak var lblGymLocation: UILabel!
    @IBOutlet weak var lblGymDescription: UILabel!
    @IBOutlet weak var cltnAmenries: UICollectionView!
    
    // MARK: - Variables
    var objGym: Gym? = nil
    var arrAmenties = [String]()
    var address = String()

    // MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpData()
        setUpCollectionView()
    }
    
    // MARK: - setUpData
    func setUpData() {
        if let imgGymi = objGym?.label, imgGymi != "" {
            let url = URL(string: imageBaseUrl + imgGymi)
            imgGym.kf.setImage(with: url)
        }else {
            imgGym.image = UIImage(named: "detail")!
        }
        lblGymName.text = objGym?.name
        if let imgLogo = objGym?.logo, imgLogo != "" {
            let url = URL(string: imageBaseUrl + imgLogo)
            imgGymLogo.kf.setImage(with: url)
        }else {
            imgGymLogo.image = UIImage(named: "C")!
        }
        lblGymSports.text = objGym?.gymType
        if let add = objGym?.address{
            address.append(add)
        }
        if let city = objGym?.city{
            address.append(",")
            address.append(city)
        }
        if let state = objGym?.state{
            address.append(",")
            address.append(state)
        }
        if let country = objGym?.country{
            address.append(",")
            address.append(country)
        }
        lblGymLocation.text = address
    }
    
    // MARK: - setUpCollectionView
    func setUpCollectionView() {
        
        cltnAmenries.register(UINib(nibName: "AmentiesCell", bundle: nil), forCellWithReuseIdentifier: "AmentiesCell")
        
        cltnAmenries.delegate = self
        cltnAmenries.dataSource = self
        
        cltnAmenries.collectionViewLayout = DGCollectionViewLeftAlignFlowLayout()
        
        arrAmenties = objGym?.amenities?.components(separatedBy: ",") ?? []
        
        cltnAmenries.reloadData()
    }
    
    // MARK: - Button Actions
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension GymDetailController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.arrAmenties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : AmentiesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AmentiesCell", for: indexPath) as! AmentiesCell
        cell.imgAmeniti.image = UIImage(named: "C")!
        cell.lblAmenitiName.text = arrAmenties[indexPath.item]
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1.0
        cell.layer.cornerRadius = 16.0
        return cell
    }
}

// MARK: - UICollectionView Delegate Flowlayout
extension GymDetailController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let textWidth = arrAmenties[indexPath.item].width(withConstrainedHeight: 32, font: .systemFont(ofSize: 13.0, weight: UIFont.Weight(rawValue: 600)))
        let width = textWidth + 16 + 24 + 16
        return CGSize(width: width, height: 32)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: 32)
    }
}

// MARK: - Amenties Model
struct Amenties {
    let imgAmenties : UIImage
    let name: String
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}
