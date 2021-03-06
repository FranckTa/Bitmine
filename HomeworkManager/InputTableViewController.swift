import UIKit
import RealmSwift

class InputTableViewController: UITableViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    var homework = Homework()
    private let realm = RealmModelManager.sharedManager
    private var reference: String?
    private var closeAt = NSDate()
    private var subjects: Results<Subject>?
    private var update = false
    private var incrementDayTimer: NSTimer?
    private var decrementDayTimer: NSTimer?
    @IBOutlet weak var deadlineDatePicker: UIDatePicker!
    @IBOutlet weak var subjectSegmentedControl: UISegmentedControl!
    @IBOutlet weak var subjectSelectedTabSegmentedControl: UISegmentedControl!
    @IBOutlet weak var referenceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    var tabNum = 0
    
    override func viewDidLoad() {
        subjects = realm.findAllObjects(Subject)
        if(homework.subject?.name != nil) {
            update = true
        }
        subjectSegmentedControl.apportionsSegmentWidthsByContent = false
        if(update) {
            deadlineDatePicker.date = homework.closeAt
            closeAt = deadlineDatePicker.date
            for (i, subject) in subjects!.enumerate(){
                if (subject ==  homework.subject) {
                    subjectSegmentedControl.setTitle(subject.name, forSegmentAtIndex: i % 5)
                    subjectSegmentedControl.setTitleTextAttributes(NSDictionary(object: UIFont.boldSystemFontOfSize(25), forKey: NSFontAttributeName) as [NSObject : AnyObject], forState: UIControlState.Normal)
                    subjectSelectedTabSegmentedControl.selectedSegmentIndex = i / 5
                    segmentChange()
                    subjectSegmentedControl.selectedSegmentIndex = i % 5
                    subjectSegmentedControl.tintColor = UIColor.hexStr(subjects![i].hexColor, alpha: 1)
                }
            }
            if(homework.reference == "教科書") {
                reference = "教科書"
                referenceSegmentedControl.selectedSegmentIndex = 1
            } else {
                reference = "プリント"
                referenceSegmentedControl.selectedSegmentIndex = 0
            }
        } else {
            reference = "プリント"
            deadlineDatePicker.date = TimezoneConverter.convertToJST(NSDate(timeIntervalSinceNow: 24*60*60*7))
            for i in 0...4{
                let subject = subjects![i+tabNum*5]
                subjectSegmentedControl.setTitle(subject.name, forSegmentAtIndex: i)
                subjectSegmentedControl.setTitleTextAttributes(NSDictionary(object: UIFont.boldSystemFontOfSize(25), forKey: NSFontAttributeName) as [NSObject : AnyObject], forState: UIControlState.Normal)
            }
            closeAt = deadlineDatePicker.date
            subjectSegmentedControl.tintColor = UIColor.hexStr(subjects![0].hexColor, alpha: 1)
        }
        referenceSegmentedControl.setTitleTextAttributes(NSDictionary(object: UIFont.boldSystemFontOfSize(25), forKey: NSFontAttributeName) as [NSObject : AnyObject], forState: UIControlState.Normal)
        configurePlusMinusButton()
        subjectSegmentedControl(subjectSegmentedControl)
    }

    func configurePlusMinusButton() {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            minusButton.hidden = true
            plusButton.hidden = true
        }
    }
    
    @IBAction func subjectSelectedTabSegmentControl(sender: UISegmentedControl) {
        segmentChange()
    }
    
    func segmentChange() {
        if (self.subjectSegmentedControl.numberOfSegments != 0) {
            self.subjectSegmentedControl.removeAllSegments()
        }
        tabNum = subjectSelectedTabSegmentedControl.selectedSegmentIndex
        for i in 0...4 {
            if i + tabNum * 5 < subjects?.count {
                self.subjectSegmentedControl.insertSegmentWithTitle(subjects![i + tabNum * 5].name, atIndex: i, animated: true)
            } else {
                break
            }
        }
        if tabNum * 5 < subjects?.count {
            self.subjectSegmentedControl.tintColor = UIColor.hexStr(subjects![tabNum*5].hexColor, alpha: 1)
        }
    }
    
    @IBAction func subjectSegmentedControl(sender: UISegmentedControl) {
        let index = subjectSegmentedControl.selectedSegmentIndex
        let selectedSubjectColor = UIColor.hexStr(subjects![index + tabNum * 5].hexColor, alpha: 1)
        self.subjectSegmentedControl.tintColor = selectedSubjectColor
    }
    
    @IBAction func referenceSegmentedControl(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            reference = "プリント"
        case 1:
            reference = "教科書"
        default:
            reference = ""
        }
    }
    
    @IBAction func deadlineDatePicker(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeZone = NSTimeZone(abbreviation: "JST")
        let date = dateFormatter.dateFromString(dateFormatter.stringFromDate(sender.date))
        closeAt = TimezoneConverter.convertToJST(date!)
        }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let homeworks = realm.findAllObjects(Homework.self)
        return (homeworks.filter(NSPredicate(format: "createdAt == %@", TimezoneConverter.convertToJST(NSDate())))).count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
         let cell = (collectionView.dequeueReusableCellWithReuseIdentifier("cell1", forIndexPath: indexPath) as! TodayHomeworkCollectionViewCell) ?? TodayHomeworkCollectionViewCell()
        let homeworks = realm.findAllObjects(Homework.self)
        cell.subjectNameLabel.text = (homeworks.filter(NSPredicate(format: "createdAt == %@", TimezoneConverter.convertToJST(NSDate()))))[indexPath.row].subject!.name
        cell.backgroundColor = UIColor.hexStr((homeworks.filter(NSPredicate(format: "createdAt == %@", TimezoneConverter.convertToJST(NSDate()))))[indexPath.row].subject!.hexColor, alpha: 1)
        return cell
    }
    
    @objc private func decrementDayTime() {
        deadlineDatePicker.date = NSDate(timeInterval: -24*60*60, sinceDate: deadlineDatePicker.date)
    }
    
    @objc private func incrementDayTime() {
        deadlineDatePicker.date = NSDate(timeInterval: 24*60*60, sinceDate: deadlineDatePicker.date)
    }
    
    @IBAction func minusDeadlineUIButtonTouchUpInside(sender: AnyObject) {
        decrementDayTime()
    }
    
    @IBAction func plusDeadlineUIButtonTouchUpInside(sender: AnyObject) {
        incrementDayTime()
    }
    
    @IBAction func minusDeadlineUIButtonLongTouchUpInside(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case UIGestureRecognizerState.Began:
            decrementDayTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(decrementDayTime), userInfo: nil, repeats: true)
            break
        case UIGestureRecognizerState.Ended:
            decrementDayTimer?.invalidate()
            break
        default:
            break
        }
    }
    
    @IBAction func plusDeadlineUIButtonLongTouchUpInside(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case UIGestureRecognizerState.Began:
            incrementDayTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(incrementDayTime), userInfo: nil, repeats: true)
            break
        case UIGestureRecognizerState.Ended:
            incrementDayTimer?.invalidate()
            break
        default:
            break
        }
    }
    
    
    @IBAction func saveUIButtonTouchUpInside(sender: UIButton) {
        let subject = subjects![subjectSegmentedControl.selectedSegmentIndex + tabNum * 5]
        let homework = Homework()
        homework.subject = subject
        homework.reference = reference!
        homework.closeAt = closeAt
        homework.createdAt = TimezoneConverter.convertToJST((NSDate()))
        
        if(update) {
            realm.update(self.homework, value: ["subject": homework.subject as! AnyObject, "reference": homework.reference, "closeAt": homework.closeAt])
        } else {
            realm.create(Homework.self, value: homework)
        }
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancelUIButtonTouchUpInside(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
