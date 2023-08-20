//
//  SchoolListViewController.swift
//  08201990-Ravikanth-Thummala-NYCSchools
//
//  Created by Ravikanth Thummala on 8/20/23.
//

import UIKit

class SchoolListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    
    let viewModel = SchoolViewModel()
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up table view delegate and data source.
        tableView.delegate = self
        tableView.dataSource = self
        
        // Fetch school data and SAT scores from the API.
        fetchDataAndSATScores()
    }
    
    // MARK: - Search Bar Delegate Methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterSchoolsBySearchText(searchText)
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        viewModel.filterSchoolsBySearchText("")
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Bar Button Methods

    @IBAction func reloadButton(_ sender: Any) {
        // Fetch school data and SAT scores from the API.
        fetchDataAndSATScores()
    }
    
    // MARK: - Private Helper Methods
    
    private func fetchDataAndSATScores() {
        LoadingIndicatorView.show("Fetching data ....")
        viewModel.fetchData { [weak self] error in
            if let error = error {
                LoadingIndicatorView.hide()
                AlertController.showTextAlert(on: self!, with: "Error fetcing data", with: error.localizedDescription)
            } else {
                self?.fetchSATScores()
            }
        }
    }
    
    private func fetchSATScores() {
        viewModel.fetchSATScores { [weak self] error in
            LoadingIndicatorView.hide()
            if let error = error {
                AlertController.showTextAlert(on: self!, with: "Error fetching SAT scores" , with: error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    self?.appendSATScoresToSchools()
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    private func appendSATScoresToSchools() {
        var updatedSchools: [School] = []
        
        for schoolIndex in 0..<viewModel.numberOfSchools() {
            if let originalSchool = viewModel.school(at: schoolIndex),
               let satScore = viewModel.schoolSAT(at: schoolIndex) {
                
                var updatedSchool = originalSchool
                updatedSchool.satScores = satScore
                updatedSchools.append(updatedSchool)
            }
        }
        
        viewModel.updateSchools(updatedSchools)
    }
    ///Instead of Segue do a select Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.isFiltering {
            let school = viewModel.filteredSchool(at: indexPath.row)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "SchoolDetailViewController") as? SchoolDetailViewController
            vc!.school = school
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            let school = viewModel.school(at: indexPath.row)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "SchoolDetailViewController") as? SchoolDetailViewController
            vc!.school = school
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.isFiltering {
            return viewModel.numberOfFilteredSchools()
        } else {
            return viewModel.numberOfSchools()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "schoolCell", for: indexPath)
        
        if viewModel.isFiltering {
            if let school = viewModel.filteredSchool(at: indexPath.row) {
                cell.textLabel?.text = school.school_name
                cell.detailTextLabel?.text = "\(school.primary_address_line_1 ?? ""), \(school.city ?? ""), \(school.state_code ?? "") \(school.zip ?? "")"
            }
        } else {
            if let school = viewModel.school(at: indexPath.row) {
                cell.textLabel?.text = school.school_name
                cell.detailTextLabel?.text = "\(school.primary_address_line_1 ?? ""), \(school.city ?? ""), \(school.state_code ?? "") \(school.zip ?? "")"
            }
        }
        
        return cell
    }
}

