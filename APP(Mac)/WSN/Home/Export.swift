//
//  Export.swift
//  WSN
//
//  Created by Azuby on 16/02/2023.
//

import UIKit
import xlsxwriter

class ExportXlsxService {
    let filename = "data.xlsx" // Tên file

    var workbook: UnsafeMutablePointer<lxw_workbook>? // file excel mới
    var worksheet: UnsafeMutablePointer<lxw_worksheet>? // sheet mới trong file excel
    var format_header: UnsafeMutablePointer<lxw_format>? // format cho header
    var format_1: UnsafeMutablePointer<lxw_format>? // format cho các dòng
    
    private var writingLine: UInt32 = 0
    private var needWriterPreparation = false // Biến kiểm tra đã viết excel xong chưa
    
    init() {
        prepareXlsWriter() // Khởi tạo excel
    }
    
    // Đường dẫn lưu tạm file
    func filePath() -> String {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("WSN")
        else { return "" }
        
        if !FileManager.default.fileExists(atPath: path.path) {
            try? FileManager.default.createDirectory(atPath: path.path, withIntermediateDirectories: true, attributes: nil)
        }

        return path.path
    }
    
    // Tạo excel mới
    private func prepareXlsWriter() {
        print("open \(filePath())")
        var destination_path = filePath()
        destination_path = destination_path + "/\(filename)"
        workbook = workbook_new(destination_path)
        // Add style
        format_header = workbook_add_format(workbook)
        format_set_bold(format_header)
        format_set_align(format_header, 2)
        
        format_1 = workbook_add_format(workbook)
        format_set_align(format_1, 2)
        
        needWriterPreparation = false
    }
    
    // Tạo header
    private func buildHeader(name: String) {
        worksheet = workbook_add_worksheet(workbook, name)

        writingLine = 0
        worksheet_write_string(worksheet, writingLine, 0, "Temperature", format_header)
        worksheet_write_string(worksheet, writingLine, 1, "Measure time", format_header)
    }
    
    // Xuất file excel
    func export() {
        if(needWriterPreparation == true){
            prepareXlsWriter()
        }
        
        ModelManager.shared.getStorage().getAllStorage().enumerated().forEach { col in
            if col.element.getAllValues().count < 1 {
                return
            }

            buildHeader(name: "ESP\(col.offset + 1)")
            for value in col.element.getAllValues() {
                buildNewLine(product: ESP(number: col.offset + 1, value: value.getValue(), date: value.getDate()))
            }
            writingLine = 0
        }
    
        // Đóng excel
        workbook_close(workbook)
        needWriterPreparation = true
        
        print(filePath())
    }
    
    // Tạo dòng mới
    private func buildNewLine(product: ESP) {
        writingLine += 1
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"

        worksheet_write_string(worksheet, writingLine, 0, "\(product.value)", format_1)
        worksheet_write_string(worksheet, writingLine, 1, dateFormatter.string(from: product.date), format_1)

        worksheet_set_column(worksheet, 0, 0, 11, format_1)
        worksheet_set_column(worksheet, 1, 1, 24, format_1)
    }
    
}

struct ESP {
    var number: Int
    var value: CGFloat
    var date: Date
}
