# =====================================================================
# fix-tombol-back.ps1
# Menyisipkan otomatis tombol "kembali ke beranda" di ambil-antrian.php
# dan CSS pendukungnya di assets/css/style.css
# Jalankan dari folder D:\ult-unima:
#   powershell -ExecutionPolicy Bypass -File .\fix-tombol-back.ps1
# =====================================================================

$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

$phpFile = ".\ambil-antrian.php"
$cssFile = ".\assets\css\style.css"

if (-not (Test-Path $phpFile)) { Write-Host "File $phpFile tidak ditemukan. Jalankan script ini dari folder D:\ult-unima." -ForegroundColor Red; exit 1 }
if (-not (Test-Path $cssFile)) { Write-Host "File $cssFile tidak ditemukan." -ForegroundColor Red; exit 1 }

# ---------------------------------------------------------------------
Write-Host "=== 1. Cek & sisipkan ke ambil-antrian.php ===" -ForegroundColor Cyan
$phpContent = Get-Content -Path $phpFile -Raw -Encoding UTF8

if ($phpContent -match "btn-back") {
    Write-Host "Sudah ada kode 'btn-back' di file ini, tidak perlu ditambah lagi." -ForegroundColor Yellow
} else {
    $target = '<h2>Ambil Nomor Antrian</h2>'
    if ($phpContent -notmatch [regex]::Escape($target)) {
        Write-Host "Baris '<h2>Ambil Nomor Antrian</h2>' tidak ditemukan. File mungkin sudah berubah strukturnya." -ForegroundColor Red
        Write-Host "Tidak ada yang diubah. Kirim isi file ini ke Claude untuk dicek." -ForegroundColor Red
    } else {
        $replacement = '<a href="index.php" class="btn-back" title="Kembali ke Beranda"><i class="bi bi-arrow-left"></i></a>' + "`r`n    " + $target
        $newContent = $phpContent.Replace($target, $replacement)
        Set-Content -Path $phpFile -Value $newContent -Encoding UTF8 -NoNewline
        Write-Host "Berhasil disisipkan ke ambil-antrian.php" -ForegroundColor Green
    }
}

# ---------------------------------------------------------------------
Write-Host ""
Write-Host "=== 2. Cek & sisipkan ke assets/css/style.css ===" -ForegroundColor Cyan
$cssContent = Get-Content -Path $cssFile -Raw -Encoding UTF8

if ($cssContent -match "\.btn-back") {
    Write-Host "Sudah ada aturan '.btn-back' di CSS ini, tidak perlu ditambah lagi." -ForegroundColor Yellow
} else {
    $cssAddition = @"


/* ---------- TOMBOL BACK (ditambahkan otomatis) ---------- */
.form-card { position: relative; }
.btn-back {
  position: absolute;
  top: 30px;
  left: 30px;
  width: 42px;
  height: 42px;
  border-radius: 50%;
  background: var(--blue-cyan);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  box-shadow: 0 4px 10px rgba(56,189,248,0.4);
  transition: transform .15s, background .2s;
}
.btn-back:hover { background: var(--navy-dark); transform: translateX(-3px); }
"@
    Add-Content -Path $cssFile -Value $cssAddition -Encoding UTF8
    Write-Host "Berhasil ditambahkan ke akhir style.css" -ForegroundColor Green
}

# ---------------------------------------------------------------------
Write-Host ""
Write-Host "=== 3. Verifikasi ===" -ForegroundColor Cyan
$phpCheck = Select-String -Path $phpFile -Pattern "btn-back"
$cssCheck = Select-String -Path $cssFile -Pattern "btn-back"

if ($phpCheck -and $cssCheck) {
    Write-Host "OK - kedua file sudah mengandung kode tombol back." -ForegroundColor Green
} else {
    Write-Host "GAGAL - salah satu file masih belum punya kode tombol back. Jangan lanjut push, laporkan ke Claude." -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------
Write-Host ""
Write-Host "=== 4. Git add, commit, push ===" -ForegroundColor Cyan
git add ambil-antrian.php assets/css/style.css
git commit -m "fix: tambah tombol kembali ke beranda (otomatis via script)"
git push

Write-Host ""
Write-Host "Selesai. Tunggu Railway redeploy (Deployments > Success), lalu hard refresh browser (Ctrl+Shift+R)." -ForegroundColor Green
