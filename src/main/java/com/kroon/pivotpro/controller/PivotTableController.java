package com.kroon.pivotpro.controller;

import org.apache.poi.ss.usermodel.*;
import com.monitorjbl.xlsx.StreamingReader;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
public class PivotTableController {

    @Autowired
    private ExcelController excelController;

    // 업로드 페이지를 표시합니다.
    @GetMapping("/upload")
    public String showUploadPage() {
        return "upload";
    }

    // 파일을 업로드하고 저장합니다.
    @PostMapping("/upload")
    public String uploadFile(@RequestParam("file") MultipartFile file, Model model) {
        if (file.isEmpty()) {
            model.addAttribute("message", "업로드된 파일이 없습니다.");
            return "upload";
        }

        try {
            Path uploadPath = Paths.get("uploads/" + file.getOriginalFilename());
            Files.createDirectories(uploadPath.getParent());
            Files.write(uploadPath, file.getBytes());

            excelController.setLastUploadedFilePath(uploadPath.toString());
            model.addAttribute("message", "파일이 성공적으로 업로드되었습니다.");
            return "pivotTable";
        } catch (Exception e) {
            model.addAttribute("message", "파일 업로드 중 오류가 발생했습니다: " + e.getMessage());
            return "upload";
        }
    }

    // 피벗 테이블 리모컨 페이지를 표시합니다.
    @GetMapping("/pivotTable")
    public String showPivotTableControl(Model model) {
        return "pivotTable";
    }

    // 피벗 테이블을 생성하여 결과를 표시합니다.
    @PostMapping("/generateTable")
    public String generatePivotTable(@RequestParam("column") int columnIndex, Model model) {
        String filePath = excelController.getLastUploadedFilePath();
        if (filePath == null) {
            model.addAttribute("message", "업로드된 파일이 없습니다.");
            return "upload";
        }

        Path path = Paths.get(filePath);
        try (InputStream is = Files.newInputStream(path);
             Workbook workbook = StreamingReader.builder()
                     .rowCacheSize(1000) // 캐시 크기 증가
                     .bufferSize(8192) // 버퍼 크기 증가
                     .open(is)) {

            Sheet sheet = workbook.getSheetAt(0);
            List<List<String>> pivotData = new ArrayList<>();

            for (Row row : sheet) {
                List<String> rowData = new ArrayList<>();
                for (Cell cell : row) {
                    rowData.add(cell.toString());
                }
                pivotData.add(rowData);
            }

            Map<String, Long> pivotSummary = pivotData.stream()
                    .skip(1) // 헤더 행 제외
                    .collect(Collectors.groupingBy(
                            row -> row.get(columnIndex), // 선택된 열을 기준으로 그룹화
                            Collectors.counting() // 발생 횟수 계산
                    ));

            model.addAttribute("pivotSummary", pivotSummary);
            return "generatedTable";
        } catch (Exception e) {
            model.addAttribute("message", "파일 처리 중 오류가 발생했습니다: " + e.getMessage());
            return "upload";
        }
    }
}
