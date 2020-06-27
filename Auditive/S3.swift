
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Foundation
import CryptoKit

enum S3Error : Error {
  case s3ListError
  case noRequest
}

fileprivate class S3Key {
  static var keyCount = "KeyCount"
  static var contents = "Contents"
  static var lastModified = "LastModified"
  static var eTag = "ETag"
  static var storageClass = "StorageClass"
  static var size = "Size"
  static var key = "Key"
  static var listBucketResult = "ListBucketResult"
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
       z.name == S3Key.listBucketResult {
      let x = z.childElements
      let keyCount = Int(x.first(where: {$0.name == S3Key.keyCount })?.text ?? "-1")
      let contents = x.filter { $0.name == S3Key.contents }
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
      case S3Key.key: key = x.text!
      case S3Key.lastModified:
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        lastModified = dateFormatter.date(from: x.text!)!
      case S3Key.eTag: eTag = x.text!
      case S3Key.size: size = Int(x.text!) ?? -1
      case S3Key.storageClass: storageClass = x.text!
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

public class S3 : AWSService {
  let bucket : String?

  public init?(bucket b : String) {
    bucket = b
    super.init(service: "s3", profile: "ONE")
  }

  public struct ETag {
    init(element: Element) {
      // print("element should be empty")
    }
  }

  public func putObject(_ n : String, _ d : Data, tags : [String : String] = [:], metadata : [String : String] = [:]) throws -> ETag {
    let sem = DispatchSemaphore(value: 0)
    var res : ETag?
    var error : Error?
    let url = "/\(n)"

    let session = URLSession.shared

    let b = md5(d)
    let h = HTTPHeader(key: "content-md5", value: b.base64EncodedString())
    let h2 = HTTPHeader(key: "x-amz-tagging", value: (tags.map { (k, v) in "\(k)=\(v)" }).joined(separator: "&"))

    let md = metadata.map { (k,v) in HTTPHeader(key: "x-amz-meta-\(k)", value: v) }

    let pr = ParsedRequest(requestMethod: "PUT", url: url, queryString: "", headers: [h, h2]+md, body: d, date: Date() )
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

  public func bucketList() throws -> [Bucket]  {
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

  func makeRequest(_ pr: ParsedRequest) -> URLRequest? {
    var host : String = "s3.amazonaws.com"
    if let b = bucket {
      host = "\(b).s3.amazonaws.com"
    }

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


    let (hh, s) = awsSignature(mpr, servic: "s3")
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


}
