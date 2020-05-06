
import Foundation
import CryptoKit

let algo = "AWS4-HMAC-SHA256"

public class AWS {

  var regionName = "us-east-1"
  var serviceName = "s3"
  var secretKey = "secretkey"
  var accessKey = "missing"

  convenience public init() {
    self.init(profile: "default")
  }

  public init(profile: String) {
    (accessKey, secretKey, regionName) = getCred(profile)
  }

  func readOpts(fromFile:String) -> [String:[String:String]] {
    let fileContent = try! String(contentsOfFile: fromFile, encoding: String.Encoding.utf8)
    var dict = [String:[String:String]]()
    let lines = fileContent.split(separator: "\n").map( {String($0).trimmingCharacters(in: .whitespaces) } )
    var thisProfile = ""
    var pDict = [String:String]()
    for line in lines {
      if (line.hasPrefix("[") && line.hasSuffix("]")) {
        dict[thisProfile]=pDict
        thisProfile = String(line[line.index(line.startIndex, offsetBy: 1)..<line.index(line.endIndex, offsetBy: -1)])
        pDict = [:]
      } else {
        let components = line.split(separator: "=", maxSplits: 1)
        if (components.count == 2) {
          pDict[String(components[0]).trimmingCharacters(in: .whitespaces)] = String(components[1]).trimmingCharacters(in: .whitespaces)
        }
      }
    }
    dict[thisProfile] = pDict
    return dict
  }

  func getCred(_ profile: String) -> (String, String, String) {
    let a = readOpts(fromFile: "\(NSHomeDirectory())/.aws/credentials")
    let b = readOpts(fromFile: "\(NSHomeDirectory())/.aws/config")
    let aa = a[profile] ?? a["default"] ?? [:]
    let bb = b["profile "+profile] ?? b["default"] ?? [:]
    return (aa["aws_access_key_id"] ?? "missing", aa["aws_secret_access_key"] ?? "missing", bb["region"] ?? "missing")
  }

  /*
   Given the bits that go into an AWS request, generate the signed request as a ByteString
   The arguments are:
   1) the request method (e.g. "GET")
   2) the request URL (e.g. "/" )
   3) the request query string
   4) the request headers (not including the headers added by the signature process)
   5) the request post ?
   6) the Timestamp (UTCTIME)
   7) the AWS Secret
   8) the AWS region
   9) the AWS service
   10) the AWS id
   */

}

func canonicalUrl(_ x:String) -> String {
  let d = x.split(separator: "/", maxSplits: .max, omittingEmptySubsequences: false)
  let n2 = d.count
  var c = [String]()
  for i in 0..<n2 {
    let di = String(d[i])
    if (i == 0) { c.append(di) }
    else if (i == n2-1) { c.append(di) }
    else if (!(di=="." || di.isEmpty)) { c.append(di) }
    else {}
  }
  for i in 1..<c.count {
    if (c[i]=="..") {
      c.remove(at: (i-1))
      c.remove(at: (i-1))
      break
    }
  }
  let z = c.joined(separator: "/")
  let zz = z.isEmpty ? "/" : z
  return c.count == n2 ? zz : canonicalUrl(zz)
}

func urlEncode(_ x:String) -> String {
  var cs = CharacterSet.urlQueryAllowed
  let y = x.replacingOccurrences(of: "+", with: " ")
  cs.remove(charactersIn: "+/,?;:@$%")
  return y.addingPercentEncoding(withAllowedCharacters: cs)!
}

func canonicalQuery(_ x:String) -> String {
  let d = x.split(separator: "&")
  let e = d.map { (z) -> [Substring] in  let a = z.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false); return a.count == 2 ? a : a + [""]  }
  let ee = e.sorted(by: { (a, b) -> Bool in String(a[0]) == String(b[0]) ? String(a[1]) < String(b[1]) : String(a[0])<String(b[0]) } )
  let ee2 = ee.map { "\(urlEncode( String($0[0])))=\(urlEncode( String($0[1])))" }
  return ee2.joined(separator: "&")
}

func awsSignature(_ a: ParsedRequest, secret: String, region: String, servic: String, ak: String) -> ([HTTPHeader], String) {
  let dd = String(timestamp(a.date).prefix(8))
  let kDate = hmac(string: dd, key: "AWS4\(secret)".data(using: .utf8)! )
  let kRegion = hmac(string: region, key: kDate)
  let kService = hmac(string: servic, key: kRegion)
  let dsk = hmac(string: "aws4_request", key: kService)
  let (ssh, hh, sst) = signatureString( a, region: region, servic: servic)
  let ish = ssh.joined(separator: ";")
  let bst = hexdigest (hmac (string: sst, key: dsk))
  return (hh, "\(algo) Credential=\(ak)/\(dd)/\(region)/\(servic)/aws4_request, SignedHeaders=\(ish), Signature=\(bst)" )
}

private func timestamp(_ date: Date) -> String {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
  formatter.timeZone = TimeZone(identifier: "UTC")
  formatter.locale = Locale(identifier: "en_US_POSIX")
  return formatter.string(from: date as Date)
}

/*func dateHeader(_ date: Date) -> String {
  let formatter = DateFormatter()
  formatter.dateFormat = "EEE, MMM yyyy HH:mm:ss Z" //  "yyyyMMdd'T'HHmmss'Z'"
  formatter.timeZone = TimeZone(identifier: "UTC")
  formatter.locale = Locale(identifier: "en_US_POSIX")
  return formatter.string(from: date)
}*/

func signatureString(_ a : ParsedRequest, region: String, servic: String) -> ([String], [HTTPHeader], String) {
  let (hsx, hh, cr) = canonicalRequest( a )
  let reqDate = timestamp(a.date)
  let credScope = "\(reqDate[reqDate.startIndex..<reqDate.index(reqDate.startIndex, offsetBy: 8)])/\(region)/\(servic)/aws4_request"
  let hcr = hexdigest (sha256 (cr.data(using:.utf8)!))
  return (hsx, hh, [algo, reqDate, credScope, hcr ].joined(separator: "\n") )
}

func hexdigest(_ data: Data) -> String {
  var hex = String()
  data.withUnsafeBytes() { (k: UnsafeRawBufferPointer) -> () in
    let j = k.baseAddress!.bindMemory(to: Int8.self, capacity: data.count)
    for i in 0 ..< data.count {
      hex.append(String(format: "%02hhx", j[i] as Int8))
    }
  }
  return hex
}

func canonicalRequest(_ a : ParsedRequest) -> ( [String], [HTTPHeader], String) {
  let (requestMethod, url, queryString, _, resourcePath, dt) = a
  var hds = a.headers
  let uri = canonicalUrl(url)
  let nl = "\n" // "\r\n"

  let hp = hexdigest (sha256 (resourcePath) )
  hds.append(HTTPHeader(key: "x-amz-content-sha256", value:hp))
  hds.append(HTTPHeader(key: "x-amz-date", value: timestamp(dt)))

  let cmpf = { (l: (String, String), r: (String, String) ) -> Bool in let (l1,l2) = l; let (r1, r2) = r; return l1 == r1 ? l2 < r2 : l1 < r1 }

  var hd = [String:[String]]()
  for l in hds {
    var a = hd[l.key] ?? []
    a.append(l.value)
    hd[l.key]=a
  }

  var shd = [(String, String)]()
  for (k,v) in hd {
    let vx = v.sorted().joined(separator:",")
    shd.append( (k, vx) )
  }

  shd = shd.sorted(by: cmpf) // remove duplicates
  let sdx : [String] = shd.map { let (a,_) = $0; return a }
  let h2 : [String] = shd.map { let (x,y) = $0; return "\(x.lowercased()):\(y)" }
  let hdrs = h2.joined(separator: nl).appending("\n")
  let shdrs = shd.map { let (x,_) = $0; return x } .joined(separator: ";")
  return (sdx, hds, [requestMethod, uri, canonicalQuery(queryString), hdrs, shdrs, hp].joined(separator: nl) )
}

func hmac(string: String, key: Data) -> Data {
  let c = HMAC<SHA256>.authenticationCode(for: string.data(using: .utf8)!, using: SymmetricKey(data: key))
  return c.withUnsafeBytes { Data(bytes: $0.baseAddress!, count: c.byteCount) }
}

func md5(_ d : Data) -> Data {
  let m5 = Insecure.MD5.hash(data: d)
  return m5.withUnsafeBytes { z in Data.init(bytes: z.baseAddress!, count: Insecure.MD5Digest.byteCount) }
}

func sha256(_ data: Data) -> Data {
  let z = SHA256.hash(data: data)
  return z.withUnsafeBytes { Data(bytes: $0.baseAddress!, count: SHA256.byteCount) }
}

var counts = [0,0]
func der(_ a:String) -> String {
  return a.replacingOccurrences(of: "\r\n", with: "\n")
}

// =====================================================================================
// Testing code
func assertEqualG<T>(_ str: String,_ a: T, _ b: T) -> Void where T: Equatable {
  let t = a == b
  if (t) {
    counts[0]+=1
    print("passing ",str)
  } else {
    counts[1]+=1
    print("failing \(str) (\n\(a) /= \n\(b)) ")
  }
}

func printCounts() {
  print("Passed:",counts[0],", Failed:",counts[1])
  counts = [0,0]
}

class HTTPHeader {
  let originalKey : String
  let key : String
  let value : String

  init( key : String, value : String) {
    self.key = key.lowercased()
    self.value = value.trimmingCharacters(in: .whitespaces)
    self.originalKey = key
  }
}

typealias ParsedRequest = (requestMethod: String, url: String, queryString: String, headers: [HTTPHeader], body: Data, date: Date)

func parseRequest(req: String) -> ParsedRequest {
  var hds = req.components(separatedBy: "\r\n")
  let g1 = hds.removeFirst()
  let z1 = g1.components(separatedBy: " ")
  let rt = z1[0], url = z1[1]

  let urqs = url.split(separator: "?", maxSplits: 1)
  let ur = String(urqs[0])
  let qsx =  urqs.count == 1 ?  ""  : String(urqs[1])

  let hd21 = hds.split(separator: "", maxSplits: 1)
  let hd1 = hd21[0]
  let rpx = hd21.count > 1 ? hd21[1] : []
  let rp = rpx.joined(separator: "\r\n")
  // print("resource path",rp)
  var headers = [HTTPHeader]()
  var dtx : Date?

  for h in hd1 {
    let ab = h.split(separator: ":", maxSplits: 1)
    let th = HTTPHeader( key: String(ab[0]), value: String(ab[1] ))
    headers.append(th)
    if (th.key == "date") {
      let dt = th.value
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
      dtx = dateFormatter.date(from: dt)
    }
  }
  return (rt, ur, qsx, headers, rp.data(using: .utf8)!, dtx!)
}

let aws_test_id = "AKIDEXAMPLE"
let aws_test_secret = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"

func scavenge_tests() -> [String] {
  let td = "test/aws4_testsuite"
  var dc : [String]
  do {
    dc = try FileManager.default.contentsOfDirectory(atPath: td)
  } catch {
    let nsError = error as NSError
    print(nsError.localizedDescription)
    return []
  }
  let f = { (x:String) -> Bool in
    if (x.hasPrefix(".")) { return false }
    if (URL(string: x)!.pathExtension == "req") { return true }
    return false
  }
  let g = { return URL(string: $0)!.deletingPathExtension() }
  return dc.filter(f).map( { "\(td)/\(g($0))" } )
}

func testTask(_  label: String, _ nam:String, _ ext:String, _ fn: (ParsedRequest)->String ) {
  do {
    let a = try String(contentsOfFile: URL(string: nam)!.appendingPathExtension("req" ).path, encoding: String.Encoding.utf8 )
    let b = try String(contentsOfFile: URL(string: nam)!.appendingPathExtension(ext).path, encoding: String.Encoding.utf8)
    let j = parseRequest(req: a )
    let c = fn(j)
    assertEqualG("\(nam) \(label)", der(b),  der(c))
  } catch {
    print("unable to read \(nam) for \(label)")
  }
}

func testTask1(_ nam:String) {
  testTask("task 1", nam, "creq", { canonicalRequest($0).2 }  )
}

func testTask2(_ nam:String) {
  testTask("task 2", nam, "sts", { signatureString($0, region: "us-east-1", servic: "host").2 })
}

func testTask3(_ nam: String) {
  testTask("task 3", nam, "authz", { awsSignature($0, secret: aws_test_secret, region: "us-east-1", servic: "host", ak: aws_test_id).1 })
}
