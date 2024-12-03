package com.kroon.pivotpro.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Controller
public class ExcelController {

    @Value("${file.upload-dir:C:/uploaded}")
    private String uploadDir;

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

            // 원본 파일명에서 확장자 추출
            String originalFilename = file.getOriginalFilename();
            String fileExtension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }

            // 고유한 파일명 생성
            String uniqueFilename = UUID.randomUUID().toString() + fileExtension;

            // 파일 저장 경로 설정
            Path filePath = uploadPath.resolve(uniqueFilename);
            file.transferTo(filePath.toFile());

            model.addAttribute("message", "파일이 성공적으로 업로드되었습니다.");
            return "upload.jsp";
        } catch (IOException e) {
            model.addAttribute("message", "파일 업로드 중 오류 발생: " + e.getMessage());
            return "upload.jsp";
        }
    }
}
