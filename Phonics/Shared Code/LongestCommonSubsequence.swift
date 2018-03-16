
// plucked from stack oveflow somewhere -- least common substring
func lComSubStr(_ w1: String, _ w2: String) -> String {
    
    if w1.length == 0 || w2.length == 0 {
        return ""
    }
    
    var (len, end) = (0, 0)
    
    let empty = Array(repeating: 0, count: w2.length + 1)
    var mat: [[Int]] = Array(repeating: empty, count: w1.length + 1)
    
    for (i, sLett) in w1.map({ String($0) }).enumerated() {
        for (j, tLett) in w2.map({ String($0) }).enumerated() where tLett == sLett {
            let curLen = mat[i][j] + 1
            mat[i + 1][j + 1] = curLen
            if curLen > len {
                len = curLen
                end = i
            }
        }
    }
    
    let start = w1.index(w1.startIndex, offsetBy: (end + 1) - len)
    let endInd = w1.index(w1.startIndex, offsetBy: end)
    
    if start > endInd {
        return ""
    }
    
    return String(w1[w1.index(w1.startIndex, offsetBy: (end + 1) - len) ... w1.index(w1.startIndex, offsetBy: end)])
    //return w1[advance(w1.startIndex, (end + 1) - len)...advance(w1.startIndex, end)]
}
