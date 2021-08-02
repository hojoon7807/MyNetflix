//
//  SearchViewController.swift
//  MyNetflix
//
//  Created by joonwon lee on 2020/04/02.
//  Copyright © 2020 com.joonwon. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
        // 네트워킹을 통한 검색
        // 서치텀을 가지고 네트워킹 통해 검색
        // 검색 API
        // 결과를 받아올 Movie, Response 모델
        // 결과를 받아서 collectionview
        SearchAPI.search(searchTerm) { movies in
            // collectionView 표현
        }
    }
}

class SearchAPI {
    // 타입 메서드 인스턴스 생성없이도 사용가능
    static func search(_ term:String, completion: @escaping ([Movie])->Void){}
}

struct Response {
    <#fields#>
}

struct Movie {
    <#fields#>
}
