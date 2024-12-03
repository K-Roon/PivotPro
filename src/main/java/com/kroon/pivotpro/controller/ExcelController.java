package com.kroon.pivotpro.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Controller
public class ExcelController {

    @Value("C:/uploaded")
    private String uploadDir;

    private String lastUploadedFilePath;

    @PostMapping("/uploadExcelFile")
    public String uploadFile(Model model, @RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            model.addAttribute("message", "업로드할 파일을 선택하세요.");
            return "upload.jsp";
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
            file.transferTo(filePath.toFile());

            // 저장된 파일 경로 기록
            lastUploadedFilePath = filePath.toString();
            model.addAttribute("filePath", lastUploadedFilePath); // 경로를 모델에 추가
            return "redirect:/pivotTable";
        } catch (Exception e) {
            model.addAttribute("message", "파일 업로드 중 오류 발생: " + e.getMessage());
            return "upload";
        }
    }

    public String getLastUploadedFilePath() {
        return lastUploadedFilePath;
    }
}
