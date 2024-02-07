import PlaygroundSupport
import SwiftUI
import TabularData
import UniformTypeIdentifiers

struct MyCSVView: View {
    @State private var showFileImporter: Bool = false
    @State private var showFileExporter: Bool = false
    
    @State private var myData: DataFrame = DataFrame()
    @State private var myCSV: MyCSV = MyCSV()
    var body: some View{
        VStack{
            //Button for fileImporter
            Button(action:{
                showFileImporter.toggle()
            },label:{Text("Import CSV")})
            Button(action:{
                showFileExporter.toggle()
                myCSV = MyCSV(initialData: myData)
            },label:{Text("Export CSV")})
        }.padding()
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [UTType.commaSeparatedText], onCompletion: { result in
            switch result{
            case .success(let url):
                let options = CSVReadingOptions(hasHeaderRow: true, delimiter: ",") //getting file permission
                if url.startAccessingSecurityScopedResource(){
                    do{
                        myData = try DataFrame.init(contentsOfCSVFile: url, options:options)
                    } catch {
                        //print(error.localizedDescription)
                        print(error.localizedDescription)
                    }
                }
                url.stopAccessingSecurityScopedResource()
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
        .fileExporter(isPresented: $showFileExporter, document: myCSV, onCompletion: {result in
                    switch result {
                    case .success(let url):
                        print(url)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                })
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.setLiveView(MyCSVView())

//for fileExporter
struct MyCSV: FileDocument {
    // tell the system we support only csv files
    static var readableContentTypes = [UTType.commaSeparatedText]
    static var writableContentTypes = [UTType.commaSeparatedText]

    // by default our DataFrame is empty
    var dataframe: DataFrame = DataFrame()

    // a simple initializer that creates new, empty documents
    init(initialData: DataFrame = DataFrame()) {
        dataframe = initialData
    }

    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            dataframe = try! DataFrame(csvData: data)
        }
    }

    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try! dataframe.csvRepresentation()
        return FileWrapper(regularFileWithContents: data)
    }
}

