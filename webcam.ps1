# Exibição de acentos no console do PowerShell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ==========================================
# CONFIGURAÇÕES
# ==========================================
$iPhoneIP = "192.168.1.XXX" # Substitua pelo IP real do seu iPhone
$DebugMode = $false         # Mudei para $false para deixar o terminal mais limpo no dia a dia

# ==========================================
# FUNÇÕES DE CONTROLE E LOG
# ==========================================
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "HH:mm:ss"
    
    if ($Level -eq "DEBUG" -and -not $DebugMode) { return }
    
    switch ($Level) {
        "INFO"    { Write-Host "[$Timestamp] [INFO] $Message" -ForegroundColor Cyan }
        "WARN"    { Write-Host "[$Timestamp] [WARN] $Message" -ForegroundColor Yellow }
        "ERROR"   { Write-Host "[$Timestamp] [ERROR] $Message" -ForegroundColor Red }
        "DEBUG"   { Write-Host "[$Timestamp] [DEBUG] $Message" -ForegroundColor DarkGray }
        "SUCCESS" { Write-Host "[$Timestamp] [OK] $Message" -ForegroundColor Green }
    }
}

function Get-LockState {
    if ($DebugMode) { Write-Log "Iniciando checagem de estado via SSH..." "DEBUG" }
    
    $sshCommand = "ssh -q -o ConnectTimeout=5 root@$iPhoneIP `"notifyutil -g com.apple.springboard.lockstate 2>/dev/null`""
    $rawOutput = Invoke-Expression $sshCommand | Out-String
    $cleanOutput = $rawOutput.Trim()
    
    if ($cleanOutput -match "lockstate\s+(\d)") {
        return $matches[1]
    }
    return "1" 
}

# NOVA FUNÇÃO: Verifica se o PC precisa da câmera
function Get-CameraRequest {
    # 1. Verifica se o processo do Zoom está rodando
    $zoomAtivo = Get-Process "Zoom" -ErrorAction SilentlyContinue
    
    # 2. Verifica se o Brave está rodando E se a janela principal contém "Meet"
    $braveAtivo = Get-Process "brave" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -match "Meet" }

    if ($zoomAtivo -or $braveAtivo) {
        return $true
    }
    
    return $false
}

# ==========================================
# LÓGICA PRINCIPAL
# ==========================================
Clear-Host
Write-Log "Monitor de Webcam Iniciado e operando em segundo plano..." "SUCCESS"

$CameraAtiva = $false

while ($true) {
    # Agora o gatilho é dinâmico e lê os programas abertos no Windows
    $CameraSolicitada = Get-CameraRequest 

    if ($CameraSolicitada -and -not $CameraAtiva) {
        
        $estado = Get-LockState
        
        if ($estado -eq "1") {
            Write-Log "ZOOM OU MEET DETECTADO! Celular bloqueado." "WARN"
            Write-Host ">>> Aperte o botão Início 2x no iPhone para liberar o Iriun <<<" -ForegroundColor Yellow
            
            # Toca um bipe no Windows para chamar sua atenção
            [Console]::Beep(800, 400)
            
            while ($estado -ne "0") {
                Start-Sleep -Seconds 1
                $estado = Get-LockState
            }
        }
        
        Write-Log "Acesso liberado! Ligando a webcam no iPhone..." "SUCCESS"
        ssh -q -o ConnectTimeout=5 root@$iPhoneIP "uiopen --bundleid iriun.usb.webcam >/dev/null 2>&1"
        $CameraAtiva = $true

    } elseif (-not $CameraSolicitada -and $CameraAtiva) {
        
        Write-Log "Reunião encerrada. Fechando Iriun e liberando o iPhone..." "INFO"
        ssh -q -o ConnectTimeout=5 root@$iPhoneIP "killall webcam >/dev/null 2>&1"
        $CameraAtiva = $false
        
    }

    # Verifica a cada 3 segundos (não consome recursos do PC)
    Start-Sleep -Seconds 3
}
