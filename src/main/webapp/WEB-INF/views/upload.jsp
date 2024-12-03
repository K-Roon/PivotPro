<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>파일 업로드</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        #loading {
            display: none;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 20px;
            color: #333;
        }
    </style>
</head>
<body>
<h1>파일 업로드</h1>
<form id="uploadForm" enctype="multipart/form-data">
    <input type="file" name="file" id="fileInput">
    <button type="button" onclick="uploadFile()">업로드</button>
</form>

<div id="loading">로드 중입니다...</div>

<script>
    function uploadFile() {
        const formData = new FormData(document.getElementById('uploadForm'));
        const xhr = new XMLHttpRequest();

        xhr.open("POST", "/uploadExcelFile", true);

        // 업로드 완료 시 처리
        xhr.onload = function () {
            if (xhr.status === 200) {
                document.getElementById("loading").style.display = "block"; // 로딩 메시지 표시
                setTimeout(() => {
                    window.location.href = "/pivotTable.jsp";
                }, 1000); // 로딩 시간 설정 (1초 후 페이지 이동)
            } else {
                alert("파일 업로드 중 오류가 발생했습니다.");
            }
        };

        // 업로드 시작
        xhr.upload.onprogress = function (event) {
            if (event.lengthComputable) {
                console.log(`Uploaded ${event.loaded} of ${event.total} bytes`);
            }
        };

        // 업로드 버튼 클릭 시 로딩 메시지 표시
        document.getElementById("loading").style.display = "block";

        xhr.send(formData);
    }
</script>
</body>
</html>
