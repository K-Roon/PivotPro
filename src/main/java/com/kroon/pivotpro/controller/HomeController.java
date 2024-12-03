package com.kroon.pivotpro.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class HomeController {

    @RequestMapping("/hello")
    public String home(){
        return "hello";
    }

    @GetMapping("/upload")
    public String uploadPage() {
        return "upload";
    }

//    @GetMapping({"/styles.css", "/style/styles.css"})
//    public String styles() {
//        return "style/styles.css";
//    }

}