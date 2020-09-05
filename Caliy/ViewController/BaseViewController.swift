import UIKit
import AudioToolbox
import RealmSwift

//let answerToTableNotificationKey = "com.hanmok.Neat-Calc.ansToTable"
//let answerFromTableNotificationKey = "com.hanmok.Neat-Calc.ansFromTable"
//let viewWilltransitionNotificationKey = "com.hanmok.Neat-Calc.transitionAlert"

class BaseViewController: UIViewController, FromTableToBaseVC {
    
    let ansFromTableNotification = Notification.Name(rawValue: answerFromTableNotificationKey)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Basic setup
    let childTableVC = HistoryRecordVC()
    let newTableVC = HistoryRecordVC()
    
    let colorList = ColorList()
    var historyRecords : Results<HistoryRecord>!
    var userDefaultSetup = UserDefaultSetup()
    var frameView = UIView()
    let localizedStrings = LocalizedStringStorage()
    var deviceName : String?
    var isOrientationPortrait = true
    let fontSize = FontSizes()
    let frameSize = FrameSizes()
    let reviewService = ReviewService.shared
    var lineSettingsum = 0
//    var floatingPointNumberCount = 0
//    var isFloatingNumberCountUnder10 = true
//    var
    
    
    var iPressed = ""
    var countingNumber = 1
    let nf1 = NumberFormatter()
    let nf6 = NumberFormatter()
    let nf11 = NumberFormatter()
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            isOrientationPortrait = false
            
        } else if UIDevice.current.orientation.isPortrait {
            isOrientationPortrait = true
        }
        
        setupPositionLayout()
        colorAndImageSetup()
        addTargetSetup()
        
        printProcess()
        
        nfSetup()
        
        let isPortrait = ["orientation" : isOrientationPortrait]
        let name = Notification.Name(rawValue: viewWilltransitionNotificationKey)
        
        NotificationCenter.default.post(name: name, object: nil, userInfo: isPortrait as [AnyHashable : Any])
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let name = Notification.Name(rawValue: viewWillAppearbasicViewControllerKey)
        NotificationCenter.default.post(name : name, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let name = Notification.Name(rawValue: viewWillDisappearbasicViewControllerKey)
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    
    override func viewDidLoad() {
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        isOrientationPortrait = screenHeight > screenWidth ? true : false
        
        childTableVC.FromTableToBaseVCdelegate = self
        newTableVC.FromTableToBaseVCdelegate = self
        
        
        super.viewDidLoad()
        
        let realm = RealmService.shared.realm
        historyRecords = realm.objects(HistoryRecord.self)
        defaultSetup()
        setupPositionLayout()
        colorAndImageSetup()
        addTargetSetup()
        
        nfSetup()
    }
    
    func nfSetup(){
//        let nf6 = NumberFormatter() // declared at the first
        
        nf1.roundingMode = .down
        nf1.maximumFractionDigits = 1
        
        nf6.roundingMode = .down
        nf6.maximumFractionDigits = 6
        
        nf11.roundingMode = .down
        nf11.maximumFractionDigits = 10
        
        
    }
    
    
    func copyAndPasteAns(ansString: String) {
        print("copyAndPasteAns called")
        
        var plusNeeded = false
        var parenNeeded = false
        var manualClearNeeded = false
        let valueFromTable = ansString
        
        if process != ""{
            let lastChar = process[process.index(before:process.endIndex)]
            
            switch lastChar {
            case "+", "-", "×","÷" : parenNeeded.toggle()
            case "(" : print("none")
            case ")" : plusNeeded.toggle()
            parenNeeded.toggle()
            case "=" : manualClearNeeded.toggle()
            default:
                plusNeeded.toggle()
                parenNeeded.toggle()
            }
            
        }else if process == ""{
        }
        
        if valueFromTable.contains("-") && manualClearNeeded{
            manualClear()
        }
        
        if plusNeeded{
            manualOperationPressed(operSymbol: "+")
        }
        
        if parenNeeded && valueFromTable.contains("-"){
            manualParenthesis(trueToOpen: true)
        }
        
        if valueFromTable.contains("-"){
            manualOperationPressed(operSymbol: "-")
        }
        
        inputNumberPressedAtOnce(numString : valueFromTable)
        
        if parenNeeded && valueFromTable.contains("-"){
            manualParenthesis(trueToOpen: false)
        }
        
//        printLineSetterElements("pasteAns!!!!!")
        
    }
    
    
    
    
    func inputNumberPressedAtOnce(numString : String){
     
        countingNumber += 1
        
        if isAnsPressed{
            clear()
            process = ""
            isAnsPressed = false
        }
        addPOfNumsAndOpers()
        addStrForProcess()
        
        if pOfNumsAndOpers[setteroi] == "op"{
            setteroi += 1
        }
        isNegativePossible = false
        let freshString = removeMinusCommaDot0(from: numString)
        
        tempDigits[pi][ni[pi]] += freshString
        process += freshString
        if let doubleNumber = Double(freshString){
            
            DS[pi][ni[pi]] = doubleNumber
            freshDI[pi][ni[pi]] = 1
            if tempDigits[pi][ni[pi]].contains("-"){
                DS[pi][ni[pi]] *= -1
            }
        }
        //        checkIndexes(saySomething: "inputNumberPressedAtOnce")
        addPOfNumsAndOpers()
        pOfNumsAndOpers[setteroi] = "n"
        addStrForProcess()
        showAnsAdvance()
        printProcess() // 이거 없애면 숫자들 사이 , 가 없어짐.
    }
    
    func removeMinusCommaDot0(from stringValue : String ) -> String{
        var stringToReturn = stringValue
        if stringValue.hasPrefix("-"){
            stringToReturn = String(stringValue.dropFirst())
        }
        if stringValue.contains(","){
            stringToReturn = stringToReturn.components(separatedBy: ",").joined()
        }
        if stringToReturn.contains("."){
            if let double = Double(stringValue){
                let int = Int(double)
                if double - Double(int) == 0{
                    stringToReturn = String(stringToReturn.dropLast())
                    stringToReturn = String(stringToReturn.dropLast())
                }
            }
        }
        return stringToReturn // without , - .0
    }
    
    
    
  
    
    var isSoundOn = true
    var isLightModeOn = false
    var isNotificationOn = false
    var numberReviewClicked = 0
    
    let tagToString = [1 : "1", 2 : "2", 3 : "3", 4 : "4", 5 : "5", 6 : "6", 7 : "7", 8 : "8", 9 : "9", 0 : "0", -1 : "00", -2 : ".", 11 : "Clear", 12 : "(", 13 : ")", 14 : "÷", 15 : "×", 16 : "+", 17 : "-", 18 : "=", 21 : "del", 31 : "etc1", 32 : "etc2", 33 : "etc3", 34 : "etc4" ]
    
    let tagToUnitSize : [Character : Double] =  ["1" : 0.02857142857, "2" : 0.03703703704, "3" : 0.03846153846, "4" : 0.04, "5" : 0.03846153846, "6" : 0.04, "7" : 0.03571428571, "8" : 0.04, "9" : 0.04, "0" : 0.03846153846, "," : 0.01724137931, "." : 0.01724137931, ")" : 0.02272727273, "(" : 0.02272727273, "+" : 0.04, "×" : 0.04, "÷" : 0.04, "-" : 0.02777777778, "=" : 0.02777777778]
    
    let tagToUnitSizeString : [String : Double] =  ["1" : 0.02857142857, "2" : 0.03703703704, "3" : 0.03846153846, "4" : 0.04, "5" : 0.03846153846, "6" : 0.04, "7" : 0.03571428571, "8" : 0.04, "9" : 0.04, "0" : 0.03846153846, "," : 0.01724137931, "." : 0.01724137931, ")" : 0.02272727273, "(" : 0.02272727273, "+" : 0.04, "×" : 0.04, "÷" : 0.04, "-" : 0.02777777778, "=" : 0.02777777778]
    
    
    var setteroi : Int = 0
    var sumOfUnitSizes : [Double] = [0.0]
    var pOfNumsAndOpers = [""]
    var pOfNumsAndOpersCount = 1
    var strForProcess = [""]
    
//    var lastMovePP : [[Int]] = [[0],[0],[0]] // lastMove Process Position
    var lastMoveOP : [[Int]] = [[0],[0],[0]]
    
    
    //    var criteriaForProcesses = [0.9, 1.4, 1.8]
    var numOfEnter = [0,0,0]
    var dictionaryForLine = [Int : String]()
    
    //    var dicForProcess = [Int : String]()
    
    var numParenCount = 0
    //MARK: - MAIN FUNCTIONS
    let numbers : [Character] = ["0","1","2","3","4","5","6","7","8","9","."]
    let operators : [Character] = ["+","×","-","÷"]
    let parenthesis : [Character] = ["(",")"]
    let notToDeleteList : [Character] = ["+","-","×","÷","(",")"]
    
    var isNegativePossible = true
    var isAnsPressed = false
    
    var pi = 0 // index for parenthesis.
    var ni = [0] // increase after pressing operation button.
    var tempDigits = [[""]] // save all digits to make a number
    var DS = [[0.0]] // Double Numbers Storage
    var answer : [[Double]] = [[100]] // the default value
    
    var operationStorage = [[""]]
    var muldiOperIndex = [[false]] // true if it is x or / .
    
    var freshDI = [[0]] // 0 : newly made, 1: got UserInput, 2 : used
    var freshAI = [[0]] // 0 :newly made, 1 : calculated, 2 : used
    
    var niStart = [[0,0]] // remember the indexes to calculate (within parenthesis)
    var niEnd = [[0]]
    
    var piMax = 0
    var indexPivotHelper = [false]
    var numOfPossibleNegative = [1] // 123 x (1 + 2) x (3 + 4 :  -> [1,2,0]
    var positionOfParen = [[0]] // remember the position of empty DS
    var isNegativeSign = [[false, false]]
    
    
    var process = ""
    // if you want operate after press ans button, this value will come up and used.
    var saveResult : Double?
    var result : Double? // to be printed, one of the answer array.
    //    var isSaveResultInt : Bool?
//    var floatingNumberDigits : Int?
    var copypi = 0
    var copyni = [0]
    var copytempDigits = [[""]]
    var copyDS = [[0.0]]
    var copyanswer : [[Double]] = [[100]]
    var copyoperationStorage = [[""]]
    var copymuldiOperIndex = [[false]]
    var copyfreshDI = [[0]]
    var copyfreshAI = [[0]]
    var copyniStart = [[0,0]]
    var copyniEnd = [[0]]
    var copypiMax = 0
    var copyindexPivotHelper = [false]
    var copynumOfPossibleNegative = [1]
    var copypositionOfParen = [[0]]
    var copyisNegativeSign = [[false, false]]
    var copyisNegativePossible = true
    var copyisAnsPressed = false
    var copyprocess = ""
    var copyresult : Double? // to be printed, one of the answer array.
    var copysaveResult : Double?
    
    var deleteTimer = Timer()
    var deleteTimer2 = Timer()
    var deleteTimerInitialSetup = Timer()
    var deleteTimerPause = Timer()
    var deleteSpeed = 0.5
    let deletePause = 2.35
    let deleteInitialSetup = 2.5
    
    var showingAnsAdvance = false
    
    
    @objc func numberPressed(sender : UIButton){
//        isFloatingNumberCountUnder10 = true
//        if tempDigits[pi][ni[pi]].count >= 12{ // 자릿수 합이 16 이상일 경우 Big Decimal 필요. 음..
//            let tempDouble = Double(tempDigits[pi][ni[pi]])
//            let tempDecimalCount = tempDouble!.decimalCount()
//            if tempDecimalCount >= 10{
//                isFloatingNumberCountUnder10 = false
//            }
//            print("tempDouble.count : \(tempDouble?.decimalCount())")
//
//        }
        
//        if tempDigits[pi][ni[pi]].count >= 12{
//            print("뭐가문제니?")
//            let dummyStr1 = Double(tempDigits[pi][ni[pi]])
//            let testStr1 = nf1.string(for: dummyStr1)
//            let testStr2 = nf11.string(for: dummyStr1)
//            print("testStr1 : \(testStr1), testStr2 : \(testStr2)")
//            if testStr2!.count - testStr1!.count >= 9{
//                isFloatingNumberCountUnder10 = false
//                print("floatingNumber is too long! ")
//            }
//        }
        
        
//        if isFloatingNumberCountUnder10{
            
            
        if let input = tagToString[sender.tag]{
            iPressed += input
            if isAnsPressed
            {
                clear()
                process = ""
                isAnsPressed = false
            }
            addPOfNumsAndOpers()
            addStrForProcess()
            // 이새끼..뭐지.. ? 만약 바로 전 입력이 '(' 이면, 이니까 괜찮.
            if pOfNumsAndOpers[setteroi] == "op"{
                setteroi += 1
//                printLineSetterElements("wwwwwtf")
            }
            
            
            // if made number is not greater than it's limit
            if (DS[pi][ni[pi]] > -1e14  && DS[pi][ni[pi]] < 1e14) && !((DS[pi][ni[pi]] >= 1e13 || DS[pi][ni[pi]] <= -1e13) && input == "00") {
                //기존 입력 : 0, -0, 공백, - && input : 0, 00
                if (input == "0" || input == "00") && (tempDigits[pi][ni[pi]] == "0" || tempDigits[pi][ni[pi]] == "-0" || tempDigits[pi][ni[pi]] == "" || tempDigits[pi][ni[pi]] == "-"){
                    switch tempDigits[pi][ni[pi]] {
                    case ""  :
                        tempDigits[pi][ni[pi]] += "0"
                        process += "0"
                        if input == "00"{sendNotification()}
                    case "-":
                        tempDigits[pi][ni[pi]] += "0"
                        process += "0"
                        if input == "00"{sendNotification()}
                    case "0" : sendNotification();break
                    case "-0": sendNotification();break
                    default : break
                    }
                } // input : . && 기존 입력 : 공백 or - or 이미 . 포함.
                else if (input == ".") && (tempDigits[pi][ni[pi]] == "" || tempDigits[pi][ni[pi]] == "-" || tempDigits[pi][ni[pi]].contains(".")){//공백, - , . >> . : 모든 경우 수정됨.
                    switch tempDigits[pi][ni[pi]] {
                    case ""  :// 기존 입력 : 공백 >> 0. 삽입.
                        tempDigits[pi][ni[pi]]  += "0."
                        process += "0."
                    case "-" :// 기존 입력 : - >> 0. 삽입. ( 이미 - 는 들어가있음)
                        tempDigits[pi][ni[pi]] += "0."
                        process += "0."
                    default : break
                    }
                    sendNotification()
                }// 기존 입력 : 0 or -0 , 새 입력 : 0, 00, . 이 아닌경우!
                else if (input != "0" && input != "00" && input != ".") && (tempDigits[pi][ni[pi]] == "0" || tempDigits[pi][ni[pi]] == "-0"){ // 0 , -0 >> 숫자 입력 : 모든 경우 수정됨.
                    tempDigits[pi][ni[pi]].removeLast()
                    tempDigits[pi][ni[pi]] += input
                    
                    process.removeLast()
                    process += input
                    sendNotification()
                }// 괄호 닫고 바로 숫자 누른 경우.
                else if tempDigits[pi][ni[pi]].contains("parenclose") && operationStorage[pi][ni[pi]] == ""{
                    setteroi += 1
                    addSumOfUnitSizes()
                    sumOfUnitSizes[setteroi] += tagToUnitSize["×"]!
                    
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "oper"
                    
                    addStrForProcess()
                    strForProcess[setteroi] = "×"
                    
                    dictionaryForLine[setteroi] = "×"
                    // ["+","-","×","÷","(",")"]
                    setteroi += 1
                    addSumOfUnitSizes()
                    addPOfNumsAndOpers()
                    addStrForProcess()
                    
                    operInputSetup("×", ni[pi])
                    process += operationStorage[pi][ni[pi]]
                    indexUpdate()
                    tempDigits[pi][ni[pi]] = input
                    
                    if input == "."{
                        tempDigits[pi][ni[pi]] = "0."
                        process += "0"
                    }
                    
                    process += String(input)
                    sendNotification()
                }
                else { // usual case
                    tempDigits[pi][ni[pi]] += input
                    process += String(input)
                }
                
                if let safeDigits = Double(tempDigits[pi][ni[pi]]){
                    DS[pi][ni[pi]] = safeDigits
                    freshDI[pi][ni[pi]] = 1
                    isNegativePossible = false
                }
            } // end if DS[pi][ni[pi]] <= 1e14{
            else if ((DS[pi][ni[pi]] >= 1e13 || DS[pi][ni[pi]] <= -1e13) && input == "00") && (DS[pi][ni[pi]] < 1e14  && DS[pi][ni[pi]] > -1e14){

                tempDigits[pi][ni[pi]] += "0"
                process += "0"
                sendNotification()
                
                if let safeDigits = Double(tempDigits[pi][ni[pi]]){
                    DS[pi][ni[pi]] = safeDigits
                    freshDI[pi][ni[pi]] = 1
                    isNegativePossible = false
                }
                
            }// 15자리에서 .이 이미 있는 경우
            else if ((DS[pi][ni[pi]] >= 1e14 || DS[pi][ni[pi]] <= -1e14) && tempDigits[pi][ni[pi]].contains(".")){
                
                if input == "."{
                    //                    showToast(message: localizedStrings.modified, with: 1, for: 1,widthRatio: 0.4 , heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                    
                    self.showToast(message: self.localizedStrings.modified, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.4, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                    
                    
                    //                    process += "."
                    //                    tempDigits[pi][ni[pi]] = "."
                }else{
                    process += input
                    tempDigits[pi][ni[pi]] += input
                    
                    if let safeDigits = Double(tempDigits[pi][ni[pi]]){
                        DS[pi][ni[pi]] = safeDigits
                       
                        
                    }
                }
                
                
            }// 15자리에서 . 없는 경우
            else if ((DS[pi][ni[pi]] >= 1e14 || DS[pi][ni[pi]] <= -1e14) && !tempDigits[pi][ni[pi]].contains(".")){
                if input == "."{
                    process += String(input)
                    tempDigits[pi][ni[pi]] += "."
                    
                }else{ // 숫자 초과!!
                    
                    
                    self.showToast(message: self.localizedStrings.numberLimit, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.8, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                    
                }
            }
            addPOfNumsAndOpers()
            
            pOfNumsAndOpers[setteroi] = "n"
            
            addStrForProcess()
            showAnsAdvance()
            
            printProcess()
        } // end of if let input = tagToString[sender.tag]{
        //                pOfProperEnter
        //        pOfNumsAndOpers.append("")
//        }else{
//            floatingExceedToast()
//        }
    } // @IBAction func numberPressed(_ sender: UIButton){
    
    
    
    func manualNumberPressed(inputStr : String){
       
        let input = inputStr
        
        if isAnsPressed
        {
            clear()
            process = ""
            isAnsPressed = false
        }
        addPOfNumsAndOpers()
        addStrForProcess()
        
        if pOfNumsAndOpers[setteroi] == "op"{
            setteroi += 1
//            printLineSetterElements("wwwwwtf")
        }
        
        if (DS[pi][ni[pi]] > -1e14  && DS[pi][ni[pi]] < 1e14) && !((DS[pi][ni[pi]] > 1e13 || DS[pi][ni[pi]] < -1e13) && input == "00") {
            
            if (input == "0" || input == "00") && (tempDigits[pi][ni[pi]] == "0" || tempDigits[pi][ni[pi]] == "-0" || tempDigits[pi][ni[pi]] == "" || tempDigits[pi][ni[pi]] == "-"){
                switch tempDigits[pi][ni[pi]] {
                case ""  :
                    tempDigits[pi][ni[pi]] += "0"
                    process += "0"
                    
                case "-":
                    tempDigits[pi][ni[pi]] += "0"
                    process += "0"
                default : break
                }
            }
                
            else if (input == ".") && (tempDigits[pi][ni[pi]] == "" || tempDigits[pi][ni[pi]] == "-" || tempDigits[pi][ni[pi]].contains(".")){//공백, - , . >> . : 모든 경우 수정됨.
                switch tempDigits[pi][ni[pi]] {
                case ""  :
                    tempDigits[pi][ni[pi]]  += "0."
                    process += "0."
                case "-" :
                    tempDigits[pi][ni[pi]] += "0."
                    process += "0."
                default : break
                }
                
            }
                
            else if (input != "0" && input != "00" && input != ".") && (tempDigits[pi][ni[pi]] == "0" || tempDigits[pi][ni[pi]] == "-0"){ // 0 , -0 >> 숫자 입력 : 모든 경우 수정됨.
                tempDigits[pi][ni[pi]].removeLast()
                tempDigits[pi][ni[pi]] += input
                
                process.removeLast()
                process += input
                
            }
                // 괄호 닫고 바로 숫자 누른 경우.
            else if tempDigits[pi][ni[pi]].contains("parenclose") && operationStorage[pi][ni[pi]] == ""{
                setteroi += 1
                addSumOfUnitSizes()
                sumOfUnitSizes[setteroi] += tagToUnitSize["×"]!
                
                addPOfNumsAndOpers()
                pOfNumsAndOpers[setteroi] = "oper"
                
                addStrForProcess()
                strForProcess[setteroi] = "×"
                
                setteroi += 1
                addSumOfUnitSizes()
                addPOfNumsAndOpers()
                addStrForProcess()
                
                operInputSetup("×", ni[pi])
                process += operationStorage[pi][ni[pi]]
                indexUpdate()
                tempDigits[pi][ni[pi]] = input
                
                if input == "."{
                    tempDigits[pi][ni[pi]] = "0."
                    process += "0"
                }
                
                process += String(input)
                sendNotification()
            }
                
            else { // usual case
                tempDigits[pi][ni[pi]] += input
                process += String(input)
            }
            
            if let safeDigits = Double(tempDigits[pi][ni[pi]]){
                DS[pi][ni[pi]] = safeDigits
                freshDI[pi][ni[pi]] = 1
                isNegativePossible = false
            }
        }
        else if ((DS[pi][ni[pi]] > 1e14 || DS[pi][ni[pi]] < -1e14) && tempDigits[pi][ni[pi]].contains(".")){
            
            process += input
            tempDigits[pi][ni[pi]] += input
            
            if let safeDigits = Double(tempDigits[pi][ni[pi]]){
                DS[pi][ni[pi]] = safeDigits
                freshDI[pi][ni[pi]] = 1
                isNegativePossible = false
            }
        }// 15자리에서 . 없는 경우
        else if ((DS[pi][ni[pi]] > 1e14 || DS[pi][ni[pi]] < -1e14) && !tempDigits[pi][ni[pi]].contains(".")){
            if input == "."{
                process += String(input)
                tempDigits[pi][ni[pi]] += "."
            }
        }
        
        addPOfNumsAndOpers()
//        printLineSetterElements("왜죠1")
        pOfNumsAndOpers[setteroi] = "n"
//        printLineSetterElements("왜죠2")
        
        addStrForProcess()
        showAnsAdvance()
        printProcess()// comment 처리가 왜 되어있었을까?
        
        
    }
    
    
    
    
    
    
    @objc func operationPressed(sender : UIButton){
       
        if let operInput = tagToString[sender.tag]{ // : String.
            iPressed += operInput
            
            if isAnsPressed{    // ans + - x /
                
                clear()
                process = ""
                isAnsPressed = false
                DS[0][0] = saveResult!
                
//                let nf6 = NumberFormatter()
//                nf6.roundingMode = .down
//                nf6.maximumFractionDigits = 6
//                nfSetup()
                tempDigits[0][0] = nf6.string(for: saveResult!)!
                
                
                //                       var realAns = ans
                //                       var dummyStrWithComma = ""
                //
//                       let dummyAnsString = nf6.string(for: ans)
//                       let dummyAnsDouble = Double(dummyAnsString!)
//                       realAns = dummyAnsDouble!
//
//                tempDigits[0][0] = "\(String(format : "%.\(floatingNumberDigits ?? 0)f", saveResult!))"
               
                
                if DS[0][0] < 0{
                    isNegativeSign = [[false,true]]
                }
                addPOfNumsAndOpers()
                pOfNumsAndOpers[setteroi] = "n"
                
                addStrForProcess()
                
                isNegativePossible = false
                
                printProcess()
                saveResult = nil
                freshDI[0][0] = 1
                setteroi += 1
                
                operInputSetup(operInput, ni[0])
                
                addSumOfUnitSizes()
                sumOfUnitSizes[setteroi] = tagToUnitSizeString[operInput]!
                
                addPOfNumsAndOpers()
                pOfNumsAndOpers[setteroi] = "oper"
                dictionaryForLine[setteroi] = operInput
                
                addStrForProcess()
                strForProcess[setteroi] = operInput
                // ["+","-","×","÷","(",")"]
                process += operationStorage[0][0]
                indexUpdate()
                setteroi += 1
                addPOfNumsAndOpers()
                addSumOfUnitSizes()
                addStrForProcess()
            }
                
            else if isNegativePossible{ // true until number input.
                if tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] == ""{// input negative Sign
                    
                    if operInput == "-"{
                        process += "-"
                        isNegativeSign[pi][numOfPossibleNegative[pi]] = true
                        tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] = "-"
                        //                        sumOfUnitSizes.append(0)
                        if pi != 0{
                            setteroi += 1
                        }
                        addSumOfUnitSizes()
                        sumOfUnitSizes[setteroi] = tagToUnitSize["-"]!
                        addPOfNumsAndOpers()
                        pOfNumsAndOpers[setteroi] = "n"
                        addStrForProcess()
                        strForProcess[setteroi] = "-"
                        
                    } else if operInput != "-"{ //first input : + x / -> do nothing.
                        sendNotification()
                    }
                }
                    
                else if tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] == "-"{ // for negative sign
                    if operInput == "-"{}// - >> - : ignore input.
                    else if operInput != "-"{ // - >> + * /
//                        printLineSetterElements("operation modified3")
                        process.removeLast()
                        isNegativeSign[pi][numOfPossibleNegative[pi]] = false
                        tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] = ""
                        sumOfUnitSizes[setteroi] -= tagToUnitSize["-"]!
                        setteroi -= 1
                        if setteroi < 0{
                            setteroi = 0
                        }
                        pOfNumsAndOpers.removeLast()
                        strForProcess.removeLast()
                        
                    }
                    
                    sendNotification()// both cases are abnormal.
                }
            }
                
            else if !isNegativePossible{ // modify Operation Input for duplicate case.
                if tempDigits[pi][ni[pi]] == ""{
//                    printLineSetterElements("operation modified")
                    operInputSetup(operInput, ni[pi]-1)
                    process.removeLast()
                    process += operationStorage[pi][ni[pi]-1]
                    sendNotification()
                    
                    sumOfUnitSizes[setteroi-1] = tagToUnitSizeString[operInput]!
                    strForProcess[setteroi-1] = operInput
                    dictionaryForLine[setteroi-1] = operInput
                    
                }
                    
                else{       //normal case
                    if process[process.index(before:process.endIndex)] == "."{ // 1.+ >> 1+ // 요깄당.
                        if tempDigits[pi][ni[pi]].contains("."){
                            sumOfUnitSizes[setteroi] -= tagToUnitSize["."]!
                            tempDigits[pi][ni[pi]].removeLast() // remove "."
                            process.removeLast()
                            sendNotification()
                            
                            strForProcess[setteroi].removeLast()
                        }
                    }
//                    printLineSetterElements("operation modified2")
                    setteroi += 1
                    
                    
                    operInputSetup(operInput, ni[pi])
                    process += operationStorage[pi][ni[pi]]
                    indexUpdate()
                    
                    addSumOfUnitSizes()
                    
                    sumOfUnitSizes[setteroi] = tagToUnitSizeString[operInput]!
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "oper"
                    
                    addStrForProcess()
                    strForProcess[setteroi] = operInput
                    
                    dictionaryForLine[setteroi] = operInput
                    
                    //                    ["+","-","×","÷","(",")"]
                    setteroi += 1
                    addPOfNumsAndOpers()
                    addSumOfUnitSizes()
                    addStrForProcess()
                }
            }
            printProcess()
        }
    }
    
    
    func manualOperationPressed(operSymbol : String){
        // ["+","-","×","÷","(",")"]
        let operInput = operSymbol
        //        showAnsAdvance()
        
                if isAnsPressed{
                    
                    clear()
                    process = ""
                    isAnsPressed = false
                    DS[0][0] = saveResult!
                    
//                    let nf6 = NumberFormatter()
//                    nf6.roundingMode = .down
//                    nf6.maximumFractionDigits = 6
                    tempDigits[0][0] = nf6.string(for: saveResult!)!
                    
//                    tempDigits[0][0] = "\(String(format : "%.\(floatingNumberDigits ?? 0)f", saveResult!))"
        
                    if DS[0][0] < 0{
                        isNegativeSign = [[false,true]]
                    }
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "n"
                    
                    addStrForProcess()
        
                    isNegativePossible = false
        
                    printProcess()
                    saveResult = nil
                    freshDI[0][0] = 1
                    setteroi += 1
        
                    operInputSetup(operInput, ni[0])
                    
                    addSumOfUnitSizes()
                    sumOfUnitSizes[setteroi] = tagToUnitSizeString[operInput]!
                    
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "oper"
                    dictionaryForLine[setteroi] = operInput
                    
                    addStrForProcess()
                    strForProcess[setteroi] = operInput
                    process += operationStorage[0][0]
                    indexUpdate()
                    setteroi += 1
                    addPOfNumsAndOpers()
                    addSumOfUnitSizes()
                    addStrForProcess()
                }
        //        else if isNegativePossible{ // true until number input.
        else if isNegativePossible{
            if tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] == ""{// input negative Sign
                
                if operInput == "-"{
                    process += "-"
                    isNegativeSign[pi][numOfPossibleNegative[pi]] = true
                    tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] = "-"
                    
                    if pi != 0{
                        setteroi += 1
                    }
                    
                    addSumOfUnitSizes()
                    sumOfUnitSizes[setteroi] = tagToUnitSize["-"]!
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "n"
                    addStrForProcess()
                    strForProcess[setteroi] = "-"
                }
                else if operInput != "-"{ //first input : + x / -> do nothing.
                    sendNotification()
                }
            }
                
            else if tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] == "-"{
                if operInput == "-"{}// - >> - : ignore input.
                else if operInput != "-"{ // - >> + * /
                    process.removeLast()
                    isNegativeSign[pi][numOfPossibleNegative[pi]] = false
                    tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] = ""
                    sumOfUnitSizes[setteroi] -= tagToUnitSizeString["-"]!
                    setteroi -= 1
                    if setteroi < 0{
                        setteroi = 0
                    }
                    pOfNumsAndOpers.removeLast()
                    strForProcess.removeLast()
                    
                }
                sendNotification()// both cases are abnormal.
            }
        }
        else if !isNegativePossible{ // modify Operation Input
            if tempDigits[pi][ni[pi]] == ""{
                operInputSetup(operInput, ni[pi]-1)
                process.removeLast()
                process += operationStorage[pi][ni[pi]-1]
                sendNotification()
                sumOfUnitSizes[setteroi-1] = tagToUnitSizeString[operInput]!
                strForProcess[setteroi-1] = operInput
                dictionaryForLine[setteroi-1] = operInput
            }
                
            else{
                if process[process.index(before:process.endIndex)] == "."{ // 1.+ >> 1+
                    if tempDigits[pi][ni[pi]].contains("."){
                        sumOfUnitSizes[setteroi] -= tagToUnitSize["."]!
                        tempDigits[pi][ni[pi]].removeLast() // remove "."
                        process.removeLast()
                        sendNotification()
                        
                        strForProcess[setteroi].removeLast()
                    }
                }
                setteroi += 1
                
                operInputSetup(operInput, ni[pi])
                process += operationStorage[pi][ni[pi]]
                indexUpdate()
                
                addSumOfUnitSizes()
                
                sumOfUnitSizes[setteroi] = tagToUnitSizeString[operInput]!
                addPOfNumsAndOpers()
                pOfNumsAndOpers[setteroi] = "oper"
                
                addStrForProcess()
                strForProcess[setteroi] = operInput
                
                dictionaryForLine[setteroi] = operInput
                
                
                
                //                    ["+","-","×","÷","(",")"]
                setteroi += 1
                addPOfNumsAndOpers()
                addSumOfUnitSizes()
                addStrForProcess()

            }
        }
        printProcess()
    }
    
    
    @objc func calculateAns() {
        
        
        if process == ""{
            clear()
        }
        
        if !isAnsPressed {
            copyCurrentStates() // 지울 때는 왜 copy 를 안하지? 이게 호출되는건 100% . 근데 왜?

            
            filterProcess()
            numParenCount = pi
            while pi > 0{
                niEnd[pi].append(ni[pi])
                pi -= 1
                process += ")"
                //                numParenCount += 1
                if !showingAnsAdvance{
                    iPressed += "="
                    while(numParenCount != 0){
                        
                        setteroi += 1
                        addSumOfUnitSizes()
                        sumOfUnitSizes[setteroi] += tagToUnitSize[")"]!
                        
                        addPOfNumsAndOpers()
                        pOfNumsAndOpers[setteroi] = "cp"
                        
                        addStrForProcess()
                        strForProcess[setteroi] = ")"
                        
//                        printLineSetterElements("line 1047")
                        
                        
//                        printLineSetterElements("984")
                        //                        dicForProcess[setteroi] = ")"
                        
                        
                        numParenCount -= 1
                    }
                }
                
                
                tempDigits[pi][ni[pi]] += "close"
                if !showingAnsAdvance{
                    sendNotification()
                }
            }
            
            if !showingAnsAdvance{
                copyCurrentStates()
                printProcess()
                if process != ""{
                    isAnsPressed = true // 이거 원래 한 5줄 아래에 있었음.
                }
            }
            
            niEnd[0].append(ni[pi])
            
            pi = piMax
            piLoop : while pi >= 0 {
                for a in 1 ... niStart[pi].count-1{
                    for i in niStart[pi][a] ..< niEnd[pi][a]{
                        // first for statement : for Operation == "×" or "÷"
                        if muldiOperIndex[pi][i]{
                            if freshDI[pi][i] == 1 && freshDI[pi][i+1] == 1{
                                //곱셈 , D[i]전항과 D[i+1]후항 존재, >> 두개 곱함.
                                if operationStorage[pi][i] == "×" {
                                    answer[pi][i] = DS[pi][i] *  DS[pi][i+1]
                                }else if  operationStorage[pi][i] == "÷"{
                                    answer[pi][i] = DS[pi][i] /  DS[pi][i+1]
                                }
                                freshAI[pi][i] = 1 ; freshDI[pi][i] = 2 ; freshDI[pi][i+1] = 2
                                result = answer[pi][i]
                            }else if  freshDI[pi][i] == 2 && freshDI[pi][i+1] == 1{
                                //곱셈, D[i]전항 존재 안할 때 >> A[i-1] * D[i+1]
                                if  operationStorage[pi][i] == "×"{
                                    answer[pi][i] = answer[pi][i-1] *  DS[pi][i+1]
                                }else if  operationStorage[pi][i] == "÷"{
                                    answer[pi][i] = answer[pi][i-1] /  DS[pi][i+1]
                                }
                                freshAI[pi][i] = 1;freshAI[pi][i-1] = 2 ; freshDI[pi][i+1] = 2
                                result = answer[pi][i]
                            }
                        }
                    } // end for i in niStart[pi][a] ...niEnd[pi][a]{
                    
                    for i in niStart[pi][a] ..< niEnd[pi][a]{
                        if !muldiOperIndex[pi][i]{ //{b
                            if freshDI[pi][i+1] == 1{
                                //+ 연산 >> D[i+1] 존재
                                if freshDI[pi][i] == 1{
                                    //+ 연산 >> D[i+1] 존재 >> D[i] 존재
                                    if  operationStorage[pi][i] == "+"{
                                        answer[pi][i] =  DS[pi][i] +  DS[pi][i+1]
                                    } else if  operationStorage[pi][i] == "-"{
                                        answer[pi][i] =  DS[pi][i] -  DS[pi][i+1]
                                    }
                                    freshAI[pi][i] = 1 ; freshDI[pi][i] = 2 ; freshDI[pi][i+1] = 2
                                    result = answer[pi][i]
                                }
                                else if freshDI[pi][i] == 2{
                                    //+ 연산 >> D[i+1] 존재 >> D[i] 존재 ㄴㄴ
                                    tobreak : for k in 1 ... i{
                                        //freshAI[i-k] 찾음
                                        if (freshAI[pi][i-k] == 1){ // 왜 한번이 더돌아? 아.. 예전꺼 찾아가는구나! 끊어줘야해. 어디서?
                                            if  operationStorage[pi][i] == "+"{
                                                answer[pi][i] = answer[pi][i-k] +  DS[pi][i+1]
                                            } else if  operationStorage[pi][i] == "-"{
                                                answer[pi][i] = answer[pi][i-k] -  DS[pi][i+1]
                                            }
                                            freshAI[pi][i] = 1;freshAI[pi][i-k] = 2 ; freshDI[pi][i+1] = 2
                                            result = answer[pi][i]
                                            break tobreak
                                        }
                                    }
                                }
                            }
                            else if freshDI[pi][i+1] == 2{
                                //  D[i+1] 존재 ㄴㄴ
                                noLatterNum : for k in i ... ni[pi]-1 {
                                    //if freshAI[k+1] found
                                    if freshAI[pi][k+1] == 1 {
                                        //  D[i+1] 존재 ㄴㄴ >>Ans[k](k :  i+1, ... ni) 존재 >>  DI[i] 존재
                                        if freshDI[pi][i] == 1{
                                            if  operationStorage[pi][i] == "+"{
                                                answer[pi][i] =  DS[pi][i] + answer[pi][k+1]}
                                            else if  operationStorage[pi][i] == "-"{
                                                answer[pi][i] =  DS[pi][i] - answer[pi][k+1]}
                                            freshAI[pi][i] = 1; freshDI[pi][i] = 2; freshAI[pi][k+1] = 2;
                                            result = answer[pi][i]
                                            break noLatterNum
                                            //+연산 >> D[i+1] 존재 ㄴㄴ >>Ans[k](k : i+1, i+2, ... ni-1 존재 >> D[i] 존재 ㄴㄴ
                                        }
                                        else if freshDI[pi][i] == 2{
                                            for j in 0 ... i{
                                                if freshAI[pi][i-j] == 1 {
                                                    //+연산 >> D[i+1] 존재 ㄴㄴ >>Ans[k](k>i) 존재 >> D[i] 존재 ㄴㄴ >> A[i-j](i-j < i) 존재
                                                    if  operationStorage[pi][i] == "+"{
                                                        answer[pi][i] = answer[pi][i-j] + answer[pi][k+1]
                                                    } else if  operationStorage[pi][i] == "-"{
                                                        answer[pi][i] = answer[pi][i-j] - answer[pi][k+1]
                                                    }
                                                    freshAI[pi][i] = 1; freshAI[pi][i-j] = 2; freshAI[pi][k+1] = 2
                                                    result = answer[pi][i]
                                                    break noLatterNum
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } // end of all calculations. (for i in niStart[pi][a] ..< niEnd[pi][a])
                } // for a in 1 ... niStart[pi].count-1{
                
                
                if pi > 0{
                    for a in 1 ... niStart[pi].count-1{
                        if niStart[pi][a] != niEnd[pi][a]{
                            for i in niStart[pi][a] ..< niEnd[pi][a]{
                                if freshAI[pi][i] == 1{
                                    DS[pi-1][positionOfParen[pi-1][a]] = answer[pi][i]
                                    freshDI[pi-1][ positionOfParen[pi-1][a]] = 1
                                    freshAI[pi][i] = 2
                                }
                            }
                        }
                        else if niStart[pi][a] == niEnd[pi][a]{
                            DS[pi-1][positionOfParen[pi-1][a]] = DS[pi][niStart[pi][a]]
                            freshDI[pi][niStart[pi][a]] = 2
                            freshDI[pi-1][positionOfParen[pi-1][a]] = 1
                        }
                    }
                    
                    for b in 1 ... niStart[pi-1].count-1{
                        if b <  positionOfParen[pi-1].count{
                            if  positionOfParen[pi-1][b] == niStart[pi-1][b]{
                                if isNegativeSign[pi-1][b]{
                                    DS[pi-1][niStart[pi-1][b]] *= -1
                                }
                            }
                        }
                    }
                    pi -= 1
                    continue piLoop
                }
                if result == nil{
                    
                    result = DS[0][0]
                    
                }
                if result! >= 1e15 || result! <= -1e15{
                    pasteStates()
                    anslimitExceedToast()
                    isAnsPressed = false // 이게 왜 여기있어 ? 여기 있어 ㅇㅇ .
                    break piLoop
                }
                if result != nil{
                    if process != ""{
                        floatingNumberDecider(ans : result!)
                    }else{
                        niEnd = [[0]]
                        result = nil
                        resultTextView.text = ""
                    }
                    //                            historyIndex += 1
                }
                let name = Notification.Name(rawValue: answerToTableNotificationKey)
                NotificationCenter.default.post(name: name, object: nil)
                break piLoop
            } // piLoop : while pi >= 0 {
        }
    }
    func anslimitExceedToast(){
        if let languageCode = Locale.current.languageCode{
            if languageCode.contains("ko"){
                self.showToast(message: self.localizedStrings.answerLimit, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.7, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                
            }else{
                
                self.showToast(message: self.localizedStrings.answerLimit, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.6, heightRatio: 0.08, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                
            }
        }
    }
    
    func floatingExceedToast(){
        if let languageCode = Locale.current.languageCode{
            if languageCode.contains("ko"){
                self.showToast(message: self.localizedStrings.floatingLimit, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.7, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                
            }else{
                
                self.showToast(message: self.localizedStrings.floatingLimit, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.6, heightRatio: 0.08, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                
            }
        }
    }
    
    
    func showAnsAdvance(){
        
        showingAnsAdvance = true
        calculateAns() // 이거 .. 하면 .. 정답 가능성이 보이면 바로 RealmData 에 추가되는거 아니냐?

        resultTextView.textColor = isLightModeOn ? colorList.textColorForSemiResultBM : colorList.textColorForSemiResultDM
        isAnsPressed = false
        pasteStates()
        showingAnsAdvance = false
        
    }
    
    
    @objc func parenthesisPressed(sender : UIButton){
        if let input = tagToString[sender.tag]{
            iPressed += input
          
            if input == "("{
                
                if isAnsPressed{
                    clear()
                    process = ""
                    isAnsPressed = false
                    
                    DS[0][0] = saveResult!
                    
                    freshDI[0][0] = 1
//                    let nf6 = NumberFormatter()
//                    nf6.roundingMode = .down
//                    nf6.maximumFractionDigits = 6
                    tempDigits[0][0] = nf6.string(for: saveResult!)!
//                    tempDigits[0][0] = "\(String(format : "%.\(floatingNumberDigits ?? 0)f", saveResult!))"
                    
                    freshDI[0][0] = 1
                    if DS[0][0] < 0{
                        isNegativeSign = [[false,true]]
                    }
                    isNegativePossible = false
                    
                    printProcess() // duplicate printProcess ??
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "n"
                    
                    addStrForProcess()
                    
                    setteroi += 1
                    
                    
                    saveResult = nil
                    operInputSetup("×", ni[0])
                    
                    addSumOfUnitSizes()
                    sumOfUnitSizes[setteroi] = tagToUnitSize["×"]!
                    
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "oper"
                    
                    addStrForProcess()
                    strForProcess[setteroi] = "×"
                    
                    dictionaryForLine[setteroi] = "×"
                    
                    process += "×"
                    indexUpdate()
                    
                    //                    setteroi -= 1
                    //1300
                }// and of isAnsPressed
                
                // 숫자만 입력하고 x 누르지 않은 상태로 ( 누를 때
                if operationStorage[pi][ni[pi]] == "" && tempDigits[pi][ni[pi]] != ""{ // 1(
                    //                    if tempDigits[pi][ni[pi]] == "0." || tempDigits[pi][ni[pi]] == "-0."{// 0. , -0. >> input (
                    if process[process.index(before : process.endIndex)] == "."{ // 5.( >> 5x(
                        //remove dot.
                        //                        sumOfUnitSizes.append(0)
                        addSumOfUnitSizes()
                        
                        sumOfUnitSizes[setteroi] -= tagToUnitSize["."]!
                        tempDigits[pi][ni[pi]].removeLast()
                        process.removeLast()
                        sendNotification()
                    }
                    if tempDigits[pi][ni[pi]] != "-"{ //add "×" after any number
                        setteroi += 1
                        addPOfNumsAndOpers()
                        pOfNumsAndOpers[setteroi] = "oper"
                        addSumOfUnitSizes()
                        sumOfUnitSizes[setteroi] = tagToUnitSize["×"]!
                        
                        addStrForProcess()
                        strForProcess[setteroi] = "×"
                        
                        dictionaryForLine[setteroi] = "×"
                        
                        
                        operationStorage[pi][ni[pi]] = "×"
                        muldiOperIndex[pi][ni[pi]] = true
                        process += operationStorage[pi][ni[pi]]
                        indexUpdate()
                        sendNotification()
                        setteroi += 1
                    }
                }
                
                addSumOfUnitSizes()
                
                if sumOfUnitSizes[setteroi] != 0{// 이건 뭐야?
                    setteroi += 1
                }
                
                addPOfNumsAndOpers()
                pOfNumsAndOpers[setteroi] = "op"
                
                addSumOfUnitSizes()
                sumOfUnitSizes[setteroi] = tagToUnitSize["("]!
                
                addStrForProcess()
                strForProcess[setteroi] = "("
                //                setteroi += 1
                process += input
                
                positionOfParen[pi].append(ni[pi])
                
                tempDigits[pi][ni[pi]] += "paren"
                pi += 1
                //                setteroi += 1// 이렇게 하면 ((( 있을 때 인덱스 껑충껑충함.
                
                if pi > piMax{
                    piMax = pi
                    ni.append(0)
                    tempDigits.append([""])
                    DS.append([0])
                    freshDI.append([0])
                    answer.append([150])
                    freshAI.append([0])
                    operationStorage.append([""])
                    muldiOperIndex.append([false])
                    
                    indexPivotHelper.append(false)
                    isNegativeSign.append([false, false])
                    numOfPossibleNegative.append(1)
                    
                    niStart.append([0])
                    niEnd.append([0])
                    
                    positionOfParen.append([0])
                }
                
                if indexPivotHelper[pi]{ // else case of pi > piMax
                    ni[pi] += 1
                    tempDigits[pi].append("")
                    DS[pi].append(0)
                    freshDI[pi].append(0)
                    
                    operationStorage[pi].append("")
                    muldiOperIndex[pi].append(false)
                    
                    answer[pi].append(0)
                    freshAI[pi].append(0)
                    
                    isNegativeSign[pi].append(false)
                    numOfPossibleNegative[pi] += 1
                }
                
                niStart[pi].append(ni[pi])
                indexPivotHelper[pi] = true
                isNegativePossible = true
            }
                
            else if (pi != 0) && input == ")"{
                if process[process.index(before:process.endIndex)] != "(" &&  process[process.index(before:process.endIndex)] != "-" && process[process.index(before:process.endIndex)] != "×" && process[process.index(before:process.endIndex)] != "+" && process[process.index(before:process.endIndex)] != "÷" {
                    
                    if process[process.index(before:process.endIndex)] == "."{ // 1.) >> 1) //
                        if tempDigits[pi][ni[pi]].contains("."){
                            tempDigits[pi][ni[pi]].removeLast() // remove "."
                            process.removeLast()
                            sendNotification()
                            addSumOfUnitSizes()
                            sumOfUnitSizes[setteroi] -= tagToUnitSize["."]!
                        }
                    }
                    
                    setteroi += 1
                    
                    addSumOfUnitSizes()
                    sumOfUnitSizes[setteroi] = tagToUnitSize[")"]!
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "cp"
                    
                    addStrForProcess()
                    strForProcess[setteroi] = ")"
                    
                    niEnd[pi].append(ni[pi])
                    pi -= 1
                    process += input
                    tempDigits[pi][ni[pi]] += "close"
                    isNegativePossible = false
                }
                else{sendNotification() } // input is ) and end of process is ( + - × ÷ >> ignore !
            }
            else{sendNotification()} // pi == 0 , close paren before open it.
            printProcess()
            //            setteroi += 1
        }
    }
    
    
    func manualParenthesis(trueToOpen : Bool){
        let input = trueToOpen ? "(" : ")"
        
        if input == "("{
            
            
            if operationStorage[pi][ni[pi]] == "" && tempDigits[pi][ni[pi]] != ""{ // 1(
                //                if tempDigits[pi][ni[pi]] == "0." || tempDigits[pi][ni[pi]] == "-0."{// 0. , -0. >> input (
                //                    tempDigits[pi][ni[pi]] += "0"
                //                    process += "0"
                //                    sendNotification()
                //                }
                if process[process.index(before : process.endIndex)] == "."{ // 5.( >> 5x(
                    //remove dot.
                    //                        sumOfUnitSizes.append(0)
                    addSumOfUnitSizes()
                    
                    sumOfUnitSizes[setteroi] -= tagToUnitSize["."]!
                    tempDigits[pi][ni[pi]].removeLast()
                    process.removeLast()
                    sendNotification()
                }
                if tempDigits[pi][ni[pi]] != "-"{ //add "×" after any number if input is "("
                    setteroi += 1
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "oper"
                    addSumOfUnitSizes()
                    sumOfUnitSizes[setteroi] = tagToUnitSize["×"]!
                    
                    addStrForProcess()
                    strForProcess[setteroi] = "×"
                    
                    dictionaryForLine[setteroi] = "×"
                    
                    
                    
                    
                    operationStorage[pi][ni[pi]] = "×"
                    muldiOperIndex[pi][ni[pi]] = true
                    process += operationStorage[pi][ni[pi]]
                    indexUpdate()
                    sendNotification()
                    setteroi += 1
                    //                    addPOfNumsAndOpers()
                    //                    addStrForProcess()
                    //                    addSumOfUnitSizes()
                }
            }
            
            addSumOfUnitSizes()
            
            if sumOfUnitSizes[setteroi] != 0{// 이건 뭐야?
                setteroi += 1
            }
            addPOfNumsAndOpers()
            pOfNumsAndOpers[setteroi] = "op"
            
            addSumOfUnitSizes()
            sumOfUnitSizes[setteroi] = tagToUnitSize["("]!
            
            addStrForProcess()
            strForProcess[setteroi] = "("
            //            setteroi += 1
            
            process += input
            
            positionOfParen[pi].append(ni[pi])
            
            tempDigits[pi][ni[pi]] += "paren"
            pi += 1
            
            if pi > piMax{
                piMax = pi
                ni.append(0)
                tempDigits.append([""])
                DS.append([0])
                freshDI.append([0])
                answer.append([150])
                freshAI.append([0])
                operationStorage.append([""])
                muldiOperIndex.append([false])
                
                indexPivotHelper.append(false)
                isNegativeSign.append([false, false])
                numOfPossibleNegative.append(1)
                
                niStart.append([0])
                niEnd.append([0])
                
                positionOfParen.append([0])
            }
            
            if indexPivotHelper[pi]{ // else case of pi > piMax
                ni[pi] += 1
                tempDigits[pi].append("")
                DS[pi].append(0)
                freshDI[pi].append(0)
                
                operationStorage[pi].append("")
                muldiOperIndex[pi].append(false)
                
                answer[pi].append(0)
                freshAI[pi].append(0)
                
                isNegativeSign[pi].append(false)
                numOfPossibleNegative[pi] += 1
            }
            
            niStart[pi].append(ni[pi])
            indexPivotHelper[pi] = true
            isNegativePossible = true
        }
        else if (pi != 0) && input == ")"{
            if process[process.index(before:process.endIndex)] != "(" &&  process[process.index(before:process.endIndex)] != "-" && process[process.index(before:process.endIndex)] != "×" && process[process.index(before:process.endIndex)] != "+" && process[process.index(before:process.endIndex)] != "÷" {
                
                if process[process.index(before:process.endIndex)] == "."{ // 1.) >> 1) //
                    if tempDigits[pi][ni[pi]].contains("."){
                        tempDigits[pi][ni[pi]].removeLast() // remove "."
                        process.removeLast()
                        sendNotification()
                        addSumOfUnitSizes()
                        sumOfUnitSizes[setteroi] -= tagToUnitSize["."]!
                    }
                }
                
                setteroi += 1
                
                addSumOfUnitSizes()
                sumOfUnitSizes[setteroi] = tagToUnitSize[")"]!
                addPOfNumsAndOpers()
                pOfNumsAndOpers[setteroi] = "cp"
                //                dicForProcess[setteroi] = ")"
                addStrForProcess()
                strForProcess[setteroi] = ")"
                
                
                niEnd[pi].append(ni[pi])
                pi -= 1
                process += input
                tempDigits[pi][ni[pi]] += "close"
                isNegativePossible = false
            }
            else{sendNotification() } // input is ) and end of process is ( + - × ÷ >> ignore !
        }
        else{sendNotification()} // pi == 0 , close paren before open it.
        printProcess()
        
    }
    
    
    
    @objc func deleteExecute(){
        iPressed += "del"
        
        playSound()
        
        
        
        caseframe : if process != ""{
            
            if process[process.index(before: process.endIndex)] == "\n"{
                process.removeLast()
            }
            
            
            if isAnsPressed
            {
                pasteStates()
            }
            isAnsPressed = false
            // case0_ "="
            if process[process.index(before:process.endIndex)] == "="{ // = 을 지울 경우.
                sumOfUnitSizes[setteroi] = 0
                pOfNumsAndOpers.removeLast()
                setteroi -= 1
                process.removeLast()
                printProcess()
                break caseframe
            }
            
            
            
            // if number deleted.
            //           numbers = ["0","1","2","3","4","5","6","7","8","9","."]
            case1_Number : for i in numbers{
                if process[process.index(before:process.endIndex)] == i{
                    //when last digit is deleted
                    if process.count <= 1{ // less or equal to one digit
                        tempDigits[pi][ni[pi]] = ""
                        DS[pi][ni[pi]] = 0 // 이상해. 지우면 없는 수가 되어야 하는데 0 이 됨. ?? 보류.
                        freshDI[pi][ni[pi]] = 0
                        process = ""
                        isNegativePossible = true // 이게 문제야. 왜 true 라고 했을까?
                        printProcess()
                        sumOfUnitSizes[setteroi] = 0
                        
                        break caseframe
                    } // usual case.
                        
                    else if process.count > 1{
                        process.removeLast()
                        tempDigits[pi][ni[pi]].removeLast()
                        
                        if let safeDigits = Double(tempDigits[pi][ni[pi]]){
                            DS[pi][ni[pi]] = safeDigits
                            freshDI[pi][ni[pi]] = 1
                        }
                        //                        printProcess()
                        
                        for k in numbers{ // 뒤에 digit 더 있으면 DS, freshDI 없애지 않고 넘어가.
                            if process[process.index(before:process.endIndex)] == k{
                                break caseframe // more numbers left, break loop. tempDigits도 수정해야함...
                            }
                        }
                        
                        if tempDigits[pi][ni[pi]] == "-"{
                            isNegativePossible = true
                        }
                        
                        // if cannot find number leftover
                        DS[pi][ni[pi]] = 0
                        
                        freshDI[pi][ni[pi]] = 0
                        //                        printLineSetterElements("numberDelete3")
                        sumOfUnitSizes[setteroi] -= tagToUnitSize[i]!
                        
                        if sumOfUnitSizes[setteroi] < 0.01{
                            strForProcess[setteroi] = ""
                        }
                        if process.last == "("{
                            pOfNumsAndOpers.removeLast()
                            strForProcess.removeLast()
                            setteroi -= 1
                        }
                        
                        break caseframe
                    }
                }
            }// end number case.
            
            //if operation deleted.
            case2_Operator : for i in operators{
                if process[process.index(before:process.endIndex)] == i{
                    process.removeLast()
                    
                    //                    sumOfUnitSizes[setteroi] = 0// 이거 꼭 필요해? 이거 .. 아래 놓자.
                    pOfNumsAndOpers.removeLast()
                    strForProcess.removeLast()
                    // why ? why not working well?
                    
                    
                    if ni[pi] > niStart[pi][numOfPossibleNegative[pi]]{
                        ni[pi] -= 1
                        tempDigits[pi].removeLast()
                        DS[pi].removeLast()
                        answer[pi].removeLast()
                        freshDI[pi].removeLast()
                        freshAI[pi].removeLast()
                        
                        operationStorage[pi].removeLast()
                        operationStorage[pi][ni[pi]] = ""
                        
                        muldiOperIndex[pi].removeLast()
                        muldiOperIndex[pi][ni[pi]] = false
                    }
                        
                    else{ // 음수의 부호를 지운 경우 .
                        isNegativePossible = true
                        tempDigits[pi][ni[pi]].removeLast()
                        isNegativeSign[pi][numOfPossibleNegative[pi]] = false
                        sumOfUnitSizes[setteroi] = 0
                        setteroi -= 1
                        break caseframe
                    }
                    setteroi -= 1
                    dictionaryForLine.removeValue(forKey: setteroi)
                    sumOfUnitSizes[setteroi] = 0
                    setteroi -= 1 // 뭐냐. 왜 두개 감소되냐!!!!
                    break caseframe
                }
            }
            
            case3_OpenParenthesis : if process[process.index(before:process.endIndex)] == "("{
                process.removeLast()
                
                if process != ""{
                    if process[process.index(before:process.endIndex)] == "("{
                        isNegativePossible = true
                    }else{
                        isNegativePossible = false
                    }
                }
                
                if numOfPossibleNegative[pi] == 1{ // one parenthesis is only left and about to deleted.
                    indexPivotHelper.removeLast()
                    niStart.removeLast()
                    niEnd.removeLast()
                    numOfPossibleNegative.removeLast()
                    freshAI.removeLast()
                    answer.removeLast()
                    muldiOperIndex.removeLast()
                    operationStorage.removeLast()
                    freshDI.removeLast()
                    DS.removeLast()
                    tempDigits.removeLast()
                    ni.removeLast()
                    isNegativeSign.removeLast()
                    positionOfParen.removeLast()
                }
                    
                else if numOfPossibleNegative[pi] > 1{
                    niStart[pi].removeLast()
                    numOfPossibleNegative[pi] -= 1
                    freshAI[pi].removeLast()
                    answer[pi].removeLast()
                    muldiOperIndex[pi].removeLast()
                    operationStorage[pi].removeLast()
                    freshDI[pi].removeLast()
                    DS[pi].removeLast()
                    tempDigits[pi].removeLast()
                    ni[pi] -= 1
                    isNegativeSign[pi].removeLast()
                }
                
                pi -= 1
                positionOfParen[pi].removeLast()
                piMax = ni.count-1
                
                if tempDigits[pi][ni[pi]].contains("paren"){
                    for _ in 1 ... 5 {
                        tempDigits[pi][ni[pi]].removeLast()
                    }
                }
                
                sumOfUnitSizes[setteroi] = 0
                
                if process.last == "("{
                    setteroi -= 1
                    pOfNumsAndOpers.removeLast()
                    
                    strForProcess.removeLast()
                }
                
                break caseframe
            }
            
            case4_ClosingParenthesis : if process[process.index(before:process.endIndex)] == ")"{
                process.removeLast()
                
                if tempDigits[pi][ni[pi]].contains("close"){
                    for _ in 1 ... 5 {
                        tempDigits[pi][ni[pi]].removeLast()
                    }
                }
                
                pi += 1
                niEnd[pi].removeLast()
                
                isNegativePossible = false
                for i in 0 ... numOfPossibleNegative.count-1{
                    if numOfPossibleNegative[i] != 0{
                        piMax = i
                    }
                }
                
                sumOfUnitSizes[setteroi] = 0
                pOfNumsAndOpers.removeLast()
                strForProcess.removeLast()
                setteroi -= 1
                break caseframe
            }
        } // end of caseframe
            
        else{
            self.showToast(message: self.localizedStrings.modified, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.4, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
            
        }
        
        
        let eProcess = 0
        var sumForEachProcess = 0.0
        
        if numOfEnter[eProcess] != 0{
            
            oiLoop : for eODigit in lastMoveOP[eProcess][numOfEnter[eProcess]-1 ] ... setteroi{
                
                sumForEachProcess += sumOfUnitSizes[eODigit]// oi index
            }
            
            if sumForEachProcess <= 0.95 - 0.1{ // reverse
                
                if let lastEnterPosition = process.lastIndexInt(of: "\n"){
                    
                    process.remove(at: process.index(process.startIndex, offsetBy: lastEnterPosition, limitedBy: process.endIndex)!)
                }
                
//                lastMovePP[eProcess].removeLast()
                lastMoveOP[eProcess].removeLast()
                numOfEnter[eProcess] -= 1
                
                sumForEachProcess = 0
            }
        }
        showAnsAdvance()
        printProcess()
    }
    
    @objc func clearPressed(sender : UIButton){
        clear()
        resultTextView.text = ""
        progressView.text = ""
        saveResult = nil
//        floatingNumberDigits = nil
        process = ""
    }
    
    func manualClear(){
        clear()
        saveResult = nil
//        floatingNumberDigits = nil
        process = ""
        progressView.text = process
    }
    
    
    @objc func clear(){
        iPressed = ""
        isNegativePossible = true
        isAnsPressed = false
        
        pi = 0
        ni = [0]
        tempDigits = [[""]]
        DS = [[0.0]]
        answer = [[100]]
        operationStorage = [[""]]
        muldiOperIndex = [[false]]
        
        freshDI = [[0]]
        freshAI = [[0]]
        
        niStart = [[0,0]]
        niEnd = [[0]]
        
        piMax = 0
        indexPivotHelper = [false]
        numOfPossibleNegative = [1]
        positionOfParen = [[0]]
        isNegativeSign = [[false, false]]
        
        process = ""
        result = nil
        
        copyfreshDI = [[0]]
        copyfreshAI = [[0]]
        copypi = 0
        copyDS = [[0.0]]
        copyanswer = [[100]]
        copyni = [0]
        copyniStart = [[0,0]]
        copyniEnd = [[0]]
        
        copytempDigits = [[""]]
        copyoperationStorage = [[""]]
        copymuldiOperIndex = [[false]]
        
        copypiMax = 0
        copyindexPivotHelper = [false]
        copynumOfPossibleNegative = [1]
        copypositionOfParen = [[0]]
        copyisNegativeSign = [[false, false]]
        copyisNegativePossible = true
        copyisAnsPressed = false
        copyprocess = ""
        
        sumOfUnitSizes = [0]
        
        
        setteroi = 0
        sumOfUnitSizes = [0.0]
        pOfNumsAndOpers  = [""]
        
//        lastMovePP = [[0],[0],[0]] // lastMove Process Position
        lastMoveOP = [[0],[0],[0]]
        numOfEnter = [0,0,0]
        dictionaryForLine = [Int : String]()
        
        strForProcess = [""]
        
        numParenCount = 0
        
    }
    
    
    func indexUpdate(){
        ni[pi] += 1
        tempDigits[pi].append("")
        DS[pi].append(0)
        freshDI[pi].append(0)
        answer[pi].append(150)
        freshAI[pi].append(0)
        operationStorage[pi].append("")
        muldiOperIndex[pi].append(false)
    }
    
    
    func filterProcess(){
        let toBeRemovedList = [".", "(", "+", "-", "×", "÷"]
        processTillEmpty : while(process != ""){
            for _ in toBeRemovedList{
                if process[process.index(before:process.endIndex)] == "." { //last char is "."
                    process.removeLast()
                    tempDigits[pi][ni[pi]].removeLast()
                    if !showingAnsAdvance{
                        //                        if sumOfUnitSizes.count >= 1{
                        sumOfUnitSizes[setteroi] -= tagToUnitSize["."]!
                        //                        }
                        strForProcess[setteroi].removeLast()
                    }
                    if let safeDigits = Double(tempDigits[pi][ni[pi]]){
                        DS[pi][ni[pi]] = safeDigits
                        freshDI[pi][ni[pi]] = 1
                    }
                    if !showingAnsAdvance{
                        sendNotification()
                    }
                    continue processTillEmpty
                }
                    
                else if process[process.index(before:process.endIndex)] == "(" { // last char is "("
                    
                    process.removeLast()
                    if !showingAnsAdvance{
                        if process.last == "("{
                            sumOfUnitSizes[setteroi] = 0
                            setteroi -= 1
                            pOfNumsAndOpers.removeLast()
                            strForProcess.removeLast()
                        }
                    }
                    if process != ""{
                        if process[process.index(before:process.endIndex)] == "("{
                            isNegativePossible = true
                        }else{
                            isNegativePossible = false
                        }
                    }
                    
                    if numOfPossibleNegative[pi] == 1{ // one parenthesis is only left and about to deleted.
                        indexPivotHelper.removeLast()
                        niStart.removeLast()
                        niEnd.removeLast()
                        numOfPossibleNegative.removeLast()
                        freshAI.removeLast()
                        answer.removeLast()
                        muldiOperIndex.removeLast()
                        operationStorage.removeLast()
                        freshDI.removeLast()
                        DS.removeLast()
                        tempDigits.removeLast()
                        ni.removeLast()
                        isNegativeSign.removeLast()
                        positionOfParen.removeLast()
                    }
                        
                    else if numOfPossibleNegative[pi] > 1{
                        niStart[pi].removeLast()
                        numOfPossibleNegative[pi] -= 1
                        freshAI[pi].removeLast()
                        answer[pi].removeLast()
                        muldiOperIndex[pi].removeLast()
                        operationStorage[pi].removeLast()
                        freshDI[pi].removeLast()
                        DS[pi].removeLast()
                        tempDigits[pi].removeLast()
                        ni[pi] -= 1
                        isNegativeSign[pi].removeLast()
                    }
                    
                    pi -= 1
                    positionOfParen[pi].removeLast()
                    piMax = ni.count-1
                    if tempDigits[pi][ni[pi]].contains("paren"){ // paren 지울 때 5번 필요해서 5번 돌림.
                        for _ in 1 ... 5 {
                            tempDigits[pi][ni[pi]].removeLast()
                        }
                    }
                    //                    printProcess()
                    sendNotification()
                    continue processTillEmpty
                }
                    
                else if process[process.index(before:process.endIndex)] == "+" || process[process.index(before:process.endIndex)] == "-" || process[process.index(before:process.endIndex)] == "×" || process[process.index(before:process.endIndex)] == "÷" { // "last char is + - * /"
                    
                    process.removeLast()
                    
                    if !showingAnsAdvance{
                        dictionaryForLine.removeValue(forKey: setteroi-1)
                    }
                    
                    if ni[pi] > niStart[pi][numOfPossibleNegative[pi]]{ // 아마도 괄호 내 첫 수가 아닌경우
                        ni[pi] -= 1
                        tempDigits[pi].removeLast()
                        DS[pi].removeLast()
                        answer[pi].removeLast()
                        freshDI[pi].removeLast()
                        freshAI[pi].removeLast()
                        
                        operationStorage[pi].removeLast()
                        operationStorage[pi][ni[pi]] = ""
                        
                        muldiOperIndex[pi].removeLast()
                        muldiOperIndex[pi][ni[pi]] = false
                        
                        if !showingAnsAdvance{
                            sumOfUnitSizes[setteroi-1] = 0
                            
                            setteroi -= 2
                            
                            pOfNumsAndOpers.removeLast()
                            strForProcess.removeLast()
                        }
                    }
                    else{ // 음수의 부호를 지운 경우 .
                        isNegativePossible = true
                        tempDigits[pi][ni[pi]].removeLast()
                        isNegativeSign[pi][numOfPossibleNegative[pi]] = false
                        if !showingAnsAdvance{
                            sumOfUnitSizes[setteroi] = 0
                            setteroi -= 1
                            pOfNumsAndOpers.removeLast()
                            sumOfUnitSizes.removeLast()
                            strForProcess.removeLast()
                        }
                    }
                    sendNotification()
                    continue processTillEmpty
                }
            }
            break processTillEmpty
        }
        if !showingAnsAdvance{
            if setteroi < 0{
                clear()
            }
        }
    }
    
    
    func operInputSetup( _ tempOperInput : String, _ tempi : Int){
        switch tempOperInput{
        case "+" :  operationStorage[pi][tempi] = "+"
        case "×" :  operationStorage[pi][tempi] = "×"
        case "-" :  operationStorage[pi][tempi] = "-"
        case "÷" :  operationStorage[pi][tempi] = "÷"
        default: break
        }
        if  operationStorage[pi][tempi] == "×" ||  operationStorage[pi][tempi] == "÷"{
            muldiOperIndex[pi][tempi] = true}
        else {
            muldiOperIndex[pi][tempi] = false}
    }
    
    func floatingNumberDecider(ans : Double) { // ans : result!
//        let nf0 = NumberFormatter()
//        nf0.roundingMode = .down
//        nf0.maximumFractionDigits = 0
        
//        let nf6 = NumberFormatter()
//        nf6.roundingMode = .down
//        nf6.maximumFractionDigits = 6
        
        var realAns = ans
        var dummyStrWithComma = ""
        
        let dummyAnsString = nf6.string(for: ans)
        let dummyAnsDouble = Double(dummyAnsString!)
        realAns = dummyAnsDouble!
        
        
        if realAns == -0.0{
            realAns = 0.0
        }
        let date = Date()
        let dateString = date.getFormattedDate(format: "yyyy.MM.dd HH:mm")
        
        if !realAns.isNaN{
            
            dummyStrWithComma = numStrToNumWithComma(num: dummyAnsString!)
            
            resultTextView.text = dummyStrWithComma
            resultTextView.textColor = isLightModeOn ? colorList.textColorForResultBM : colorList.textColorForResultDM
            
            if !showingAnsAdvance{
                
                self.showToast(message: self.localizedStrings.savedToHistory, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.4, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                
                let newHistoryRecord = HistoryRecord(processOrigin : process, processStringHis : lineSettingOtherProcess(1.4),processStringHisLong: lineSettingOtherProcess(1.8), processStringCalc: process, resultString: dummyStrWithComma, resultValue : realAns, dateString: dateString)
                lastMoveOP[1] = [0]
                lastMoveOP[2] = [0]
                numOfEnter[1] = 0
                numOfEnter[2] = 0
                
                
                RealmService.shared.create(newHistoryRecord)
                saveResult = realAns // what is the difference?
                
            }
            
        }else{
            anslimitExceedToast()
        }
        
        if !showingAnsAdvance{
            if process != ""{
                setteroi += 1
                addPOfNumsAndOpers()
                addStrForProcess()
                pOfNumsAndOpers[setteroi] = "e"
                strForProcess[setteroi] = ""
                addSumOfUnitSizes()
                sumOfUnitSizes[setteroi] = tagToUnitSize["="]!
                
                process += "="
                copyprocess = process
                printProcess()
            }
        }
    }
    
    @objc func ansPressed(sender : UIButton){
        calculateAns()
    }
    
    
    func addPOfNumsAndOpers(){
        if pOfNumsAndOpers.count <= setteroi{
            pOfNumsAndOpers.append("")
        }
    }
    func addSumOfUnitSizes(){
        if sumOfUnitSizes.count <= setteroi{
            sumOfUnitSizes.append(0)
        }
    }
    func addStrForProcess(){
        if strForProcess.count <= setteroi{
            strForProcess.append("")
        }
    }
    
    
    func printProcess(){
        if tempDigits[pi][ni[pi]] != ""{
            removeNumberInProcess()
            
            let withCommaReturnValue = numStrToNumWithComma(num: tempDigits[pi][ni[pi]])
            process += withCommaReturnValue
            
            
            if withCommaReturnValue != ""{
                addStrForProcess()
                strForProcess[setteroi] = withCommaReturnValue
            }
            
            
            if withCommaReturnValue != ""{
                var sum = 0.0
                for element in withCommaReturnValue{
                    sum += tagToUnitSize[element]!
                }
                addSumOfUnitSizes()
                sumOfUnitSizes[setteroi] = sum
            }
        }
        
//        if pOfNumsAndOpers.count != pOfNumsAndOpersCount{
            lineSetter()
//            pOfNumsAndOpersCount = pOfNumsAndOpers.count
//        }
        
        progressView.text = process
        
        progressView.scrollRangeToVisible(progressView.selectedRange)
        
    }
    
    func printLineSetterElements( _ toPrint : String){
        print(toPrint)
        print("process : \(process)")
        print("oi : \(setteroi)")
        print("sumOfUnitSizes : \(sumOfUnitSizes)")
        print("pOfNumsAndOpers : \(pOfNumsAndOpers)")
        print("strForProcess : \(strForProcess)")
//        print("positionOfLastMovePP : \(lastMovePP)")
        print("positionOfLastMoveOP : \(lastMoveOP)")
        
        print("numOfEnter : \(numOfEnter)")
        print("dictionaryForLine : \(dictionaryForLine)")
        
        
    }
    
    func lineSetter(){
        var sumForEachProcess = 0.0
        
        let eProcess = 0
        if setteroi >= 0{
            
            if lastMoveOP[eProcess][numOfEnter[eProcess]] < setteroi{
                //잠시 막아둠(윗줄)
                oiLoop : for eODigit in lastMoveOP[eProcess][numOfEnter[eProcess]] ... setteroi{
                    
                    sumForEachProcess += sumOfUnitSizes[eODigit]// oi index
                    
                    if sumForEachProcess > 0.95 - 0.1{
                        if let indexForpOfNumsAndOpers = pOfNumsAndOpers.lastIndex(of: "oper"){ // index of last operator
                            
                            let lastOperator = (dictionaryForLine[indexForpOfNumsAndOpers]!) // what is operator ?
                            var lastPositionToSave = process.lastIndexInt(of: Character(lastOperator))! //process의 index of that operator.
                            
                            small2 : for _ in 0 ... 5{
                                if String(process[lastPositionToSave - 1]) == "(" {
                                    lastPositionToSave -= 2
                                    if lastPositionToSave < 2 {break small2}
                                }else{break small2}
                            }
                            
                            
                            numOfEnter[eProcess] += 1
                            
                            if lastMoveOP[eProcess].count <= numOfEnter[eProcess]{
                                lastMoveOP[eProcess].append(0)
                            }

                            if lastMoveOP[eProcess][numOfEnter[eProcess]-1] == indexForpOfNumsAndOpers + 1{
                                lastMoveOP[eProcess].removeLast()
                                numOfEnter[eProcess] -= 1
                                break oiLoop
                            }
                            
                            process.insert("\n", at: process.index(process.startIndex, offsetBy: lastPositionToSave, limitedBy: process.endIndex)!) // 그 위치에 \n 삽입.
                            
                            
                            lastMoveOP[eProcess][numOfEnter[eProcess]] = indexForpOfNumsAndOpers + 1
                            
                            sumForEachProcess = 0
                            
                            break oiLoop
                        }
                    } // if sumForEachProcess > 0.95 - 0.1{
                } // oiLoop : for eODigit in lastMoveOP[eProcess][numOfEnter[eProcess]] ... setteroi{
            } // if lastMoveOP[eProcess][numOfEnter[eProcess]] <= setteroi{
        } // if setteroi >= 0{
    }
    
    
    //2300
    func lineSettingOtherProcess( _ length : Double) -> String{
        var processToBeReturn = ""
        var sumForEachProcess = 0.0
        
        let eProcess = length < 1.5 ? 1 : 2 // for length of 1, eProcess = 1, and 2 for other cases.
        
        var str = strForProcess
        
        var lastOperatorPosition = 0
        //prevent error when floating points are too long
        startFor : while(lastMoveOP[eProcess][numOfEnter[eProcess]] < setteroi){
            print("line2278, lineSettingOtherProcess")
            print("lastMoveOP : \(lastMoveOP), setteroi : \(setteroi)")
            print("lastOperatorPosition : \(lastOperatorPosition)")
            sumForEachProcess = 0
            
            for eachOi in lastMoveOP[eProcess][numOfEnter[eProcess]] ... setteroi{
                sumForEachProcess += sumOfUnitSizes[eachOi]
                
                if sumForEachProcess > length - 0.1{
                    
                    small1 : for i in 0 ... eachOi - lastMoveOP[eProcess][numOfEnter[eProcess]]{
                        if pOfNumsAndOpers[eachOi-i] == "oper"{ // : operation, op : open paren
                            lastOperatorPosition = eachOi - i
                            break small1
                        }
                    }
                    
                    
                    
                    numOfEnter[eProcess] += 1
                    if lastMoveOP[eProcess].count <= numOfEnter[eProcess]{
                        lastMoveOP[eProcess].append(0)
                    }
                    
                    if lastMoveOP[eProcess][numOfEnter[eProcess]-1] == lastOperatorPosition + 1{
//                        lastMoveOP[eProcess].removeLast()
//                        numOfEnter[eProcess] -= 1
                        if lastOperatorPosition + 2 < setteroi{
                            lastMoveOP[eProcess][numOfEnter[eProcess]] = lastOperatorPosition + 2
                        }else{
                            break startFor
                        }
//                        break startFor
                        continue startFor
                    }
                    
                    str[lastOperatorPosition] = "\n" + str[lastOperatorPosition]
                    
                    lastMoveOP[eProcess][numOfEnter[eProcess]] = lastOperatorPosition + 1
                    sumForEachProcess = 0
                    
//                    if lastMoveOP[eProcess][numOfEnter[eProcess]] == lastMoveOP[eProcess][numOfEnter[eProcess]-1]{
//                        break startFor
//                    }
                    
                    continue startFor
                }
                
            } // and of for
            break startFor
        }
        
        if str.count > 0{
            for eachOne in 0 ... setteroi{
                processToBeReturn += str[eachOne] // str[setteroi] 까지만 작업함. 고로.. 뒤에껀 ㄱㅊ.
            }
        }
        
        return processToBeReturn
    }
    
    
    
    // what is this for?
    func removeNumberInProcess(){ // for removing last number(including negative sign)
        end : while(process != ""){
            switch process[process.index(before: process.endIndex)]{
            case "+","-","×","÷","(",")","=" : break
            default :
                process.removeLast()
                continue end
            }
            if tempDigits[pi][ni[pi]].contains("-") && process[process.index(before: process.endIndex)] == "-" {
                process.removeLast()
            }
            break end
        }
    }
    
    
    func numStrToNumWithComma(num : String) -> String{
        var k = 0; var mProcess = ""; var num2 = num; var isdotRemoved = false; var isOutputNegativeSign = false; var isDot0Removed = false
        
        if process.contains("="){
            return ""
        }
        if num2.contains("-paren"){
            return ""
        }
        
        if num2[num2.index(before: num2.endIndex)] == "."{
            num2.removeLast()
            isdotRemoved = true
        } // add dot later.
        
        if num2[num2.startIndex] == "-"{
            isOutputNegativeSign = true
            num2.removeFirst()
        }
        
        // comma 붙이는 과정.
        if var tempNum = Double(num2){
            let dummyStr = String(format : "%.0f", tempNum)
            if num2 == dummyStr + ".0"{ // 여기구나! .0 하면 없어지는 이유..!!
                isDot0Removed = true
                num2.removeLast()
                num2.removeLast()
            }
            
            if (tempNum >= 1000) || (tempNum <= -1000){
                while(tempNum >= 1000) || (tempNum <= -1000){
                    tempNum /= 10
                    k += 1
                }
                
                while k != 0{
                    mProcess.insert(num2[num2.startIndex], at: mProcess.endIndex)
                    num2.removeFirst()
                    k -= 1
                    if k % 3 == 0{
                        mProcess.insert(",", at: mProcess.endIndex)
                    }
                    
                    if k == 0{
                        mProcess.insert(contentsOf: num2, at: mProcess.endIndex)
                    }
                }
            }
                
            else { // -1000 < tempNum < 1000
                mProcess = num2
            }
        }
        
        if isOutputNegativeSign{
            mProcess.insert("-", at: mProcess.startIndex)
        }
        
        if isdotRemoved{
            mProcess.insert(".", at: mProcess.endIndex)
            isdotRemoved = false
        }
        
        if isDot0Removed{
            mProcess += ".0"
        }
        //        print("dicForProcess : \(dicForProcess)")
        return mProcess
    }
    
    
    func copyCurrentStates(){
        print("copyCurrentStates called")
        copyisNegativePossible = isNegativePossible
        copyisAnsPressed = isAnsPressed
        copypi = pi
        copyni = ni
        copytempDigits = tempDigits
        copyDS = DS
        copyanswer = answer
        copyoperationStorage = operationStorage
        copymuldiOperIndex = muldiOperIndex
        copyfreshDI = freshDI
        copyfreshAI = freshAI
        copyniStart = niStart
        copyniEnd = niEnd
        copypiMax = piMax
        copyindexPivotHelper = indexPivotHelper
        copynumOfPossibleNegative = numOfPossibleNegative
        copypositionOfParen = positionOfParen
        copyisNegativeSign = isNegativeSign
        copyprocess = process
        copyresult = result
        print("copied isAnsPressed : \(isAnsPressed)")
    }
    
    func pasteStates(){
        print("pasteStates baseVC")
        isNegativePossible = copyisNegativePossible
        isAnsPressed = copyisAnsPressed
        pi = copypi
        ni = copyni
        tempDigits = copytempDigits
        DS = copyDS
        answer = copyanswer
        operationStorage = copyoperationStorage
        muldiOperIndex = copymuldiOperIndex
        freshDI = copyfreshDI
        freshAI = copyfreshAI
        niStart = copyniStart
        niEnd = copyniEnd
        piMax = copypiMax
        indexPivotHelper = copyindexPivotHelper
        numOfPossibleNegative = copynumOfPossibleNegative
        positionOfParen = copypositionOfParen
        isNegativeSign = copyisNegativeSign
        process = copyprocess
        result = copyresult
    }
    
    
    @objc func initialSetup(){
        clear()
        progressView.text = ""
        resultTextView.text = ""
        deleteSpeed = 0.5
        deleteTimer.invalidate()
        deleteTimer2.invalidate()
        deleteTimerInitialSetup.invalidate()
    }
    
    //MARK: - SUB Functions
    
    
    @objc func backToOriginalColor(sender : UIButton){
        if isLightModeOn{
            switch sender.tag {
            case -2 ... 9:
                sender.backgroundColor = colorList.bgColorForEmptyAndNumbersBM
            case 10 ... 20 :
                sender.backgroundColor =  colorList.bgColorForOperatorsBM
            case 31 ... 40:
                sender.backgroundColor =  colorList.bgColorForExtrasBM
            case 21 ... 30 :
                sender.backgroundColor =  colorList.bgColorForEmptyAndNumbersBM
                deleteTimer.invalidate()
                deleteTimer2.invalidate()
                deleteTimerPause.invalidate()
                deleteTimerInitialSetup.invalidate()
            default :
                sender.backgroundColor = .magenta
            }
        }else{
            switch sender.tag {
            case -2 ... 9:
                sender.backgroundColor =  colorList.bgColorForEmptyAndNumbersDM
            case 10 ... 20 :
                sender.backgroundColor =  colorList.bgColorForOperatorsDM
            case 31 ... 40:
                sender.backgroundColor =  colorList.bgColorForExtrasDM
            case 21 ... 30 :
                sender.backgroundColor =  colorList.bgColorForEmptyAndNumbersDM
                deleteTimer.invalidate()
                deleteTimer2.invalidate()
                deleteTimerPause.invalidate()
                deleteTimerInitialSetup.invalidate()
            default :
                sender.backgroundColor = .magenta
            }
        }
    }
    
    
    @objc func deleteDragOut(sender : UIButton){
        deleteTimer.invalidate()
        deleteTimer2.invalidate()
        deleteTimerPause.invalidate()
        deleteTimerInitialSetup.invalidate()
    }
    
    
    @objc func soundOnOff1(sender : UIButton){
        userDefaultSetup.setIsUserEverChanged(isUserEverChanged: true)
        
        isSoundOn = userDefaultSetup.getIsSoundOn()
        
        
        isSoundOn ? self.showToast(message: self.localizedStrings.soundOff, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.5, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13) : self.showToast(message: self.localizedStrings.soundOn, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.5, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
        
        
        isSoundOn.toggle()
        userDefaultSetup.setIsSoundOn(isSoundOn: isSoundOn)
        colorAndImageSetup()
    }
    
    @objc func backgroundColorChanger2(sender : UIButton){
        print("tempDigits : \(tempDigits)")
        printLineSetterElements("changer")
        print("iPressed : \(iPressed)")
        userDefaultSetup.setIsUserEverChanged(isUserEverChanged: true)
        checkIndexes(saySomething: "fdsa")
        
        isLightModeOn = userDefaultSetup.getIsLightModeOn()
        
        isLightModeOn ? self.showToast(message: self.localizedStrings.darkMode, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.5, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13) : self.showToast(message: self.localizedStrings.lightMode, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.5, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
        
        isLightModeOn.toggle()
        
        userDefaultSetup.setIsLightModeOn(isLightModeOn: isLightModeOn)
        colorAndImageSetup()
        
    }
    
    @objc func notificationOnOff3(sender : UIButton){
        userDefaultSetup.setIsUserEverChanged(isUserEverChanged: true)
        
        isNotificationOn = userDefaultSetup.getIsNotificationOn()
        
        isNotificationOn ? self.showToast(message: self.localizedStrings.notificationOff, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.65, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13) : self.showToast(message: self.localizedStrings.notificationOn, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.65, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
        
        isNotificationOn.toggle()
        
        userDefaultSetup.setIsNotificationOn(isNotificationOn: isNotificationOn)
        colorAndImageSetup()
        
    }
    
    
    @objc func gotoFeedbackPage4(sender : UIButton){
        userDefaultSetup.setIsUserEverChanged(isUserEverChanged: true)
        numberReviewClicked = userDefaultSetup.getNumberReviewClicked()
        userDefaultSetup.setNumberReviewClicked(numberReviewClicked: numberReviewClicked+1)
        
        if (numberReviewClicked < 3){
            reviewService.requestReview()
        }else{
            if let languageCode = Locale.current.languageCode{
                if languageCode.contains("ko"){ // kor google survey page
                    if let url = URL(string: "https://apps.apple.com/kr/app/%EC%B9%BC%EB%A6%AC/id1525102227") { //\\
                        UIApplication.shared.open(url, options: [:])
                    }
                }else{// english google question page.
                    if let url = URL(string: "https://apps.apple.com/us/app/calie/id1525102227?l=en") {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
            }
        }
    }
    
    
    
    //google for kor : https://docs.google.com/forms/d/e/1FAIpQLScpexKHzOxWQjbzG0cnCjMkPR-OWX021QBUst4OwLp2b01ZYQ/viewform?usp=sf_link"
    //google for eng : https://docs.google.com/forms/d/e/1FAIpQLSeuMqhwdEI29WrZxAmhxQNdnNfSjlsl_l5ELvWJFze6QHG3pA/viewform?usp=sf_link
    
    
    func sendNotification(){
        if isNotificationOn{
            
            self.showToast(message: self.localizedStrings.modified, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.4, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
            
        }
    }
    
    func defaultSetup(){
        if userDefaultSetup.getIsUserEverChanged(){
            isLightModeOn = userDefaultSetup.getIsLightModeOn()
            isSoundOn = userDefaultSetup.getIsSoundOn()
            isNotificationOn = userDefaultSetup.getIsNotificationOn()
            numberReviewClicked = userDefaultSetup.getNumberReviewClicked()
        }
        else{ // initial value . when a user first downloaded.
            userDefaultSetup.setIsLightModeOn(isLightModeOn: false)
            userDefaultSetup.setIsNotificationOn(isNotificationOn: false)
            userDefaultSetup.setIsSoundOn(isSoundOn: true)
            userDefaultSetup.setNumberReviewClicked(numberReviewClicked: 0)
            
            isLightModeOn = false
            isNotificationOn = false
            isSoundOn = true
            numberReviewClicked = 0
            //            numberReview
            
        }
        
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        
        let maxLength = screenWidth > screenHeight ? screenWidth : screenHeight
        
        switch maxLength {
        case 0 ... 800:
            userDefaultSetup.setUserDeviceSizeInfo(userDeviceSizeInfo: "A")
        case 801 ... 1000:
            userDefaultSetup.setUserDeviceSizeInfo(userDeviceSizeInfo: "B")
        case 1001 ... 1100:
            userDefaultSetup.setUserDeviceSizeInfo(userDeviceSizeInfo: "C")
        case 1101 ... 1500:
            userDefaultSetup.setUserDeviceSizeInfo(userDeviceSizeInfo: "D")
        default:
            userDefaultSetup.setUserDeviceSizeInfo(userDeviceSizeInfo: "A")
        }
    }
    
    
    func playSound(){
        if isSoundOn{
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    
    @objc func deletePressedDown(sender : UIButton){
        if isLightModeOn{
            sender.backgroundColor =  colorList.bgColorForExtrasBM
        }else{
            sender.backgroundColor =  colorList.bgColorForExtrasDM
        }
        
        if deleteSpeed == 0.5{
            deleteExecute()
        }
        
        deleteTimer = Timer.scheduledTimer(timeInterval: deleteSpeed, target: self, selector: #selector(deleteFaster), userInfo: nil, repeats: false)
        deleteTimerPause = Timer.scheduledTimer(timeInterval: deletePause, target: self, selector: #selector(pauseDelete), userInfo: nil, repeats: false)
        deleteTimerInitialSetup = Timer.scheduledTimer(timeInterval: deleteInitialSetup, target: self, selector: #selector(initialSetup), userInfo: nil, repeats: false)
    }
    
    @objc func deleteFaster(){
        deleteSpeed = 0.1
        deleteTimer2 = Timer.scheduledTimer(timeInterval: deleteSpeed, target: self, selector: #selector(deleteExecute), userInfo: nil, repeats: true)
    }
    
    @objc func pauseDelete(){
        deleteTimer.invalidate()
        deleteTimer2.invalidate()
    }
    
    @objc func deletePressedUp(sender : UIButton){
        sender.backgroundColor =  colorList.bgColorForEmptyAndNumbersBM
        deleteTimer.invalidate()
        deleteTimer2.invalidate()
        deleteTimerPause.invalidate()
        deleteTimerInitialSetup.invalidate()
        deleteSpeed = 0.5
    }
    
    // color change and sound play when touched
    @objc func numberPressedDown(sender : UIButton){
        if isLightModeOn{
            sender.backgroundColor =  colorList.bgColorForExtrasBM
        }else{
            sender.backgroundColor =  colorList.bgColorForExtrasDM
        }
        playSound()
    }
    
    //delete not included
    @objc func otherPressedDown(sender : UIButton){
        playSound()
        if isLightModeOn{
            sender.backgroundColor =  colorList.bgColorForExtrasBM
        }else{
            sender.backgroundColor =  colorList.bgColorForExtrasDM
        }
    }
    
    
    func checkIndexes(saySomething : String){
        print("func checkIndexes(saySomething : \(saySomething){")
        print(" \(saySomething)")
        print("process : \(process)")
        print("1.")
        print("ni : \(ni)")
        print("pi : \(pi)")
        print("piMax : \(piMax)")
        print("2.")
        print("tempDigits : \(tempDigits)")
        print("DS : \(DS)")
        print("freshDI : \(freshDI)")
        print("3.")
        print("operationStorage : \(operationStorage)")
        print("muldiOperIndex : \(muldiOperIndex)")
        print("4.")
        print("niStart : \(niStart)")
        print("niEnd : \(niEnd)")
        print("indexPivotHelper : \(indexPivotHelper)")
        print(" positionOfParen : \( positionOfParen)")
        print("5.")
        print("numOfPossibleNegative : \(numOfPossibleNegative)")
        print("isNegativeSign : \(isNegativeSign)")
        print("isNegativePossible : \(isNegativePossible)")
        print("6.")
        print("answer : \(answer)")
        print("freshAI : \(freshAI)")
        print("result : \(String(describing: result))")
        if saveResult != nil{
            print("saveResult : \(saveResult!)")
        }else{
            print("saveResult is nil.")
        }
        print("isAnsPressed : \(isAnsPressed)\n\n")
        
        
        //        print("process : \(process)")
        print("process : \(process)")
        print("oi : \(setteroi)")
        print("sumOfUnitSizes : \(sumOfUnitSizes)")
        print("pOfNumsAndOpers : \(pOfNumsAndOpers)")
        //        print("dicForProcess : \(dicForProcess)")
        print("strForProcess : \(strForProcess)")
        //        print("positionOfProperEnter : \(pOfProperEnter)")
//        print("lastMovePP : \(lastMovePP)")
        print("lastMoveOP : \(lastMoveOP)")
        print("numOfEnter : \(numOfEnter)")
        print("dictionaryForLine : \(dictionaryForLine)")
        
        
        
    }
    
    func returnLightModeSetup() -> Bool{
        return isLightModeOn
    }
    
    @objc func toHistory(sender : UIButton){
        //print("toHistory baseVC")
        //        let newController = HistoryRecordVC()
        //        newTableVC
        let transition = CATransition()
        transition.duration = 0.3 // don't adjust it shorter. looks very weird!
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        view.window!.layer.add(transition, forKey: kCATransition)
        newTableVC.modalPresentationStyle = .fullScreen
        self.present(newTableVC, animated: true, completion: nil)
    }
    
    
    //MARK: - <# Main Functional Section Ends
    
    
    //MARK: - setup images transparent
    var subHistory = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    
    var sub0 = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var sub00 = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var sub1 = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var sub2 = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var sub3 = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var sub4 = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var sub5 = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var sub6 = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var sub7 = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var sub8 = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var sub9 = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var subDot = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var subPlus = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var subMinus = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var subMulti = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var subDivide = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var subClear = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var subOpenpar = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var subClosepar = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var subEqual = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    
    var subEx1Sound = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var subEx2Color = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var subEx3Notification = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    var subEx4Feedback = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    // those are all transparent!
    
    //MARK: - <#UI Section starts
    
    let num0 : UIButton = {
        let n0 = UIButton(type: .custom)
        n0.translatesAutoresizingMaskIntoConstraints = false
        n0.tag = 0
        return n0
    }()
    
    let num1 : UIButton = {
        let n1 = UIButton(type: .custom)
        n1.translatesAutoresizingMaskIntoConstraints = false
        n1.tag = 1
        return n1
    }()
    
    let num2 : UIButton = {
        let n2 = UIButton(type: .custom)
        
        n2.translatesAutoresizingMaskIntoConstraints = false
        n2.tag = 2
        return n2
    }()
    
    let num3 : UIButton = {
        let n3 = UIButton(type: .custom)
        n3.translatesAutoresizingMaskIntoConstraints = false
        n3.tag = 3
        return n3
    }()
    
    let num4 : UIButton = {
        let n4 = UIButton(type: .custom)
        n4.translatesAutoresizingMaskIntoConstraints = false
        n4.tag = 4
        return n4
    }()
    
    let num5 : UIButton = {
        let n5 = UIButton(type: .custom)
        n5.translatesAutoresizingMaskIntoConstraints = false
        n5.tag = 5
        return n5
    }()
    
    let num6 : UIButton = {
        let n6 = UIButton(type: .custom)
        n6.translatesAutoresizingMaskIntoConstraints = false
        n6.tag = 6
        return n6
    }()
    
    let num7 : UIButton = {
        let n7 = UIButton(type: .custom)
        n7.translatesAutoresizingMaskIntoConstraints = false
        n7.tag = 7
        return n7
    }()
    
    let num8 : UIButton = {
        let n8 = UIButton(type: .custom)
        n8.translatesAutoresizingMaskIntoConstraints = false
        n8.tag = 8
        return n8
    }()
    
    let num9 : UIButton = {
        let n9 = UIButton(type: .custom)
        n9.translatesAutoresizingMaskIntoConstraints = false
        n9.tag = 9
        return n9
    }()
    
    let num00 : UIButton = {
        let n00 = UIButton(type: .custom)
        n00.translatesAutoresizingMaskIntoConstraints = false
        n00.tag = -1
        return n00
    }()
    
    let numberDot : UIButton = {
        let nDot = UIButton(type: .custom)
        nDot.translatesAutoresizingMaskIntoConstraints = false
        nDot.tag = -2
        return nDot
    }()
    
    let clearButton : UIButton = {
        let clearbutton = UIButton(type: .custom)
        clearbutton.translatesAutoresizingMaskIntoConstraints = false
        clearbutton.tag = 11
        return clearbutton
    }()
    
    let openParenthesis : UIButton = {
        let opar = UIButton(type: .custom)
        opar.translatesAutoresizingMaskIntoConstraints = false
        opar.tag = 12
        return opar
    }()
    
    let closeParenthesis : UIButton = {
        let cpar = UIButton(type: .custom)
        cpar.translatesAutoresizingMaskIntoConstraints = false
        cpar.tag = 13
        return cpar
    }()
    
    let operationButtonDivide : UIButton = {
        let divide = UIButton(type: .custom)
        divide.translatesAutoresizingMaskIntoConstraints = false
        divide.tag = 14
        return divide
    }()
    
    let operationButtonMultiply : UIButton = {
        let multiply = UIButton(type: .custom)
        multiply.translatesAutoresizingMaskIntoConstraints = false
        multiply.tag = 15
        return multiply
    }()
    
    let operationButtonPlus : UIButton = {
        let plus = UIButton(type: .custom)
        plus.translatesAutoresizingMaskIntoConstraints = false
        plus.tag = 16
        return plus
    }()
    
    let operationButtonMinus : UIButton = {
        let minus = UIButton(type: .custom)
        minus.translatesAutoresizingMaskIntoConstraints = false
        minus.tag = 17
        return minus
    }()
    
    let equalButton : UIButton = {
        let equal = UIButton(type: .custom)
        equal.translatesAutoresizingMaskIntoConstraints = false
        equal.tag = 18
        return equal
    }()
    
    // set numbers and operators layer borderWidth and Color on 2 lines.
    
    
    let extra1 : UIButton = {
        let ex1 = UIButton(type: .custom)
        ex1.translatesAutoresizingMaskIntoConstraints = false
        ex1.tag = 31
        return ex1
    }()
    
    let extra2 : UIButton = {
        let ex2 = UIButton(type: .custom)
        ex2.translatesAutoresizingMaskIntoConstraints = false
        ex2.tag = 32
        return ex2
    }()
    
    let extra3 : UIButton = {
        let ex3 = UIButton(type: .custom)
        ex3.translatesAutoresizingMaskIntoConstraints = false
        ex3.tag = 33
        return ex3
    }()
    
    let extra4 : UIButton = {
        let ex4 = UIButton(type: .custom)
        ex4.translatesAutoresizingMaskIntoConstraints = false
        ex4.tag = 34
        return ex4
    }()
    
    let deleteButton : UIButton = {
        let del = UIButton(type: .custom)
        del.translatesAutoresizingMaskIntoConstraints = false
        del.tag = 21
        
        let sub = UIImageView(image: #imageLiteral(resourceName: "delD")) // delete Image.
        del.addSubview(sub)
        
        sub.translatesAutoresizingMaskIntoConstraints = false
        sub.centerXAnchor.constraint(equalTo: del.centerXAnchor).isActive = true
        sub.centerYAnchor.constraint(equalTo: del.centerYAnchor).isActive = true
        //        sub.widthAnchor.constraint(equalTo: del.widthAnchor, multiplier: 0.5).isActive = true
        sub.widthAnchor.constraint(equalTo: del.heightAnchor, multiplier: 0.5625).isActive = true
        sub.heightAnchor.constraint(equalTo: del.heightAnchor, multiplier: 0.5).isActive = true
        
        return del
    }()
    
    let emptySpace : UIImageView = {
        let empty = UIImageView(image: #imageLiteral(resourceName: "transparent")) // transparent
        empty.translatesAutoresizingMaskIntoConstraints = false
        return empty
    }()
    
    let resultTextView : UITextView = {
        let result = UITextView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.textAlignment = .right
        result.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        result.adjustsFontForContentSizeCategory = true
        result.textContainer.maximumNumberOfLines = 1
        //        result.sizeToFit()
        //        result.zoomScale = 0.5
        result.isUserInteractionEnabled = true
        result.isEditable = false
        //        result.sizeToFit()
        
        return result
    }()
    
    
    var progressView : UITextView = {
        let progress = UITextView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.isUserInteractionEnabled = true
        progress.isEditable = false
        progress.textAlignment = .right
        progress.font = UIFont.preferredFont(forTextStyle: .body)
        progress.adjustsFontForContentSizeCategory = true
        return progress
    }()
    
    let deleteWidthReference : UIImageView = {
        let sub = UIImageView(image: #imageLiteral(resourceName: "transparent")) // transparent
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let deleteHeightReference : UIImageView = {
        let sub = UIImageView(image: #imageLiteral(resourceName: "transparent")) // transparent
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let resultWidthReference : UIImageView = {
        let sub = UIImageView(image:  #imageLiteral(resourceName: "transparent"))// transparent
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let resultHeightReference : UIImageView = {
        let sub = UIImageView(image: #imageLiteral(resourceName: "transparent"))// transparent
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let progressWidthReference : UIImageView = {
        let sub = UIImageView(image:  #imageLiteral(resourceName: "transparent"))// transparent
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let progressHeightReference : UIImageView = {
        let sub = UIImageView(image: #imageLiteral(resourceName: "transparent"))// transparent
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let historyClickButton : UIButton = {
        let sub = UIButton(type: .custom)
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let historyDragButton : UIButton = {
        let sub = UIButton(type: .custom)
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let rightSideForLandscapeMode : UIView = {
        let sub = UIView()
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let leftSideForLandscapeMode : UIView = {
        let sub = UIView()
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    //MARK: - <#UI Section Not Included Any Function End.
    
    func setupPositionLayout(){
       
        // frameView = UIView()
        for subview in frameView.subviews{
            subview.removeFromSuperview()
        }
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
        
        let horStackView0 : [UIButton] = [extra1, extra2, extra3, extra4]
        let horStackView1 : [UIButton] = [num0, num00, numberDot, equalButton]
        let horStackView2 : [UIButton] = [num1, num2, num3, operationButtonPlus]
        let horStackView3 : [UIButton] = [num4, num5, num6, operationButtonMinus]
        let horStackView4 : [UIButton] = [num7, num8, num9, operationButtonMultiply]
        let horStackView5 : [UIButton] = [clearButton, openParenthesis, closeParenthesis, operationButtonDivide]
        let numAndOper : [UIButton] = horStackView1 + horStackView2 + horStackView3 + horStackView4 + horStackView5
        let verStackView0 : [UIButton] = [clearButton, num7, num4, num1, num0]
        let verStackView1 : [UIButton] = [openParenthesis, num8, num5, num2, num00]
        let verStackView2 : [UIButton] = [closeParenthesis, num9, num6, num3, numberDot]
        let verStackView3 : [UIButton] = [operationButtonDivide, operationButtonMultiply, operationButtonPlus, operationButtonMinus, equalButton]
        
        
        if isOrientationPortrait{ // Portrait Mode
            frameView = view
            
            for button in horStackView0{ //extras 1,2,3,4
                frameView.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: 0.108).isActive = true
            }
        }else if !isOrientationPortrait{ // LandScape Mode
           
            //right side (calculator)
            view.addSubview(rightSideForLandscapeMode)
            rightSideForLandscapeMode.translatesAutoresizingMaskIntoConstraints = false
            rightSideForLandscapeMode.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            rightSideForLandscapeMode.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.562).isActive = true
            rightSideForLandscapeMode.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            rightSideForLandscapeMode.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            
            //what are these lines?
            frameView = rightSideForLandscapeMode as UIView
            frameView.translatesAutoresizingMaskIntoConstraints = false
            
            //additional setup for tableView at the left side.
            view.addSubview(leftSideForLandscapeMode)
            leftSideForLandscapeMode.translatesAutoresizingMaskIntoConstraints = false
            leftSideForLandscapeMode.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            leftSideForLandscapeMode.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.438).isActive = true
            leftSideForLandscapeMode.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            leftSideForLandscapeMode.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            
            
            addChild(childTableVC)
            //            adds the specified ViewController as a child of current view controller
            view.addSubview(childTableVC.view)
            //            childTableVC.didMove(toParent: self)
            //            Called after the view controller is added or removed from a container view controller.
            
            childTableVC.view.translatesAutoresizingMaskIntoConstraints = false
            childTableVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            childTableVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            childTableVC.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.438).isActive = true
            childTableVC.view.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            //            childTableVC.backgroundColo
        }
        
        
        
        // execute all the time (portrait and landscape mode)
        for button in numAndOper{
            frameView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            if isOrientationPortrait{
                button.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: 0.108).isActive = true
            }else{
                button.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: CGFloat(0.108*1.2)).isActive = true
            }
            
            button.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.25).isActive = true
            //            button.layer.borderWidth = 0.23
            button.layer.borderWidth = 0.23
            button.layer.borderColor = CGColor(genericGrayGamma2_2Gray: 0, alpha: 0.15)
            //frameView : view or rightSideForLandscapeMode view (UIView)
        }
        
        //again? yeap. don't touch it . (already tried ..)
        if isOrientationPortrait{
            for button in horStackView0{
                button.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.25).isActive = true
                button.bottomAnchor.constraint(equalTo: frameView.bottomAnchor).isActive = true
                button.layer.borderWidth = 0.23
                button.layer.borderColor = CGColor(genericGrayGamma2_2Gray: 0, alpha: 0.15)
            }
            
            for button in horStackView1{
                button.bottomAnchor.constraint(equalTo: extra1.topAnchor).isActive = true
            }
            
            extra1.leftAnchor.constraint(equalTo: frameView.leftAnchor).isActive = true
            extra2.leftAnchor.constraint(equalTo: extra1.rightAnchor).isActive = true
            extra3.leftAnchor.constraint(equalTo: extra2.rightAnchor).isActive = true
            extra4.leftAnchor.constraint(equalTo: extra3.rightAnchor).isActive = true
            extra4.rightAnchor.constraint(equalTo: frameView.rightAnchor).isActive = true
            
        }else {
            
            for button in horStackView1{
                button.bottomAnchor.constraint(equalTo: frameView.bottomAnchor).isActive = true
            }
        }
        
        
        for button in horStackView2{
            button.bottomAnchor.constraint(equalTo: num0.topAnchor).isActive = true
        }
        for button in horStackView3{
            button.bottomAnchor.constraint(equalTo: num1.topAnchor).isActive = true
        }
        for button in horStackView4{
            button.bottomAnchor.constraint(equalTo: num4.topAnchor).isActive = true
        }
        for button in horStackView5{
            button.bottomAnchor.constraint(equalTo: num7.topAnchor).isActive = true
        }
        
        for button in verStackView0{
            button.leftAnchor.constraint(equalTo: frameView.leftAnchor).isActive = true
        }
        for button in verStackView1{
            button.leftAnchor.constraint(equalTo: num0.rightAnchor).isActive = true
        }
        for button in verStackView2{
            button.leftAnchor.constraint(equalTo: num00.rightAnchor).isActive = true
        }
        for button in verStackView3{
            button.leftAnchor.constraint(equalTo: numberDot.rightAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        }
        
        frameView.addSubview(emptySpace)
        
        frameView.addSubview(deleteWidthReference)
        frameView.addSubview(deleteHeightReference)
        frameView.addSubview(deleteButton)
        
        frameView.addSubview(resultWidthReference)
        frameView.addSubview(resultHeightReference)
        frameView.addSubview(resultTextView)
        
        frameView.addSubview(progressWidthReference)
        frameView.addSubview(progressHeightReference)
        frameView.addSubview(progressView)
        
        if isOrientationPortrait{
            emptySpace.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: 0.352).isActive = true
            emptySpace.topAnchor.constraint(equalTo: frameView.topAnchor).isActive = true
            emptySpace.leftAnchor.constraint(equalTo: frameView.leftAnchor).isActive = true
            emptySpace.rightAnchor.constraint(equalTo: frameView.rightAnchor).isActive = true
            
            // only applied to portrait Mode
            
            deleteWidthReference.rightAnchor.constraint(equalTo: frameView.rightAnchor).isActive = true
            deleteWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.122).isActive = true
            
            deleteHeightReference.bottomAnchor.constraint(equalTo: emptySpace.bottomAnchor).isActive = true
            deleteHeightReference.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: 0.1446010638).isActive = true
            
            deleteButton.centerXAnchor.constraint(equalTo: deleteWidthReference.leftAnchor).isActive = true
            deleteButton.centerYAnchor.constraint(equalTo: deleteHeightReference.topAnchor).isActive = true
            deleteButton.widthAnchor.constraint(equalTo: emptySpace.widthAnchor, multiplier: 0.18).isActive = true
            deleteButton.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: 0.255).isActive = true
            
            
            resultWidthReference.rightAnchor.constraint(equalTo: frameView.rightAnchor).isActive = true
            resultWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.01).isActive = true
            
            resultHeightReference.bottomAnchor.constraint(equalTo: emptySpace.bottomAnchor).isActive = true
            resultHeightReference.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: 0.2978723404).isActive = true
            
            resultTextView.bottomAnchor.constraint(equalTo: resultHeightReference.topAnchor).isActive = true
            resultTextView.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: 0.27).isActive = true
            resultTextView.leftAnchor.constraint(equalTo: emptySpace.leftAnchor).isActive = true
            resultTextView.rightAnchor.constraint(equalTo: resultWidthReference.leftAnchor).isActive = true
            
            
            progressWidthReference.rightAnchor.constraint(equalTo: frameView.rightAnchor).isActive = true
            progressWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.248).isActive = true
            
            progressHeightReference.bottomAnchor.constraint(equalTo: emptySpace.bottomAnchor).isActive = true
            progressHeightReference.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: 0.02).isActive = true
            
            progressView.bottomAnchor.constraint(equalTo: progressHeightReference.topAnchor).isActive = true
            progressView.widthAnchor.constraint(equalTo: emptySpace.widthAnchor, multiplier: 0.6906666667).isActive = true
            progressView.rightAnchor.constraint(equalTo: progressWidthReference.leftAnchor).isActive = true
            progressView.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: 0.264).isActive = true
        }else{
            let k = 1.307
            emptySpace.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: 0.352).isActive = true
            emptySpace.topAnchor.constraint(equalTo: frameView.topAnchor).isActive = true
            emptySpace.leftAnchor.constraint(equalTo: frameView.leftAnchor).isActive = true
            emptySpace.rightAnchor.constraint(equalTo: frameView.rightAnchor).isActive = true
            
            // only applied to portrait Mode
            
            deleteWidthReference.rightAnchor.constraint(equalTo: frameView.rightAnchor).isActive = true
            //            deleteWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.122).isActive = true
            deleteWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.032).isActive = true
            
            deleteHeightReference.bottomAnchor.constraint(equalTo: emptySpace.bottomAnchor).isActive = true
            //            deleteHeightReference.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: 0.20).isActive = true
            deleteHeightReference.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: CGFloat(0.0171*k)).isActive = true
            
            //            deleteButton.centerXAnchor.constraint(equalTo: deleteWidthReference.leftAnchor).isActive = true
            deleteButton.rightAnchor.constraint(equalTo: deleteWidthReference.leftAnchor).isActive = true
            //            deleteButton.centerYAnchor.constraint(equalTo: deleteHeightReference.topAnchor).isActive = true
            deleteButton.bottomAnchor.constraint(equalTo: deleteHeightReference.topAnchor).isActive = true
            deleteButton.widthAnchor.constraint(equalTo: emptySpace.widthAnchor, multiplier: 0.18).isActive = true
            //            deleteButton.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: 0.255).isActive = true
            deleteButton.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: CGFloat(0.386364*k)).isActive = true
            
            
            
            progressWidthReference.rightAnchor.constraint(equalTo: frameView.rightAnchor).isActive = true
            progressWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.248).isActive = true
            
            progressHeightReference.bottomAnchor.constraint(equalTo: emptySpace.bottomAnchor).isActive = true
            //            progressHeightReference.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: 0.02).isActive = true
            progressHeightReference.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: CGFloat(0.02*k)).isActive = true
            
            progressView.bottomAnchor.constraint(equalTo: progressHeightReference.topAnchor).isActive = true
            progressView.widthAnchor.constraint(equalTo: emptySpace.widthAnchor, multiplier: 0.6906666667).isActive = true
            progressView.rightAnchor.constraint(equalTo: progressWidthReference.leftAnchor).isActive = true
            progressView.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: CGFloat(0.35*k)).isActive = true
            
            
            
            resultWidthReference.rightAnchor.constraint(equalTo: frameView.rightAnchor).isActive = true
            resultWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.01).isActive = true
            
            resultHeightReference.bottomAnchor.constraint(equalTo: emptySpace.bottomAnchor).isActive = true
            resultHeightReference.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: CGFloat(0.385 * k)).isActive = true
            resultTextView.bottomAnchor.constraint(equalTo: resultHeightReference.topAnchor).isActive = true
            resultTextView.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: CGFloat(0.30*k)).isActive = true
            resultTextView.leftAnchor.constraint(equalTo: emptySpace.leftAnchor).isActive = true
            resultTextView.rightAnchor.constraint(equalTo: resultWidthReference.leftAnchor).isActive = true
            
            
            
        }
        
        if isOrientationPortrait{
            frameView.addSubview(historyDragButton)
            frameView.addSubview(historyClickButton)
            historyClickButton.translatesAutoresizingMaskIntoConstraints = false
            historyClickButton.bottomAnchor.constraint(equalTo: resultTextView.topAnchor).isActive = true
            historyClickButton.topAnchor.constraint(equalTo:frameView.safeTopAnchor ).isActive = true // 요기
            
            historyClickButton.leftAnchor.constraint(equalTo: frameView.leftAnchor).isActive = true
            historyClickButton.rightAnchor.constraint(equalTo: frameView.rightAnchor).isActive = true
            
            historyDragButton.translatesAutoresizingMaskIntoConstraints = false
            historyDragButton.topAnchor.constraint(equalTo: frameView.safeTopAnchor).isActive = true
            
            historyDragButton.bottomAnchor.constraint(equalTo: resultTextView.bottomAnchor).isActive = true
            historyDragButton.leftAnchor.constraint(equalTo: frameView.leftAnchor).isActive = true
            historyDragButton.rightAnchor.constraint(equalTo: frameView.rightAnchor).isActive = true
        }
        
        resultTextView.font = UIFont.systemFont(ofSize: fontSize.resultBasicPortrait[userDefaultSetup.getUserDeviceSizeInfo()]!)
        progressView.font = UIFont.systemFont(ofSize: fontSize.processBasicPortrait[userDefaultSetup.getUserDeviceSizeInfo()]!)
    }
    
    func addTargetSetup(){
        let numButtons = [num0,num1,num2,num3,num4,num5,num6,num7,num8,num9,num0,num00,numberDot]
        let operButtons = [operationButtonDivide,operationButtonMultiply,operationButtonPlus,operationButtonMinus]
        let otherButtons = [clearButton,openParenthesis,closeParenthesis,operationButtonDivide,operationButtonMultiply,operationButtonPlus,operationButtonMinus,equalButton]
        
        for aButton in numButtons {
            aButton.addTarget(self, action: #selector( numberPressed), for: .touchUpInside)
            aButton.addTarget(self, action: #selector(numberPressedDown), for: .touchDown)
            aButton.addTarget(self, action: #selector(backToOriginalColor), for: .touchUpInside) // does nothing.
            aButton.addTarget(self, action: #selector(backToOriginalColor), for: .touchDragExit)
        }
        for aButton in operButtons{
            aButton.addTarget(self, action: #selector( operationPressed), for: .touchUpInside)
            aButton.addTarget(self, action: #selector(backToOriginalColor), for: .touchDragExit)
        }
        for aButton in otherButtons{
            aButton.addTarget(self, action: #selector( otherPressedDown), for: .touchDown)
            aButton.addTarget(self, action: #selector( backToOriginalColor(sender:)), for: .touchUpInside)//does nothing
            aButton.addTarget(self, action: #selector(backToOriginalColor), for: .touchDragExit)
        }
        
        equalButton.addTarget(self, action: #selector( ansPressed), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector( clearPressed), for: .touchUpInside)
        
        openParenthesis.addTarget(self, action: #selector( parenthesisPressed), for: .touchUpInside)
        closeParenthesis.addTarget(self, action: #selector( parenthesisPressed), for: .touchUpInside)
        
        deleteButton.addTarget(self, action: #selector( deletePressedDown), for: .touchDown)
        deleteButton.addTarget(self, action: #selector(deletePressedUp), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteDragOut), for: .touchDragExit)
        
        deleteButton.addTarget(self, action: #selector( backToOriginalColor), for: .touchUpInside)
        //sound, backgroundColor, notification, feedback
        extra1.addTarget(self, action: #selector(soundOnOff1), for: .touchUpInside)
        extra2.addTarget(self, action: #selector(backgroundColorChanger2(sender:)), for: .touchUpInside)
        extra3.addTarget(self, action: #selector(notificationOnOff3), for: .touchUpInside)
        extra4.addTarget(self, action: #selector(gotoFeedbackPage4), for: .touchUpInside)
        
        historyClickButton.addTarget(self, action: #selector(toHistory), for: .touchUpInside)
        historyClickButton.addTarget(self, action: #selector(toHistory), for: .touchDragExit)
        historyDragButton.addTarget(self, action: #selector(toHistory), for: .touchDragExit)
        //        historyClickButton
    }
    
    
    func colorAndImageSetup(){
        
        let ratio = 1.3
        
        let numsAndOpers = [num0,num1,num2,num3,num4,num5,num6,num7,num8,num9,num00,numberDot,clearButton,openParenthesis,closeParenthesis,operationButtonDivide,operationButtonMultiply, operationButtonPlus,operationButtonMinus,equalButton]
        
        let widths = [0.12, 0.12*0.6, 0.12, 0.12, 0.12*1.05, 0.12*0.98,0.12,0.12,0.12,0.12,1.9*0.12,0.2*0.12,0.13*1.05, 0.12*0.5, 0.12*0.5,0.13*1.15,0.14*1.2,0.13,0.13,0.14 ] // for numsAndOpers.
        
        var modifiedWidth = [Double]()
        
        for widthElement in widths{
            modifiedWidth.append(widthElement * ratio)
        }
        let heights =  [0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*0.3,0.13*1.9,0.12*2.45,0.12*2.45,0.13*1.5,0.14*1.9,0.13*1.3,0.13*0.2,0.14*0.8] // for numsAndOpers
        
        let numButtons = [num0,num1,num2,num3,num4,num5,num6,num7,num8,num9,num0,num00,numberDot,progressView,resultTextView,emptySpace]
        let otherButtons = [clearButton,openParenthesis,closeParenthesis,operationButtonDivide,operationButtonMultiply,operationButtonPlus,operationButtonMinus,equalButton]
        let extras = [extra1, extra2, extra3, extra4]
        
        if isLightModeOn{
            for num in numButtons{
                num.backgroundColor =  colorList.bgColorForEmptyAndNumbersBM
            }
            for other in otherButtons{
                other.backgroundColor =  colorList.bgColorForOperatorsBM
            }
            for extra in extras{
                extra.backgroundColor =  colorList.bgColorForExtrasBM
            }
            deleteButton.backgroundColor =  colorList.bgColorForEmptyAndNumbersBM
            
            subHistory = UIImageView(image: #imageLiteral(resourceName: "historyC"))
            
            sub0 = UIImageView(image: #imageLiteral(resourceName: "0C"))
            sub1 = UIImageView(image: #imageLiteral(resourceName: "1C"))
            sub2 = UIImageView(image: #imageLiteral(resourceName: "2C"))
            sub3 = UIImageView(image: #imageLiteral(resourceName: "3C"))
            sub4 = UIImageView(image: #imageLiteral(resourceName: "4C"))
            sub5 = UIImageView(image: #imageLiteral(resourceName: "5C"))
            sub6 = UIImageView(image: #imageLiteral(resourceName: "6C"))
            sub7 = UIImageView(image: #imageLiteral(resourceName: "7C"))
            sub8 = UIImageView(image: #imageLiteral(resourceName: "8C"))
            sub9 = UIImageView(image: #imageLiteral(resourceName: "9C"))
            sub00 = UIImageView(image: #imageLiteral(resourceName: "00C"))
            subDot = UIImageView(image: #imageLiteral(resourceName: "dotC"))
            
            subClear = UIImageView(image: #imageLiteral(resourceName: "CC"))
            subOpenpar = UIImageView(image: #imageLiteral(resourceName: "(C"))
            subClosepar = UIImageView(image: #imageLiteral(resourceName: ")C"))
            subDivide = UIImageView(image: #imageLiteral(resourceName: "÷C"))
            subMulti = UIImageView(image: #imageLiteral(resourceName: "xC"))
            subPlus = UIImageView(image: #imageLiteral(resourceName: "+C"))
            subMinus = UIImageView(image: #imageLiteral(resourceName: "–C"))
            subEqual = UIImageView(image: #imageLiteral(resourceName: "=C"))
            
            subEx2Color = UIImageView(image: #imageLiteral(resourceName: "etcColorModeChangeToDark"))
            subEx4Feedback = UIImageView(image: #imageLiteral(resourceName: "etcFeedbackLight"))
            
            
            for view in subHistory.subviews{
                view.removeFromSuperview()
            }
            
            for i in 0 ..< numsAndOpers.count{
                for view in numsAndOpers[i].subviews { // It works !!! whow!!
                    view.removeFromSuperview()
                }
            }
            
            for i in 0 ..< extras.count{
                for view in extras[i].subviews{
                    view.removeFromSuperview()
                }
            }
            historyClickButton.addSubview(subHistory)
            subHistory.translatesAutoresizingMaskIntoConstraints = false
            subHistory.centerXAnchor.constraint(equalTo: historyClickButton.centerXAnchor).isActive = true
            subHistory.topAnchor.constraint(equalTo: historyClickButton.topAnchor).isActive = true
            subHistory.widthAnchor.constraint(equalTo: historyClickButton.widthAnchor, multiplier: 0.6).isActive = true
            subHistory.heightAnchor.constraint(equalToConstant: 15).isActive = true
            
            num0.addSubview(sub0)
            sub0.translatesAutoresizingMaskIntoConstraints = false
            sub0.centerXAnchor.constraint(equalTo: num0.centerXAnchor).isActive = true
            sub0.centerYAnchor.constraint(equalTo: num0.centerYAnchor).isActive = true
            sub0.widthAnchor.constraint(equalTo: num0.heightAnchor, multiplier: CGFloat(modifiedWidth[0])).isActive = true
            sub0.heightAnchor.constraint(equalTo: num0.heightAnchor, multiplier: CGFloat(heights[0])).isActive = true
            
            num1.addSubview(sub1)
            sub1.translatesAutoresizingMaskIntoConstraints = false
            sub1.centerXAnchor.constraint(equalTo: num1.centerXAnchor).isActive = true
            sub1.centerYAnchor.constraint(equalTo: num1.centerYAnchor).isActive = true
            sub1.widthAnchor.constraint(equalTo: num1.heightAnchor, multiplier: CGFloat(modifiedWidth[1])).isActive = true
            sub1.heightAnchor.constraint(equalTo: num1.heightAnchor, multiplier: CGFloat(heights[1])).isActive = true
            
            num2.addSubview(sub2)
            sub2.translatesAutoresizingMaskIntoConstraints = false
            sub2.centerXAnchor.constraint(equalTo: num2.centerXAnchor).isActive = true
            sub2.centerYAnchor.constraint(equalTo: num2.centerYAnchor).isActive = true
            sub2.widthAnchor.constraint(equalTo: num2.heightAnchor, multiplier: CGFloat(modifiedWidth[2])).isActive = true
            sub2.heightAnchor.constraint(equalTo: num2.heightAnchor, multiplier: CGFloat(heights[2])).isActive = true
            
            num3.addSubview(sub3)
            sub3.translatesAutoresizingMaskIntoConstraints = false
            sub3.centerXAnchor.constraint(equalTo: num3.centerXAnchor).isActive = true
            sub3.centerYAnchor.constraint(equalTo: num3.centerYAnchor).isActive = true
            sub3.widthAnchor.constraint(equalTo: num3.heightAnchor, multiplier: CGFloat(modifiedWidth[3])).isActive = true
            sub3.heightAnchor.constraint(equalTo: num3.heightAnchor, multiplier: CGFloat(heights[3])).isActive = true
            //
            num4.addSubview(sub4)
            sub4.translatesAutoresizingMaskIntoConstraints = false
            sub4.centerXAnchor.constraint(equalTo: num4.centerXAnchor).isActive = true
            sub4.centerYAnchor.constraint(equalTo: num4.centerYAnchor).isActive = true
            sub4.widthAnchor.constraint(equalTo: num4.heightAnchor, multiplier: CGFloat(modifiedWidth[4])).isActive = true
            sub4.heightAnchor.constraint(equalTo: num4.heightAnchor, multiplier: CGFloat(heights[4])).isActive = true
            //
            num5.addSubview(sub5)
            sub5.translatesAutoresizingMaskIntoConstraints = false
            sub5.centerXAnchor.constraint(equalTo: num5.centerXAnchor).isActive = true
            sub5.centerYAnchor.constraint(equalTo: num5.centerYAnchor).isActive = true
            sub5.widthAnchor.constraint(equalTo: num5.heightAnchor, multiplier: CGFloat(modifiedWidth[5])).isActive = true
            sub5.heightAnchor.constraint(equalTo: num5.heightAnchor, multiplier: CGFloat(heights[5])).isActive = true
            //
            num6.addSubview(sub6)
            sub6.translatesAutoresizingMaskIntoConstraints = false
            sub6.centerXAnchor.constraint(equalTo: num6.centerXAnchor).isActive = true
            sub6.centerYAnchor.constraint(equalTo: num6.centerYAnchor).isActive = true
            sub6.widthAnchor.constraint(equalTo: num6.heightAnchor, multiplier: CGFloat(modifiedWidth[6])).isActive = true
            sub6.heightAnchor.constraint(equalTo: num6.heightAnchor, multiplier: CGFloat(heights[6])).isActive = true
            
            num7.addSubview(sub7)
            sub7.translatesAutoresizingMaskIntoConstraints = false
            sub7.centerXAnchor.constraint(equalTo: num7.centerXAnchor).isActive = true
            sub7.centerYAnchor.constraint(equalTo: num7.centerYAnchor).isActive = true
            sub7.widthAnchor.constraint(equalTo: num7.heightAnchor, multiplier: CGFloat(modifiedWidth[7])).isActive = true
            sub7.heightAnchor.constraint(equalTo: num7.heightAnchor, multiplier: CGFloat(heights[7])).isActive = true
            
            num8.addSubview(sub8)
            sub8.translatesAutoresizingMaskIntoConstraints = false
            sub8.centerXAnchor.constraint(equalTo: num8.centerXAnchor).isActive = true
            sub8.centerYAnchor.constraint(equalTo: num8.centerYAnchor).isActive = true
            sub8.widthAnchor.constraint(equalTo: num8.heightAnchor, multiplier: CGFloat(modifiedWidth[8])).isActive = true
            sub8.heightAnchor.constraint(equalTo: num8.heightAnchor, multiplier: CGFloat(heights[8])).isActive = true
            
            num9.addSubview(sub9)
            sub9.translatesAutoresizingMaskIntoConstraints = false
            sub9.centerXAnchor.constraint(equalTo: num9.centerXAnchor).isActive = true
            sub9.centerYAnchor.constraint(equalTo: num9.centerYAnchor).isActive = true
            sub9.widthAnchor.constraint(equalTo: num9.heightAnchor, multiplier: CGFloat(modifiedWidth[9])).isActive = true
            sub9.heightAnchor.constraint(equalTo: num9.heightAnchor, multiplier: CGFloat(heights[9])).isActive = true
            
            num00.addSubview(sub00)
            sub00.translatesAutoresizingMaskIntoConstraints = false
            sub00.centerXAnchor.constraint(equalTo: num00.centerXAnchor).isActive = true
            sub00.centerYAnchor.constraint(equalTo: num00.centerYAnchor).isActive = true
            sub00.widthAnchor.constraint(equalTo: num00.heightAnchor, multiplier: CGFloat(modifiedWidth[10])).isActive = true
            sub00.heightAnchor.constraint(equalTo: num00.heightAnchor, multiplier: CGFloat(heights[10])).isActive = true
            
            numberDot.addSubview(subDot)
            subDot.translatesAutoresizingMaskIntoConstraints = false
            subDot.centerXAnchor.constraint(equalTo: numberDot.centerXAnchor).isActive = true
            subDot.centerYAnchor.constraint(equalTo: numberDot.centerYAnchor).isActive = true
            subDot.widthAnchor.constraint(equalTo: numberDot.heightAnchor, multiplier: CGFloat(modifiedWidth[11])).isActive = true
            subDot.heightAnchor.constraint(equalTo: numberDot.heightAnchor, multiplier: CGFloat(heights[11])).isActive = true
            
            
            clearButton.addSubview(subClear)
            subClear.translatesAutoresizingMaskIntoConstraints = false
            subClear.centerXAnchor.constraint(equalTo: clearButton.centerXAnchor).isActive = true
            subClear.centerYAnchor.constraint(equalTo: clearButton.centerYAnchor).isActive = true
            subClear.widthAnchor.constraint(equalTo: clearButton.heightAnchor, multiplier: CGFloat(modifiedWidth[12])).isActive = true
            subClear.heightAnchor.constraint(equalTo: clearButton.heightAnchor, multiplier: CGFloat(heights[12])).isActive = true
            
            
            openParenthesis.addSubview(subOpenpar)
            subOpenpar.translatesAutoresizingMaskIntoConstraints = false
            subOpenpar.centerXAnchor.constraint(equalTo: openParenthesis.centerXAnchor).isActive = true
            subOpenpar.centerYAnchor.constraint(equalTo: openParenthesis.centerYAnchor).isActive = true
            subOpenpar.widthAnchor.constraint(equalTo: openParenthesis.heightAnchor, multiplier: CGFloat(modifiedWidth[13])).isActive = true
            subOpenpar.heightAnchor.constraint(equalTo: openParenthesis.heightAnchor, multiplier: CGFloat(heights[13])).isActive = true
            
            closeParenthesis.addSubview(subClosepar)
            subClosepar.translatesAutoresizingMaskIntoConstraints = false
            subClosepar.centerXAnchor.constraint(equalTo: closeParenthesis.centerXAnchor).isActive = true
            subClosepar.centerYAnchor.constraint(equalTo: closeParenthesis.centerYAnchor).isActive = true
            subClosepar.widthAnchor.constraint(equalTo: closeParenthesis.heightAnchor, multiplier: CGFloat(modifiedWidth[14])).isActive = true
            subClosepar.heightAnchor.constraint(equalTo: closeParenthesis.heightAnchor, multiplier: CGFloat(heights[14])).isActive = true
            
            operationButtonDivide.addSubview(subDivide)
            subDivide.translatesAutoresizingMaskIntoConstraints = false
            subDivide.centerXAnchor.constraint(equalTo: operationButtonDivide.centerXAnchor).isActive = true
            subDivide.centerYAnchor.constraint(equalTo: operationButtonDivide.centerYAnchor).isActive = true
            subDivide.widthAnchor.constraint(equalTo: operationButtonDivide.heightAnchor, multiplier: CGFloat(modifiedWidth[15])).isActive = true
            subDivide.heightAnchor.constraint(equalTo: operationButtonDivide.heightAnchor, multiplier: CGFloat(heights[15])).isActive = true
            
            operationButtonMultiply.addSubview(subMulti)
            subMulti.translatesAutoresizingMaskIntoConstraints = false
            subMulti.centerXAnchor.constraint(equalTo: operationButtonMultiply.centerXAnchor).isActive = true
            subMulti.centerYAnchor.constraint(equalTo: operationButtonMultiply.centerYAnchor).isActive = true
            subMulti.widthAnchor.constraint(equalTo: operationButtonMultiply.heightAnchor, multiplier: CGFloat(modifiedWidth[16])).isActive = true
            subMulti.heightAnchor.constraint(equalTo: operationButtonMultiply.heightAnchor, multiplier: CGFloat(heights[16])).isActive = true
            
            operationButtonPlus.addSubview(subPlus)
            subPlus.translatesAutoresizingMaskIntoConstraints = false
            subPlus.centerXAnchor.constraint(equalTo: operationButtonPlus.centerXAnchor).isActive = true
            subPlus.centerYAnchor.constraint(equalTo: operationButtonPlus.centerYAnchor).isActive = true
            subPlus.widthAnchor.constraint(equalTo: operationButtonPlus.heightAnchor, multiplier: CGFloat(modifiedWidth[17])).isActive = true
            subPlus.heightAnchor.constraint(equalTo: operationButtonPlus.heightAnchor, multiplier: CGFloat(heights[17])).isActive = true
            
            operationButtonMinus.addSubview(subMinus)
            subMinus.translatesAutoresizingMaskIntoConstraints = false
            subMinus.centerXAnchor.constraint(equalTo: operationButtonMinus.centerXAnchor).isActive = true
            subMinus.centerYAnchor.constraint(equalTo: operationButtonMinus.centerYAnchor).isActive = true
            subMinus.widthAnchor.constraint(equalTo: operationButtonMinus.heightAnchor, multiplier: CGFloat(modifiedWidth[18])).isActive = true
            subMinus.heightAnchor.constraint(equalTo: operationButtonMinus.heightAnchor, multiplier: CGFloat(heights[18])).isActive = true
            
            equalButton.addSubview(subEqual)
            subEqual.translatesAutoresizingMaskIntoConstraints = false
            subEqual.centerXAnchor.constraint(equalTo: equalButton.centerXAnchor).isActive = true
            subEqual.centerYAnchor.constraint(equalTo: equalButton.centerYAnchor).isActive = true
            subEqual.widthAnchor.constraint(equalTo: equalButton.heightAnchor, multiplier: CGFloat(modifiedWidth[19])).isActive = true
            subEqual.heightAnchor.constraint(equalTo: equalButton.heightAnchor, multiplier: CGFloat(heights[19])).isActive = true
            
            extra2.addSubview(subEx2Color)
            subEx2Color.translatesAutoresizingMaskIntoConstraints = false
            subEx2Color.centerXAnchor.constraint(equalTo: extra2.centerXAnchor).isActive = true
            subEx2Color.centerYAnchor.constraint(equalTo: extra2.centerYAnchor).isActive = true
            subEx2Color.widthAnchor.constraint(equalTo: extra2.heightAnchor, multiplier: CGFloat(0.288) * CGFloat(ratio)).isActive = true
            subEx2Color.heightAnchor.constraint(equalTo: extra2.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
            
            extra4.addSubview(subEx4Feedback)
            subEx4Feedback.translatesAutoresizingMaskIntoConstraints = false
            subEx4Feedback.centerXAnchor.constraint(equalTo: extra4.centerXAnchor).isActive = true
            subEx4Feedback.centerYAnchor.constraint(equalTo: extra4.centerYAnchor).isActive = true
            subEx4Feedback.widthAnchor.constraint(equalTo: extra4.heightAnchor, multiplier: CGFloat(0.288 * ratio) ).isActive = true
            subEx4Feedback.heightAnchor.constraint(equalTo: extra4.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
            
            
            if isSoundOn{
                subEx1Sound = UIImageView(image: #imageLiteral(resourceName: "etcSoundsOnLight"))// light and Sound On
                extra1.addSubview(subEx1Sound)
                subEx1Sound.translatesAutoresizingMaskIntoConstraints = false
                subEx1Sound.centerXAnchor.constraint(equalTo: extra1.centerXAnchor).isActive = true
                subEx1Sound.centerYAnchor.constraint(equalTo: extra1.centerYAnchor).isActive = true
                subEx1Sound.widthAnchor.constraint(equalTo: extra1.heightAnchor, multiplier: CGFloat(0.288 * ratio)).isActive = true
                subEx1Sound.heightAnchor.constraint(equalTo: extra1.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
            }else{
                subEx1Sound = UIImageView(image: #imageLiteral(resourceName: "etcSoundsOffLight"))// light and Sound Off
                extra1.addSubview(subEx1Sound)
                subEx1Sound.translatesAutoresizingMaskIntoConstraints = false
                subEx1Sound.centerXAnchor.constraint(equalTo: extra1.centerXAnchor).isActive = true
                subEx1Sound.centerYAnchor.constraint(equalTo: extra1.centerYAnchor).isActive = true
                subEx1Sound.widthAnchor.constraint(equalTo: extra1.heightAnchor, multiplier: CGFloat(0.288 * ratio)).isActive = true
                subEx1Sound.heightAnchor.constraint(equalTo: extra1.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
            }
            
            if isNotificationOn{
                subEx3Notification = UIImageView(image: #imageLiteral(resourceName: "etcNotificationOnLight")) // light and Notification On
                extra3.addSubview(subEx3Notification)
                subEx3Notification.translatesAutoresizingMaskIntoConstraints = false
                subEx3Notification.centerXAnchor.constraint(equalTo: extra3.centerXAnchor).isActive = true
                subEx3Notification.centerYAnchor.constraint(equalTo: extra3.centerYAnchor).isActive = true
                subEx3Notification.widthAnchor.constraint(equalTo: extra3.heightAnchor, multiplier: CGFloat(0.288 * ratio)).isActive = true
                subEx3Notification.heightAnchor.constraint(equalTo: extra3.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
            }else{
                subEx3Notification = UIImageView(image: #imageLiteral(resourceName: "etcNotificationOffLight")) // light and Notification Off
                extra3.addSubview(subEx3Notification)
                subEx3Notification.translatesAutoresizingMaskIntoConstraints = false
                subEx3Notification.centerXAnchor.constraint(equalTo: extra3.centerXAnchor).isActive = true
                subEx3Notification.centerYAnchor.constraint(equalTo: extra3.centerYAnchor).isActive = true
                subEx3Notification.widthAnchor.constraint(equalTo: extra3.heightAnchor, multiplier: CGFloat(0.288 * ratio)).isActive = true
                subEx3Notification.heightAnchor.constraint(equalTo: extra3.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
            }
            
            progressView.textColor = colorList.textColorForProcessBM
            if isAnsPressed{
                resultTextView.textColor = colorList.textColorForResultBM
            }
            
            resultTextView.textColor = isAnsPressed ? colorList.textColorForResultBM : colorList.textColorForSemiResultBM
            //             resultTextView.textColor = isLightModeOn ? colorList.textColorForSemiResultBM : colorList.textColorForSemiResultDM
            
        }else{ // darkMode
            for num in numButtons{
                num.backgroundColor =  colorList.bgColorForEmptyAndNumbersDM
            }
            for other in otherButtons{
                other.backgroundColor =  colorList.bgColorForOperatorsDM
            }
            for extra in extras{
                extra.backgroundColor =  colorList.bgColorForExtrasDM
            }
            deleteButton.backgroundColor =  colorList.bgColorForEmptyAndNumbersDM
            
            subHistory = UIImageView(image: #imageLiteral(resourceName: "historyD"))
            
            sub0 = UIImageView(image: #imageLiteral(resourceName: "0D"))
            sub1 = UIImageView(image: #imageLiteral(resourceName: "1D"))
            sub2 = UIImageView(image: #imageLiteral(resourceName: "2D"))
            sub3 = UIImageView(image: #imageLiteral(resourceName: "3D"))
            sub4 = UIImageView(image: #imageLiteral(resourceName: "4D"))
            sub5 = UIImageView(image: #imageLiteral(resourceName: "5D"))
            
            sub6 = UIImageView(image: #imageLiteral(resourceName: "6D"))
            sub7 = UIImageView(image: #imageLiteral(resourceName: "7D"))
            sub8 = UIImageView(image: #imageLiteral(resourceName: "8D"))
            sub9 = UIImageView(image: #imageLiteral(resourceName: "9D"))
            sub00 = UIImageView(image: #imageLiteral(resourceName: "00D"))
            subDot = UIImageView(image: #imageLiteral(resourceName: "dotD"))
            
            subClear = UIImageView(image: #imageLiteral(resourceName: "CD"))
            subOpenpar = UIImageView(image: #imageLiteral(resourceName: "(D"))
            subClosepar = UIImageView(image: #imageLiteral(resourceName: ")D"))
            subDivide = UIImageView(image: #imageLiteral(resourceName: "÷D"))
            subMulti = UIImageView(image: #imageLiteral(resourceName: "xD"))
            subPlus = UIImageView(image: #imageLiteral(resourceName: "+D"))
            subMinus = UIImageView(image: #imageLiteral(resourceName: "–D"))
            subEqual = UIImageView(image: #imageLiteral(resourceName: "=D"))
            
            subEx2Color = UIImageView(image: #imageLiteral(resourceName: "etcColorModeChangeToLight"))
            subEx4Feedback = UIImageView(image: #imageLiteral(resourceName: "etcFeedbackDark"))
            
            for view in historyClickButton.subviews{
                view.removeFromSuperview()
            }
            
            for i in 0 ..< numsAndOpers.count{
                for view in numsAndOpers[i].subviews { // It works !!! whow!!
                    view.removeFromSuperview()
                }
            }
            
            for i in 0 ..< extras.count{
                for view in extras[i].subviews { // It works !!! whow!!
                    view.removeFromSuperview()
                }
            }
            
            historyClickButton.addSubview(subHistory)
            subHistory.translatesAutoresizingMaskIntoConstraints = false
            subHistory.centerXAnchor.constraint(equalTo: historyClickButton.centerXAnchor).isActive = true
            subHistory.topAnchor.constraint(equalTo: historyClickButton.topAnchor).isActive = true
            subHistory.widthAnchor.constraint(equalTo: historyClickButton.widthAnchor, multiplier: 0.6).isActive = true
            subHistory.heightAnchor.constraint(equalToConstant: 15).isActive = true
            
            num0.addSubview(sub0)
            sub0.translatesAutoresizingMaskIntoConstraints = false
            sub0.centerXAnchor.constraint(equalTo: num0.centerXAnchor).isActive = true
            sub0.centerYAnchor.constraint(equalTo: num0.centerYAnchor).isActive = true
            sub0.widthAnchor.constraint(equalTo: num0.heightAnchor, multiplier: CGFloat(modifiedWidth[0])).isActive = true
            sub0.heightAnchor.constraint(equalTo: num0.heightAnchor, multiplier: CGFloat(heights[0])).isActive = true
            
            num1.addSubview(sub1)
            sub1.translatesAutoresizingMaskIntoConstraints = false
            sub1.centerXAnchor.constraint(equalTo: num1.centerXAnchor).isActive = true
            sub1.centerYAnchor.constraint(equalTo: num1.centerYAnchor).isActive = true
            sub1.widthAnchor.constraint(equalTo: num1.heightAnchor, multiplier: CGFloat(modifiedWidth[1])).isActive = true
            sub1.heightAnchor.constraint(equalTo: num1.heightAnchor, multiplier: CGFloat(heights[1])).isActive = true
            
            num2.addSubview(sub2)
            sub2.translatesAutoresizingMaskIntoConstraints = false
            sub2.centerXAnchor.constraint(equalTo: num2.centerXAnchor).isActive = true
            sub2.centerYAnchor.constraint(equalTo: num2.centerYAnchor).isActive = true
            sub2.widthAnchor.constraint(equalTo: num2.heightAnchor, multiplier: CGFloat(modifiedWidth[2])).isActive = true
            sub2.heightAnchor.constraint(equalTo: num2.heightAnchor, multiplier: CGFloat(heights[2])).isActive = true
            
            num3.addSubview(sub3)
            sub3.translatesAutoresizingMaskIntoConstraints = false
            sub3.centerXAnchor.constraint(equalTo: num3.centerXAnchor).isActive = true
            sub3.centerYAnchor.constraint(equalTo: num3.centerYAnchor).isActive = true
            sub3.widthAnchor.constraint(equalTo: num3.heightAnchor, multiplier: CGFloat(modifiedWidth[3])).isActive = true
            sub3.heightAnchor.constraint(equalTo: num3.heightAnchor, multiplier: CGFloat(heights[3])).isActive = true
            
            num4.addSubview(sub4)
            sub4.translatesAutoresizingMaskIntoConstraints = false
            sub4.centerXAnchor.constraint(equalTo: num4.centerXAnchor).isActive = true
            sub4.centerYAnchor.constraint(equalTo: num4.centerYAnchor).isActive = true
            sub4.widthAnchor.constraint(equalTo: num4.heightAnchor, multiplier: CGFloat(modifiedWidth[4])).isActive = true
            sub4.heightAnchor.constraint(equalTo: num4.heightAnchor, multiplier: CGFloat(heights[4])).isActive = true
            
            num5.addSubview(sub5)
            sub5.translatesAutoresizingMaskIntoConstraints = false
            sub5.centerXAnchor.constraint(equalTo: num5.centerXAnchor).isActive = true
            sub5.centerYAnchor.constraint(equalTo: num5.centerYAnchor).isActive = true
            sub5.widthAnchor.constraint(equalTo: num5.heightAnchor, multiplier: CGFloat(modifiedWidth[5])).isActive = true
            sub5.heightAnchor.constraint(equalTo: num5.heightAnchor, multiplier: CGFloat(heights[5])).isActive = true
            //
            num6.addSubview(sub6)
            sub6.translatesAutoresizingMaskIntoConstraints = false
            sub6.centerXAnchor.constraint(equalTo: num6.centerXAnchor).isActive = true
            sub6.centerYAnchor.constraint(equalTo: num6.centerYAnchor).isActive = true
            sub6.widthAnchor.constraint(equalTo: num6.heightAnchor, multiplier: CGFloat(modifiedWidth[6])).isActive = true
            sub6.heightAnchor.constraint(equalTo: num6.heightAnchor, multiplier: CGFloat(heights[6])).isActive = true
            
            num7.addSubview(sub7)
            sub7.translatesAutoresizingMaskIntoConstraints = false
            sub7.centerXAnchor.constraint(equalTo: num7.centerXAnchor).isActive = true
            sub7.centerYAnchor.constraint(equalTo: num7.centerYAnchor).isActive = true
            sub7.widthAnchor.constraint(equalTo: num7.heightAnchor, multiplier: CGFloat(modifiedWidth[7])).isActive = true
            sub7.heightAnchor.constraint(equalTo: num7.heightAnchor, multiplier: CGFloat(heights[7])).isActive = true
            
            num8.addSubview(sub8)
            sub8.translatesAutoresizingMaskIntoConstraints = false
            sub8.centerXAnchor.constraint(equalTo: num8.centerXAnchor).isActive = true
            sub8.centerYAnchor.constraint(equalTo: num8.centerYAnchor).isActive = true
            sub8.widthAnchor.constraint(equalTo: num8.heightAnchor, multiplier: CGFloat(modifiedWidth[8])).isActive = true
            sub8.heightAnchor.constraint(equalTo: num8.heightAnchor, multiplier: CGFloat(heights[8])).isActive = true
            
            num9.addSubview(sub9)
            sub9.translatesAutoresizingMaskIntoConstraints = false
            sub9.centerXAnchor.constraint(equalTo: num9.centerXAnchor).isActive = true
            sub9.centerYAnchor.constraint(equalTo: num9.centerYAnchor).isActive = true
            sub9.widthAnchor.constraint(equalTo: num9.heightAnchor, multiplier: CGFloat(modifiedWidth[9])).isActive = true
            sub9.heightAnchor.constraint(equalTo: num9.heightAnchor, multiplier: CGFloat(heights[9])).isActive = true
            
            num00.addSubview(sub00)
            sub00.translatesAutoresizingMaskIntoConstraints = false
            sub00.centerXAnchor.constraint(equalTo: num00.centerXAnchor).isActive = true
            sub00.centerYAnchor.constraint(equalTo: num00.centerYAnchor).isActive = true
            sub00.widthAnchor.constraint(equalTo: num00.heightAnchor, multiplier: CGFloat(modifiedWidth[10])).isActive = true
            sub00.heightAnchor.constraint(equalTo: num00.heightAnchor, multiplier: CGFloat(heights[10])).isActive = true
            
            numberDot.addSubview(subDot)
            subDot.translatesAutoresizingMaskIntoConstraints = false
            subDot.centerXAnchor.constraint(equalTo: numberDot.centerXAnchor).isActive = true
            subDot.centerYAnchor.constraint(equalTo: numberDot.centerYAnchor).isActive = true
            subDot.widthAnchor.constraint(equalTo: numberDot.heightAnchor, multiplier: CGFloat(modifiedWidth[11])).isActive = true
            subDot.heightAnchor.constraint(equalTo: numberDot.heightAnchor, multiplier: CGFloat(heights[11])).isActive = true
            
            
            clearButton.addSubview(subClear)
            subClear.translatesAutoresizingMaskIntoConstraints = false
            subClear.centerXAnchor.constraint(equalTo: clearButton.centerXAnchor).isActive = true
            subClear.centerYAnchor.constraint(equalTo: clearButton.centerYAnchor).isActive = true
            subClear.widthAnchor.constraint(equalTo: clearButton.heightAnchor, multiplier: CGFloat(modifiedWidth[12])).isActive = true
            subClear.heightAnchor.constraint(equalTo: clearButton.heightAnchor, multiplier: CGFloat(heights[12])).isActive = true
            
            
            openParenthesis.addSubview(subOpenpar)
            subOpenpar.translatesAutoresizingMaskIntoConstraints = false
            subOpenpar.centerXAnchor.constraint(equalTo: openParenthesis.centerXAnchor).isActive = true
            subOpenpar.centerYAnchor.constraint(equalTo: openParenthesis.centerYAnchor).isActive = true
            subOpenpar.widthAnchor.constraint(equalTo: openParenthesis.heightAnchor, multiplier: CGFloat(modifiedWidth[13])).isActive = true
            subOpenpar.heightAnchor.constraint(equalTo: openParenthesis.heightAnchor, multiplier: CGFloat(heights[13])).isActive = true
            
            closeParenthesis.addSubview(subClosepar)
            subClosepar.translatesAutoresizingMaskIntoConstraints = false
            subClosepar.centerXAnchor.constraint(equalTo: closeParenthesis.centerXAnchor).isActive = true
            subClosepar.centerYAnchor.constraint(equalTo: closeParenthesis.centerYAnchor).isActive = true
            subClosepar.widthAnchor.constraint(equalTo: closeParenthesis.heightAnchor, multiplier: CGFloat(modifiedWidth[14])).isActive = true
            subClosepar.heightAnchor.constraint(equalTo: closeParenthesis.heightAnchor, multiplier: CGFloat(heights[14])).isActive = true
            
            operationButtonDivide.addSubview(subDivide)
            subDivide.translatesAutoresizingMaskIntoConstraints = false
            subDivide.centerXAnchor.constraint(equalTo: operationButtonDivide.centerXAnchor).isActive = true
            subDivide.centerYAnchor.constraint(equalTo: operationButtonDivide.centerYAnchor).isActive = true
            subDivide.widthAnchor.constraint(equalTo: operationButtonDivide.heightAnchor, multiplier: CGFloat(modifiedWidth[15])).isActive = true
            subDivide.heightAnchor.constraint(equalTo: operationButtonDivide.heightAnchor, multiplier: CGFloat(heights[15])).isActive = true
            
            
            operationButtonMultiply.addSubview(subMulti)
            subMulti.translatesAutoresizingMaskIntoConstraints = false
            subMulti.centerXAnchor.constraint(equalTo: operationButtonMultiply.centerXAnchor).isActive = true
            subMulti.centerYAnchor.constraint(equalTo: operationButtonMultiply.centerYAnchor).isActive = true
            subMulti.widthAnchor.constraint(equalTo: operationButtonMultiply.heightAnchor, multiplier: CGFloat(modifiedWidth[16])).isActive = true
            subMulti.heightAnchor.constraint(equalTo: operationButtonMultiply.heightAnchor, multiplier: CGFloat(heights[16])).isActive = true
            
            operationButtonPlus.addSubview(subPlus)
            subPlus.translatesAutoresizingMaskIntoConstraints = false
            subPlus.centerXAnchor.constraint(equalTo: operationButtonPlus.centerXAnchor).isActive = true
            subPlus.centerYAnchor.constraint(equalTo: operationButtonPlus.centerYAnchor).isActive = true
            subPlus.widthAnchor.constraint(equalTo: operationButtonPlus.heightAnchor, multiplier: CGFloat(modifiedWidth[17])).isActive = true
            subPlus.heightAnchor.constraint(equalTo: operationButtonPlus.heightAnchor, multiplier: CGFloat(heights[17])).isActive = true
            
            operationButtonMinus.addSubview(subMinus)
            subMinus.translatesAutoresizingMaskIntoConstraints = false
            subMinus.centerXAnchor.constraint(equalTo: operationButtonMinus.centerXAnchor).isActive = true
            subMinus.centerYAnchor.constraint(equalTo: operationButtonMinus.centerYAnchor).isActive = true
            subMinus.widthAnchor.constraint(equalTo: operationButtonMinus.heightAnchor, multiplier: CGFloat(modifiedWidth[18])).isActive = true
            subMinus.heightAnchor.constraint(equalTo: operationButtonMinus.heightAnchor, multiplier: CGFloat(heights[18])).isActive = true
            
            equalButton.addSubview(subEqual)
            subEqual.translatesAutoresizingMaskIntoConstraints = false
            subEqual.centerXAnchor.constraint(equalTo: equalButton.centerXAnchor).isActive = true
            subEqual.centerYAnchor.constraint(equalTo: equalButton.centerYAnchor).isActive = true
            subEqual.widthAnchor.constraint(equalTo: equalButton.heightAnchor, multiplier: CGFloat(modifiedWidth[19])).isActive = true
            subEqual.heightAnchor.constraint(equalTo: equalButton.heightAnchor, multiplier: CGFloat(heights[19])).isActive = true
            
            extra2.addSubview(subEx2Color)
            subEx2Color.translatesAutoresizingMaskIntoConstraints = false
            subEx2Color.centerXAnchor.constraint(equalTo: extra2.centerXAnchor).isActive = true
            subEx2Color.centerYAnchor.constraint(equalTo: extra2.centerYAnchor).isActive = true
            subEx2Color.widthAnchor.constraint(equalTo: extra2.heightAnchor, multiplier: CGFloat(0.288 * ratio)).isActive = true
            subEx2Color.heightAnchor.constraint(equalTo: extra2.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
            
            extra4.addSubview(subEx4Feedback)
            subEx4Feedback.translatesAutoresizingMaskIntoConstraints = false
            subEx4Feedback.centerXAnchor.constraint(equalTo: extra4.centerXAnchor).isActive = true
            subEx4Feedback.centerYAnchor.constraint(equalTo: extra4.centerYAnchor).isActive = true
            subEx4Feedback.widthAnchor.constraint(equalTo: extra4.heightAnchor, multiplier: CGFloat(0.288 * ratio)).isActive = true
            subEx4Feedback.heightAnchor.constraint(equalTo: extra4.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
            
            
            if isSoundOn{
                subEx1Sound = UIImageView(image: #imageLiteral(resourceName: "etcSoundsOnDark"))// dark and Sound On
                extra1.addSubview(subEx1Sound)
                subEx1Sound.translatesAutoresizingMaskIntoConstraints = false
                subEx1Sound.centerXAnchor.constraint(equalTo: extra1.centerXAnchor).isActive = true
                subEx1Sound.centerYAnchor.constraint(equalTo: extra1.centerYAnchor).isActive = true
                subEx1Sound.widthAnchor.constraint(equalTo: extra1.heightAnchor, multiplier: CGFloat(0.288 * ratio)).isActive = true
                subEx1Sound.heightAnchor.constraint(equalTo: extra1.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
            }else{
                subEx1Sound = UIImageView(image: #imageLiteral(resourceName: "etcSoundsOffDark"))// dark and Sound Off
                extra1.addSubview(subEx1Sound)
                subEx1Sound.translatesAutoresizingMaskIntoConstraints = false
                subEx1Sound.centerXAnchor.constraint(equalTo: extra1.centerXAnchor).isActive = true
                subEx1Sound.centerYAnchor.constraint(equalTo: extra1.centerYAnchor).isActive = true
                subEx1Sound.widthAnchor.constraint(equalTo: extra1.heightAnchor, multiplier: CGFloat(0.288 * ratio)).isActive = true
                subEx1Sound.heightAnchor.constraint(equalTo: extra1.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
            }
            
            if isNotificationOn{
                subEx3Notification = UIImageView(image: #imageLiteral(resourceName: "etcNotificationOnDark")) // dark and Notification On
                extra3.addSubview(subEx3Notification)
                subEx3Notification.translatesAutoresizingMaskIntoConstraints = false
                subEx3Notification.centerXAnchor.constraint(equalTo: extra3.centerXAnchor).isActive = true
                subEx3Notification.centerYAnchor.constraint(equalTo: extra3.centerYAnchor).isActive = true
                subEx3Notification.widthAnchor.constraint(equalTo: extra3.heightAnchor, multiplier: CGFloat(0.288 * ratio)).isActive = true
                subEx3Notification.heightAnchor.constraint(equalTo: extra3.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
            }else{
                subEx3Notification = UIImageView(image: #imageLiteral(resourceName: "etcNotificationOffDark")) // dark and Notification Off
                extra3.addSubview(subEx3Notification)
                subEx3Notification.translatesAutoresizingMaskIntoConstraints = false
                subEx3Notification.centerXAnchor.constraint(equalTo: extra3.centerXAnchor).isActive = true
                subEx3Notification.centerYAnchor.constraint(equalTo: extra3.centerYAnchor).isActive = true
                subEx3Notification.widthAnchor.constraint(equalTo: extra3.heightAnchor, multiplier: CGFloat(0.288 * ratio)).isActive = true
                subEx3Notification.heightAnchor.constraint(equalTo: extra3.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
            }
            
            progressView.textColor = colorList.textColorForProcessDM
            resultTextView.textColor = isAnsPressed ? colorList.textColorForResultDM : colorList.textColorForSemiResultDM
        }
    }
}

extension Date {
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}


public extension String {
    func firstIndexInt(of char: Character) -> Int? {
        return firstIndex(of: char)?.utf16Offset(in: self)
    }
    
    func lastIndexInt(of char : Character) -> Int? {
        return lastIndex(of: char)?.utf16Offset(in: self)
    }
}



extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}

extension FloatingPoint{}

extension Double {
    func decimalCount() -> Int {
        if self == Double(Int(self)) {
            return 0
        }

        let integerString = String(Int(self))
        let doubleString = String(Double(self))
        let decimalCount = doubleString.count - integerString.count - 1

        return decimalCount
    }
}
