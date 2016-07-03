func lComSubStr(w1: String, _ w2: String) -> String {
    
    var (len, end) = (0, 0)
    
    let empty = Array(Repeat(count: w2.length + 1, repeatedValue: 0))
    var mat: [[Int]] = Array(Repeat(count: w1.length + 1, repeatedValue: empty))
    
    for (i, sLett) in w1.characters.map({ String($0) }).enumerate() {
        for (j, tLett) in w2.characters.map({ String($0) }).enumerate() where tLett == sLett {
            let curLen = mat[i][j] + 1
            mat[i + 1][j + 1] = curLen
            if curLen > len {
                len = curLen
                end = i
            }
        }
    }
    
    let start = w1.startIndex.advancedBy((end + 1) - len)
    let endInd = w1.startIndex.advancedBy(end)
    
    if start > endInd {
        return ""
    }
    
    return w1[w1.startIndex.advancedBy((end + 1) - len)...w1.startIndex.advancedBy(end)]
    //return w1[advance(w1.startIndex, (end + 1) - len)...advance(w1.startIndex, end)]
}