//
//  multiSelectionPopUpVC.swift
//  GoFeds
//

import UIKit


var selectedPortIndex : [Int] = []
var currentPortIndex = -1

var selectedPorts : [Int] = []

var seletedDesiredPorts = ""
var selectedCurrentPort = ""
var selectedDesiredPortsArray : [String] = []

var selectedMultiPortIndexes : [Int] = []

 let desiredPorts = ["Port Arthur/ Beaumont","TXPort Canaveral","FLPort Everglades","FL Port Huename","CA Port Huron","ML Port Townsend","WA Portal","ND Porthill","ID Portland","ME Portland","OR Portsmouth","NH Presidio","TX Progreso TX San Luis", "AZ San Ysidrdo","CA Sandford", "FL Santa Teresa", "NM Sarasota/Bradenton Airport(UF)", "FL Sales","ND Sasabe","AZ Sault Sainte Marie","ML Savannah", "GA Scobey", "MT Seattle","WA Sherwood", "ND Shreveport","LA Tulsa","OK Turner","MT Van Buren","ME Vanceboro","ME Vicksburg","MS Walhalla","ND Warroad","MN West Palm Beach","FL Westhope","ND Whitlash","MT Wichita","KS Wild Horse","MTWilkes Barre/Scranton","PA"]
let currentPort = ["Albany, NY","Albuquerque, NM","Alexandria Bay, NY","Ambrose, ND","Anacortes, WA","Andrade, CA","Antler, ND","Appleton International Airport, WI","Ashtabula/Conneaut, OH","Astoria, OR","Atlanta, GA","Atlantic City User Fee Airport, NJ","Austin, TX","Baltimore, MD","Bangor, ME","Austin, TX","Baltimore, MD","Bangor, ME","Baton Rouge, LA","Battle Creek, MI","Baudette, MN","Beaufort-Morehead, NC","Beecher Falls, VT","Bellingham, WA","Binghamton Regional Airport, NY","Birmingham, AL","Blaine, WA","Blue Grass Airport, KY","Boise, ID","Bozeman Yellowstone, MT","Bridgewater, ME","Brownsville, TX","Brunswick, GA","Buffalo, NY","Calais, ME","Calexico, CA","Carbury, ND","Centennial Airport, Englewood, CO","Champlain, NY","Charleston, SC","Charlotte Amalie, USVI","Charlotte, NC","Chattanooga, TN","Chester PA/Wilmington, DE","Chicago, IL","Cincinnati, OH-Lawrenceburg, IN","Cleveland, OH","Saipan, CNMI","Cobb County Airport, GA","Columbia, SC","Columbus, NM","Columbus, OH","Corpus Christi, TX","Cristiansted, VI","Dallas/Fort Worth, TX","Dalton Cache, AK","Danville, WA","Dayton, OH","Daytona Beach, FL","Del Bonita, MT","Del Rio, TX","Denver, CO","Derby Line, VT","Detroit, MI","Detroit (Airport), MI","Douglas, AZ","Dulles Airport, VA","Duluth, MN","Dunseith, ND","Durham, NC","Eagle County, CO","Eagle Pass, TX","Eastport, ID","Eastport, ME","El Paso, TX","Erie, PA","Eureka, CA","Fairbanks, AK","Fajardo Culebra, PR","Fajardo Vieques, PR","Fargo, ND","Fernandina, FL","Fort Fairfield, ME","Fort Kent, ME","Fort Lauderdale, FL","Fort Myers, FL","Fortuna, ND","Freeport, TX","Fresno, CA","Friday Harbor, WA","Frontier, WA","Galveston, TX","Gramercy, LA","Grand Forks, ND","Grand Portage, MN","Grand Rapids, MI","Grant County, WA","Great Falls, MT","Green Bay, WI","Greenville-Spartanburg, SC","Griffiss, NY","Guam, GU","Gulfport, MS","Hannah, ND","Hansboro, ND","Harrisburg, PA","Hartford, CT","Helena, MT","Hidalgo/Pharr, TX","Highgate Springs, VT","Hillsboro, OR","Honolulu, HI","Houlton, ME","Houston (Airport), TX","Houston (Seaport), TX","Huntsville, AL","Indianapolis, IN","International Falls-Rainer, MN","Jackman-Cobum Gore, ME","Jackman-Jackman, ME","Jacksonville, FL","Jefferson City, CO","JFK, NY","Juneau, AK","Kahului, HI","Kalispell, MT","Kansas City, MO","Ketchikan, AK","Key West, FL","Knoxville, TN","Kona-Hilo-Hilo, HI","Kona-Hilo-Kailua Kona, HI","Long Beach, CA","Lake Charles, LA","Lancaster, MN","Laredo, TX","Las Vegas, NV","Laurier, WA","LAX, CA","Leesburg, FL","Lehigh Valley, PA","Little Rock, AR","Logan, MA","Longview, WA","Louisville, KY","Lukeville, AZ","Lynden, WA","Madawaska, ME","Maguire, NJ","Maida, ND","Manatee, FL","Manchester User Fee, NH","Marathon, FL","Massena, NY","Melbourne, FL","Memphis, TN","Metaline Falls, WA","Miami Seaport, FL","Miami Airport, FL","Mid America, IL","Midland, TX","Milwaukee, WI","Minneapolis, MN","Minot, ND","Mobile, AL","Morgan City, LA","Morgan, MT","Naco, AZ","Naples, FL","Nashville, TN","Neche, ND","New Bedford, MA","New Haven, CT","New Orleans, LA","Newark, NJ","Newport, OR","Nogales, AZ","Noonan, ND","Norfolk, VA","Northgate, ND","Norton, VT","Ogdensburg, NY","Oklahoma City, OK","Omaha, NE","Ontario, CA","Opheim, MT","Orlando Executive, FL","Orlando, FL","Oroville, WA","Otay Mesa, CA","Panama City, FL","Pascagoula, MS","Pembina, ND","Pensacola, FL","Philadelphia, PA","Phoenix, AZ","Piegan, MT","Pinecreek, MN","Pittsburgh, PA","Plattsburg, NY","Point Roberts, WA","Port Angeles, WA","Port Arthur/Beaumont, TX","Port Canaveral, FL","Port Everglades, FL","Port Hueneme, CA","Port Huron, MI","Port Townsend, WA","Portal, ND","Porthill, ID","Portland, ME","Portland, OR","Portsmouth, NH","Presidio, TX","Progreso, TX","Providence, RI","Raymond, MT","Reno, NV","Richford, VT","Richmond-Petersburg, VA","Rio Grande City, TX","Rochester, NY","Roma, TX","Roosville, MT","Roseau, MN","Sacramento, CA","Saginaw-Bay City-Flint, MI","Salt Lake City, UT","San Antonio, TX","San Diego, CA","San Francisco, CA","San Juan, PR","San Luis, AZ","San Ysidro, CA","Sanford, FL","Santa Teresa, NM","Sarasota-Bradenton, FL","Sarles, ND","Sasabe, AZ","Sault Sainte Marie, MI","Savannah, GA","Scobey, MT","Seattle, WA","Sherwood, ND","Shreveport, LA","Sioux Falls, SD","Skagway, AK","South Bend, IN","Spokane, WA","St. Augustine, FL","St. John, ND","St. Louis, MO","St. Petersburg, FL","Sumas, WA","Sweetgrass, MT","Syracuse, NY","Tampa, FL","Tecate, CA","Toledo-Sandusky, OH","Tornillo-Guadalupe, TX","Trenton-Merced, NJ","Tri Cities, TN","Trout River-Chateau-Covington, NY","Tucson, AZ","Tulsa, OK","Turner, MT","Van Buren, ME","Vanceboro, ME","Vicksburg, MS","Walhalla, ND","Warroad, MN","West Palm Beach, FL","Westhope, ND","Whitlash, MT","Wichita, KS","Wild Horse, MT","Wilkes Barre-Scranton, PA","Williston, PA","Willow Creek, MT","Wilmington, NC","Winston-Salem, NC","Worchester, MA"]

enum PortType {
    case current
    case desired
}

var selectedType : PortType = .current

class multiSelectionPopUpVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var portTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if selectedType == .current {
            portTitle.text = "Select Current Port"
        }
        
        else{
            portTitle.text = "Select Desired Port"
            for _ in currentPort {
                    selectedPorts.append(0)
                }
            
            if selectedPortIndex.count > 0 {
                for index in selectedPortIndex {
                        selectedPorts[index] = 0
                }
            }
        }
        
        listTableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var listTableView: UITableView!
    
    
    @IBAction func selectPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: .updateDesiredPorts, object: self)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if portType == "current" {
            currentPortIndex = indexPath.row
            selectedCurrentPort = currentPort[indexPath.row]
            listTableView.reloadData()
            return
        }
        
        if selectedPorts.count > 0 {
            
        }
            
            //desired port
            
            if selectedMultiPortIndexes.count == 0 {
                selectedMultiPortIndexes.append(indexPath.row)
                listTableView.reloadData()
                return
            }
            else {
                
                for index in 0..<selectedMultiPortIndexes.count {
                    print(index)
                    
                    if selectedMultiPortIndexes[index] == indexPath.row {
                        selectedMultiPortIndexes.remove(at: index)
                        listTableView.reloadData()
                        return
                    }
                }
                selectedMultiPortIndexes.append(indexPath.row)
                 print(selectedMultiPortIndexes)
            }
       
        
            listTableView.reloadData()
            
            
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPort.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell : UITableViewCell = listTableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        cell.accessoryType = .none
        
        if selectedType == .current {
            cell.textLabel?.text = currentPort[indexPath.row]
            if currentPortIndex != -1 {
                if indexPath.row == currentPortIndex {
                    cell.accessoryType = .checkmark
                }
                else {
                    cell.accessoryType = .none
                }
            }
        }
        else {
            cell.textLabel?.text = currentPort[indexPath.row]
            var isChecked = false
            
            for index in selectedMultiPortIndexes {
                if index == indexPath.row {
                    isChecked = true
                }
            }
            
                if isChecked {
                        cell.accessoryType = .checkmark
                }
                else {
                    cell.accessoryType = .none
            }
        }
        
        return cell
    }
    

}
