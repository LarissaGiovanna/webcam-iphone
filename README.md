# Webcam iPhone para Windows (10/11)
Automação para transformar um iPhone antigo em uma webcam estática para Windows.

Este projeto utiliza um script em PowerShell no Windows para monitorar softwares de vídeo (Zoom, OBS, Meet, Discord) e enviar comandos via SSH para o iPhone. A tela do aparelho liga, desbloqueia e abre a câmera automaticamente apenas quando requisitado, desligando e economizando bateria logo em seguida.

## Aviso importante
Este projeto exige que o dispositivo iOS tenha Jailbreak. Prossiga por sua conta e risco. Como o aparelho será usado como uma webcam fixa e dedicada, não é recomendado realizar este procedimento no seu celular de uso pessoal e diário.

## Como funciona
1. Abra o seu aplicativo de preferência de vídeo
2. O script manda uma notificação pedindo que você aperte o botão Home do iPhone
3. Ao clicar, a câmera inicia automaticamente.
4. Ao fechar seu app de vídeo, a câmera fecha.

## Como executar
### Requisitos:
1. Um iPhone antigo ([Veja os dispositivos compatíveis](https://docs.website-msw.pages.dev/docs/reference/compatibility-chart/))
2. Cabo Lightning (de preferência Lightning para USB A)
3. Um computador com processador Intel
   
    3.1 Um pendrive com pelo menos 8GB, se tiver apenas um PC com Windows
   
### 1. Jailbreak
*Nota: O método pode variar dependendo da sua versão do iOS e modelo do aparelho. Este guia foca no método utilizado para o iOS 15 e em um iPhone SE (1ª Geração)*

- **Processador AMD:** É fortemente recomendado utilizar um computador com o processador Intel no processo de jailbreak, pois os processadores AMD dão muitos problemas na hora de executar o código para o iPhone. Nos meus testes, apenas funcionou quando utilizei um computador com Intel.

#### Se tiver apenas um PC com Windows:
1. Baixe a ferramenta [Rufus](https://rufus.ie/pt_BR/), para criar um pendrive bootável.
2. Baixe também uma distro Linux, de preferência, o [Mint](https://linuxmint.com/edition.php?id=326)
3. 
