struct ImageRequest : Encodable
{
    let user_id: Int
    let role_id: Int
    let type: Int
    let filetoupload:String
   
}

struct ImageResponse: Codable {
    let status: Int
    let response, imagename, type: String
    let imageurl: String
}
struct Endpoints
{
    static let uploadImageMultiPartForm = "https://doctorsapp.in/uat/doctorsapp/public/v1/appService/certificate-upload"
}
struct ImageManager
{
    func uploadImage(data: Data, completionHandler: @escaping(_ result: ImageResponse) -> Void)
    {
        let httpUtility = HttpUtility()
        
        let imageUploadRequest = ImageRequest(user_id: 10,  role_id: 2, type: 1,filetoupload: data.base64EncodedString())
        print("-----------\(imageUploadRequest)-------")
        httpUtility.postApiDataWithMultipartForm(requestUrl: URL(string: Endpoints.uploadImageMultiPartForm)!, request: imageUploadRequest, resultType: ImageResponse.self) {
            (response) in
            
            _ = completionHandler(response)
            
        }
    }
}
struct HttpUtility
{
func postApiDataWithMultipartForm<T:Decodable>(requestUrl: URL, request: ImageRequest, resultType: T.Type, completionHandler:@escaping(_ result: T)-> Void)
    {
        var urlRequest = URLRequest(url: requestUrl)
        let lineBreak = "\r\n"

        urlRequest.httpMethod = "POST"
        let boundary = "---------------------------------\(UUID().uuidString)"
        urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "content-type")

        var requestData = Data()
//user_id
        requestData.append("--\(boundary)\r\n" .data(using: .utf8)!)
        requestData.append("content-disposition: form-data; name=\"user_id\" \(lineBreak + lineBreak)" .data(using: .utf8)!)
        requestData.append("\(request.user_id)" .data(using: .utf8)!)
//role_id
        
        requestData.append("\(lineBreak)--\(boundary)\r\n" .data(using: .utf8)!)
        requestData.append("content-disposition: form-data; name=\"role_id\" \(lineBreak + lineBreak)" .data(using: .utf8)!)
        requestData.append("\(request.role_id)" .data(using: .utf8)!)
//type
        
        requestData.append("\(lineBreak)--\(boundary)\r\n" .data(using: .utf8)!)
        requestData.append("content-disposition: form-data; name=\"type\" \(lineBreak + lineBreak)" .data(using: .utf8)!)
        requestData.append("\(request.type)" .data(using: .utf8)!)
   
//filetoupload
        requestData.append("\(lineBreak)--\(boundary)\r\n" .data(using: .utf8)!)
        requestData.append("content-disposition: form-data; name=\"filetoupload\" \(lineBreak + lineBreak)" .data(using: .utf8)!)
        requestData.append(request.filetoupload .data(using: .utf8)!)
        
        requestData.append("--\(boundary)--\(lineBreak)" .data(using: .utf8)!)

        urlRequest.addValue("\(requestData.count)", forHTTPHeaderField: "content-length")
        urlRequest.httpBody = requestData

//        let multipartStr = String(decoding: requestData, as: UTF8.self) //to view the multipart form string
        URLSession.shared.dataTask(with: urlRequest) { (data, httpUrlResponse, error) in
            if(error == nil )
            {
//             let dataStr = String(decoding: requestData, as: UTF8.self) //to view the data you receive from the API
                do {
                    let response = try JSONDecoder().decode(T.self, from: data!)
                    _=completionHandler(response)
                }
                catch let decodingError {
                    debugPrint(decodingError)
                }
            }
            else if (error != nil){
                print("the error is \(error)")
            }

        }.resume()

    }
}
