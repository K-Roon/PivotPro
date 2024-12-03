package com.kroon.pivotpro.controller;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.util.IOUtils;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.List;

@Controller
public class PivotTableController {

    @Autowired
    private ExcelController excelController;

    static {
        // 최대 크기 제한을 1GB로 설정
        IOUtils.setByteArrayMaxOverride(1024 * 1024 * 1024);
    }

    @GetMapping("/pivotTable")
    public String showPivotTable(Model model) {
        String filePath = excelController.getLastUploadedFilePath();
        if (filePath == null) {
            model.addAttribute("message", "업로드된 파일이 없습니다.");
            return "upload";
        }

        try (FileInputStream fis = new FileInputStream(filePath)) {
            Workbook workbook = filePath.endsWith(".xls") ? new HSSFWorkbook(fis) : new XSSFWorkbook(fis);
            Sheet sheet = workbook.getSheetAt(0);

            List<List<String>> excelData = new ArrayList<>();
            for (Row row : sheet) {
                List<String> rowData = new ArrayList<>();
                for (Cell cell : row) {
                    rowData.add(cellToString(cell));
                }
                excelData.add(rowData);
            }

            model.addAttribute("excelData", excelData);
            return "pivotTable";
        } catch (Exception e) {
            model.addAttribute("message", "파일 읽기 중 오류 발생: " + e.getMessage());

            //오류탐색 임시코드
            // TODO: 해당 코드는 임시코드이므로, 제거가 필요함.
            System.out.println(e.getMessage());
            return "upload";
        }
    }

    private String cellToString(Cell cell) {
        return switch (cell.getCellType()) {
            case STRING -> cell.getStringCellValue();
            case NUMERIC -> DateUtil.isCellDateFormatted(cell) ? cell.getDateCellValue().toString() :
                    String.valueOf(cell.getNumericCellValue());
            case BOOLEAN -> String.valueOf(cell.getBooleanCellValue());
            case FORMULA -> cell.getCellFormula();
            default -> "";
        };
    }
}
