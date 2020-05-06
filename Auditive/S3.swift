
import Foundation
import CryptoKit


class Element : CustomStringConvertible {
  let name: String
  open var text: String?
  open var attributes = [String: String]()
  open var childElements = [Element]()

  // for println
  open weak var parentElement: Element?

  public init(name: String) {
    self.name = name
  }

  public var description : String {
    var str = "<\(name)"
    for (k,v) in attributes {
      str.append(" \(k)=\"\(v)\"")
    }
    str.append(">")
    if text != nil { str.append(text!) }
    for z in childElements {
      str.append(z.description)
    }
    str.append("</\(name)>\n")
    return str
  }
}

struct Leaf {
  let label : String
  let value : String
}


class PD: NSObject, XMLParserDelegate {

  func parse(_ data: Data) -> Element {
    stack = [Element]()
    stack.append(documentRoot)
    let parser = XMLParser(data: data)
    parser.delegate = self
    parser.parse()
    return documentRoot
  }

  override init() {
    trimmingManner = nil
  }

  init(trimming manner: CharacterSet) {
    trimmingManner = manner
  }

  // MARK:- private
  fileprivate var documentRoot = Element(name: "root")
  fileprivate var stack = [Element]()
  fileprivate let trimmingManner: CharacterSet?

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    let node = Element(name: elementName)
    if !attributeDict.isEmpty {
      node.attributes = attributeDict
    }

    let parentNode = stack.last

    node.parentElement = parentNode
    parentNode?.childElements.append(node)
    stack.append(node)
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    if let text = stack.last?.text {
      stack.last?.text = text + string
    } else {
      stack.last?.text = "" + string
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if let trimmingManner = self.trimmingManner {
      stack.last?.text = stack.last?.text?.trimmingCharacters(in: trimmingManner)
    }
    stack.removeLast()
  }
}

enum S3Error : Error {
  case s3ListError
}
public struct Bucket : CustomStringConvertible {
  let name : String
  let created : Date

  init(element : Element) {
    name = element.childElements[0].text!

    let dateFormatter = DateFormatter()

    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

    created = dateFormatter.date(from: element.childElements[1].text!)!
  }

  public var description : String {
    return "\(name) (\(created))"
  }

  static func objectList(element: Element) throws -> [S3Object] {
    if let z = element.childElements.first,
      z.name == "ListBucketResult" {
      let x = z.childElements
      /*
      let name = x.first(where: {$0.name == "Name"})?.text
      let prefix = x.first(where: {$0.name == "Prefix"})?.text
      let isTruncated = x.first(where: {$0.name == "isTruncated"})?.text == "true"
      */
      let keyCount = Int(x.first(where: {$0.name == "KeyCount"})?.text ?? "-1")
      let contents = x.filter { $0.name == "Contents" }
      if (contents.count != keyCount) {
        print("wrong number of contents")
      }
      return contents.map { S3Object(element: $0) }
    }
    throw S3Error.s3ListError
  }
}

public struct S3Object {
  var key : String?
  var lastModified : Date?
  var eTag : String?
  var size : Int?
  var storageClass : String?

  init(element : Element) {
    for x in element.childElements {
      switch x.name {
      case "Key": key = x.text!
      case "LastModified":
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        lastModified = dateFormatter.date(from: x.text!)!
      case "ETag": eTag = x.text!
      case "Size": size = Int(x.text!) ?? -1
      case "StorageClass": storageClass = x.text!
      default:
        break
      }
    }

  }
}

public struct BucketList : CustomStringConvertible {
  let owner : (String, String)
  let buckets : [Bucket]

  init(element: Element) {
    let o = element.childElements[0].childElements[0]
    owner = (o.childElements[0].text!, o.childElements[1].text!)
    var bs = [Bucket]()
    for z in element.childElements[0].childElements[1].childElements {
      bs.append(Bucket(element: z))
    }
    buckets = bs
  }

  public var description : String {
    let (i,o) = owner
    var str = "Owner: \(o) (\(i))"
    for z in buckets {
      str.append("\n\(z)")
    }
    return str
  }
}

public class S3 {
  // let aws : AWS?
  let bucket : String
  static var aws = AWS()

  public init(bucket b : String) {
    bucket = b
  }

  func makeRequest(_ pr: ParsedRequest) -> URLRequest {
    let host = "\(bucket).s3.amazonaws.com"
    var request = URLRequest(url: URL(string: "https://\(host)"+pr.url + "?" + pr.queryString)! )
    request.httpMethod = pr.requestMethod
    var mpr = pr
    mpr.headers.append(HTTPHeader(key:"Host",value: host))

    let (hh, s) = awsSignature(mpr, secret: Self.aws.secretKey, region: Self.aws.regionName, servic: "s3", ak: Self.aws.accessKey)
    request.addValue( s, forHTTPHeaderField: "Authorization" )

    for h in hh {
      request.addValue( h.value, forHTTPHeaderField: h.key)
    }
    return request
  }

  class func makeRequest(_ pr: ParsedRequest) -> URLRequest {
    let host = "s3.amazonaws.com"
    var request = URLRequest(url: URL(string: "https://\(host)"+pr.url)! )
    var mpr = pr
    mpr.headers.append(HTTPHeader(key:"Host",value: host))

    let (hh, s) = awsSignature(mpr, secret: aws.secretKey, region: aws.regionName, servic: "s3", ak: aws.accessKey)
    request.addValue( s, forHTTPHeaderField: "Authorization" )

    for h in hh {
      request.addValue( h.value, forHTTPHeaderField: h.key)
    }
    return request
  }

  public struct ETag {
    init(element: Element) {
      // print("element should be empty")
    }
  }

  public func putObject(_ n : String, _ d : Data) throws -> ETag {
    let sem = DispatchSemaphore(value: 0)
    var res : ETag?
    var error : Error?
    let url = "/\(n)"

    let session = URLSession.shared

    let b = md5(d)
    let h = HTTPHeader(key: "content-md5", value: b.base64EncodedString())
    
    let pr = ParsedRequest(requestMethod: "PUT", url: url, queryString: "", headers: [h], body: d, date: Date() )
    let r = makeRequest(pr)
    let task = session.uploadTask(with: r, from: d, completionHandler: { data, response, err in
      guard err == nil else {
        print(err!); error = err; return }
      guard let data = data else { return }
      // print(String(data: data, encoding: String.Encoding.utf8))
      //  print("")

      /*
       do {
       if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] { print(json) }
       } catch let error {
       print(error.localizedDescription)
       }
       */

      let xml = PD().parse(data)
      res = ETag(element: xml)
      sem.signal()
    })
    task.resume()
    sem.wait()
    if let e = error { throw e }
    return res!


  }

  public func listObjects() throws -> [S3Object] {
    let sem = DispatchSemaphore(value: 0)
    var res : [S3Object] = []
    var error : Error?
    let url = "/"

    let session = URLSession.shared
    let pr = ParsedRequest(requestMethod: "GET", url: url, queryString: "list-type=2", headers: [], body: Data(), date: Date() )
    let r = makeRequest(pr)
    let task = session.dataTask(with: r, completionHandler: { data, response, err in
      guard err == nil else { print(err!); error = err; return }
      guard let data = data else { return }
      // print(String(data: data, encoding: String.Encoding.utf8))
      //  print("")

      /*
       do {
       if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] { print(json) }
       } catch let error {
       print(error.localizedDescription)
       }
       */

      let xml = PD().parse(data)
      do {
        res = try Bucket.objectList(element: xml)
      } catch(let e) {
        error = e
      }
      sem.signal()
    })
    task.resume()
    sem.wait()
    if let e = error { throw e }
    return res

  }

  class public func get() throws -> [Bucket]  {
    let sem = DispatchSemaphore(value: 0)

    var res : [Bucket] = []
    var error : Error?

    let url = "/"
    let session = URLSession.shared
    let pr = ParsedRequest(requestMethod: "GET", url: url, queryString: "", headers: [], body: Data(), date: Date() )
    let r = makeRequest(pr)
    let task = session.dataTask(with: r, completionHandler: { data, response, err in
      guard err == nil else { print(err!); error = err; return }
      guard let data = data else { return }
      // print(String(data: data, encoding: String.Encoding.utf8))
      //  print("")

      /*
       do {
       if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] { print(json) }
       } catch let error {
       print(error.localizedDescription)
       }
       */

      let xml = PD().parse(data)
      res = BucketList(element: xml).buckets
      sem.signal()
    })
    task.resume()
    sem.wait()
    if let e = error { throw e }
    return res

    /*
     objc_sync_enter(lock)
     defer { objc_sync_exit(lock) }
     return try body()
     */
  }
}
