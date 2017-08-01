//
//	KahunaStatu.swift
//
//	Create by Kahuna on 1/8/2017
//	Copyright © 2017. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

public class KahunaStatus: NSObject {

    public var cause: String!
    public var code: Int!
    public var message: String!

    /**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
    init(fromDictionary dictionary: [String: Any]) {
        cause = dictionary["cause"] as? String
        code = dictionary["code"] as? Int
        message = dictionary["message"] as? String
    }

}
