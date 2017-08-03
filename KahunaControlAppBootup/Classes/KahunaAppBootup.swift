//
//	KahunaAppBootup.swift
//
//	Create by Kahuna on 1/8/2017
//	Copyright © 2017. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

public class KahunaAppBootup: NSObject {

    public var action: String!
    public var message: String!
    public var title: String!
    public var status: KahunaStatus!

    /**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
    init(fromDictionary dictionary: NSDictionary) {
        action = dictionary["action"] as? String
        message = dictionary["message"] as? String
        title = dictionary["title"] as? String
        if let statusData = dictionary["status"] as? [String: Any] {
            status = KahunaStatus(fromDictionary: statusData)
        }
    }

}
