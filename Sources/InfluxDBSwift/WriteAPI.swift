//
// Created by Jakub Bednář on 05/11/2020.
//

#if canImport(Combine)
import Combine
#endif
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Gzip

/// The asynchronous API to Write time-series data into InfluxDB 2.0.
///
/// ### Example: ###
/// ````
/// //
/// // Record defined as String
/// //
/// let recordString = "demo,type=string value=1i"
/// //
/// // Record defined as Data Point
/// //
/// let recordPoint = InfluxDBClient
///         .Point("demo")
///         .addTag(key: "type", value: "point")
///         .addField(key: "value", value: .int(2))
/// //
/// // Record defined as Data Point with Timestamp
/// //
/// let recordPointDate = InfluxDBClient
///         .Point("demo")
///         .addTag(key: "type", value: "point-timestamp")
///         .addField(key: "value", value: .int(2))
///         .time(time: .date(Date()))
/// //
/// // Record defined as Tuple
/// //
/// let recordTuple: InfluxDBClient.Point.Tuple
///     = (measurement: "demo", tags: ["type": "tuple"], fields: ["value": .int(3)], time: nil)
///
/// let records: [Any] = [recordString, recordPoint, recordPointDate, recordTuple]
///
/// client.makeWriteAPI().writeRecords(records: records) { result, error in
///     // For handle error
///     if let error = error {
///         print("Error:\n\n\(error)")
///     }
///
///     // For Success write
///     if result != nil {
///         print("Successfully written data:\n\n\(records)")
///     }
/// }
/// ````
public class WriteAPI {
    /// Shared client.
    private let client: InfluxDBClient
    /// Settings for DataPoint.
    private let pointSettings: InfluxDBClient.PointSettings?

    /// Create a new WriteAPI for a InfluxDB
    ///
    /// - Parameters
    ///   - client: Client with shared configuration and http library.
    ///   - pointSettings: Default settings for DataPoint, useful for default tags.
    init(client: InfluxDBClient, pointSettings: InfluxDBClient.PointSettings? = nil) {
        self.client = client
        self.pointSettings = pointSettings
    }

    /// Write time-series data into InfluxDB.
    ///
    /// - Parameters:
    ///   - record: The record to write.
    ///   - bucket:  The destination bucket for writes. Takes either the `ID` or `Name` interchangeably.
    ///   - org: The destination organization for writes. Takes either the `ID` or `Name` interchangeably.
    ///   - precision: The precision for the unix timestamps within the body line-protocol.
    ///   - responseQueue: The queue on which api response is dispatched.
    ///   - completion: completion handler to receive the data and the error objects
    ///
    /// - SeeAlso: https://docs.influxdata.com/influxdb/v2.0/reference/syntax/line-protocol/
    public func write(record: InfluxDBClient.Point,
                      bucket: String? = nil,
                      org: String? = nil,
                      precision: InfluxDBClient.TimestampPrecision? = nil,
                      responseQueue: DispatchQueue = .main,
                      completion: @escaping (_ response: Void?,
                                             _ error: InfluxDBClient.InfluxDBError?) -> Void) {
        self.write(
            records: [record],
            bucket: bucket,
            org: org,
            precision: precision,
            responseQueue: responseQueue,
            completion: completion)
    }

    /// Write time-series data into InfluxDB.
    ///
    /// - Parameters:
    ///   - records: The records to write.
    ///   - bucket:  The destination bucket for writes. Takes either the `ID` or `Name` interchangeably.
    ///   - org: The destination organization for writes. Takes either the `ID` or `Name` interchangeably.
    ///   - precision: The precision for the unix timestamps within the body line-protocol.
    ///   - responseQueue: The queue on which api response is dispatched.
    ///   - completion: handler to receive the data and the error objects
    ///
    /// - SeeAlso: https://docs.influxdata.com/influxdb/v2.0/reference/syntax/line-protocol/
    public func write(records: [InfluxDBClient.Point],
                      bucket: String? = nil,
                      org: String? = nil,
                      precision: InfluxDBClient.TimestampPrecision? = nil,
                      responseQueue: DispatchQueue = .main,
                      completion: @escaping (_ response: Void?,
                                             _ error: InfluxDBClient.InfluxDBError?) -> Void) {
        postWrite(bucket, org, precision, records, responseQueue) { result in
            switch result {
            case .success:
                completion((), nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }

    #if canImport(Combine)
    /// Write time-series data into InfluxDB.
    ///
    /// - Parameters:
    ///   - record: The record to write.
    ///   - bucket:  The destination bucket for writes. Takes either the `ID` or `Name` interchangeably.
    ///   - org: The destination organization for writes. Takes either the `ID` or `Name` interchangeably.
    ///   - precision: The precision for the unix timestamps within the body line-protocol.
    ///   - responseQueue: The queue on which api response is dispatched.
    /// - Returns: Publisher to attach a subscriber
    ///
    /// - SeeAlso: https://docs.influxdata.com/influxdb/v2.0/reference/syntax/line-protocol/
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func writeRecord(record: InfluxDBClient.Point,
                            bucket: String? = nil,
                            org: String? = nil,
                            precision: InfluxDBClient.TimestampPrecision? = nil,
                            responseQueue: DispatchQueue = .main) -> AnyPublisher<Void, InfluxDBClient.InfluxDBError> {
        self.writeRecords(
            records: [record],
            bucket: bucket,
            org: org,
            precision: precision,
            responseQueue: responseQueue)
    }

    /// Write time-series data into InfluxDB.
    ///
    /// - Parameters:
    ///   - records: The records to write.
    ///   - bucket:  The destination bucket for writes. Takes either the `ID` or `Name` interchangeably.
    ///   - org: The destination organization for writes. Takes either the `ID` or `Name` interchangeably.
    ///   - precision: The precision for the unix timestamps within the body line-protocol.
    ///   - responseQueue: The queue on which api response is dispatched.
    /// - Returns: Publisher to attach a subscriber
    ///
    /// - SeeAlso: https://docs.influxdata.com/influxdb/v2.0/reference/syntax/line-protocol/
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func writeRecords(records: [InfluxDBClient.Point],
                             bucket: String? = nil,
                             org: String? = nil,
                             precision: InfluxDBClient.TimestampPrecision? = nil,
                             responseQueue: DispatchQueue = .main)
            -> AnyPublisher<Void, InfluxDBClient.InfluxDBError> {
        Future<Void, InfluxDBClient.InfluxDBError> { promise in
            self.postWrite(bucket, org, precision, records, responseQueue) { result -> Void in
                switch result {
                case .success:
                    promise(.success(()))
                case let .failure(error):
                    promise(.failure(error))
                }
            }
        }
            .eraseToAnyPublisher()
    }
    #endif

    // swiftlint:disable function_parameter_count
    private func postWrite(_ bucket: String?,
                           _ org: String?,
                           _ precision: InfluxDBClient.TimestampPrecision?,
                           _ records: [InfluxDBClient.Point],
                           _ responseQueue: DispatchQueue,
                           _ completion: @escaping
                           (_ result: Swift.Result<Void, InfluxDBClient.InfluxDBError>) -> Void) {
        var components = URLComponents(string: client.url + "/api/v2/write")

        guard let bucket = bucket ?? client.options.bucket else {
            completion(.failure(.generic("The bucket destination should be specified.")))
            return
        }

        guard let org = org ?? client.options.org else {
            completion(.failure(.generic("The org destination should be specified.")))
            return
        }

        let precision = precision ?? client.options.precision

        // we need sort batches by insertion time (for LP without timestamp)
        let defaultTags = pointSettings?.evaluate()
        do {
            let lines = try toLineProtocol(records: records, precision: precision, defaultTags: defaultTags)
            guard let body = lines
                .joined(separator: "\n")
                .data(using: .utf8)
                else {
                completion(.failure(InfluxDBClient.InfluxDBError.generic("points contain invalid UTF-8")))
                return
            }

            components?.queryItems = [
                URLQueryItem(name: "bucket", value: bucket),
                URLQueryItem(name: "org", value: org),
                URLQueryItem(name: "precision", value: precision.rawValue)
            ]

            client.httpPost(
                components,
                "text/plain; charset=utf-8",
                "application/json",
                InfluxDBClient.GZIPMode.request,
                body,
                responseQueue) { result -> Void in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(.cause(error)))
        }
    }

    private func toLineProtocol(records: [InfluxDBClient.Point],
                                precision: InfluxDBClient.TimestampPrecision,
                                defaultTags: [String: String?]?) throws -> [String] {
        try records.compactMap { point in
            try point.toLineProtocol(precision: precision, defaultTags: defaultTags)
        }
    }

    // swiftlint:enable function_parameter_count
}
