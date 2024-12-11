package com.kroon.pivotpro.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Controller
public class ExcelController {

    @Value("${file.upload.dir:C:/uploaded}")
    private String uploadDir;

    private String lastUploadedFilePath;

    // 업로드 페이지를 표시합니다.
    @GetMapping("/upload")
    public String showUploadPage() {
        return "upload";
    }

    // 파일을 업로드하고 저장합니다.
    @PostMapping("/uploadExcelFile")
    public String uploadFile(Model model, @RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            model.addAttribute("message", "업로드할 파일을 선택하세요.");
            return "upload";
        }

        try {
            // 업로드 디렉토리 생성
            Path uploadPath = Paths.get(uploadDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // 고유한 파일명 생성
            String fileExtension = "";
            String originalFilename = file.getOriginalFilename();
            if (originalFilename != null && originalFilename.contains(".")) {
                fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String uniqueFilename = UUID.randomUUID().toString() + fileExtension;
            Path filePath = uploadPath.resolve(uniqueFilename);

            // 파일 저장
            Files.write(filePath, file.getBytes());

            // 저장된 파일 경로 기록
            lastUploadedFilePath = filePath.toString();
            model.addAttribute("filePath", lastUploadedFilePath); // 경로를 모델에 추가
            return "redirect:/pivotTable";
        } catch (IOException e) {
            model.addAttribute("message", "파일 업로드 중 오류 발생: " + e.getMessage());
            return "upload";
        }
    }

    // 마지막으로 업로드된 파일의 경로를 반환합니다.
    public String getLastUploadedFilePath() {
        return lastUploadedFilePath;
    }

    // 업로드된 파일의 경로를 설정합니다.
    public void setLastUploadedFilePath(String filePath) {
        this.lastUploadedFilePath = filePath;
    }
}
