//
//  Strings.swift
//  basic iptv
//
//  Created by Nevzat BOZKURT on 8.10.2022.
//

extension String {
    /// Başlangıç ve bitiş arasındaki metni döner. Birden fazla aynı değer varsa index değeri ile istenen string  elde edilebilir.
    func findBetween(start:String, end:String, index: Int = 1) -> String? {
        
        if (!self.contains(start) || !self.contains(end)) {
            return nil
        }
        
        //ios 16 ve sonrası..
        //let startSplit = self.split(separator: start)
        //let endSplit = startSplit[index].split(separator: end)
        let startSplit = self.components(separatedBy: start)
        let endSplit = startSplit[index].components(separatedBy: end)
     
        return String(endSplit[0])
    }
    
    /// metnin içinde kaç tane geçiyor onu döner.
    /// Ör: let a = "Ali ata bak.".countInstances("a")
    func countInstances(string: String) -> Int {
        return self.components(separatedBy:string).count - 1
    }
}


