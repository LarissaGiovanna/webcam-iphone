# Exibição de acentos no console do PowerShell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ==========================================
# CONFIGURAÇÕES
# ==========================================
$iPhoneIP = "192.168.1.XXX" # Substitua pelo IP real do seu iPhone
$DebugMode = $true          # Mantenha $true para ver os logs

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
    Write-Log "Iniciando checagem de estado via SSH..." "DEBUG"
    
    $sshCommand = "ssh -q -o ConnectTimeout=5 root@$iPhoneIP `"notifyutil -g com.apple.springboard.lockstate 2>/dev/null`""
    $rawOutput = Invoke-Expression $sshCommand | Out-String
    $cleanOutput = $rawOutput.Trim()
    
    Write-Log "Saída bruta recebida do iPhone: '$cleanOutput'" "DEBUG"

    # Nova Regex: procura pela palavra lockstate, seguida de espaço e captura o número (0 ou 1)
    if ($cleanOutput -match "lockstate\s+(\d)") {
        $estado = $matches[1]
        Write-Log "Leitura bem-sucedida. Estado numérico: $estado" "DEBUG"
        return $estado
    }
    
    Write-Log "Falha na extração com Regex. Assumindo que está bloqueado (1)." "ERROR"
    return "1" 
}

# ==========================================
# LÓGICA PRINCIPAL
# ==========================================
Clear-Host
Write-Log "Monitor de Webcam Iniciado" "SUCCESS"
Write-Log "Modo de Depuração (DEBUG) Ativado" "WARN"

$CameraAtiva = $false

while ($true) {
    # Gatilho manual para teste
    $CameraSolicitada = $true 

    if ($CameraSolicitada -and -not $CameraAtiva) {
        
        $estado = Get-LockState
        
        if ($estado -eq "1") {
            Write-Log "CÂMERA SOLICITADA! Celular bloqueado." "WARN"
            Write-Host ">>> Aperte o botão Início 2x no iPhone para liberar o Iriun <<<" -ForegroundColor Yellow
            
            while ($estado -ne "0") {
                Start-Sleep -Seconds 1
                $estado = Get-LockState
            }
        }
        
        Write-Log "Acesso liberado! Enviando comando para abrir o Iriun..." "SUCCESS"
        ssh -q -o ConnectTimeout=5 root@$iPhoneIP "uiopen --bundleid iriun.usb.webcam >/dev/null 2>&1"
        $CameraAtiva = $true

    } elseif (-not $CameraSolicitada -and $CameraAtiva) {
        
        Write-Log "Câmera liberada pelo PC. Fechando aplicativo no iPhone..." "INFO"
        ssh -q -o ConnectTimeout=5 root@$iPhoneIP "killall webcam >/dev/null 2>&1"
        $CameraAtiva = $false
        
        Write-Log "Aguardando nova solicitação de câmera..." "INFO"
    }

    Start-Sleep -Seconds 2
}
