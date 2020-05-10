
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Foundation
import CryptoKit

enum S3Error : Error {
  case s3ListError
  case noRequest
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

var accessKey : String?
var secretKey: String?
var regionName: String?

public class S3 : AWSService {
  let bucket : String

  var aws : AWS?

  public init(bucket b : String) {
    
    bucket = b
    if let a = accessKey,
    let s = secretKey,
      let r = regionName {
         aws = AWS(accessKey: a, secretKey: s, regionName: r)
    }
  }

  func makeRequest(_ pr: ParsedRequest) -> URLRequest? {
    guard let aw = aws else { return nil }
    let host = "\(bucket).s3.amazonaws.com"

    var mpr = pr
    var cs = CharacterSet.alphanumerics
    cs.insert(charactersIn: "-._~ ")

    mpr.url = "/"+pr.url[pr.url.index(pr.url.startIndex, offsetBy: 1)...].addingPercentEncoding(withAllowedCharacters: cs)!.replacingOccurrences(of: " ", with: "%20")
    mpr.queryString = pr.queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

    let urlstr = "https://\(host.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)" + mpr.url + "?" + mpr.queryString
    if let u = URL(string: urlstr) {
    var request = URLRequest(url: u )
    request.httpMethod = mpr.requestMethod

    mpr.headers.append(HTTPHeader(key:"Host",value: host))


    let (hh, s) = awsSignature(mpr, secret: aw.secretKey, region: aw.regionName, servic: "s3", ak: aw.accessKey)
    request.addValue( s, forHTTPHeaderField: "Authorization" )

    for h in hh {
      request.addValue( h.value, forHTTPHeaderField: h.key)
    }
      return request
    } else {
      print("failed to create URL")
      return nil
    }
  }

  class func makeRequest(_ pr: ParsedRequest) -> URLRequest? {
    guard let a = accessKey,
      let s = secretKey,
      let r = regionName else { return nil }
    let aws = AWS(accessKey: a, secretKey: s, regionName: r)
    let host = "s3.amazonaws.com"
    var request = URLRequest(url: URL(string: "https://\(host)"+pr.url)! )

    var mpr = pr
    mpr.headers.append(HTTPHeader(key:"Host",value: host))

    let (hh, sx) = awsSignature(mpr, secret: aws.secretKey, region: aws.regionName, servic: "s3", ak: aws.accessKey)
    request.addValue( sx, forHTTPHeaderField: "Authorization" )

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
    guard let r = makeRequest(pr) else  { throw S3Error.noRequest }
    let task = session.uploadTask(with: r, from: d, completionHandler: { data, response, err in
      guard err == nil else {
        print(err!); error = err; return }
      guard let data = data else { return }

      // FIXME: I want to get an error here if the file already exists in the bucket (prevents over-write)
      let xml = PD().parse(data)
      print(xml)

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
    guard let r = makeRequest(pr)  else { throw S3Error.noRequest }
    let task = session.dataTask(with: r, completionHandler: { data, response, err in
      guard err == nil else { print(err!); error = err; return }
      guard let data = data else { return }
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
    guard let r = makeRequest(pr) else { throw S3Error.noRequest }
    let task = session.dataTask(with: r, completionHandler: { data, response, err in
      guard err == nil else { print(err!); error = err; return }
      guard let data = data else { return }
      let xml = PD().parse(data)
      res = BucketList(element: xml).buckets
      sem.signal()
    })
    task.resume()
    sem.wait()
    if let e = error { throw e }
    return res
  }
}
