//
// Created by Jakub Bednář on 27/11/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@testable import InfluxDBSwift
import XCTest

final class QueryAPITests: XCTestCase {
    private var client: InfluxDBClient!

    override func setUp() {
        client = InfluxDBClient(
                url: Self.dbURL(),
                token: "my-token",
                options: InfluxDBClient.InfluxDBOptions(bucket: "my-bucket", org: "my-org"),
                protocolClasses: [MockURLProtocol.self])
    }

    override func tearDown() {
        client.close()
    }

    func testGetQueryAPI() {
        XCTAssertNotNil(client.getQueryAPI())
    }

    func testQuery() {
        let expectation = self.expectation(description: "Success response from API doesn't arrive")
        expectation.expectedFulfillmentCount = 2

        let csv = """
                  #datatype,string,long,dateTime:RFC3339,dateTime:RFC3339,string,string,string,string,long,long,string
                  #group,false,false,true,true,true,true,true,true,false,false,false
                  #default,_result,,,,,,,,,,
                  ,result,table,_start,_stop,_field,_measurement,host,region,_value2,value1,value_str
                  ,,0,1677-09-21T00:12:43.145224192Z,2018-07-16T11:21:02.547596934Z,free,mem,A,west,121,11,test

                  """

        MockURLProtocol.handler = { request, bodyData in
            expectation.fulfill()

            let response = HTTPURLResponse(statusCode: 200)
            return (response, csv.data(using: .utf8)!)
        }

        client.getQueryAPI().query(query: "from(bucket:\"my-bucket\") |> range(start: -1h)") { response, error in
            if let error = error {
                XCTFail("Error occurs: \(error)")
            }

            if let response = response {
                guard let collection = try? Array(response) else {
                    XCTFail("Cannot create an Array.")
                    expectation.fulfill()
                    return
                }
                XCTAssertEqual(1, collection.count)
                XCTAssertEqual(121, collection[0].values["_value2"] as? Int64)
                XCTAssertEqual(11, collection[0].values["value1"] as? Int64)
                XCTAssertEqual("test", collection[0].values["value_str"] as? String)
                XCTAssertEqual("A", collection[0].values["host"] as? String)
                XCTAssertEqual("west", collection[0].values["region"] as? String)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testQueryRaw() {
        let expectation = self.expectation(description: "Success response from API doesn't arrive")
        expectation.expectedFulfillmentCount = 2

        let csv = """
                  #datatype,string,long,dateTime:RFC3339,dateTime:RFC3339,string,string,string,string,long,long,string
                  #group,false,false,true,true,true,true,true,true,false,false,false
                  #default,_result,,,,,,,,,,
                  ,result,table,_start,_stop,_field,_measurement,host,region,_value2,value1,value_str
                  ,,0,1677-09-21T00:12:43.145224192Z,2018-07-16T11:21:02.547596934Z,free,mem,A,west,121,11,test

                  """

        let responseBody = csv.data(using: .utf8)!

        MockURLProtocol.handler = { request, bodyData in
            XCTAssertEqual("Token my-token", request.allHTTPHeaderFields!["Authorization"])
            XCTAssertEqual("application/json; charset=utf-8", request.allHTTPHeaderFields!["Content-Type"])
            XCTAssertEqual("163", request.allHTTPHeaderFields!["Content-Length"])
            XCTAssertEqual("identity", request.allHTTPHeaderFields!["Content-Encoding"])
            XCTAssertEqual("identity", request.allHTTPHeaderFields!["Accept-Encoding"])
            XCTAssertEqual("text/csv", request.allHTTPHeaderFields!["Accept"])
            XCTAssertEqual(
                    "\(Self.dbURL())/api/v2/query?org=my-org",
                    request.url?.description)
            let query = try CodableHelper.decode(Query.self, from: bodyData!).get()

            XCTAssertEqual("from(bucket:\"my-bucket\") |> range(start: -1h)", query.query)
            XCTAssertEqual([
                Dialect.Annotations.datatype,
                Dialect.Annotations.group,
                Dialect.Annotations._default
            ], query.dialect?.annotations)

            expectation.fulfill()

            let response = HTTPURLResponse(statusCode: 200)
            return (response, responseBody)
        }

        client.getQueryAPI().queryRaw(query: "from(bucket:\"my-bucket\") |> range(start: -1h)") { response, error in
            if let error = error {
                XCTFail("Error occurs: \(error)")
            }

            if let response = response {
                XCTAssertTrue(response == responseBody)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}
