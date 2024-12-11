package com.kroon.pivotpro.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    // 홈 페이지를 표시
    @GetMapping("/")
    public String showHomePage(Model model) {
        model.addAttribute("message", "환영합니다! 파일을 업로드하고 피벗 테이블을 생성하세요.");
        return "home"; // 홈 페이지 JSP로 이동
    }
}
