<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <link rel="stylesheet" href="<c:url value='../../resources/css/styles.css' />">
    <title>파일 업로드</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        #progressBar {
            width: 100%;
            background-color: #f3f3f3;
            border: 1px solid #ddd;
            margin-top: 10px;
        }
        #progressBar div {
            height: 20px;
            width: 0;
            background-color: #4caf50;
            text-align: center;
            line-height: 20px;
            color: white;
        }
    </style>
</head>
<body>
<h1>파일 업로드</h1>
<form id="uploadForm" enctype="multipart/form-data">
    <input type="file" name="file" id="fileInput">
    <button type="button" onclick="uploadFile()">업로드</button>
</form>
<div id="progressBar"><div></div></div>
<div id="statusMessage"></div>

<script>
    function uploadFile() {
        const formData = new FormData(document.getElementById('uploadForm'));
        const xhr = new XMLHttpRequest();

        xhr.open("POST", "/uploadExcelFile", true);

        // 업로드 진행 상태 업데이트
        xhr.upload.onprogress = function(event) {
            if (event.lengthComputable) {
                const percentComplete = (event.loaded / event.total) * 100;
                document.querySelector("#progressBar div").style.width = percentComplete + "%";
                document.querySelector("#progressBar div").textContent = Math.round(percentComplete) + "%";
            }
        };

        // 업로드 완료 시 처리
        xhr.onload = function() {
            if (xhr.status === 200) {
                document.getElementById("statusMessage").textContent = "업로드 완료! 파일을 띄울 수 있도록 불러오고 있어요";
                // 페이지 이동
                setTimeout(() => {
                    window.location.href = "/pivotTable";
                }, 2000);
            } else {
                document.getElementById("statusMessage").textContent = "업로드 실패!";
            }
        };

        // 업로드 시작 표시
        document.getElementById("statusMessage").textContent = "올리고 있어요";

        xhr.send(formData);
    }
</script>
</body>
</html>
