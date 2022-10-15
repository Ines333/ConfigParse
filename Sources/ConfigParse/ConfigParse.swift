import SwiftIO
import MadBoard
import ExtrasJSON

@main
public struct ConfigParse {

    public static func main() {
        let globalConfigs = GlobalConfig()

//        writeConfig(config: globalConfigs, to: "/SD:/Config.json")
//        sleep(ms: 1000)
//
//        let textBytes = readRawBytes(from: "/SD:/Config.json")
//        print(String(decoding: textBytes, as: UTF8.self))
//        print(try! XJSONDecoder().decode(GlobalConfig.self, from: textBytes))



        let encode = try! XJSONEncoder().encode(globalConfigs)
        print(String(decoding: encode, as: UTF8.self))

        let decode = try! XJSONDecoder().decode(GlobalConfig.self, from: encode)
        print(decode)



//        sleep(ms: 2000)
//
//        var start = getClockCycle()
//
//        for _ in 0..<1000 {
//            let encode = try! XJSONEncoder().encode(globalConfigs)
//        }
//
//        var stop = getClockCycle()
//        print(cyclesToNanoseconds(start: start, stop: stop) / 1000_000)
//
//        sleep(ms: 2000)
//
//
//        let encode = try! XJSONEncoder().encode(globalConfigs)
//
//        start = getClockCycle()
//
//        for _ in 0..<1000 {
//           let decode = try! XJSONDecoder().decode(GlobalConfig.self, from: encode)
//        }
//
//        stop = getClockCycle()
//        print(cyclesToNanoseconds(start: start, stop: stop) / 1000_000)



        func writeConfig(config: GlobalConfig, to path: String) {
            let configBytes: [UInt8]

            do {
                configBytes = try XJSONEncoder().encode(config)
            } catch {
                fatalError("parse config failed")
            }

            let file = FileDescriptor.open(path, .writeOnly, options: .create)
            defer { file.close() }

            file.truncate(to: 0)
            file.write(configBytes)
        }

        func readRawBytes(from path: String) -> [UInt8] {
            let file = FileDescriptor.open(path)
            defer { file.close() }
            file.seek(offset: 0, from: FileDescriptor.SeekOrigin.end)
            let size = file.tell()

            print("file size = \(size)bytes")

            //size = 1030

            var buffer = [UInt8](repeating: 0, count: size)

            buffer.withUnsafeMutableBytes { rawPointer in
                _ = file.read(fromAbsoluteOffest: 0, into: rawPointer, count: size)
            }

            return buffer
        }
    }
}
