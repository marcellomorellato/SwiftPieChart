//
//  ViewController.swift
//  SwiftPieChartDemo
//
//  Created by Marcello on 24/05/22.
//

import UIKit
import SwiftUI
import SwiftPieChart

class ViewController: UIViewController {
    var chart: PieChartView!
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        chart = PieChartView(values: [200, 100, 400], names: ["Ordini inviati", "Ordini Temporanei", "Ordini bloccati" ], formatter: { value in
            String(format: "$%.2f", value)
        },backgroundColor: .white, widthFraction: 0.25)
        
        chart.frame(width: containerView.bounds.width, height: containerView.bounds.height, alignment: .topLeading)
        let chartHostingVC = UIHostingController(rootView: chart)
        addChild(chartHostingVC)
        chartHostingVC.view.frame = containerView.bounds
        containerView.addSubview(chartHostingVC.view)
        chartHostingVC.didMove(toParent: self)
    }


}

