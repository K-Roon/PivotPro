package com.kroon.pivotpro.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/")
    public String showHomePage(Model model) {
        model.addAttribute("message", "환영합니다! 파일을 업로드하고 피벗 테이블을 생성하세요.");
        return "home";
    }
}
