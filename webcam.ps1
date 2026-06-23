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
    # 1. Verifica Zoom
    $zoomAtivo = Get-Process "Zoom" -ErrorAction SilentlyContinue
    
    # 2. Verifica Brave (somente abas do Meet)
    $braveAtivo = Get-Process "brave" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -match "Meet" }
    
    # 3. Verifica OBS Studio (64 e 32 bits)
    $obsAtivo = Get-Process "obs64", "obs" -ErrorAction SilentlyContinue
    
    # 4. Verifica App de Câmera nativo do Windows
    $winCameraAtiva = Get-Process "WindowsCamera" -ErrorAction SilentlyContinue

    if ($zoomAtivo -or $braveAtivo -or $obsAtivo -or $winCameraAtiva) {
        return $true
    }
    
    return $false
}

# ==========================================
# LÓGICA PRINCIPAL (RODANDO NO FUNDO)
# ==========================================
$CameraAtiva = $false

while ($true) {
    $CameraSolicitada = Get-CameraRequest 

    if ($CameraSolicitada -and -not $CameraAtiva) {
        
        $estado = Get-LockState
        
        if ($estado -eq "1") {
            # Dispara a notificação do Windows e um aviso sonoro
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

    } elseif (-not $CameraSolicitada -and $CameraAtiva) {
        
        Show-Notification -Titulo "Camera Encerrada" -Mensagem "Desligando camera..." -Icone Info
        ssh -q -o ConnectTimeout=5 root@$iPhoneIP "killall webcam >/dev/null 2>&1"
        $CameraAtiva = $false
    }

    Start-Sleep -Seconds 3
}
