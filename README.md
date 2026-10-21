# Catálogo de Automações

Aplicativo desktop para catalogar as automações da empresa: onde cada uma está na rede, o que faz, quais empresas usam e a documentação de cada uma. Funciona como o Explorer do Windows, com pastas por setor e "arquivos" que são fichas de automação.

É só para consulta e organização. O app não executa nem acessa as automações.

Feito em Python com PySide6 (Qt 6). A base é um arquivo JSON numa pasta de rede, compartilhada entre todos os usuários.

## Funcionalidades

**Pastas e automações**
- Pastas e subpastas para organizar por setor, com criar, renomear e excluir
- Cada automação tem nome, tipo, empresas, pasta, local e descrição
- Lista de tipos pronta (Python, Power Automate, Macro VBA, RPA, SQL, BAT/PowerShell, Power BI etc.), aceitando tipos novos
- Busca em tudo: nome, tipo, local, descrição, empresas, pasta e nome dos anexos
- Botão para copiar o local da automação

**Empresas**
- Cadastro com código de 4 dígitos e nome, exibidos juntos (`0001 ALVES & MELLO ASSESSORIA CONTABIL`). Códigos com menos dígitos são completados com zeros: 10 vira 0010
- O código é único e é ele que liga a empresa às automações, então trocar o nome ou o código atualiza tudo de uma vez
- Aba própria em que cada empresa funciona como uma pasta com as automações ligadas a ela
- "Atribuir empresas" numa automação: marca e desmarca empresas numa lista, ou cadastra uma nova digitando `código nome`
- Importação de planilha na mesma tela: escolha o arquivo (.xlsx, .xlsm ou .csv), a aba e a coluna dos códigos, e as empresas são marcadas automaticamente. Os códigos que não estão cadastrados aparecem numa lista ao final
- "Atribuir automações" numa empresa: marca e desmarca automações organizadas pelas pastas dos setores
- Pasta "Sem empresa" para achar automações que ainda não têm empresa vinculada

**Anexos**
- Anexar PDFs ou qualquer outro arquivo a uma automação, pelo botão ou arrastando do Windows
- Abrir, salvar cópia, mostrar na pasta e remover
- Arquivos removidos vão para uma subpasta `_excluidos` em vez de serem apagados

**Histórico**
- Registro de toda criação, edição, renomeação, exclusão, anexo e atribuição de empresa
- Guarda data, hora, usuário do Windows e o antes e depois de cada campo
- Consulta da base inteira ou de um item específico, com busca e filtro por tipo de ação

**Uso em equipe**
- Várias pessoas usando a mesma base ao mesmo tempo
- Alterações de outros usuários aparecem em até 2 segundos, sem recarregar
- Trava de gravação, releitura antes de salvar e gravação atômica, com cópia `.bak` da versão anterior

**Interface**
- Quatro temas: Claro, Escuro, Grafite e Verde
- Várias bases, com criação, abertura e lista de bases recentes pelo menu

## Requisitos

- Windows 10 ou 11, 64 bits
- Python 3.10 ou superior, 64 bits (só para rodar o código ou gerar o executável)
- Uma pasta de rede com permissão de leitura e escrita para todos os usuários

## Como rodar pelo código

```bash
pip install PySide6 openpyxl
python catalogo_automacoes.py
```

O `openpyxl` só é usado na importação de planilhas. Sem ele o app funciona normalmente e avisa quando alguém tentar importar.

Na primeira execução o app pergunta onde fica a base: abra uma existente ou crie uma nova na pasta de rede.

## Como gerar o executável

Coloque na mesma pasta:

```
catalogo_automacoes.py
gerar_exe.bat
icone.ico        (opcional, ícone do app)
config.json      (opcional, base padrão)
```

Execute o `gerar_exe.bat`. Ele cria um ambiente Python isolado, instala as dependências, gera o executável e abre a pasta `dist` com o `CatalogoAutomacoes.exe`.

O executável é um arquivo único e não precisa de Python nas outras máquinas. Copie o `.exe` (e o `config.json`) para cada computador em vez de abrir direto da rede, porque a abertura fica bem mais rápida.

Como o executável não tem assinatura digital, o Windows pode mostrar o aviso "O Windows protegeu o computador" na primeira vez. Clique em "Mais informações" e "Executar assim mesmo".

## Configuração

### Base padrão para todos os usuários

Crie um `config.json` ao lado do executável apontando para a base. Use o caminho UNC (`\\servidor\...`) em vez de letra de unidade mapeada, que pode mudar entre máquinas. No JSON, cada barra invertida é duplicada:

```json
{
  "db_path": "\\\\servidor\\automacoes\\automacoes.json"
}
```

### Preferências de cada usuário

Tema, última base aberta e bases recentes ficam em `%APPDATA%\CatalogoAutomacoes\prefs.json`, separados por usuário.

### Ícone

Coloque um `icone.ico` ao lado do `.py`. O `gerar_exe.bat` embute o ícone no executável e o app usa o mesmo ícone na janela e na barra de tarefas. O ideal é um `.ico` com os tamanhos 16, 32, 48 e 256 px.

## Estrutura na rede

O app cria tudo sozinho a partir da base. Não é preciso criar pastas à mão.

```
\\servidor\automacoes\
├── automacoes.json          base: pastas, automações, empresas e histórico
├── automacoes.json.bak      versão anterior, refeita a cada gravação
├── automacoes.json.lock     existe só por instantes, enquanto alguém grava
└── automacoes_anexos\
    ├── <id da automação>\   uma pasta por automação com anexos
    │   └── detalhamento.pdf
    └── _excluidos\          anexos removidos e de automações excluídas
```

Cada base tem sua pasta de anexos com o mesmo nome seguido de `_anexos`. Se mover ou renomear o `.json`, mova ou renomeie a pasta de anexos junto.

## Atalhos

| Atalho | Ação |
|---|---|
| Ctrl+N | Nova automação |
| Ctrl+Shift+N | Nova pasta |
| F2 | Editar ou renomear o item selecionado |
| Delete | Excluir o item selecionado |
| Ctrl+F | Buscar |
| Ctrl+E | Abrir a aba Empresas |
| Ctrl+H | Histórico completo da base |
| Ctrl+O | Abrir outra base |
| Backspace | Subir um nível |

## Formato da base

Arquivo JSON em UTF-8, legível e fácil de versionar ou auditar:

```json
{
  "folders":   [{ "id": "...", "name": "CONTABIL", "parent_id": null }],
  "items":     [{ "id": "...", "name": "CONCILIACAO 01", "type": "Python",
                  "companies": ["0001", "0010"],
                  "folder_id": "...", "location": "\\\\servidor\\codigos\\conciliacao.py",
                  "description": "...", "attachments": [] }],
  "companies": [{ "code": "0001", "name": "EMPRESA EXEMPLO LTDA" },
                { "code": "0010", "name": "OUTRA EMPRESA SA" }],
  "history":   [{ "at": "19/10/2026 15:23:10", "user": "usuario",
                  "action": "editou", "kind": "automação", "changes": [] }]
}
```

As automações guardam só os códigos das empresas; o nome vem do cadastro. O histórico guarda os 5.000 registros mais recentes.

Bases de versões anteriores, em que a empresa era um texto único como `0001 NOME`, são convertidas sozinhas na primeira abertura: o código é separado do nome, espaços repetidos são removidos e entradas com o mesmo código viram uma só. A conversão fica registrada no histórico.

## Limitações

- Se duas pessoas abrirem a tela de edição da mesma automação ao mesmo tempo e as duas salvarem, prevalece quem salvou por último. As duas edições ficam no histórico, então dá para conferir e corrigir.
- O modelo de arquivo JSON com trava atende bem dezenas de usuários e milhares de automações. Bem acima disso, o caminho seria migrar para um banco de dados como SQL Server ou PostgreSQL.
- Não roda em Windows 7 ou 8, nem em 32 bits, por exigência do Qt 6.

## Arquivos do projeto

| Arquivo | Descrição |
|---|---|
| `catalogo_automacoes.py` | Código completo do aplicativo |
| `gerar_exe.bat` | Gera o executável com PyInstaller |
| `icone.ico` | Ícone do app (opcional) |
| `config.json` | Caminho da base padrão (opcional, não versionar se tiver caminho interno) |
