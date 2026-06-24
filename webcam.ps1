# ==========================================
# CONFIGURAÇÕES INICIAIS
# ==========================================
$iPhoneIP = "192.168.1.XXX" # Substitua pelo IP real

# Carrega as bibliotecas nativas de interface do Windows
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Cria o objeto de notificação do sistema
$global:balao = New-Object System.Windows.Forms.NotifyIcon
$global:balao.Icon = [System.Drawing.SystemIcons]::Information
$global:balao.Visible = $true

# ==========================================
# FUNÇÕES DE CONTROLE
# ==========================================
function Show-Notification {
    param([string]$Titulo, [string]$Mensagem, [System.Windows.Forms.ToolTipIcon]$Icone = [System.Windows.Forms.ToolTipIcon]::Info)
    $global:balao.BalloonTipTitle = $Titulo
    $global:balao.BalloonTipText = $Mensagem
    $global:balao.BalloonTipIcon = $Icone
    $global:balao.ShowBalloonTip(3000) # Fica na tela por 3 segundos
}

function Get-LockState {
    $sshCommand = "ssh -q -o ConnectTimeout=5 root@$iPhoneIP `"notifyutil -g com.apple.springboard.lockstate 2>/dev/null`""
    $rawOutput = Invoke-Expression $sshCommand | Out-String
    if ($rawOutput.Trim() -match "lockstate\s+(\d)") {
        return $matches[1]
    }
    return "1" 
}

function Get-CameraRequest {
    # Ele testa na ordem e retorna o primeiro que encontrar aberto
    
    if (Get-Process "Zoom" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle }) { return "Zoom" }
    
    if (Get-Process "brave" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -match "Meet" }) { return "Brave (Google Meet)" }
    
    if (Get-Process "obs64", "obs" -ErrorAction SilentlyContinue) { return "OBS Studio" }
    
    if (Get-Process "WindowsCamera" -ErrorAction SilentlyContinue) { return "Camera do Windows" }
    
    if (Get-Process "Discord" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle }) { return "Discord" }
    
    if (Get-Process "SoundRec", "VoiceRecorder" -ErrorAction SilentlyContinue) { return "Gravador de Voz" }

    return $null
}

# ==========================================
# LÓGICA PRINCIPAL (RODANDO NO FUNDO)
# ==========================================
$CameraAtiva = $false
$UltimoHeartbeat = Get-Date

while ($true) {
    $CameraSolicitada = Get-CameraRequest 

    # 1. PC pediu a câmera e ela está fechada
    if ($CameraSolicitada -and -not $CameraAtiva) {
        
        $estado = Get-LockState
        
        if ($estado -eq "1") {
            Show-Notification -Titulo "Camera Solicitada" -Mensagem "Aperte o botao Home 2x no iPhone para liberar o acesso." -Icone Warning
            [Console]::Beep(800, 400)
            
            while ($estado -ne "0") {
                Start-Sleep -Seconds 1
                $estado = Get-LockState
            }
        }
        
        Show-Notification -Titulo "Camera Liberada" -Mensagem "Ligando a camera no iPhone..." -Icone Info
        ssh -q -o ConnectTimeout=5 root@$iPhoneIP "uiopen --bundleid iriun.usb.webcam >/dev/null 2>&1"
        $CameraAtiva = $true
        $UltimoHeartbeat = Get-Date # Registra a hora que abrimos

    # 2. PC continua usando a câmera (O HEARTBEAT)
    } elseif ($CameraSolicitada -and $CameraAtiva) {
        
        $TempoDecorrido = (Get-Date) - $UltimoHeartbeat
        
        # A cada 20 segundos, manda um pulso para o iOS não dormir
        if ($TempoDecorrido.TotalSeconds -ge 20) {
            ssh -q -o ConnectTimeout=5 root@$iPhoneIP "uiopen --bundleid iriun.usb.webcam >/dev/null 2>&1"
            $UltimoHeartbeat = Get-Date
        }

    # 3. PC parou de usar a câmera
    } elseif (-not $CameraSolicitada -and $CameraAtiva) {
        
        Show-Notification -Titulo "Camera Desligada" -Mensagem "Desligando camera..." -Icone Info
        ssh -q -o ConnectTimeout=5 root@$iPhoneIP "killall webcam >/dev/null 2>&1"
        $CameraAtiva = $false
    }

    Start-Sleep -Seconds 3
}
