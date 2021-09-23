

//
//  HistoryRecordVC.swift
//  Neat Calc
//
//  Created by hanmok on 2020/05/20.
//  Copyright © 2020 hanmok. All rights reserved.
//
// to table receiver

//from table sender

//view will transition listener! (receiver)

import UIKit
import RealmSwift

protocol FromTableToBaseVC{
    func copyAndPasteAns(ansString : String)
}

class HistoryRecordVC: UIViewController {
    
    let localizedStrings = LocalizedStringStorage()
    
    let ansToTableNotification = Notification.Name(rawValue: answerToTableNotificationKey)
    let viewWillTransitionNotification = Notification.Name(rawValue: viewWilltransitionNotificationKey)
    let viewWillDisappearBasicVCNotification = Notification.Name(rawValue: viewWillDisappearbasicViewControllerKey)
    let viewWillAppearBasicVCNotification = Notification.Name(rawValue: viewWillAppearbasicViewControllerKey)
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var deviceInfo = UIDevice.modelName
    
    let fontSize = FontSizes()
    let frameSize = FrameSizes()
    var tableView = UITableView()
    
    var historyRecords : Results<HistoryRecord>!
    
    let colorList = ColorList()
    
    var userDefaultSetup = UserDefaultSetup()
    var isLightModeOn = false
    
    let realm = RealmService.shared.realm
    
    let trashbinImage = UIImageView(image: #imageLiteral(resourceName: "trashBinSample"))
    let trashbinHelper = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    
    var isOrientationPortrait = true
    
    var willbasicVCdisappear = false
    
    var FromTableToBaseVCdelegate : FromTableToBaseVC?
    
//    var testCounter = 1
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        
        //        isOrientationPortrait
        if UIDevice.current.orientation.isLandscape {
            isOrientationPortrait = false
            print("Landscape viewWillTransition baseVC")
        } else if UIDevice.current.orientation.isPortrait {
            print("Portrait viewWillTransition baseVC")
            isOrientationPortrait = true
        }else{
            print("Neither Landscape nor Portrait mode viewWillTransition baseVC ")
        }
        
        
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        isOrientationPortrait = screenWidth > screenHeight ? true : false
        
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HistoryRecordCell.self, forCellReuseIdentifier: "HistoryRecordReuseIdentifier")
        tableView.reloadData()
        //        print("end of viewWillTransition , willbasicVCdisappear : \(willbasicVCdisappear)")
    }
    // 왜 그런데 .. 두번씩 실행돼?
    //ipod 의 경우에도 새로운 사이즈가 필요함.
    // 20 정도 줄이면 될 것 같은데?
    // X 이후 버전은 20정도 늘리면 될 것 같고.
    override func viewDidLoad() {
        print("viewDidLoad table")
        //        let modifiedDeviceInfo = deviceInfo.removeFirst()
        if deviceInfo.first == " "{
            deviceInfo.removeFirst()
        }
        //        userDefaultSetup.getUserDeviceVersionInfo()
        //        userDefaultSetup.getIsLightModeOn()
        print("type of userDefaultSetup.getUserDeviceVersionInfo() : \(userDefaultSetup.getUserDeviceVersionInfo())")
        
        if userDefaultSetup.getUserDeviceVersionInfo() == "ND"{ // Not Determined
            userDefaultSetup.setUserDeviceVersionInfo(userDeviceVersionInfo: deviceInfo)
            
            if userDefaultSetup.getUserDeviceVersionInfo().contains("iPh"){
                print("iPh 포함")
                switch userDefaultSetup.getUserDeviceVersionInfo().first {
                case "4","5","6","7","8","S":
                    userDefaultSetup.setUserDeviceVersionTypeInfo(userDeviceVersionTypeInfo: "P")
                    print("first Name : \(String(describing: userDefaultSetup.getUserDeviceVersionInfo().first))")
                default:
                    userDefaultSetup.setUserDeviceVersionTypeInfo(userDeviceVersionTypeInfo: "MP")
                    print("first Name : \(String(describing: userDefaultSetup.getUserDeviceVersionInfo().first))")
                    print("what was the version ?:\(userDefaultSetup.getUserDeviceVersionInfo())")
                }
            }
            else if userDefaultSetup.getUserDeviceVersionInfo().contains("iPo"){
                userDefaultSetup.setUserDeviceVersionTypeInfo(userDeviceVersionTypeInfo: "LP")
                print("iPod touch model.")
            }
        }else{
            print("modelName : \(deviceInfo)")
        }
        print("userDefaultSetup.getUserDeviceVersionInfo() : \(userDefaultSetup.getUserDeviceVersionInfo())")
        print("deviceType : \(userDefaultSetup.getUserDeviceVersionTypeInfo())")
        // P : Popular, MP : Most Popular, LP : Least Popular
        
        print("modelName : \(deviceInfo)")
        //        print("deviceType : \(type(of: deviceInfo))")
        
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        isOrientationPortrait = screenHeight > screenWidth ? true : false
        
        super.viewDidLoad()
        
        createObservers()
        
        if UIDevice.current.orientation.isLandscape {
            isOrientationPortrait = false
        } else if UIDevice.current.orientation.isPortrait {
            isOrientationPortrait = true
        }
        
        returnLightMode()
        
        setupLayout()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HistoryRecordCell.self, forCellReuseIdentifier: "HistoryRecordReuseIdentifier")
        historyRecords = realm.objects(HistoryRecord.self)
        
        tableView.setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: false)
        
        self.tableView.reloadData()
        addTargetSetup()
        
        tableView.setContentOffset(.zero, animated: false)
        
        
//                let indexPath = IndexPath(row: historyRecords.count - 1, section: 0)
        //                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
        //        let indexPath = IndexPath(row: 0, section: 1)
//        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        //        print("end of viewDidLoad, willbasicVCdisappear : \(willbasicVCdisappear)")
        
        
        //test1 it works.. perfect!
//        DispatchQueue.main.async {
//            if self.historyRecords.count != 0{
//                let indexPath = IndexPath(row: self.historyRecords.count-1, section: 0)
//                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//            }
//            }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear table")
    }
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear table")
        viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear table")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear table")
        //        print("viewWillDisappear called in table, willbasicVCdisappear : \(willbasicVCdisappear)")
    }
    
    func createObservers(){
        print("createObservers table")
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryRecordVC.answerToTable(notification:)), name: ansToTableNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(HistoryRecordVC.transitionOccured(notification:)),name: viewWillTransitionNotification,object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryRecordVC.viewWillDisappearBasicVC(notification:)), name: viewWillDisappearBasicVCNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(HistoryRecordVC.viewWillAppearBasicVC(notification:)),name: viewWillAppearBasicVCNotification,object: nil)
    }
    
    @objc func viewWillDisappearBasicVC(notification : NSNotification){
        print("viewWillDisappearBasicVC table")
        if !willbasicVCdisappear{
            willbasicVCdisappear.toggle()
        }
    }
    
    @objc func viewWillAppearBasicVC(notification : NSNotification){
        print("viewWillAppearBasicVC table")
        if willbasicVCdisappear{
            willbasicVCdisappear.toggle()
        }
    }
    
    
    @objc func answerToTable(notification: NSNotification) {
        print("answerToTable table")
        loadData()
    }
    
    @objc func transitionOccured(notification: NSNotification){
        print("transitionOccured table")
        guard let newPortrait = notification.userInfo?["orientation"] as? Bool else {
            print("there's an error in tableView transitionOccured function")
            return }
        
        isOrientationPortrait = newPortrait // 현재 아무런 역할도 안함
    }
    
    func loadData(){
        print("loadData table")
        historyRecords = realm.objects(HistoryRecord.self)
        tableView.reloadData()
    }
    
    
    func returnLightMode(){
        print("returnLightMode table")
        isLightModeOn = userDefaultSetup.getIsLightModeOn()
    }
    
    func setupLayout(){
        print("setupLayout table")
        for subview in tableView.subviews{
            subview.removeFromSuperview()
        }
        
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
        
        view.addSubview(tableView)
        
        if isOrientationPortrait{
            tableView.pinWithSpace2(to: view, type : userDefaultSetup.getUserDeviceVersionTypeInfo())
            //            tableView.pinWithSpace2(to: view)
            
            
            
            
            view.addSubview(infoView)
            infoView.translatesAutoresizingMaskIntoConstraints = false
            infoView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            infoView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            infoView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            
            switch userDefaultSetup.getUserDeviceVersionTypeInfo() {
            //  MP : Most popular, P : Popular, LP : Least Popular
            //            case "MP" : infoView.heightAnchor.constraint(equalToConstant: 70).isActive = true
            case "MP" : infoView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            case "LP" : infoView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            default:
                infoView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            }
            
            infoView.addSubview(infoLabel)
            infoLabel.translatesAutoresizingMaskIntoConstraints = false
            
            infoLabel.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
            
            
            infoLabel.bottomAnchor.constraint(equalTo: infoView.bottomAnchor, constant: -7).isActive = true
            
            infoView.addSubview(trashButton)
            trashButton.translatesAutoresizingMaskIntoConstraints = false
            trashButton.rightAnchor.constraint(equalTo: infoView.rightAnchor, constant: 0).isActive = true
            
            trashButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
            trashButton.bottomAnchor.constraint(equalTo: infoView.bottomAnchor).isActive = true
            trashButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            
            //            trashButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
            trashButton.addSubview(trashbinImage)
            trashButton.addSubview(trashbinHelper)
            trashbinHelper.translatesAutoresizingMaskIntoConstraints = false
            trashbinHelper.topAnchor.constraint(equalTo: trashButton.topAnchor).isActive = true
            trashbinHelper.bottomAnchor.constraint(equalTo: trashButton.bottomAnchor).isActive = true
            trashbinHelper.leftAnchor.constraint(equalTo: trashButton.leftAnchor).isActive = true
            trashbinHelper.widthAnchor.constraint(equalTo: trashButton.widthAnchor, multiplier: 0.1).isActive = true
            
            trashbinImage.translatesAutoresizingMaskIntoConstraints = false
            trashbinImage.heightAnchor.constraint(equalTo: trashButton.heightAnchor, multiplier: 0.9).isActive = true
            trashbinImage.bottomAnchor.constraint(equalTo: trashButton.bottomAnchor).isActive = true
            trashbinImage.leftAnchor.constraint(equalTo: trashbinHelper.rightAnchor).isActive =  true
            trashbinImage.widthAnchor.constraint(equalTo: trashButton.widthAnchor, multiplier: 0.55).isActive = true
            
            
            if isLightModeOn{
                infoView.backgroundColor = colorList.bgColorForExtrasBM
                
                tableView.backgroundColor = colorList.bgColorForEmptyAndNumbersBM // 들췄을 때 color.
                
                
                view.addSubview(subHistoryLight)
                subHistoryLight.translatesAutoresizingMaskIntoConstraints = false
                subHistoryLight.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
//                subHistoryLight.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                
                //                if userDefaultSetup.getUserDeviceVersionTypeInfo() == "LP"{
                ////                    subhis
                //                    subHistoryLight.heightAnchor.constraint(equalToConstant: 10).isActive = true
                //                }else{
                subHistoryLight.heightAnchor.constraint(equalToConstant: 15).isActive = true
                //                }
                //                subHistoryLight.heightAnchor.constraint(equalToConstant: 15).isActive = true
                
                subHistoryLight.widthAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 0.6).isActive = true
                subHistoryLight.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                
                
                
            }else{
                infoView.backgroundColor = colorList.bgColorForExtrasDM
                infoLabel.textColor = .white
                
                tableView.backgroundColor = colorList.bgColorForEmptyAndNumbersDM
                
                view.addSubview(subHistoryDark)
                subHistoryDark.translatesAutoresizingMaskIntoConstraints = false
                subHistoryDark.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive
                    = true
                subHistoryDark.heightAnchor.constraint(equalToConstant: 15).isActive = true
                
                subHistoryDark.widthAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 0.6).isActive = true
                subHistoryDark.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                
            }
            
//            view.addSubview(historyDragExitHelper)
//            historyDragExitHelper.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
//            historyDragExitHelper.heightAnchor.constraint(equalToConstant: 70).isActive = true
////            historyDragExitHelper.widthAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 0.75).isActive = true
//            historyDragExitHelper.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
//            historyDragExitHelper.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
//            historyDragExitHelper.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            
            view.addSubview(historyClickButton)
            historyClickButton.translatesAutoresizingMaskIntoConstraints = false
            historyClickButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
//            historyClickButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            historyClickButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
            historyClickButton.widthAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 0.6).isActive = true
//            historyClickButton.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
//            historyClickButton.backgroundColor = UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 0.5)
            historyClickButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            
            
        }else{
            tableView.pin(to: view) // 이거같은데?
//            tableView.backgroundColor = .blue
            
            tableView.backgroundColor = isLightModeOn ? colorList.bgColorForEmptyAndNumbersBM : colorList.bgColorForEmptyAndNumbersDM
        }
    }
    
    @objc func backToBaseController(){
        print("backToBaseController table")
        if willbasicVCdisappear{
            willbasicVCdisappear.toggle()
        }
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func addTargetSetup(){
        print("addTargetSetup table")
        historyClickButton.addTarget(self, action: #selector(backToBaseController), for: .touchUpInside)
        historyClickButton.addTarget(self, action: #selector(backToBaseController), for: .touchDragExit)
//        historyDragExitHelper.addTarget(self, action: #selector(backToBaseController), for: .touchDragExit)
//        historyDragExitHelper.addTarget(self, action: #selector(lastOneClicked), for: .touchUpInside)
        trashButton.addTarget(self, action: #selector(removeAllAlert), for: .touchUpInside)
    }
//    @objc func lastOneClicked() {
////        backToBaseController()
//        if historyRecords.count != 0 {
//            let historyIndex = historyRecords.count - 1


//            FromTableToBaseVCdelegate?.copyAndPasteAns(ansString: historyRecords[historyIndex].resultString ?? "nothing transmitted")
//        }
//
//
//
//        loadData() // 아.. 이게.. 알았다.. 모드 두개 비교를 해봐야겠다.
//        if !(!UIDevice.current.orientation.isPortrait && !willbasicVCdisappear){
//            backToBaseController()
//        }
//    }
    
    @objc func removeAllAlert(){
        print("removeAllAlert table")
        showAlert(title: "Clear History", message: localizedStrings.removeAll,
                  handlerA: { actionA in
                  },
                  handlerB: { actionB in
                    
                    for element in self.historyRecords{
                        RealmService.shared.delete(element)
                    }
                    self.tableView.reloadData()
                    
                    self.showToast(message: self.localizedStrings.deleteAllComplete, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.6, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                  })
    }
    
    @objc func backToOriginalColor(sender : UITableViewCell){
        print("backToOriginalColor table")
        if isLightModeOn{
            sender.backgroundColor = colorList.bgColorForEmptyAndNumbersBM
        }else{
            sender.backgroundColor = colorList.bgColorForEmptyAndNumbersDM
        }
    }
    
    let infoView : UIView = {
        let sub = UIView()
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let infoLabel : UILabel = {
        let label = UILabel()
        label.text = "History"
        label.font = .boldSystemFont(ofSize: 20)
        
        return label
    }()
    
    let trashButton : UIButton = {
        let sub = UIButton(type: .custom)
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let historyClickButton : UIButton = {
        let sub = UIButton(type: .custom)
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
//    let historyDragExitHelper : UIButton = {
//        let sub = UIButton(type: .custom)
//        sub.translatesAutoresizingMaskIntoConstraints = false
//        return sub
//    }()
    
    let fillBottom : UIView = {
        let sub = UIView()
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let subHistoryLight : UIImageView = {
        let sub = UIImageView(image: #imageLiteral(resourceName: "historyUpwardLight"))
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let subHistoryDark : UIImageView = {
        let sub = UIImageView(image: #imageLiteral(resourceName: "historyUpwardDark"))
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
}





// MARK: - Table view data source.
extension HistoryRecordVC : UITableViewDataSource, UITableViewDelegate{
    
    //additional
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection table")
        print("section : \(section)")
//        if section == 0 {
        return historyRecords.count
//        }
//        else {
//            return 1
//        }
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt table")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryRecordReuseIdentifier") as? HistoryRecordCell else{ return UITableViewCell()}
        
        //reverse mode,  top the latest
        let maxNumber = historyRecords.count
        let historyIndex = maxNumber - indexPath.row - 1
        
        // bottom the latest
        
        //original mode
//        let historyIndex = indexPath.row
        
        

        let historyRecord = historyRecords[historyIndex]
        
        cell.configure(with: historyRecord, orientationPortrait : isOrientationPortrait, willbasicVCdisappear : willbasicVCdisappear)
        cell.colorSetup(isLightModeOn: isLightModeOn)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt table")
        
        
       
        //reverse mode
        let maxNumber = historyRecords.count
        let historyIndex = maxNumber - indexPath.row - 1
       
        
        //original mode
//        let historyIndex = indexPath.row
       
        
        FromTableToBaseVCdelegate?.copyAndPasteAns(ansString: historyRecords[historyIndex].resultString ?? "nothing transmitted")
        

        
        loadData() // 아.. 이게.. 알았다.. 모드 두개 비교를 해봐야겠다.
        if !(!UIDevice.current.orientation.isPortrait && !willbasicVCdisappear){
            backToBaseController()
        }
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print("trailingSwipeActionConfigurationForRowAt table")
        
//        let delete = UIContextualAction(style: .normal, title: localizedStrings.delete) { (action, view, completionHandler) in
        let delete = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            
            //reverse Mode
            let maxNumber = self.historyRecords.count
            let historyIndex = maxNumber - indexPath.row - 1
            
        
            
            //original Mode
//            let historyIndex = indexPath.row
            
            
            if let record = self.historyRecords?[historyIndex]{
                RealmService.shared.delete(record)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            self.showToast(message: self.localizedStrings.deleteComplete, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.4, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
            
            
            completionHandler(true)
            
        }
//        let trashbinImage = UIImageView(image: #imageLiteral(resourceName: "trashBinSample"))
        delete.image = UIImage(systemName: "trash.fill")
//        delete.image = UIImage(named: "trashBinSample")
        delete.backgroundColor = .red
        
        let rightSwipe = UISwipeActionsConfiguration(actions: [delete])
        return rightSwipe
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print("leadingSwipeActionsConfigurationForRowAt table")
        
//        let copyAction = UIContextualAction(style: .normal, title: localizedStrings.copy) { (action, view, completionHandler) in
        let copyAction = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            
            
            
            //reverse Mode
            let maxNumber = self.historyRecords.count
            let historyIndex = maxNumber - indexPath.row - 1
            
            
            //original Mode
//            let historyIndex = indexPath.row
            
            
            if self.isOrientationPortrait{
                if let record = self.historyRecords?[historyIndex]{
                    let toBeSaved = record.processStringHis! + "=" + record.resultString!
                    UIPasteboard.general.string = toBeSaved
                }
            }else{
                if let record = self.historyRecords?[historyIndex]{
                    let toBeSaved = record.processStringCalc! + "=" + record.resultString!
                    UIPasteboard.general.string = toBeSaved
                }
            }
            
            
            
            self.showToast(message: self.localizedStrings.copyComplete, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.5, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
            
            completionHandler(true)
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            
            //reverse Mode
                        let maxNumber = self.historyRecords.count
            let historyIndex = maxNumber - indexPath.row - 1
           
            
            //original Mode
//            let historyIndex = indexPath.row
            
            
            if self.isOrientationPortrait{
                if let record = self.historyRecords?[historyIndex]{
                    let toBeSaved = record.processStringHis! + "=" + record.resultString!
                    
                    UIPasteboard.general.string = toBeSaved
                    let activityController = UIActivityViewController(activityItems: [toBeSaved], applicationActivities: nil)
                    
                    self.present(activityController, animated: true, completion: nil)
                    
                }
            }else{
                if let record = self.historyRecords?[historyIndex]{
                    let toBeSaved = record.processStringCalc! + "=" + record.resultString!
                    let activityController = UIActivityViewController(activityItems: [toBeSaved], applicationActivities: nil)
                    
                    self.present(activityController, animated: true, completion: nil)
                    
                    UIPasteboard.general.string = toBeSaved
                }
            }
            
            
            completionHandler(true)
        }
        
        copyAction.image = UIImage(systemName: "doc.on.doc.fill")
        copyAction.backgroundColor = colorList.bgColorForExtrasDM
        
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        shareAction.backgroundColor = colorList.bgColorForExtrasMiddle
        
        let leftSwipe = UISwipeActionsConfiguration(actions: [copyAction, shareAction])
        return leftSwipe
    }
}
