import Foundation

// Estrutura para representar URLs no JSON
struct URLList: Codable {
    let urls: [String]
}


// Estrutura para gerar um relatório JSON
struct URLReport: Codable {
    let url: String
    let statusCode: Int?
    let responseTime: TimeInterval?
    let success: Bool
    
    // Definindo uma ordem de chaves manualmente
    private enum CodingKeys: String, CodingKey {
        case url
        case statusCode
        case responseTime
        case success
    }
}

// Função para carregar URLs a partir de um arquivo JSON
func loadURLs(from filename: String) -> [String]? {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: filename)) else {
        print("Erro ao ler o arquivo \(filename)")
        return nil
    }
    
    let decoder = JSONDecoder()
    let urlList = try? decoder.decode(URLList.self, from: data)
    return urlList?.urls
}

// Função para realizar o acesso às URLs e medir tempo de resposta, com repetição em caso de falha
func fetchURL(_ url: String, retries: Int = 3, completion: @escaping (URLReport) -> Void) {
    guard let url = URL(string: url) else {
        completion(URLReport(url: url, statusCode: nil, responseTime: nil, success: false))
        return
    }

    let startTime = Date()
    let task = URLSession.shared.dataTask(with: url) { _, response, error in
        let endTime = Date()
        let timeInterval = endTime.timeIntervalSince(startTime)

        if let httpResponse = response as? HTTPURLResponse {
            completion(URLReport(url: url.absoluteString, statusCode: httpResponse.statusCode, responseTime: timeInterval, success: true))
        } else if retries > 0 {
            print("Falha ao acessar \(url). Tentando novamente...")
            fetchURL(url.absoluteString, retries: retries - 1, completion: completion)
        } else {
            completion(URLReport(url: url.absoluteString, statusCode: nil, responseTime: timeInterval, success: false))
        }
    }
    task.resume()
}

// Função para processar URLs com um número limitado de conexões simultâneas
func processURLs(from filename: String, maxConcurrentConnections: Int = 5) {
    guard let urls = loadURLs(from: filename) else {
        print("Falha ao carregar URLs.")
        return
    }

    let group = DispatchGroup()
    let semaphore = DispatchSemaphore(value: maxConcurrentConnections)
    var reports: [URLReport] = []

    for url in urls {
        group.enter()
        semaphore.wait()
        
        fetchURL(url) { report in
            reports.append(report)
            semaphore.signal()
            group.leave()
        }
    }

    group.wait()
    saveReport(reports)
    print("Todos os acessos concluídos.")
}

// Função para salvar o relatório final em JSON
func saveReport(_ reports: [URLReport]) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    if let jsonData = try? encoder.encode(reports), let jsonString = String(data: jsonData, encoding: .utf8) {
        let filePath = "../output/url_report.json"
        do {
            try jsonString.write(toFile: filePath, atomically: true, encoding: .utf8)
            print("Relatório salvo em \(filePath)")
        } catch {
            print("Erro ao salvar o relatório.")
        }
    }
}

// Caminho para o arquivo JSON de URLs
let jsonFilePath = "./urls.json"
processURLs(from: jsonFilePath)

