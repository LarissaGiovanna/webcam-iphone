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
3. Conecte seu pendrive no computador e inicie o Rufus
4. Em Dispositivo, selecione seu pendrive, escolha Seleção de Boot e faça o upload da iso do Linux:
![Rufus Selecionar](docs/rufus.png)
5. Aperte em Iniciar e siga as recomendações que o Rufus disser.
6. Após concluir essa etapa, conecte este pendrive em um computador com Windows e processador Intel (pode manter em seu computador se ele já atender esses requisitos).
7. Ligue (ou reinicie) o computador e entre na BIOS da sua placa mãe (Fique apertando Delete, F1 ou F2 até abrir uma tela com informações da sua placa mãe, parecida com essa:)
![bios](docs/bios.png)
8. Navegue até BIOS e procure por alguma opção relacionada a selecionar o dispositivo de boot (Select Boot Device)
9. Coloque seu pendrive no topo da lista (geralmente através das setas ou F5 e F6)
10. Vá até a seção de Exit e saia. Seu computador irá reiniciar.
11. Ao reiniciar, irá aparecer uma tela do Linux Mint (Se optou por instalar o Mint):
![Mint start menu](docs/mint_start.png)
12. Selecione Start Linux Mint e o sistema operacional irá iniciar.

#### No Linux
1. Abra o Terminal
2. Execute este comando para instalar o Palera1n:
```bash
sudo /bin/sh -c "$(curl -fsSL https://static.palera.in/scripts/install.sh)"
```
3. Após instalar, execute:
```bash
sudo palera1n -f
```
4. Conecte seu iPhone no computador e siga as instruções do palera1n para fazer o jailbreak no iPhone.
5. 