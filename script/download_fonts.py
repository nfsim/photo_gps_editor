import os
import urllib.request

# Google Fonts 실제 VariableFont_wght.ttf 경로로 수정
FONTS = [
    {
        "name": "NotoSansKR",
        "folder": "assets/fonts/NotoSansKR/",
        "files": [
            {
                "url": "https://github.com/google/fonts/raw/main/ofl/notosanskr/NotoSansKR-VariableFont_wght.ttf",
                "filename": "NotoSansKR-VariableFont_wght.ttf"
            },
            {
                "url": "https://github.com/google/fonts/raw/main/ofl/notosanskr/OFL.txt",
                "filename": "OFL.txt"
            }
        ]
    },
    {
        "name": "Roboto",
        "folder": "assets/fonts/Roboto/",
        "files": [
            {
                "url": "https://github.com/google/fonts/raw/main/apache/roboto/Roboto-VariableFont_wght.ttf",
                "filename": "Roboto-VariableFont_wght.ttf"
            },
            {
                "url": "https://github.com/google/fonts/raw/main/apache/roboto/OFL.txt",
                "filename": "OFL.txt"
            }
        ]
    }
]

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

for font in FONTS:
    folder_path = os.path.join(ROOT, font["folder"])
    os.makedirs(folder_path, exist_ok=True)
    for file in font["files"]:
        dest = os.path.join(folder_path, file["filename"])
        print(f"Downloading {file['url']} -> {dest}")
        try:
            urllib.request.urlretrieve(file["url"], dest)
        except Exception as e:
            print(f"Failed to download {file['url']}: {e}")
print("All fonts downloaded and placed in assets/fonts/")
