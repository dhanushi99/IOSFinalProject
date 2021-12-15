//
//  ViewController.swift
//  CovidTracking
//
//  Created by user202327 on 12/13/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayData.count
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dayData[indexPath.row]
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text =  createText(with: data)
        return cell
    }
    private func createText(with data: ServiceController.DayData) -> String?{
        let dateString = DateFormatter.prettyFormatter.string(from: data.date)
        return "\(dateString): \(data.Count)"
    }
//Data of covid cases
  
    private var dayData: [ServiceController.DayData] = []{
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private var scope: ServiceController.DataScope = .national
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "covid cases"
        configureTable()
        
        createFilterButton()
        fetchData()
    }
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    private func configureTable(){
        view.addSubview(tableView)
        tableView.dataSource = self
    }
    private func createFilterButton(){
        let buttonTitle: String = {
            switch scope{
            case .national: return "National"
            case .state(let state): return state.name
            }
        }()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: buttonTitle,
            style: .done,
            target: self,
            action: #selector(didTapFilter)
        )
    }
    private func fetchData(){
        ServiceController.shared.getCovidData(for: scope){[weak self]
            result in
            switch result{
            case .success(let dayData):
                self?.dayData = dayData
            case .failure(let error):
                print(error)
            }
        }  }
    @objc private func didTapFilter(){
        let vc = FViewController()
        vc.completion = { [weak self] state in
            self?.scope =  .state(state)
            self?.fetchData()
            self?.createFilterButton()
        }
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
        
    }
    
}
