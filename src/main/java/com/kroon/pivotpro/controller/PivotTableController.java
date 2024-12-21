package com.kroon.pivotpro.controller;

import org.apache.poi.ss.usermodel.*;
import com.monitorjbl.xlsx.StreamingReader;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import java.util.stream.Collectors;

@RestController
public class PivotTableController {

    @Autowired
    private ExcelController excelController;

    /**
     * 업로드된 Excel 파일의 헤더(필드 목록) 반환
     */
    @GetMapping("/api/getFields")
    public ResponseEntity<?> getFields() {
        String filePath = excelController.getLastUploadedFilePath();
        if (filePath == null) {
            return ResponseEntity.badRequest().body("업로드된 파일이 없습니다.");
        }

        Path path = Paths.get(filePath);
        try (InputStream is = Files.newInputStream(path);
             Workbook workbook = StreamingReader.builder()
                     .rowCacheSize(1000)
                     .bufferSize(8192)
                     .open(is)) {

            Sheet sheet = workbook.getSheetAt(0);
            Iterator<Row> rowIterator = sheet.iterator();
            if (!rowIterator.hasNext()) {
                return ResponseEntity.badRequest().body("파일에 데이터가 없습니다.");
            }

            // 첫 번째 행(헤더)에서 필드 추출
            Row headerRow = rowIterator.next();
            List<String> fields = new ArrayList<>();
            for (Cell cell : headerRow) {
                fields.add(cell.toString());
            }

            return ResponseEntity.ok(fields);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("파일 처리 중 오류 발생: " + e.getMessage());
        }
    }

    /**
     * 피벗 테이블 데이터 생성 및 JSON 반환
     */
    @GetMapping("/api/getPivotData")
    public ResponseEntity<?> getPivotData() {
        String filePath = excelController.getLastUploadedFilePath();
        if (filePath == null) {
            return ResponseEntity.badRequest().body("업로드된 파일이 없습니다.");
        }

        Path path = Paths.get(filePath);
        try (InputStream is = Files.newInputStream(path);
             Workbook workbook = StreamingReader.builder()
                     .rowCacheSize(1000)
                     .bufferSize(8192)
                     .open(is)) {

            Sheet sheet = workbook.getSheetAt(0);
            List<Map<String, String>> data = new ArrayList<>();
            Iterator<Row> rowIterator = sheet.iterator();

            // 헤더 추출
            Row headerRow = rowIterator.next();
            List<String> headers = new ArrayList<>();
            for (Cell cell : headerRow) {
                headers.add(cell.toString());
            }

            // 데이터 추출
            while (rowIterator.hasNext()) {
                Row row = rowIterator.next();
                Map<String, String> rowData = new HashMap<>();
                for (int i = 0; i < headers.size(); i++) {
                    Cell cell = row.getCell(i, Row.MissingCellPolicy.CREATE_NULL_AS_BLANK);
                    rowData.put(headers.get(i), cell.toString());
                }
                data.add(rowData);
            }

            return ResponseEntity.ok(data);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("파일 처리 중 오류 발생: " + e.getMessage());
        }
    }
}

@Controller
class PivotTablePageController {

    @Autowired
    private ExcelController excelController;

    /**
     * 피벗 테이블 페이지 반환 (JSP 사용)
     */
    @GetMapping("/pivotTable")
    public String showPivotTableControl(Model model) {
        return "pivotTable"; // pivotTable.jsp 반환
    }

    /**
     * JSP를 사용한 피벗 테이블 생성 및 렌더링
     */
    @PostMapping("/generatedTable")
    public String generatePivotTable(
            @RequestParam("rowField") String rowField,
            @RequestParam("colField") String colField,
            @RequestParam("aggregator") String aggregator,
            Model model) {
        String filePath = excelController.getLastUploadedFilePath();
        if (filePath == null) {
            model.addAttribute("message", "업로드된 파일이 없습니다.");
            return "upload";
        }

        Path path = Paths.get(filePath);
        try (InputStream is = Files.newInputStream(path);
             Workbook workbook = StreamingReader.builder()
                     .rowCacheSize(1000)
                     .bufferSize(8192)
                     .open(is)) {

            Sheet sheet = workbook.getSheetAt(0);
            List<Map<String, String>> pivotData = new ArrayList<>();
            Iterator<Row> rowIterator = sheet.iterator();

            // 헤더 추출
            Row headerRow = rowIterator.next();
            List<String> headers = new ArrayList<>();
            for (Cell cell : headerRow) {
                headers.add(cell.toString());
            }

            // 데이터 추출
            while (rowIterator.hasNext()) {
                Row row = rowIterator.next();
                Map<String, String> rowData = new HashMap<>();
                for (int i = 0; i < headers.size(); i++) {
                    Cell cell = row.getCell(i, Row.MissingCellPolicy.CREATE_NULL_AS_BLANK);
                    rowData.put(headers.get(i), cell.toString());
                }
                pivotData.add(rowData);
            }

            // 피벗 테이블 데이터 요약 생성
            Map<String, Map<String, Double>> summary = new HashMap<>();
            for (Map<String, String> row : pivotData) {
                String rowKey = row.getOrDefault(rowField, "N/A");
                String colKey = row.getOrDefault(colField, "N/A");
                double value = Double.parseDouble(row.getOrDefault("Value", "0"));

                summary.computeIfAbsent(rowKey, k -> new HashMap<>())
                        .merge(colKey, value, Double::sum);
            }

            model.addAttribute("pivotSummary", summary);
            model.addAttribute("rowField", rowField);
            model.addAttribute("colField", colField);
            model.addAttribute("aggregator", aggregator);

            return "generatedTable"; // generatedTable.jsp 반환
        } catch (Exception e) {
            model.addAttribute("message", "파일 처리 중 오류 발생: " + e.getMessage());
            return "upload";
        }
    }
}
