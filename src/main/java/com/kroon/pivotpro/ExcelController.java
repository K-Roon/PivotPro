package com.kroon.pivotpro;

import org.apache.commons.io.FilenameUtils;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Controller
public class ExcelController {

    @PostMapping("/uploadExcelFile")
    public String uploadFile(Model model, @RequestParam("file") MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            model.addAttribute("message", "업로드할 파일을 선택하세요.");
            return "upload.jsp"; // 파일 선택 창으로 다시 이동
        }

        try (InputStream in = file.getInputStream()) {
            Workbook workbook;
            if(Objects.equals(FilenameUtils.getExtension(file.getOriginalFilename()), "xls")) workbook = new HSSFWorkbook(in);
            else workbook = new XSSFWorkbook(in);

            Sheet sheet = workbook.getSheetAt(0); // 첫 번째 시트 읽기

            List<List<String>> excelData = new ArrayList<>(); // 엑셀의 모든 데이터를 저장할 리스트

            // 각 행과 각 셀의 값을 읽어옴
            for (Row row : sheet) {
                List<String> rowData = new ArrayList<>();
                for (Cell cell : row) {
                    switch (cell.getCellType()) {
                        case STRING:
                            rowData.add(cell.getStringCellValue());
                            break;
                        case NUMERIC:
                            if (DateUtil.isCellDateFormatted(cell)) {
                                rowData.add(cell.getDateCellValue().toString());
                            } else {
                                rowData.add(String.valueOf(cell.getNumericCellValue()));
                            }
                            break;
                        case BOOLEAN:
                            rowData.add(String.valueOf(cell.getBooleanCellValue()));
                            break;
                        case FORMULA:
                            rowData.add(cell.getCellFormula());
                            break;
                        case BLANK:
                            rowData.add(""); // 빈 셀 처리
                            break;
                        default:
                            rowData.add("");
                    }
                }
                excelData.add(rowData); // 각 행 데이터를 리스트에 추가
            }

            model.addAttribute("excelData", excelData); // JSP로 보낼 데이터
            return "pivotTable.jsp"; // 데이터를 넘기고 JSP로 이동
        } catch (Exception e) {
            model.addAttribute("message", "파일 처리 중 오류가 발생했습니다: " + e.getMessage());
            return "upload.jsp"; // 오류 발생 시 다시 업로드 페이지로
        }
    }

}
