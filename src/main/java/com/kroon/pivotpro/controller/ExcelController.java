package com.kroon.pivotpro.controller;

import com.kroon.pivotpro.model.ExcelData;
import org.apache.commons.io.FilenameUtils;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Controller
public class ExcelController {

    @Value("${file.upload-dir}")
    private String uploadDir;

    @PostMapping("/uploadExcelFile")
    public String uploadFile(Model model, @RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            model.addAttribute("message", "업로드할 파일을 선택하세요.");
            return "upload.jsp";
        }

        // 서버에 파일 저장
        String savedFilePath = saveFileToServer(file);
        if (savedFilePath == null) {
            model.addAttribute("message", "파일 저장 중 오류가 발생했습니다.");
            return "upload.jsp";
        }

        // 파일 처리
        try (InputStream in = new FileInputStream(savedFilePath)) {
            Workbook workbook = Objects.equals(FilenameUtils.getExtension(file.getOriginalFilename()), "xls") ?
                    new HSSFWorkbook(in) : new XSSFWorkbook(in);

            Sheet sheet = workbook.getSheetAt(0);
            List<List<String>> excelDataList = new ArrayList<>();

            for (Row row : sheet) {
                List<String> rowData = new ArrayList<>();
                for (Cell cell : row) {
                    rowData.add(cellToString(cell));
                }
                excelDataList.add(rowData);
            }

            ExcelData excelData = new ExcelData(excelDataList);
            model.addAttribute("excelData", excelData);
            return "pivotTable.jsp";
        } catch (Exception e) {
            model.addAttribute("message", "파일 처리 중 오류 발생: " + e.getMessage());
            return "upload.jsp";
        } finally {
            // 처리 완료 후 파일 삭제
            deleteFileFromServer(savedFilePath);
        }
    }

    private String saveFileToServer(MultipartFile file) {
        try {
            Path uploadPath = Paths.get(uploadDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            String filePath = uploadPath.resolve(Objects.requireNonNull(file.getOriginalFilename())).toString();
            file.transferTo(new File(filePath));
            return filePath;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private void deleteFileFromServer(String filePath) {
        try {
            Files.deleteIfExists(Paths.get(filePath));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String cellToString(Cell cell) {
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                return DateUtil.isCellDateFormatted(cell) ? cell.getDateCellValue().toString() :
                        String.valueOf(cell.getNumericCellValue());
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                return cell.getCellFormula();
            case BLANK:
            default:
                return "";
        }
    }
}
