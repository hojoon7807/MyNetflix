//
//  SearchViewController.swift
//  MyNetflix
//
//  Created by joonwon lee on 2020/04/02.
//  Copyright © 2020 com.joonwon. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultCollectionView: UICollectionView!
    
    var movies:[Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension SearchViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultCell", for: indexPath) as? ResultCell else {return UICollectionViewCell()}
        
        let movie = movies[indexPath.item]
        let url = URL(string: movie.thumbnailPath)!
        // 서드파티 라이브러리 사용
        // swift pakage manager, cocoapod, carthage
        cell.movieThumbnail.kf.setImage(with: url)
        return cell
    }
    
    
}

extension SearchViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies[indexPath.item]
        let url = URL(string: movie.previewUrl)!
        let item = AVPlayerItem(url: url)
        
        let storyboard = UIStoryboard(name: "Player", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "PlayerViewController") as! PlayerViewController
        vc.modalPresentationStyle = .fullScreen
        vc.player.replaceCurrentItem(with: item)
        present(vc, animated: false, completion: nil)
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin:CGFloat = 8
        let itemSpacing:CGFloat = 10
        let width = (collectionView.bounds.width-margin*2-itemSpacing*2)/3
        let height = width*10/7
        return CGSize(width: width, height: height)
    }
}

class ResultCell: UICollectionViewCell{
    @IBOutlet weak var movieThumbnail:UIImageView!
}

extension SearchViewController: UISearchBarDelegate {
    private func dismissKeyboard (){
        searchBar.resignFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 키보드 동작 처리
        dismissKeyboard()
        // 검색어가 있는지
        guard let searchTerm = searchBar.text, searchTerm.isEmpty == false else {return}
        print("search --> \(searchTerm)")
        // 네트워킹을 통한 검색
        // -서치텀을 가지고 네트워킹 통해 검색
        //[x] 검색 API
        //[x] 결과를 받아올 Movie, Response 모델
        // 결과를 받아서 collectionview
        SearchAPI.search(searchTerm) { movies in
            // collectionView 표현
            DispatchQueue.main.async {
                self.movies = movies
                self.resultCollectionView.reloadData()
            }
            print(movies.count)
            
        }
    }
}

class SearchAPI {
    // 타입 메서드 인스턴스 생성없이도 사용가능
    static func search(_ term:String, completion: @escaping ([Movie])->Void){
        let session = URLSession(configuration: .default)
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search?")!
        let mediaQuery = URLQueryItem(name: "media", value: "movie")
        let entityQuery = URLQueryItem(name: "entity", value: "movie")
        let termQuery = URLQueryItem(name: "term", value: term)
        
        urlComponents.queryItems?.append(mediaQuery)
        urlComponents.queryItems?.append(entityQuery)
        urlComponents.queryItems?.append(termQuery)
        let requestUrl = urlComponents.url!
        
        let dataTask = session.dataTask(with: requestUrl) { data, response, error in
            let successRange = 200..<300
            guard error == nil,
                  let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode) else { completion([])
                return }
            
            guard let resultData = data else {completion([])
                return}
            
            let movies = SearchAPI.parseMovies(resultData)
            completion(movies)
            //data -> Movie
        }
        dataTask.resume()
    }
    
    static func parseMovies(_ data: Data)->[Movie]{
        let decoder = JSONDecoder()
        
        do{
            let response = try decoder.decode(Response.self, from: data)
            let movies = response.movies
            return movies
        }catch let error{
            print("error--->\(error)")
            return []
        }
    }
}

struct Response:Codable  {
    let resultCount:Int
    let movies:[Movie]
    
    enum CodingKeys:String,CodingKey{
        case resultCount
        case movies = "results"
    }
}

struct Movie:Codable {
    let title:String
    let director:String
    let thumbnailPath:String
    let previewUrl:String
    
    enum CodingKeys:String,CodingKey{
        case title = "trackName"
        case director = "artistName"
        case thumbnailPath = "artworkUrl100"
        case previewUrl = "previewUrl"
    }
}
