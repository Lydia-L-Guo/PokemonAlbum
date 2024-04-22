//
//  PokemonDetailViewController.swift
//  PhotoAlbum
//
//  Created by Lydia Guo on 2024/3/23.
//

import UIKit

class PokemonDetailViewController: UIViewController {
    var pokemon: PKDetailItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        let nameLabel = UILabel()
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 20)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        let abilitiesLabel = UILabel()
        abilitiesLabel.textAlignment = .center
        abilitiesLabel.font = UIFont.systemFont(ofSize: 20)
        abilitiesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(abilitiesLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            abilitiesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            abilitiesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            abilitiesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        if let pokemon = pokemon, let url = pokemon.frontDefaultURL {
            imageView.loadImage(from: url)
        }
        nameLabel.text = "Name: \(pokemon?.name ?? "")"
//        var abilitiesStr = "Abilities: "
//        if let abilities = pokemon?.abilities {
//            for (index, ability) in abilities.enumerated() {
//                let name = ability.name
//                abilitiesStr += name
//                if index < abilities.count - 1 {
//                    abilitiesStr += ", "
//                }
//            }
//        }
//
//        abilitiesLabel.text = abilitiesStr
        navigationItem.setHidesBackButton(false, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}

extension PokemonDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
