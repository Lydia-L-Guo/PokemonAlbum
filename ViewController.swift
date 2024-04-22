//
//  ViewController.swift
//  PhotoAlbum
//
//  Created by Lydia Guo on 2024/3/14.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    var collectionView: UICollectionView! = nil
    
    var pkList: [PKListItem] = []
    var pkDetail : [PKDetailItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Pokédex"
        configureHierarchy()
        configureDataSource()
        startLoad()
        collectionView.delegate = self

    }
}

extension ViewController {
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension ViewController {
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
     
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<LogoCell, Int> { (cell, indexPath, identifier) in
            if identifier < self.pkDetail.count {
                if let url = self.pkDetail[identifier].frontDefaultURL {
//                    cell.imageView.loadImage(from: url)
                    cell.imageView.kf.setImage(with: url)
                }
            }
            cell.contentView.backgroundColor = UIColor.white
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        // Initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(0..<self.pkDetail.count))
        dataSource.apply(snapshot, animatingDifferences: false)
    }

}

extension UIImageView {
    func loadImage(from url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}

struct PKListItem: Codable {
    let name: String
    let url: URL?
}
struct Sprite: Codable {
    let back_default: String?
    let back_female: String?
    let front_default: String?
}

struct PKDetailItem: Codable {
    let sprites: Sprite?
    let frontDefaultURL: URL?
    let name: String?
//    let abilities : [PKListItem]?
}

struct PKListResponse: Codable {
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [PKListItem]
}
struct PKDetailResponse: Codable {
    let sprites: Sprite?
}

extension ViewController {
    func startLoad(){
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon/?limit=100&offset=0")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(PKListResponse.self, from: data)
                self.pkList = response.results
                self.fetchPokemonImageURL(pkList: self.pkList)
            } catch {
                print("JSON decoding failed: \(error)")
            }
        }
        
        task.resume()
    }
    func fetchPokemonImageURL(pkList: [PKListItem])  {
        for pokemon in pkList {
            guard let url = pokemon.url else {return}
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    let pokemonDetails = try JSONDecoder().decode(PKDetailItem.self, from: data)
                    if let sprites = pokemonDetails.sprites,
                       let name = pokemonDetails.name,
                       let frontDefaultURLString = sprites.front_default,
                       let frontDefaultURL = URL(string: frontDefaultURLString) {
                        let updatedPokemonDetails = PKDetailItem(sprites: sprites, frontDefaultURL: frontDefaultURL, name: name)
                        self.pkDetail.append(updatedPokemonDetails)
                        
                        DispatchQueue.main.async {
                            self.configureDataSource()
                        }
                    }
                } catch {
                    print("JSON decoding failed: \(error)")
                }
            }
            task.resume()
        }
        
    }
}
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPokemon = pkDetail[indexPath.item]
        print(selectedPokemon)
        
        guard let navigationController = self.navigationController else {
            print("Navigation controller is nil")
            return
        }

        let pokemonDetailVC = PokemonDetailViewController()
        pokemonDetailVC.pokemon = selectedPokemon
        navigationController.pushViewController(pokemonDetailVC, animated: true)
    }
}

