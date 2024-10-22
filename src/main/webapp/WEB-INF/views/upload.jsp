<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>엑셀 파일 업로드</title>
    <link rel="stylesheet" href="style/styles.css">
    <style>
        .container {
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
        }

        .drop-zone {
            max-width: 400px;
            height: 200px;
            padding: 50px 5px;
            border: 2px dashed #0071e3;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            color: #0071e3;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .drop-zone.dragover {
            background-color: #e0f7ff;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>엑셀 파일을 업로드하세요</h1>
    <form id="upload-form" method="post" enctype="multipart/form-data" action="uploadExcelFile">
        <div class="file-input">
            <input type="file" name="file" id="file" class="file" style="display: none;">
            <label for="file" class="drop-zone" id="drop-zone">여기에 파일을 끌어다 놓으세요.<br>(아니면 선택하기...)</label>
        </div>
        <button type="submit" class="btn" id="submitButton" style="display: none;">업로드</button>
    </form>
</div>

<script>
    const dropZone = document.getElementById('drop-zone');
    const fileInput = document.getElementById('file');
    const form = document.getElementById('upload-form');

    // 파일을 클릭해서 선택할 때
    dropZone.addEventListener('click', () => {
        fileInput.click();
    });

    // 파일이 선택되면 자동으로 폼을 제출
    fileInput.addEventListener('change', () => {
        if (fileInput.files.length) {
            form.submit(); // 파일 선택 후 바로 폼 제출
        }
    });

    // 드래그 앤 드롭 이벤트 처리
    dropZone.addEventListener('dragover', (e) => {
        e.preventDefault();
        dropZone.classList.add('dragover');
    });

    dropZone.addEventListener('dragleave', () => {
        dropZone.classList.remove('dragover');
    });

    dropZone.addEventListener('drop', (e) => {
        e.preventDefault();
        dropZone.classList.remove('dragover');

        const files = e.dataTransfer.files;
        if (files.length) {
            fileInput.files = files; // 파일 선택
            form.submit(); // 파일 드롭 후 바로 폼 제출
        }
    });
</script>
</body>
</html>
